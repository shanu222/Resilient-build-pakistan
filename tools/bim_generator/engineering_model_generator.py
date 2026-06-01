#!/usr/bin/env python3
"""
EngineeringModelGenerator — professional BIM meshes → GLB per cumulative construction stage.

Uses ProfessionalBimEngine (grid-aligned, centered, 13-stage cumulative sequencing).
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

import trimesh

try:
    import trimesh  # noqa: F811 — verify install
except ImportError as e:
    raise SystemExit("Install deps: pip install -r tools/bim_generator/requirements.txt") from e

from engine.professional_bim_engine import (
    HouseDims,
    ProfessionalBimEngine,
    STAGES_13,
    sequence_payload_13,
)

ROOT = Path(__file__).resolve().parent
SPECS = ROOT / "engineering_specs"
SEQUENCES_OUT = ROOT / "construction_sequences"
MODELS_OUT = ROOT / "generated_models"


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

        engine = ProfessionalBimEngine(archetype, self.dims)
        engine.build()

        master_parts: list[trimesh.Trimesh] = []
        for idx, (code, key, _) in enumerate(STAGES_13):
            parts = engine.cumulative_meshes(idx)
            master_parts = parts
            scene = trimesh.Scene(parts)
            glb_path = out_dir / f"stage_{code}_{key}.glb"
            scene.export(str(glb_path))
            print(f"  wrote {glb_path.relative_to(self.root)} ({len(parts)} meshes)")

        master = trimesh.Scene(master_parts)
        master.export(str(out_dir / "construction_master.glb"))

        seq = sequence_payload_13(model_id, display, archetype)
        SEQUENCES_OUT.mkdir(parents=True, exist_ok=True)
        seq_path = SEQUENCES_OUT / f"{model_id}.json"
        seq_path.write_text(json.dumps(seq, indent=2), encoding="utf-8")
        print(f"  wrote {seq_path.relative_to(self.root)}")

    def generate_all(self) -> None:
        for m in self.catalog["models"]:
            print(f"Generating {m['id']} ({m['archetype']})...")
            self.generate_model(m["id"])

    def deploy_to_flutter_assets(self) -> None:
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

    p = argparse.ArgumentParser(description="Professional engineering BIM GLB generator")
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
