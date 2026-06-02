"""Global engineering rules for resilient housing BIM generation."""

from __future__ import annotations

GRID_MM = 100
GRID_M = GRID_MM / 1000.0
TOLERANCE_M = 0.08


def snap(value: float, grid: float = GRID_M) -> float:
    if grid <= 0:
        return value
    return round(value / grid) * grid


FOUNDATION_RULES = (
    "foundation.columns_bear",
    "foundation.no_float",
    "foundation.footing_centered",
    "foundation.width_exceeds_wall",
)

COLUMN_RULES = (
    "column.vertical",
    "column.align_footing",
    "column.no_overlap",
    "column.no_float",
)

WALL_RULES = (
    "wall.on_foundation",
    "wall.below_roof",
    "opening.grid_align",
    "wall.corner_connect",
)

BEAM_RULES = ("beam.connect_columns", "beam.level", "beam.on_support")

ROOF_RULES = ("roof.centered", "roof.projection", "roof.load_transfer")

CONNECTION_RULES = (
    "connection.support_path",
    "connection.continuous",
    "connection.no_isolate",
)

GRID_RULES = ("grid.snap", "grid.symmetry")

ALL_RULES = (
    FOUNDATION_RULES
    + COLUMN_RULES
    + WALL_RULES
    + BEAM_RULES
    + ROOF_RULES
    + CONNECTION_RULES
    + GRID_RULES
)
