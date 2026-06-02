"""QC gate — export prohibited when validation fails (Phase 19)."""

from __future__ import annotations

import warnings

from engine.professional_bim_engine import BimPart, HouseDims, qc_validate
from engineering_rule_library import TOLERANCE_M


class EngineeringConstraintSolver:
    @staticmethod
    def validate(parts: list[BimPart], dims: HouseDims, levels: dict[str, float]) -> list[str]:
        issues: list[str] = []
        with warnings.catch_warnings(record=True) as caught:
            warnings.simplefilter("always")
            qc_validate(parts, dims, levels)
            for w in caught:
                issues.append(str(w.message))

        contact = levels.get("plinth_top", 0.0)
        cols = [p for p in parts if p.role == "column"]
        for p in cols:
            mn, mx = p.mesh.bounds
            if float(mn[1]) > contact + TOLERANCE_M:
                issues.append(f"Column float: {p.role}")
            if float(mx[1]) - float(mn[1]) < dims.h * 0.5:
                issues.append("Column too short for wall plate")

        walls = [p for p in parts if p.role == "wall"]
        if walls:
            lowest = min(float(p.mesh.bounds[0][1]) for p in walls)
            if lowest > contact + TOLERANCE_M * 3:
                issues.append("Wall not bearing on foundation")

        roofs = [p for p in parts if p.role == "roof"]
        if roofs and walls:
            roof_min = min(float(p.mesh.bounds[0][1]) for p in roofs)
            wall_top = max(float(p.mesh.bounds[1][1]) for p in walls)
            if roof_min < wall_top - TOLERANCE_M * 6:
                issues.append("Roof disconnected from walls")

        return issues

    @staticmethod
    def validate_or_raise(parts: list[BimPart], dims: HouseDims, levels: dict[str, float]) -> None:
        issues = EngineeringConstraintSolver.validate(parts, dims, levels)
        if issues:
            raise RuntimeError("Engineering QC failed: " + "; ".join(issues[:5]))
        for msg in issues:
            warnings.warn(msg, stacklevel=2)
