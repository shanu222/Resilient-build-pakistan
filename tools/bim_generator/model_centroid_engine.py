"""Center structural meshes at origin; ground plane Y = 0."""

from __future__ import annotations

import numpy as np

from engine.professional_bim_engine import BimPart, center_meshes


class ModelCentroidEngine:
    @staticmethod
    def center_parts(parts: list[BimPart]) -> tuple[float, float, float]:
        center_meshes(parts)
        if not parts:
            return (0.0, 0.0, 0.0)
        structural = [p for p in parts if p.role not in ("terrain", "grid", "footprint")]
        verts = np.vstack([p.mesh.vertices for p in (structural or parts)])
        mins = verts.min(axis=0)
        maxs = verts.max(axis=0)
        cx = float((mins[0] + maxs[0]) / 2)
        cz = float((mins[2] + maxs[2]) / 2)
        return (cx, 0.0, cz)
