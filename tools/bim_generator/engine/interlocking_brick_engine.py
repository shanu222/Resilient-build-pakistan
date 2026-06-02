"""
Interlocking Brick Digital Twin — component-based GLB export.

Generates separate GLB files per structural assembly unit for realistic
playback assembly (instead of cumulative stage snapshots).

Components:
  foundation.glb, footing.glb, plinth_beam.glb, dpc.glb,
  wall_courses.glb, vertical_rebar.glb, lintel_band.glb,
  roof_band.glb, roof_truss.glb, roof_cover.glb
"""

from __future__ import annotations

import json
import math
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import numpy as np
import trimesh

# Engineering dimensions — 6×8 m interlocking brick house
W = 6.0
D = 8.0
WALL_H = 3.0
WALL_T = 0.23
PLINTH_H = 0.45
TRENCH = 1.0
PCC = 0.075
FOOT_D = 0.3
FOOT_W = 0.6
PLINTH_BEAM = 0.23
BAND = 0.15
BLOCK_L = 0.39
BLOCK_H = 0.19
BLOCK_W = 0.23
ROOF_SLOPE = math.radians(15)
DPC_T = 0.004
FOUND_COURSES = 2

WALL_BASE = PLINTH_H
WALL_TOP = WALL_BASE + WALL_H
LINTEL_Y = WALL_BASE + 2.1
ROOF_BAND_Y = WALL_TOP
EAVE_Y = ROOF_BAND_Y + BAND
RIDGE_Y = EAVE_Y + (D / 2) * math.tan(ROOF_SLOPE)


def _box(ext: tuple[float, float, float], center: tuple[float, float, float], color: list[int]) -> trimesh.Trimesh:
    m = trimesh.creation.box(extents=ext)
    m.apply_translation(center)
    m.visual.face_colors = [*color, 255]
    return m


def _cyl(r: float, h: float, center: tuple[float, float, float], color: list[int]) -> trimesh.Trimesh:
    m = trimesh.creation.cylinder(radius=r, height=h, sections=12)
    m.apply_translation(center)
    m.visual.face_colors = [*color, 255]
    return m


@dataclass
class ComponentPart:
    mesh: trimesh.Trimesh
    component: str
    stage: int
    name: str = ""


@dataclass
class InterlockingBrickEngine:
    parts: list[ComponentPart] = field(default_factory=list)

    def build(self) -> None:
        self.parts.clear()
        self._excavation_and_pcc()
        self._footings()
        self._foundation_wall()
        self._plinth_beam()
        self._dpc()
        self._vertical_rebar()
        self._wall_courses()
        self._lintel_band()
        self._roof_band()
        self._roof_truss()
        self._roof_cover()
        self._center_all()

    def _excavation_and_pcc(self) -> None:
        y = -TRENCH + TRENCH / 2
        tw = 0.65
        for z in (0, D):
            self.parts.append(ComponentPart(
                _box((W + tw * 2, TRENCH, tw), (W / 2, y, z), [161, 98, 7]),
                "foundation", 2, "trench"))
        for x in (0, W):
            self.parts.append(ComponentPart(
                _box((tw, TRENCH, D), (x, y, D / 2), [161, 98, 7]),
                "foundation", 2, "trench"))
        y_pcc = -TRENCH + PCC / 2
        self.parts.append(ComponentPart(
            _box((W + 0.4, PCC, D + 0.4), (W / 2, y_pcc, D / 2), [209, 213, 219]),
            "foundation", 3, "pcc"))

    def _footings(self) -> None:
        y = -TRENCH + PCC + FOOT_D / 2
        specs = [
            ((W + FOOT_W, FOOT_D, FOOT_W), (W / 2, y, 0)),
            ((W + FOOT_W, FOOT_D, FOOT_W), (W / 2, y, D)),
            ((FOOT_W, FOOT_D, D + FOOT_W * 0.5), (0, y, D / 2)),
            ((FOOT_W, FOOT_D, D + FOOT_W * 0.5), (W, y, D / 2)),
        ]
        for ext, c in specs:
            self.parts.append(ComponentPart(_box(ext, c, [156, 163, 175]), "footing", 4, "strip_footing"))

    def _foundation_wall(self) -> None:
        y0 = -TRENCH + PCC + FOOT_D
        for c in range(FOUND_COURSES):
            y = y0 + c * BLOCK_H + BLOCK_H / 2
            self.parts.append(ComponentPart(
                _box((W + WALL_T, BLOCK_H, D + WALL_T), (W / 2, y, D / 2), [180, 83, 9]),
                "foundation", 4, f"found_course_{c}"))

    def _plinth_beam(self) -> None:
        y0 = -TRENCH + PCC + FOOT_D + FOUND_COURSES * BLOCK_H
        self.parts.append(ComponentPart(
            _box((W + 0.4, PLINTH_BEAM + 0.06, D + 0.4), (W / 2, y0 + PLINTH_BEAM / 2, D / 2), [222, 184, 135]),
            "plinth_beam", 5, "formwork"))
        for i in range(8):
            t = i / 7
            self.parts.append(ComponentPart(
                _cyl(0.006, PLINTH_BEAM * 0.7, (0.2 + t * (W - 0.4), y0 + PLINTH_BEAM * 0.3, 0.15), [234, 88, 12]),
                "plinth_beam", 5, "rebar"))
        self.parts.append(ComponentPart(
            _box((W + WALL_T * 0.5, PLINTH_BEAM, D + WALL_T * 0.5), (W / 2, y0 + PLINTH_BEAM / 2, D / 2), [107, 114, 128]),
            "plinth_beam", 5, "concrete"))

    def _dpc(self) -> None:
        y = WALL_BASE - DPC_T / 2
        self.parts.append(ComponentPart(
            _box((W + WALL_T, DPC_T, D + WALL_T), (W / 2, y, D / 2), [30, 41, 59]),
            "dpc", 5, "dpc_layer"))

    def _vertical_rebar(self) -> None:
        bar_h = WALL_H + BAND * 2
        corners = [(0.12, 0.12), (W - 0.12, 0.12), (W - 0.12, D - 0.12), (0.12, D - 0.12)]
        for i, (x, z) in enumerate(corners):
            self.parts.append(ComponentPart(
                _cyl(0.006, bar_h, (x, WALL_BASE + bar_h / 2, z), [234, 88, 12]),
                "vertical_rebar", 6, f"corner_bar_{i}"))

    def _wall_courses(self) -> None:
        courses = int(WALL_H / BLOCK_H)
        for course in range(courses):
            y = WALL_BASE + course * BLOCK_H + BLOCK_H / 2
            stagger = (course % 2) * BLOCK_L / 2
            # Front & back
            for z in (0, D - BLOCK_W):
                x = WALL_T + stagger
                while x + BLOCK_L <= W - WALL_T:
                    self.parts.append(ComponentPart(
                        _box((BLOCK_L * 0.94, BLOCK_H, BLOCK_W * 0.94), (x + BLOCK_L / 2, y, z + BLOCK_W / 2), [217, 119, 6]),
                        "wall_courses", 7, f"blk_{course}"))
                    x += BLOCK_L
            # Sides
            for x in (0, W - BLOCK_W):
                z = WALL_T + stagger
                while z + BLOCK_L <= D - WALL_T:
                    self.parts.append(ComponentPart(
                        _box((BLOCK_W * 0.94, BLOCK_H, BLOCK_L * 0.94), (x + BLOCK_W / 2, y, z + BLOCK_L / 2), [180, 83, 9]),
                        "wall_courses", 7, f"blk_s_{course}"))
                    z += BLOCK_L

    def _lintel_band(self) -> None:
        y = LINTEL_Y + BAND / 2
        self.parts.append(ComponentPart(
            _box((W + 0.35, BAND + 0.05, D + 0.35), (W / 2, y, D / 2), [222, 184, 135]),
            "lintel_band", 8, "formwork"))
        for i in range(10):
            t = i / 9
            self.parts.append(ComponentPart(
                _cyl(0.006, BAND * 0.7, (0.2 + t * (W - 0.4), LINTEL_Y + BAND * 0.3, 0.15), [234, 88, 12]),
                "lintel_band", 8, "rebar"))
        self.parts.append(ComponentPart(
            _box((W + WALL_T, BAND, D + WALL_T), (W / 2, y, D / 2), [156, 163, 175]),
            "lintel_band", 8, "concrete"))

    def _roof_band(self) -> None:
        y = ROOF_BAND_Y + BAND / 2
        for i in range(10):
            t = i / 9
            self.parts.append(ComponentPart(
                _cyl(0.006, BAND * 0.75, (0.15 + t * (W - 0.3), ROOF_BAND_Y + BAND * 0.28, 0.12), [234, 88, 12]),
                "roof_band", 9, "rebar"))
        self.parts.append(ComponentPart(
            _box((W + WALL_T * 1.1, BAND, D + WALL_T * 1.1), (W / 2, y, D / 2), [107, 114, 128]),
            "roof_band", 9, "concrete"))

    def _roof_truss(self) -> None:
        spacing = 2.0
        t_count = int(W / spacing) + 1
        for t in range(t_count):
            x = t * spacing
            if x > W:
                break
            self.parts.append(ComponentPart(
                _box((0.08, 0.06, D + 0.2), (x, EAVE_Y + 0.08, D / 2), [146, 64, 14]),
                "roof_truss", 10, f"truss_bottom_{t}"))
            rafter_h = (D / 2) / math.cos(ROOF_SLOPE)
            self.parts.append(ComponentPart(
                _box((0.07, rafter_h, 0.07), (x, EAVE_Y + (RIDGE_Y - EAVE_Y) / 2, D / 4), [180, 83, 9]),
                "roof_truss", 10, f"rafter_l_{t}"))
            self.parts.append(ComponentPart(
                _box((0.07, rafter_h, 0.07), (x, EAVE_Y + (RIDGE_Y - EAVE_Y) / 2, D * 3 / 4), [180, 83, 9]),
                "roof_truss", 10, f"rafter_r_{t}"))
        self.parts.append(ComponentPart(
            _box((W + 0.15, 0.1, 0.1), (W / 2, RIDGE_Y, D / 2), [146, 64, 14]),
            "roof_truss", 10, "ridge_beam"))

    def _roof_cover(self) -> None:
        purlin_sp = 0.9
        rows = int(D / purlin_sp)
        for row in range(rows):
            for col in range(3):
                z = row * purlin_sp
                x = col * (W / 3)
                t = z / D
                sy = EAVE_Y + t * (RIDGE_Y - EAVE_Y) * min(t, 1 - t) * 4
                self.parts.append(ComponentPart(
                    _box((W / 3 + 0.05, 0.001, purlin_sp + 0.05), (x + W / 6, sy, z + purlin_sp / 2), [71, 85, 105]),
                    "roof_cover", 11, f"sheet_{row}_{col}"))

    def _center_all(self) -> None:
        if not self.parts:
            return
        all_m = trimesh.util.concatenate([p.mesh for p in self.parts])
        cx = (all_m.bounds[0] + all_m.bounds[1]) / 2
        cx[1] = 0  # keep ground at y=0
        for p in self.parts:
            p.mesh.apply_translation(-cx)

    def component_meshes(self, component: str) -> list[trimesh.Trimesh]:
        return [p.mesh for p in self.parts if p.component == component]

    def cumulative_meshes(self, max_stage: int) -> list[trimesh.Trimesh]:
        return [p.mesh for p in self.parts if p.stage <= max_stage]


COMPONENTS = [
    ("foundation", "foundation.glb", 2, "Excavation, trenches & PCC"),
    ("footing", "footing.glb", 4, "Strip footings"),
    ("plinth_beam", "plinth_beam.glb", 5, "Plinth beam formwork, rebar & concrete"),
    ("dpc", "dpc.glb", 5, "Damp proof course"),
    ("vertical_rebar", "vertical_rebar.glb", 6, "Vertical reinforcement"),
    ("wall_courses", "wall_courses.glb", 7, "Interlocking brick courses"),
    ("lintel_band", "lintel_band.glb", 8, "Lintel band"),
    ("roof_band", "roof_band.glb", 9, "Seismic roof band"),
    ("roof_truss", "roof_truss.glb", 10, "Trusses & ridge"),
    ("roof_cover", "roof_cover.glb", 11, "Roof sheets"),
]


def export_interlocking_brick(out_dir: Path) -> dict[str, Any]:
    """Export component GLBs and return digital twin assembly manifest."""
    engine = InterlockingBrickEngine()
    engine.build()
    out_dir.mkdir(parents=True, exist_ok=True)

    assembly_components = []
    for key, glb_name, stage, description in COMPONENTS:
        meshes = engine.component_meshes(key)
        if meshes:
            scene = trimesh.Scene(meshes)
            scene.export(str(out_dir / glb_name))
            print(f"  wrote {glb_name} ({len(meshes)} meshes)")
        assembly_components.append({
            "key": key,
            "glb": f"assets/models/interlocking_brick_masonry/{glb_name}",
            "stage": stage,
            "description": description,
            "meshCount": len(meshes),
        })

    # Master assembly
    all_m = engine.cumulative_meshes(11)
    trimesh.Scene(all_m).export(str(out_dir / "construction_master.glb"))

    return {
        "modelId": "interlocking_brick_masonry",
        "displayName": "Interlocking Brick Masonry",
        "archetype": "interlocking_brick_v2",
        "assemblyMode": "component",
        "masterGlb": "assets/models/interlocking_brick_masonry/construction_master.glb",
        "assemblyComponents": assembly_components,
        "dimensions": {
            "buildingWidth": W,
            "buildingDepth": D,
            "wallHeight": WALL_H,
            "wallThickness": WALL_T,
            "plinthHeight": PLINTH_H,
            "roofSlopeDegrees": 15,
        },
    }


if __name__ == "__main__":
    import argparse

    p = argparse.ArgumentParser()
    p.add_argument("--out", default=str(Path(__file__).resolve().parent.parent / "generated_models" / "interlocking_brick_masonry"))
    p.add_argument("--manifest", action="store_true")
    args = p.parse_args()
    out = Path(args.out)
    manifest = export_interlocking_brick(out)
    if args.manifest:
        manifest_path = Path(__file__).resolve().parent.parent / "construction_sequences" / "interlocking_brick_masonry.json"
        # Merge with existing stage narration from bim JSON
        manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
        print(f"  wrote manifest {manifest_path}")
