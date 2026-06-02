"""
EngineeringBimGenerator — constraint-validated BIM pipeline for all resilient models.

Pipeline: constraints → grid → foundation → frame → walls → roof → validate → export
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))

from engine.professional_bim_engine import (  # noqa: E402
    HouseDims,
    ProfessionalBimEngine,
    STAGES_13,
    qc_validate,
    sequence_payload_13,
)
from engineering_model_generator import EngineeringModelGenerator  # noqa: E402


class EngineeringBimGenerator(EngineeringModelGenerator):
    """Regenerates models only when engineering QC passes."""

    MAX_REGEN_ATTEMPTS = 3

    def generate_model(self, model_id: str) -> None:
        if model_id == "interlocking_brick_masonry":
            self._generate_interlocking_brick(model_id)
            return
        entry = next(m for m in self.catalog["models"] if m["id"] == model_id)
        archetype = entry["archetype"]
        display = entry["displayName"]
        dims = HouseDims.from_catalog(self.catalog["dimensions"])

        engine: ProfessionalBimEngine | None = None
        for attempt in range(1, self.MAX_REGEN_ATTEMPTS + 1):
            engine = ProfessionalBimEngine(archetype, dims)
            engine.build()
            issues = self._strict_validate(engine, dims)
            if not issues:
                self._export(engine, model_id, display, archetype)
                return
            print(f"  QC fail attempt {attempt} ({model_id}): {issues[0]}")

        assert engine is not None
        raise RuntimeError(
            f"QC failed for {model_id} after {self.MAX_REGEN_ATTEMPTS} attempts: {issues}"
        )

    def _strict_validate(self, engine: ProfessionalBimEngine, dims: HouseDims) -> list[str]:
        issues: list[str] = []
        contact = engine.lv["plinth_top"]
        tol = 0.08

        for p in engine.parts:
            if p.role != "column":
                continue
            mn, mx = p.mesh.bounds
            if float(mn[1]) > contact + tol:
                issues.append("column float")

        return issues

    def _export(self, engine: ProfessionalBimEngine, model_id: str, display: str, archetype: str) -> None:
        import trimesh

        out_dir = ROOT / "generated_models" / model_id
        out_dir.mkdir(parents=True, exist_ok=True)
        master_parts: list = []
        for idx, (code, key, _) in enumerate(STAGES_13):
            parts = engine.cumulative_meshes(idx)
            master_parts = parts
            scene = trimesh.Scene(parts)
            glb_path = out_dir / f"stage_{code}_{key}.glb"
            scene.export(str(glb_path))
        master = trimesh.Scene(master_parts)
        master.export(str(out_dir / "construction_master.glb"))

        seq = sequence_payload_13(model_id, display, archetype)
        seq_dir = ROOT / "construction_sequences"
        seq_dir.mkdir(parents=True, exist_ok=True)
        (seq_dir / f"{model_id}.json").write_text(json.dumps(seq, indent=2), encoding="utf-8")
        print(f"  exported {model_id} ({len(master_parts)} meshes final)")

    def _generate_interlocking_brick(self, model_id: str) -> None:
        from engine.interlocking_brick_engine import export_interlocking_brick, COMPONENTS

        out_dir = ROOT / "generated_models" / model_id
        base_manifest = export_interlocking_brick(out_dir)

        # Build stage timeline aligned with procedural BIM (12 stages)
        stages = self._interlocking_stages()
        manifest = {**base_manifest, "stageCount": len(stages), "stages": stages,
                    "hazardSimulations": {
                        "earthquake": {"title": "Earthquake", "explanation": "Bands and vertical bars activate ductile box action.", "animationKey": "earthquake"},
                        "wind": {"title": "Wind", "explanation": "Roof sheet fixings and truss bracing resist uplift.", "animationKey": "wind"},
                    },
                    "components": self._interlocking_components()}
        seq_dir = ROOT / "construction_sequences"
        seq_dir.mkdir(parents=True, exist_ok=True)
        (seq_dir / f"{model_id}.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
        print(f"  exported {model_id} component assembly ({len(COMPONENTS)} GLBs)")

    def _interlocking_stages(self) -> list[dict]:
        return [
            {"index": i, "key": k, "title": t, "timelineLabel": f"Stage {i + 1} of 12",
             "durationMs": d, "glb": f"assets/models/interlocking_brick_masonry/{g}",
             "narration": n, "explanation": n, "engineeringPrinciple": n,
             "constructionActivity": t, "inspectionChecklist": "Verify per engineering checklist.",
             "commonMistakes": ["Misaligned grid", "Skipped inspection"],
             "resilienceBenefits": ["Structural continuity", "Seismic box action"],
             "highlights": ["Component assembly", "Engineering sequence"]}
            for i, (k, t, g, d, n) in enumerate([
                ("site", "Site Layout", "foundation.glb", 5000, "Stage 1. Site layout on 6×8 m grid."),
                ("excavation", "Excavation", "foundation.glb", 6000, "Stage 2. Trenches to 1 m depth."),
                ("pcc", "PCC Blinding", "foundation.glb", 4000, "Stage 3. PCC blinding in trenches."),
                ("footings", "Strip Footings", "footing.glb", 7000, "Stage 4. Strip footings placed."),
                ("plinth_beam", "Plinth Beam & DPC", "plinth_beam.glb", 6500, "Stage 5. Plinth beam and DPC."),
                ("vertical_rebar", "Vertical Reinforcement", "vertical_rebar.glb", 5000, "Stage 6. Vertical bars anchored."),
                ("walls", "Interlocking Walls", "wall_courses.glb", 10000, "Stage 7. Course-by-course masonry."),
                ("lintel_band", "Lintel Band", "lintel_band.glb", 6000, "Stage 8. RC lintel band cast."),
                ("roof_band", "Roof Band", "roof_band.glb", 6000, "Stage 9. Seismic roof band."),
                ("roof_truss", "Roof Trusses", "roof_truss.glb", 8000, "Stage 10. Trusses assembled."),
                ("roof_cover", "Roof Sheets", "roof_cover.glb", 7000, "Stage 11. Roof sheets installed."),
                ("complete", "Completed Structure", "construction_master.glb", 6000, "Stage 12. Structure complete."),
            ])
        ]

    def _interlocking_components(self) -> dict:
        return {
            "foundation": {"title": "Foundation", "loadTransfer": "To bearing soil"},
            "footing": {"title": "Strip Footing", "loadTransfer": "Spreads wall load"},
            "plinth_beam": {"title": "Plinth Beam", "loadTransfer": "Ties foundation"},
            "dpc": {"title": "DPC", "loadTransfer": "Moisture barrier"},
            "wall": {"title": "Interlocking Wall", "loadTransfer": "Vertical load path"},
            "vertical_reinforcement": {"title": "Vertical Bars", "loadTransfer": "Seismic ductility"},
            "lintel_band": {"title": "Lintel Band", "loadTransfer": "Horizontal tie"},
            "roof_band": {"title": "Roof Band", "loadTransfer": "Box action"},
            "roof_truss": {"title": "Roof Truss", "loadTransfer": "Diaphragm frame"},
            "roof_cover": {"title": "Roof Cover", "loadTransfer": "Weather envelope"},
        }


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--model")
    p.add_argument("--deploy", action="store_true")
    args = p.parse_args()
    gen = EngineeringBimGenerator()
    if args.model:
        gen.generate_model(args.model)
    else:
        for m in gen.catalog["models"]:
            print(f"Generating {m['id']}...")
            gen.generate_model(m["id"])
    if args.deploy:
        gen.deploy_to_flutter_assets()
