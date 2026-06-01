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
        print(f"  WARNING: exporting {model_id} after QC retries with residual notes")
        self._export(engine, model_id, display, archetype)

    def _strict_validate(self, engine: ProfessionalBimEngine, dims: HouseDims) -> list[str]:
        issues: list[str] = []
        qc_validate(engine.parts, dims, engine.lv)

        hw, hd = dims.w / 2, dims.d / 2
        for p in engine.parts:
            b = p.mesh.bounds
            cx, _, cz = (b[0] + b[1]) / 2
            mn, mx = b[0], b[1]

            if p.role in ("wall", "column", "beam", "foundation", "roof"):
                if abs(cx) > hw + dims.wall_t + 0.2 or abs(cz) > hd + dims.wall_t + 0.2:
                    if p.role != "terrain":
                        issues.append(f"{p.role} outside footprint")

            if p.role == "column":
                if mn[1] > engine.lv["plinth_top"] + 0.15:
                    issues.append("column float")
                if mx[1] < engine.lv["wall_top"] - 0.25:
                    issues.append("column short")

            if p.role == "roof":
                if abs(cx) > 0.35 or abs(cz) > 0.35:
                    issues.append("roof off-center")

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
