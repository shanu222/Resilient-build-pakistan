"""
Professional BIM engine — grid-referenced, cumulative construction sequencing,
auto-centered geometry for all resilient housing archetypes.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Any

import numpy as np
import trimesh

# 13 engineering-accurate cumulative stages
STAGES_13 = [
    ("00", "site", "Site Layout"),
    ("01", "excavation", "Excavation"),
    ("02", "foundation", "Foundation"),
    ("03", "foundation_reinforcement", "Foundation Reinforcement"),
    ("04", "columns", "Columns / Structural Supports"),
    ("05", "beams", "Beams"),
    ("06", "walls", "Wall Construction"),
    ("07", "openings", "Openings"),
    ("08", "bands", "Bands / Bracing / Reinforcement"),
    ("09", "roof_structure", "Roof Structure"),
    ("10", "roof_covering", "Roof Covering"),
    ("11", "finishing", "Finishing"),
    ("12", "complete", "Completed Structure"),
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
    wall_t: float = 0.23
    col_size: float = 0.24

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
            wall_t=raw.get("wallThickness", 0.23),
            col_size=raw.get("columnSize", 0.24),
        )


@dataclass
class BimPart:
    mesh: trimesh.Trimesh
    stage_min: int
    role: str
    parent: str = "structure"


@dataclass
class StructuralGrid:
    """Column positions on building footprint (centered at origin)."""

    columns: list[tuple[float, float]]
    beam_lines_x: list[tuple[float, float, float]]  # z, x0, x1
    beam_lines_z: list[tuple[float, float, float]]  # x, z0, z1

    @staticmethod
    def from_footprint(w: float, d: float, inset: float = 0.18) -> StructuralGrid:
        hw, hd = w / 2, d / 2
        cols = [
            (-hw + inset, -hd + inset),
            (hw - inset, -hd + inset),
            (hw - inset, hd - inset),
            (-hw + inset, hd - inset),
        ]
        mid_x, mid_z = 0.0, 0.0
        cols.extend([(mid_x, -hd + inset), (mid_x, hd - inset), (-hw + inset, mid_z), (hw - inset, mid_z)])
        bx = [(-hw + inset, hw - inset), (mid_x, mid_x)]
        bz = [(-hd + inset, hd - inset), (mid_z, mid_z)]
        beam_lines_x = [(z, x0, x1) for z in bz for x0, x1 in bx]
        beam_lines_z = [(x, z0, z1) for x, _ in [(-hw + inset, 0), (hw - inset, 0), (mid_x, 0)] for z0, z1 in bz]
        return StructuralGrid(columns=cols, beam_lines_x=beam_lines_x, beam_lines_z=beam_lines_z)


def _box(ext: tuple[float, float, float], center: tuple[float, float, float], color: list[int]) -> trimesh.Trimesh:
    m = trimesh.creation.box(extents=ext)
    m.apply_translation(center)
    m.visual.face_colors = [*color, 255]
    return m


def _cyl(r: float, h: float, center: tuple[float, float, float], color: list[int], sections: int = 16) -> trimesh.Trimesh:
    m = trimesh.creation.cylinder(radius=r, height=h, sections=sections)
    m.apply_translation(center)
    m.visual.face_colors = [*color, 255]
    return m


def _levels(d: HouseDims) -> dict[str, float]:
    y_fb = -d.trench
    y_ft = y_fb + d.footing
    y_pt = y_ft + d.plinth
    y_wb = y_pt
    y_wt = y_wb + d.h
    y_band = y_wt
    y_roof = y_band + d.band
    y_top = y_roof + d.slab
    return {
        "footing_bottom": y_fb,
        "footing_top": y_ft,
        "plinth_top": y_pt,
        "wall_base": y_wb,
        "wall_top": y_wt,
        "lintel": y_band,
        "roof_beam": y_roof,
        "roof_top": y_top,
    }


class ProfessionalBimEngine:
    """Builds cumulative, grid-aligned BIM meshes for one archetype."""

    def __init__(self, archetype: str, dims: HouseDims):
        self.archetype = archetype
        self.d = dims
        self.grid = StructuralGrid.from_footprint(dims.w, dims.d)
        self.lv = _levels(dims)
        self.parts: list[BimPart] = []

    def build(self) -> None:
        self.parts.clear()
        builders = {
            "masonry_bands": self._build_masonry_house,
            "timber_wattle": self._build_wattle_house,
            "bamboo_frame": self._build_bamboo_frame_house,
            "earthbag": self._build_earthbag_house,
            "elevated_rc": self._build_elevated_house,
            "amphibious": self._build_amphibious_house,
            "steel_frame": self._build_steel_house,
            "geogrid": self._build_geogrid_wall,
            "prefab": self._build_prefab_house,
            "raised_plinth": self._build_raised_plinth_house,
            "timber_bands": self._build_timber_bands_house,
            "adobe_bands": self._build_adobe_house,
            "timber_frame": self._build_timber_frame_house,
        }
        fn = builders.get(self.archetype, self._build_masonry_house)
        fn()
        center_meshes(self.parts)
        qc_validate(self.parts, self.d, self.lv)

    def cumulative_meshes(self, stage_idx: int) -> list[trimesh.Trimesh]:
        return [p.mesh for p in self.parts if p.stage_min <= stage_idx]

  # --- Shared building blocks (all reference grid / levels) ---

    def _site(self) -> None:
        d = self.d
        hw, hd = d.w / 2, d.d / 2
        self.parts.append(BimPart(_box((d.w + 5, 0.1, d.d + 5), (0, -0.05, 0), [139, 115, 85]), 0, "terrain"))
        # Grid markers on ground
        for x, z in self.grid.columns[:4]:
            self.parts.append(
                BimPart(
                    _box((0.04, 0.02, 0.04), (x, 0.01, z), [148, 163, 184]),
                    0,
                    "grid",
                    "site",
                )
            )
        self.parts.append(
            BimPart(_box((d.w + 0.15, 0.03, d.d + 0.15), (0, 0.015, 0), [15, 23, 42]), 0, "footprint", "site")
        )

    def _excavation(self) -> None:
        d, lv = self.d, self.lv
        hw, hd = d.w / 2, d.d / 2
        tw = d.wall_t + 0.35
        y = lv["footing_bottom"] + d.trench / 2
        for z in (-hd + 0.2, hd - 0.2):
            self.parts.append(BimPart(_box((d.w + tw, d.trench, tw), (0, y, z), [161, 98, 7]), 1, "excavation"))
        for x in (-hw + 0.2, hw - 0.2):
            self.parts.append(BimPart(_box((tw, d.trench, d.d + tw), (x, y, 0), [161, 98, 7]), 1, "excavation"))

    def _foundation_strip(self) -> None:
        d, lv = self.d, self.lv
        y = lv["footing_bottom"] + d.footing / 2
        self.parts.append(
            BimPart(_box((d.w + 0.45, d.footing, d.d + 0.45), (0, y, 0), [156, 163, 175]), 2, "foundation")
        )
        yp = lv["footing_top"] + d.plinth / 2
        self.parts.append(
            BimPart(_box((d.w + 0.28, d.plinth, d.d + 0.28), (0, yp, 0), [107, 114, 128]), 2, "plinth", "foundation")
        )

    def _foundation_rebar(self) -> None:
        d, lv = self.d, self.lv
        y = lv["footing_bottom"] + d.footing * 0.35
        hw, hd = d.w / 2, d.d / 2
        for x, z in self.grid.columns[:4]:
            self.parts.append(
                BimPart(_box((0.08, 0.08, 0.08), (x, y, z), [234, 88, 12]), 3, "rebar", "foundation")
            )
        # Perimeter footing bars
        self.parts.append(BimPart(_box((d.w + 0.2, 0.05, 0.05), (0, y, -hd + 0.12), [234, 88, 12]), 3, "rebar"))
        self.parts.append(BimPart(_box((d.w + 0.2, 0.05, 0.05), (0, y, hd - 0.12), [234, 88, 12]), 3, "rebar"))

    def _columns_on_grid(self, stage: int, radius: float | None = None, color: list[int] | None = None) -> None:
        d, lv = self.d, self.lv
        r = radius or d.col_size / 2
        col = color or [107, 114, 128]
        y0, y1 = lv["plinth_top"], lv["wall_top"]
        h = y1 - y0
        cy = y0 + h / 2
        for x, z in self.grid.columns[:4]:
            # Snap to exact grid — no drift
            sx = round(x, 4)
            sz = round(z, 4)
            self.parts.append(BimPart(_cyl(r, h, (sx, cy, sz), col), stage, "column", "structure"))

    def _beams_on_grid(self, stage: int, depth: float = 0.14, color: list[int] | None = None) -> None:
        d, lv = self.d, self.lv
        col = color or [75, 85, 99]
        y = lv["wall_top"] + depth / 2
        hw = d.w / 2
        hd = d.d / 2
        # Perimeter beams
        self.parts.append(BimPart(_box((d.w + 0.1, depth, 0.12), (0, y, -hd + 0.06), col), stage, "beam"))
        self.parts.append(BimPart(_box((d.w + 0.1, depth, 0.12), (0, y, hd - 0.06), col), stage, "beam"))
        self.parts.append(BimPart(_box((0.12, depth, d.d + 0.1), (-hw + 0.06, y, 0), col), stage, "beam"))
        self.parts.append(BimPart(_box((0.12, depth, d.d + 0.1), (hw - 0.06, y, 0), col), stage, "beam"))

    def _perimeter_walls(self, stage: int, color: list[int], courses: int | None = None) -> None:
        d, lv = self.d, self.lv
        hw, hd = d.w / 2, d.d / 2
        wt = d.wall_t
        n = courses or max(8, int(d.h / 0.2))
        ch = d.h / n
        for c in range(n):
            y = lv["wall_base"] + c * ch + ch / 2
            # Front / back
            self.parts.append(BimPart(_box((d.w, ch - 0.008, wt), (0, y, -hd + wt / 2), color), stage, "wall"))
            self.parts.append(BimPart(_box((d.w, ch - 0.008, wt), (0, y, hd - wt / 2), color), stage, "wall"))
            # Sides
            self.parts.append(BimPart(_box((wt, ch - 0.008, d.d - wt), (-hw + wt / 2, y, 0), color), stage, "wall"))
            self.parts.append(BimPart(_box((wt, ch - 0.008, d.d - wt), (hw - wt / 2, y, 0), color), stage, "wall"))

    def _bands(self, stage: int) -> None:
        d, lv = self.d, self.lv
        y = lv["lintel"] + d.band / 2
        self.parts.append(BimPart(_box((d.w + 0.32, d.band, d.d + 0.32), (0, y, 0), [107, 114, 128]), stage, "band"))
        y2 = lv["roof_beam"] - d.band / 2
        self.parts.append(BimPart(_box((d.w + 0.35, d.band, d.d + 0.35), (0, y2, 0), [75, 85, 99]), stage, "band"))

    def _roof_structure(self, stage: int) -> None:
        d, lv = self.d, self.lv
        y = lv["roof_beam"]
        hw, hd = d.w / 2, d.d / 2
        # Ridge beam
        self.parts.append(
            BimPart(_box((d.w + 0.2, 0.1, 0.1), (0, y + 0.05, 0), [100, 116, 139]), stage, "ridge", "roof")
        )
        for x in (-hw * 0.5, 0, hw * 0.5):
            self.parts.append(
                BimPart(_box((0.08, 0.45, d.d + 0.15), (x, y + 0.22, 0), [146, 64, 14]), stage, "truss", "roof")
            )

    def _roof_cover(self, stage: int) -> None:
        d, lv = self.d, self.lv
        # Slab top flush with engineering roof_top level
        y = lv["roof_top"] - d.slab / 2
        overhang = 0.35
        self.parts.append(
            BimPart(
                _box((d.w + overhang, d.slab, d.d + overhang), (0, y, 0), [156, 163, 175]),
                stage,
                "roof",
            )
        )

    def _openings(self, stage: int) -> None:
        d, lv = self.d, self.lv
        y = lv["wall_base"] + d.h * 0.45
        hw, hd = d.w / 2, d.d / 2
        self.parts.append(BimPart(_box((1.0, 2.1, 0.06), (0, y, -hd + 0.03), [200, 220, 235]), stage, "opening"))
        self.parts.append(BimPart(_box((0.9, 1.2, 0.06), (hw - 0.03, y, 0), [200, 220, 235]), stage, "opening"))

    def _finishing(self, stage: int) -> None:
        d = self.d
        self.parts.append(BimPart(_box((d.w + 5, 0.06, 1.0), (0, 0.03, d.d / 2 + 2), [34, 197, 94]), stage, "landscape"))

    # --- Archetype assemblies ---

    def _build_masonry_house(self) -> None:
        self._site()
        self._excavation()
        self._foundation_strip()
        self._foundation_rebar()
        self._columns_on_grid(4, radius=0.11, color=[107, 114, 128])
        self._beams_on_grid(5)
        brick = [217, 119, 6]
        if self.archetype == "adobe_bands":
            brick = [180, 83, 9]
        self._perimeter_walls(6, brick)
        self._openings(7)
        self._bands(8)
        self._roof_structure(9)
        self._roof_cover(10)
        self._finishing(11)
        self.parts.append(BimPart(_box((0.2, 0.2, 0.2), (0, self.lv["roof_top"] + 0.1, 0), [34, 197, 94]), 12, "complete"))

    def _build_wattle_house(self) -> None:
        self._site()
        self._excavation()
        self._foundation_strip()
        self._foundation_rebar()
        d, lv = self.d, self.lv
        y0, y1 = lv["plinth_top"], lv["wall_top"]
        h = y1 - y0
        bamboo = [34, 139, 34]
        for x, z in self.grid.columns[:4]:
            self.parts.append(BimPart(_cyl(0.09, h, (x, y0 + h / 2, z), bamboo), 4, "column"))
        self._beams_on_grid(5, color=[146, 64, 14])
        # Wattle panels between posts
        hw, hd = d.w / 2, d.d / 2
        for i in range(6):
            y = y0 + i * (h / 6) + (h / 12)
            self.parts.append(BimPart(_box((d.w - 0.4, 0.03, 0.05), (0, y, -hd + 0.08), [160, 120, 80]), 6, "wattle"))
            self.parts.append(BimPart(_box((d.w - 0.4, h / 6 - 0.02, 0.025), (0, y, -hd + 0.12), [214, 180, 140]), 6, "daub"))
        self._openings(7)
        self._bands(8)
        self._roof_structure(9)
        self._roof_cover(10)
        self._finishing(11)
        self.parts.append(BimPart(_box((0.15, 0.15, 0.15), (0, self.lv["roof_top"] + 0.08, 0), [34, 197, 94]), 12, "complete"))

    def _build_bamboo_frame_house(self) -> None:
        self._build_wattle_house()
        # Bracing diagonals stage 8
        d, lv = self.d, self.lv
        y0, y1 = lv["plinth_top"], lv["wall_top"]
        hw, hd = d.w / 2, d.d / 2
        self.parts.append(BimPart(_box((0.06, 0.06, math.hypot(d.w, d.h)), (-hw + 0.2, y0 + d.h * 0.5, -hd + 0.2), [34, 139, 34]), 8, "brace"))

    def _build_earthbag_house(self) -> None:
        self._site()
        self._excavation()
        self._foundation_strip()
        self._foundation_rebar()
        d, lv = self.d, self.lv
        n = 12
        bag = [180, 140, 90]
        for i in range(n):
            t = i / max(n - 1, 1)
            y = lv["wall_base"] + t * d.h
            r = d.wall_t * 0.95
            hw, hd = d.w / 2, d.d / 2
            for z in (-hd + r, hd - r):
                for x in np.linspace(-hw + r, hw - r, 8):
                    self.parts.append(BimPart(_cyl(0.22, 0.28, (float(x), y, z), bag), 6 if i > 0 else 4, "earthbag"))
        self._bands(8)
        self._roof_structure(9)
        self._roof_cover(10)
        self._finishing(11)
        self.parts.append(BimPart(_box((0.2, 0.2, 0.2), (0, lv["roof_top"] + 0.1, 0), [34, 197, 94]), 12, "complete"))

    def _build_elevated_house(self) -> None:
        self._site()
        self._excavation()
        d, lv = self.d, self.lv
        # Pad footings
        for x, z in self.grid.columns[:4]:
            y = lv["footing_bottom"] + 0.25
            self.parts.append(BimPart(_box((0.55, 0.5, 0.55), (x, y, z), [156, 163, 175]), 2, "footing"))
        # Columns to platform
        plat_y = 1.35
        for x, z in self.grid.columns[:4]:
            self.parts.append(BimPart(_box((0.28, plat_y, 0.28), (x, plat_y / 2, z), [107, 114, 128]), 4, "column"))
        self.parts.append(BimPart(_box((d.w + 0.25, 0.14, d.d + 0.25), (0, plat_y, 0), [156, 163, 175]), 5, "beam"))
        self._perimeter_walls(6, [200, 210, 220], courses=10)
        self._openings(7)
        self._bands(8)
        self._roof_structure(9)
        self._roof_cover(10)
        self._finishing(11)
        self.parts.append(BimPart(_box((0.2, 0.2, 0.2), (0, lv["roof_top"] + 0.1, 0), [34, 197, 94]), 12, "complete"))

    def _build_amphibious_house(self) -> None:
        self._site()
        d, lv = self.d, self.lv
        hw, hd = d.w / 2, d.d / 2
        # Symmetrical buoyancy drums
        for ix, x in enumerate([-hw * 0.55, hw * 0.55]):
            for iz, z in enumerate([-hd * 0.55, hd * 0.55]):
                self.parts.append(BimPart(_cyl(0.32, 0.45, (x, 0.22, z), [14, 165, 233]), 2, "buoyancy"))
        self.parts.append(BimPart(_box((d.w + 0.2, 0.12, d.d + 0.2), (0, 0.55, 0), [146, 64, 14]), 3, "platform"))
        for x, z in self.grid.columns[:4]:
            self.parts.append(BimPart(_cyl(0.07, 1.6, (x, 0.55 + 0.8, z), [100, 116, 139]), 4, "guide_post"))
        self._columns_on_grid(5, radius=0.08, color=[146, 64, 14])
        self._beams_on_grid(6, color=[146, 64, 14])
        self._perimeter_walls(7, [200, 210, 220], courses=8)
        self._roof_structure(9)
        self._roof_cover(10)
        self._finishing(11)
        self.parts.append(BimPart(_box((0.2, 0.2, 0.2), (0, lv["roof_top"] + 0.1, 0), [34, 197, 94]), 12, "complete"))

    def _build_steel_house(self) -> None:
        self._site()
        self._excavation()
        self._foundation_strip()
        self._foundation_rebar()
        d, lv = self.d, self.lv
        y0, y1 = lv["plinth_top"], lv["wall_top"]
        steel = [96, 125, 139]
        hw, hd = d.w / 2, d.d / 2
        # Tracks
        self.parts.append(BimPart(_box((d.w, 0.05, 0.08), (0, y0, -hd + 0.04), steel), 4, "track"))
        self.parts.append(BimPart(_box((d.w, 0.05, 0.08), (0, y0, hd - 0.04), steel), 4, "track"))
        for x, z in self.grid.columns[:4]:
            self.parts.append(BimPart(_box((0.09, y1 - y0, 0.09), (x, y0 + (y1 - y0) / 2, z), steel), 4, "stud"))
        self._beams_on_grid(5, depth=0.1, color=steel)
        self.parts.append(BimPart(_box((0.05, 0.05, math.hypot(d.w, d.h) * 0.5), (-hw + 0.15, y0 + d.h * 0.4, -hd + 0.15), steel), 8, "brace"))
        self._perimeter_walls(6, [220, 225, 230], courses=6)
        self._openings(7)
        self._roof_structure(9)
        self._roof_cover(10)
        self._finishing(11)
        self.parts.append(BimPart(_box((0.15, 0.15, 0.15), (0, lv["roof_top"] + 0.08, 0), [34, 197, 94]), 12, "complete"))

    def _build_geogrid_wall(self) -> None:
        d = self.d
        self._site()
        self.parts.append(BimPart(_box((8, 2.8, 0.35), (0, 1.4, -2.5), [120, 113, 108]), 2, "facing"))
        for i in range(6):
            y = 0.35 + i * 0.42
            self.parts.append(BimPart(_box((7.5, 0.03, 4.5), (0, y, 0), [29, 78, 216]), 4 + (i // 2), "geogrid"))
        self.parts.append(BimPart(_box((0.12, 0.12, 5), (-3.8, 0.06, 0), [71, 85, 105]), 8, "drainage"))
        self.parts.append(BimPart(_box((8, 0.08, 1.2), (0, 0.04, 3.2), [34, 197, 94]), 11, "road"))
        self.parts.append(BimPart(_box((0.3, 0.3, 0.3), (0, 2.9, 0), [34, 197, 94]), 12, "complete"))

    def _build_prefab_house(self) -> None:
        self._site()
        self._excavation()
        self._foundation_strip()
        d, lv = self.d, self.lv
        y = lv["plinth_top"] + 0.08
        hw, hd = d.w / 2, d.d / 2
        self.parts.append(BimPart(_box((d.w, 0.12, d.d), (0, y, 0), [59, 130, 246]), 4, "floor"))
        # Modular wall panels on grid
        panel_t = 0.12
        self.parts.append(BimPart(_box((d.w, 2.6, panel_t), (0, y + 1.35, -hd + panel_t / 2), [147, 197, 253]), 6, "panel"))
        self.parts.append(BimPart(_box((d.w, 2.6, panel_t), (0, y + 1.35, hd - panel_t / 2), [147, 197, 253]), 6, "panel"))
        self.parts.append(BimPart(_box((panel_t, 2.6, d.d), (-hw + panel_t / 2, y + 1.35, 0), [147, 197, 253]), 6, "panel"))
        self.parts.append(BimPart(_box((panel_t, 2.6, d.d), (hw - panel_t / 2, y + 1.35, 0), [147, 197, 253]), 6, "panel"))
        self._openings(7)
        self._roof_cover(10)
        self._finishing(11)
        self.parts.append(BimPart(_box((0.15, 0.15, 0.15), (0, lv["roof_top"] + 0.08, 0), [34, 197, 94]), 12, "complete"))

    def _build_raised_plinth_house(self) -> None:
        self._site()
        self._excavation()
        d, lv = self.d, self.lv
        plinth_h = 0.85
        self.parts.append(BimPart(_box((d.w + 0.5, plinth_h, d.d + 0.5), (0, plinth_h / 2, 0), [161, 98, 7]), 2, "plinth"))
        self._foundation_rebar()
        self._columns_on_grid(4)
        self._beams_on_grid(5)
        self._perimeter_walls(6, [217, 119, 6])
        self._openings(7)
        self._bands(8)
        self._roof_structure(9)
        self._roof_cover(10)
        self.parts.append(BimPart(_box((0.08, 0.08, 2), (d.w / 2 + 0.5, 0.04, 0), [14, 165, 233]), 8, "drainage"))
        self._finishing(11)
        self.parts.append(BimPart(_box((0.2, 0.2, 0.2), (0, lv["roof_top"] + plinth_h * 0.1, 0), [34, 197, 94]), 12, "complete"))

    def _build_timber_bands_house(self) -> None:
        self._build_masonry_house()
        d, lv = self.d, self.lv
        y = lv["wall_base"] + d.h * 0.35
        hw = d.w / 2
        self.parts.append(BimPart(_box((d.w + 0.05, 0.08, 0.08), (0, y, 0), [146, 64, 14]), 8, "timber_band"))

    def _build_adobe_house(self) -> None:
        self._build_masonry_house()
        d, lv = self.d, self.lv
        y0 = lv["wall_base"]
        for i in range(4):
            y = y0 + i * (d.h / 5)
            self.parts.append(BimPart(_box((d.w, 0.02, d.d), (0, y, 0), [180, 83, 9]), 8, "mesh"))

    def _build_timber_frame_house(self) -> None:
        self._build_wattle_house()
        d, lv = self.d, self.lv
        y0, y1 = lv["plinth_top"], lv["wall_top"]
        hw, hd = d.w / 2, d.d / 2
        for i in range(10):
            y = y0 + i * (d.h / 10)
            self.parts.append(BimPart(_box((d.w - 0.3, 0.02, 0.04), (0, y, -hd + 0.06), [180, 160, 140]), 6, "lath"))


def center_meshes(parts: list[BimPart]) -> None:
    """Center footprint on origin; rest on ground plane (min Y = 0)."""
    if not parts:
        return
    all_verts = np.vstack([p.mesh.vertices for p in parts])
    mins = all_verts.min(axis=0)
    maxs = all_verts.max(axis=0)
    cx = (mins[0] + maxs[0]) / 2
    cz = (mins[2] + maxs[2]) / 2
    offset = np.array([-cx, -mins[1], -cz])
    for p in parts:
        p.mesh.apply_translation(offset)


def qc_validate(parts: list[BimPart], d: HouseDims, lv: dict[str, float]) -> None:
    """Validate alignment: foundations, columns, walls, roof continuity."""
    hw, hd = d.w / 2, d.d / 2
    issues: list[str] = []
    tol = 0.08
    grid_pts = set((round(x, 3), round(z, 3)) for x, z in StructuralGrid.from_footprint(d.w, d.d).columns[:4])

    for p in parts:
        b = p.mesh.bounds
        mn, mx = b[0], b[1]
        cx, cy, cz = (mn + mx) / 2
        ext = mx - mn

        if p.role == "column":
            base_y = mn[1]
            if base_y > lv["plinth_top"] + tol:
                issues.append("Column floating above plinth")
            top_y = mx[1]
            if top_y < lv["wall_top"] - tol:
                issues.append("Column too short for wall plate")

        if p.role == "wall":
            if abs(cx) > hw + d.wall_t + tol or abs(cz) > hd + d.wall_t + tol:
                issues.append("Wall outside footprint")

        if p.role == "roof":
            roof_bottom = mn[1]
            if abs(roof_bottom - (lv["roof_top"] - d.slab)) > tol * 2:
                issues.append("Roof slab misaligned with structure")

        if p.role == "foundation":
            if mn[1] < -tol:
                issues.append("Foundation below ground plane")

    # Overlap check (coarse): columns should sit on grid
    cols = [p for p in parts if p.role == "column"]
    for p in cols[:4]:
        b = p.mesh.bounds
        cx, _, cz = (b[0] + b[1]) / 2
        key = (round(cx, 3), round(cz, 3))
        if grid_pts and min(math.hypot(cx - gx, cz - gz) for gx, gz in grid_pts) > tol * 2:
            issues.append("Column off structural grid")

    if issues:
        import warnings

        warnings.warn(f"QC ({len(issues)}): " + "; ".join(dict.fromkeys(issues).keys()))


def sequence_payload_13(model_id: str, display: str, archetype: str) -> dict[str, Any]:
    templates = [
        ("Site layout establishes grid, drainage and structural reference before excavation.", "Verify setbacks and runoff."),
        ("Excavation to competent bearing; trenches align with foundation footprint.", "Check depth and soil class."),
        ("Foundation spreads loads through footings and plinth beam.", "Rebar cover and continuity."),
        ("Foundation reinforcement cages placed before concrete pour.", "Lap lengths and cover."),
        ("Columns erected on grid from plinth to beam level.", "Verticality and base plates."),
        ("Beams connect column heads; continuous ring at wall top.", "Level and anchorage."),
        ("Walls built on foundation perimeter between supports.", "Bond and verticality."),
        ("Door and window openings framed with lintels.", "Diagonal bracing at openings."),
        ("Seismic bands and bracing tie the box.", "Continuous pour at corners."),
        ("Roof trusses and rafters on wall plates.", "Connections and bracing."),
        ("Roof covering — slab or sheets — completes diaphragm.", "Anchors and waterproofing."),
        ("Plaster, drainage and landscape finishing.", "DPC and services."),
        ("Completed resilient structure ready for occupancy.", "Final inspection checklist."),
    ]
    stages = []
    for i, (code, key, title) in enumerate(STAGES_13):
        t = templates[i]
        stages.append({
            "index": i,
            "key": key,
            "title": title,
            "timelineLabel": f"Stage {i + 1} of 13",
            "durationMs": 5000 if i < 12 else 6000,
            "glb": f"assets/models/{model_id}/stage_{code}_{key}.glb",
            "narration": f"Stage {i + 1}. {title}. {t[0]}",
            "explanation": t[0],
            "engineeringPrinciple": t[0],
            "constructionActivity": title,
            "inspectionChecklist": t[1],
            "commonMistakes": ["Misaligned grid", "Skipped inspection"],
            "resilienceBenefits": ["Structural continuity", "Resilience compliance"],
            "highlights": ["Cumulative build", "Engineering sequence"],
        })
    return {
        "modelId": model_id,
        "displayName": display,
        "archetype": archetype,
        "masterGlb": f"assets/models/{model_id}/construction_master.glb",
        "stageCount": 13,
        "stages": stages,
        "hazardSimulations": _hazards(model_id, archetype),
        "components": _components(),
    }


def _hazards(model_id: str, archetype: str) -> dict[str, Any]:
    h: dict[str, Any] = {
        "earthquake": {"title": "Earthquake", "explanation": "Frame and bands activate ductile load paths.", "animationKey": "earthquake"},
        "wind": {"title": "Wind", "explanation": "Roof anchorage resists uplift.", "animationKey": "wind"},
    }
    if "flood" in model_id or archetype in ("elevated_rc", "raised_plinth", "amphibious"):
        h["flood"] = {"title": "Flood", "explanation": "Elevated/buoyant system keeps space dry.", "animationKey": "flood"}
    if archetype == "geogrid":
        h["landslide"] = {"title": "Landslide", "explanation": "Geogrid tension stabilizes slope.", "animationKey": "landslide"}
    return h


def _components() -> dict[str, Any]:
    return {
        "foundation": {"title": "Foundation", "loadTransfer": "To bearing soil"},
        "column": {"title": "Column", "loadTransfer": "Vertical load path"},
        "beam": {"title": "Beam", "loadTransfer": "Wall-to-wall tie"},
        "wall": {"title": "Wall", "loadTransfer": "Lateral resistance"},
        "roof": {"title": "Roof", "loadTransfer": "Diaphragm"},
    }
