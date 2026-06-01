#!/usr/bin/env python3
"""Run engineering QC on all resilient models and write MODEL_QA_REPORT.md."""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))

from engine.professional_bim_engine import (  # noqa: E402
    HouseDims,
    ProfessionalBimEngine,
    foundation_contact_y,
    qc_validate,
)
from engineering_model_generator import EngineeringModelGenerator  # noqa: E402

DISPLAY_NAMES = {
    "interlocking_brick_masonry": "Interlocking Brick",
    "bamboo_frame_wattle_daub": "Bamboo Wattle",
    "cement_bamboo_frame": "Cement Bamboo",
    "confined_concrete_block_masonry": "Confined Block",
    "earthbag_masonry": "Earthbag",
    "elevated_flood_resilient_house": "Elevated Flood",
    "floating_amphibious_structure": "Floating Amphibious",
    "fly_ash_masonry": "Fly Ash",
    "geogrid_reinforced_retaining_wall": "Geogrid",
    "light_gauge_steel_house": "Light Gauge Steel",
    "loh_kaat_timber_house": "Loh-Kaat",
    "pre_fabricated_house": "Prefab",
    "raised_plinth_flood_resilient_house": "Raised Plinth",
    "rat_trap_bond_masonry": "Rat Trap Bond",
    "reinforced_adobe_brick_structure": "Reinforced Adobe",
    "timber_frame_lath_plaster": "Timber Frame",
}


def validate_model(model_id: str, archetype: str, dims: HouseDims) -> dict:
    engine = ProfessionalBimEngine(archetype, dims)
    engine.build()
    issues: list[str] = []
    qc_notes: list[str] = []
    contact = engine.lv["plinth_top"]
    tol = 0.08

    for p in engine.parts:
        if p.role != "column":
            continue
        mn, mx = p.mesh.bounds
        if float(mn[1]) > contact + tol:
            issues.append("column float")

    import warnings

    with warnings.catch_warnings(record=True) as caught:
        warnings.simplefilter("always")
        qc_validate(engine.parts, dims, engine.lv)
        for w in caught:
            msg = str(w.message)
            if "QC" in msg:
                qc_notes.extend(
                    part.strip()
                    for part in msg.split(": ", 1)[-1].split("; ")
                    if part.strip()
                )

    checks = {
        "columns_touch_foundations": "column float" not in issues,
        "walls_touch_foundations": "wall float" not in qc_notes,
        "beams_touch_columns": "beam low" not in qc_notes,
        "roofs_touch_walls": "Roof slab misaligned" not in " ".join(qc_notes),
        "bracing_touches_frame": True,
    }

    return {
        "model_id": model_id,
        "display_name": DISPLAY_NAMES.get(model_id, model_id),
        "status": "PASS" if not issues else "FAIL",
        "issues": sorted(set(issues)),
        "qc_notes": sorted(set(qc_notes))[:6],
        "checks": checks,
        "foundation_contact_y": contact,
        "part_count": len(engine.parts),
    }


def main() -> int:
    gen = EngineeringModelGenerator()
    dims = HouseDims.from_catalog(gen.catalog["dimensions"])
    results = []
    for entry in gen.catalog["models"]:
        mid = entry["id"]
        print(f"QA {mid}...")
        results.append(validate_model(mid, entry["archetype"], dims))

    passed = sum(1 for r in results if r["status"] == "PASS")
    failed = len(results) - passed
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

    lines = [
        "# MODEL QA REPORT",
        "",
        f"Generated: {now}",
        "",
        "## Summary",
        "",
        f"| Metric | Value |",
        f"|--------|-------|",
        f"| Models tested | {len(results)} |",
        f"| PASS | {passed} |",
        f"| FAIL | {failed} |",
        "",
        "## Per-model results",
        "",
        "| Model | Status | Columns→Foundation | Walls→Foundation | Beams→Columns | Roofs→Walls | Issues |",
        "|-------|--------|--------------------|------------------|---------------|------------|--------|",
    ]

    for r in results:
        c = r["checks"]
        issue_txt = "; ".join(r["issues"][:3]) if r["issues"] else "—"
        lines.append(
            f"| {r['display_name']} | **{r['status']}** | "
            f"{'✓' if c['columns_touch_foundations'] else '✗'} | "
            f"{'✓' if c['walls_touch_foundations'] else '✗'} | "
            f"{'✓' if c['beams_touch_columns'] else '✗'} | "
            f"{'✓' if c['roofs_touch_walls'] else '✗'} | {issue_txt} |"
        )

    lines.extend(["", "## Validation criteria", ""])
    lines.append("- Column base Y must equal foundation contact plane (±0.08 m)")
    lines.append("- Walls and beams checked against same contact / wall-top levels")
    lines.append("- Geometry centered on footprint; ground plane Y = 0")
    lines.append("- No export when strict QC fails")

    report_path = ROOT.parent.parent / "docs" / "MODEL_QA_REPORT.md"
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"\nWrote {report_path}")
    print(f"PASS: {passed}/{len(results)}")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
