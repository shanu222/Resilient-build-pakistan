#!/usr/bin/env python3
"""
EngineeringModelGenerator — procedural BIM meshes → GLB/GLTF per construction stage.

Outputs:
  generated_models/<model_id>/stage_XX_<key>.glb
  generated_models/<model_id>/construction_master.glb
  construction_sequences/<model_id>.json
"""

from __future__ import annotations

import json
import math
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import numpy as np

try:
    import trimesh
except ImportError as e:
    raise SystemExit("Install deps: pip install -r tools/bim_generator/requirements.txt") from e

ROOT = Path(__file__).resolve().parent
SPECS = ROOT / "engineering_specs"
SEQUENCES_OUT = ROOT / "construction_sequences"
MODELS_OUT = ROOT / "generated_models"
ANIM_OUT = ROOT / "generated_animations"

STAGES = [
    ("00", "site", "Site Layout"),
    ("01", "excavation", "Excavation"),
    ("02", "foundation", "Foundation"),
    ("03", "structural_frame", "Structural Frame"),
    ("04", "walls", "Walls"),
    ("05", "bands", "Lintel & Roof Bands"),
    ("06", "roof", "Roof"),
    ("07", "complete", "Completed Structure"),
]


@dataclass
class HouseDims:
    w: float = 6.0
    d: float = 4.0
    h: float = 3.0
    trench: float = 0.8
    footing: float = 0.35
    plinth: float = 0.25
    band: float = 0.15
    slab: float = 0.12

    @staticmethod
    def from_catalog(raw: dict[str, float]) -> HouseDims:
        return HouseDims(
            w=raw.get("buildingWidth", 6.0),
            d=raw.get("buildingDepth", 4.0),
            h=raw.get("wallHeight", 3.0),
            trench=raw.get("trenchDepth", 0.8),
            footing=raw.get("footingDepth", 0.35),
            plinth=raw.get("plinthHeight", 0.25),
            band=raw.get("bandHeight", 0.15),
            slab=raw.get("slabThickness", 0.12),
        )


def _box(extents: tuple[float, float, float], center: tuple[float, float, float], color: list[int]) -> trimesh.Trimesh:
    m = trimesh.creation.box(extents=extents)
    m.apply_translation(center)
    m.visual.face_colors = [*color, 255]
    return m


def _cyl(r: float, height: float, center: tuple[float, float, float], color: list[int], sections: int = 12) -> trimesh.Trimesh:
    m = trimesh.creation.cylinder(radius=r, height=height, sections=sections)
    m.apply_translation(center)
    m.visual.face_colors = [*color, 255]
    return m


class MeshBuilder:
    """Archetype-specific cumulative stage meshes (meters)."""

    def __init__(self, archetype: str, dims: HouseDims):
        self.archetype = archetype
        self.d = dims
        self.cx, self.cz = dims.w / 2, dims.d / 2

    def cumulative_meshes(self, stage_idx: int) -> list[trimesh.Trimesh]:
        meshes: list[trimesh.Trimesh] = []
        d = self.d
        if stage_idx >= 0:
            meshes.append(_box((d.w + 4, 0.12, d.d + 4), (self.cx, -0.06, self.cz), [139, 115, 85]))
            meshes.append(_box((d.w + 0.2, 0.04, d.d + 0.2), (self.cx, 0.02, self.cz), [15, 23, 42]))
        if stage_idx >= 1:
            meshes.append(_box((d.w + 0.6, d.trench, 0.5), (self.cx, -d.trench / 2, 0.25), [161, 98, 7]))
            meshes.append(_box((d.w + 0.6, d.trench, 0.5), (self.cx, -d.trench / 2, d.d - 0.25), [161, 98, 7]))
        if stage_idx >= 2:
            y = -d.trench + d.footing / 2
            meshes.append(_box((d.w + 0.5, d.footing, d.d + 0.5), (self.cx, y, self.cz), [156, 163, 175]))
            meshes.append(_box((d.w + 0.3, d.plinth, d.d + 0.3), (self.cx, y + d.footing / 2 + d.plinth / 2, self.cz), [107, 114, 128]))
        if stage_idx >= 3:
            meshes.extend(self._frame_meshes())
        if stage_idx >= 4:
            meshes.extend(self._wall_meshes())
        if stage_idx >= 5:
            yb = self._wall_base_y()
            meshes.append(_box((d.w + 0.35, d.band, d.d + 0.35), (self.cx, yb + d.h - d.band / 2, self.cz), [107, 114, 128]))
            meshes.append(_box((d.w + 0.4, d.band, d.d + 0.4), (self.cx, yb + d.h + d.band * 0.6, self.cz), [75, 85, 99]))
        if stage_idx >= 6:
            yb = self._wall_base_y()
            meshes.append(_box((d.w + 0.35, d.slab, d.d + 0.35), (self.cx, yb + d.h + d.band * 1.2 + d.slab / 2, self.cz), [156, 163, 175]))
        if stage_idx >= 7:
            meshes.append(_box((d.w + 6, 0.08, 1.2), (self.cx, 0.04, d.d + 2), [34, 197, 94]))
        return meshes

    def _wall_base_y(self) -> float:
        return -self.d.trench + self.d.footing + self.d.plinth

    def _frame_meshes(self) -> list[trimesh.Trimesh]:
        d, meshes = self.d, []
        y0 = self._wall_base_y()
        if self.archetype in ("steel_frame", "bamboo_frame", "timber_frame", "timber_wattle"):
            col = [146, 64, 14] if "timber" in self.archetype or "wattle" in self.archetype else [96, 125, 139]
            r = 0.08 if self.archetype == "steel_frame" else 0.1
            for x, z in [(0.15, 0.15), (d.w - 0.15, 0.15), (d.w - 0.15, d.d - 0.15), (0.15, d.d - 0.15)]:
                meshes.append(_cyl(r, d.h, (x, y0 + d.h / 2, z), col))
            return meshes
        if self.archetype == "elevated_rc":
            for x, z in [(0.2, 0.2), (d.w - 0.2, 0.2), (d.w - 0.2, d.d - 0.2), (0.2, d.d - 0.2)]:
                meshes.append(_box((0.28, 2.2, 0.28), (x, 1.1, z), [107, 114, 128]))
            return meshes
        if self.archetype == "amphibious":
            for i in range(4):
                meshes.append(_cyl(0.35, 0.5, (1.2 + i * 1.2, 0.25, self.cz), [14, 165, 233]))
            meshes.append(_box((d.w, 0.12, d.d), (self.cx, 0.55, self.cz), [146, 64, 14]))
            return meshes
        if self.archetype == "geogrid":
            meshes.append(_box((8, 2.5, 6), (4, 1.2, 3), [120, 113, 108]))
            meshes.append(_box((0.05, 8, 5), (0, 2, 2.5), [29, 78, 216]))
            return meshes
        if self.archetype == "prefab":
            meshes.append(_box((d.w, 0.15, d.d), (self.cx, y0 + 0.08, self.cz), [59, 130, 246]))
            return meshes
        return []

    def _wall_meshes(self) -> list[trimesh.Trimesh]:
        d = self.d
        meshes: list[trimesh.Trimesh] = []
        y0 = self._wall_base_y()
        if self.archetype == "earthbag":
            n = 10
            for i in range(n):
                t = i / max(n - 1, 1)
                y = y0 + t * d.h
                r = 0.45 + 0.05 * math.sin(t * math.pi)
                meshes.append(_cyl(r, 0.35, (self.cx, y, 0.35), [180, 140, 90]))
                meshes.append(_cyl(r, 0.35, (self.cx, y, d.d - 0.35), [180, 140, 90]))
            return meshes
        if self.archetype in ("timber_wattle", "timber_frame"):
            for i in range(8):
                y = y0 + i * (d.h / 8)
                meshes.append(_box((d.w, 0.04, 0.06), (self.cx, y, 0.02), [146, 64, 14]))
                meshes.append(_box((d.w, d.h / 8 - 0.01, 0.04), (self.cx, y, 0.04), [214, 180, 140]))
            return meshes
        brick = [180, 83, 9] if self.archetype == "adobe_bands" else [217, 119, 6]
        courses = 14
        ch = d.h / courses
        for c in range(courses):
            y = y0 + c * ch + ch / 2
            meshes.append(_box((d.w, ch - 0.01, 0.22), (self.cx, y, 0.11), brick))
            meshes.append(_box((d.w, ch - 0.01, 0.22), (self.cx, y, d.d - 0.11), brick))
            meshes.append(_box((0.22, ch - 0.01, d.d), (0.11, y, self.cz), brick))
            meshes.append(_box((0.22, ch - 0.01, d.d), (d.w - 0.11, y, self.cz), brick))
        return meshes


def _sequence_payload(model_id: str, display: str, archetype: str) -> dict[str, Any]:
    stages = []
    templates = [
        ("Site layout establishes grid, drainage and load zones before excavation.",
         "Verify setbacks, north orientation and surface runoff paths.",
         ["Wrong setback", "Poor drainage slope"],
         ["Clear build zone", "Documented layout"]),
        ("Excavation reaches competent bearing stratum for safe load transfer.",
         "Check trench depth, soil class and dewatering if required.",
         ["Shallow trench", "Sloping sides unstable"],
         ["Bearing capacity", "Dry trench base"]),
        ("Foundation spreads loads to soil through footings and plinth continuity.",
         "Inspect rebar cover, concrete grade and plinth beam continuity.",
         ["Cold joints", "Insufficient cover"],
         ["Load dispersion", "Settlement control"]),
        ("Primary structural frame defines load paths for roof and walls.",
         "Confirm verticality, connections and temporary bracing.",
         ["Misaligned frame", "Missing ties"],
         ["Ductile frame", "Continuous load path"]),
        ("Wall systems enclose the structure and transfer lateral loads.",
         "Check interlocking, grout cells and vertical reinforcement.",
         ["Dry joints weak", "Missing grout"],
         ["Composite action", "Reduced mass"]),
        ("RC bands tie walls for seismic box action.",
         "Continuous pour; no gaps at corners.",
         ["Discontinuous band", "Poor anchorage"],
         ["Box action", "Force redistribution"]),
        ("Roof diaphragm distributes gravity and seismic loads to walls.",
         "Curing, formwork removal sequence, anchor bolts.",
         ["Inadequate curing", "Missing anchors"],
         ["Diaphragm action", "Uniform load transfer"]),
        ("Completed resilient house ready for services and occupancy.",
         "Final waterproofing, openings, and quality checklist.",
         ["Skipped DPC", "Unprotected openings"],
         ["Durability", "Occupancy readiness"]),
    ]
    for i, (code, key, title) in enumerate(STAGES):
        t = templates[i]
        stages.append({
            "index": i,
            "key": key,
            "title": title,
            "timelineLabel": f"Animation {i + 1} of 8",
            "durationMs": 5500 if i < 7 else 6500,
            "glb": f"assets/models/{model_id}/stage_{code}_{key}.glb",
            "narration": f"Stage {i + 1}. {title}. {t[0]}",
            "explanation": t[0],
            "engineeringPrinciple": t[0],
            "constructionActivity": title,
            "inspectionChecklist": t[1],
            "commonMistakes": t[2],
            "resilienceBenefits": t[3],
            "highlights": t[3],
        })
    hazards = _hazard_block(model_id, archetype)
    return {
        "modelId": model_id,
        "displayName": display,
        "archetype": archetype,
        "masterGlb": f"assets/models/{model_id}/construction_master.glb",
        "stageCount": len(stages),
        "stages": stages,
        "hazardSimulations": hazards,
        "components": _default_components(),
    }


def _hazard_block(model_id: str, archetype: str) -> dict[str, Any]:
    h: dict[str, Any] = {
        "earthquake": {
            "title": "Earthquake Simulation",
            "explanation": "Structural frame and bands redistribute inertia forces; flexible connections limit damage.",
            "animationKey": "earthquake",
        },
        "wind": {
            "title": "Wind Simulation",
            "explanation": "Roof anchorage and wall ties resist uplift and racking.",
            "animationKey": "wind",
        },
    }
    if "flood" in model_id or archetype in ("elevated_rc", "raised_plinth", "amphibious"):
        h["flood"] = {
            "title": "Flood Simulation",
            "explanation": "Elevated platform or buoyancy keeps living space above flood level.",
            "animationKey": "flood",
        }
    if archetype == "amphibious":
        h["flood"]["explanation"] = "Buoyant drums lift the platform as flood water rises."
    if archetype == "geogrid":
        h["landslide"] = {
            "title": "Landslide Simulation",
            "explanation": "Geogrid reinforces the soil mass and protects the roadway above.",
            "animationKey": "landslide",
        }
    if archetype == "earthbag":
        h["earthquake"]["explanation"] = "Flexible earthbag mass and wire keys dissipate seismic energy."
    return h


def _default_components() -> dict[str, Any]:
    return {
        "foundation": {"title": "Foundation", "loadTransfer": "Spreads loads to bearing soil"},
        "plinth_band": {"title": "Plinth Band", "continuity": "Ties wall bases"},
        "vertical_reinforcement": {"title": "Vertical Reinforcement", "seismicResistance": "Ductility and tie-down"},
        "lintel_band": {"title": "Lintel Band", "earthquakeResistance": "Prevents wall separation"},
        "roof_band": {"title": "Roof Band", "boxAction": "Ring beam box action"},
        "roof_slab": {"title": "Roof", "loadTransfer": "Diaphragm to walls"},
    }


class EngineeringModelGenerator:
    def __init__(self, root: Path | None = None):
        self.root = root or ROOT
        catalog = json.loads((SPECS / "_catalog.json").read_text(encoding="utf-8"))
        self.catalog = catalog
        self.dims = HouseDims.from_catalog(catalog["dimensions"])

    def generate_model(self, model_id: str) -> None:
        entry = next(m for m in self.catalog["models"] if m["id"] == model_id)
        archetype = entry["archetype"]
        display = entry["displayName"]
        out_dir = MODELS_OUT / model_id
        out_dir.mkdir(parents=True, exist_ok=True)

        builder = MeshBuilder(archetype, self.dims)
        master_parts: list[trimesh.Trimesh] = []

        for idx, (code, key, _) in enumerate(STAGES):
            parts = builder.cumulative_meshes(idx)
            master_parts = parts
            scene = trimesh.Scene(parts)
            glb_path = out_dir / f"stage_{code}_{key}.glb"
            scene.export(str(glb_path))
            print(f"  wrote {glb_path.relative_to(self.root)}")

        master = trimesh.Scene(master_parts)
        master_path = out_dir / "construction_master.glb"
        master.export(str(master_path))

        seq = _sequence_payload(model_id, display, archetype)
        SEQUENCES_OUT.mkdir(parents=True, exist_ok=True)
        seq_path = SEQUENCES_OUT / f"{model_id}.json"
        seq_path.write_text(json.dumps(seq, indent=2), encoding="utf-8")
        print(f"  wrote {seq_path.relative_to(self.root)}")

    def generate_all(self) -> None:
        for m in self.catalog["models"]:
            print(f"Generating {m['id']} ({m['archetype']})...")
            self.generate_model(m["id"])

    def deploy_to_flutter_assets(self) -> None:
        """Copy generated GLBs + sequences into mobile/assets."""
        repo = self.root.parent.parent
        mobile_models = repo / "mobile" / "assets" / "models"
        mobile_dt = repo / "mobile" / "assets" / "data" / "digital_twin"
        mobile_dt.mkdir(parents=True, exist_ok=True)

        import shutil

        for m in self.catalog["models"]:
            mid = m["id"]
            src = MODELS_OUT / mid
            dst = mobile_models / mid
            if src.exists():
                if dst.exists():
                    shutil.rmtree(dst)
                shutil.copytree(src, dst)
            seq_src = SEQUENCES_OUT / f"{mid}.json"
            if seq_src.exists():
                shutil.copy2(seq_src, mobile_dt / f"{mid}.json")
        print("Deployed to mobile/assets/models and mobile/assets/data/digital_twin")


if __name__ == "__main__":
    import argparse

    p = argparse.ArgumentParser(description="Engineering BIM GLB generator")
    p.add_argument("--model", help="Single model id")
    p.add_argument("--deploy", action="store_true", help="Copy to Flutter assets")
    args = p.parse_args()
    gen = EngineeringModelGenerator()
    if args.model:
        gen.generate_model(args.model)
    else:
        gen.generate_all()
    if args.deploy:
        gen.deploy_to_flutter_assets()
