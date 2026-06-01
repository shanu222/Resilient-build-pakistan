# MODEL QA REPORT

Generated: 2026-06-01 20:59 UTC

## Summary

| Metric | Value |
|--------|-------|
| Models tested | 16 |
| PASS | 16 |
| FAIL | 0 |

## Per-model results

| Model | Status | Columns→Foundation | Walls→Foundation | Beams→Columns | Roofs→Walls | Issues |
|-------|--------|--------------------|------------------|---------------|------------|--------|
| Interlocking Brick | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Bamboo Wattle | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Cement Bamboo | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Confined Block | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Earthbag | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Elevated Flood | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Floating Amphibious | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Fly Ash | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Geogrid | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Light Gauge Steel | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Loh-Kaat | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Prefab | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Raised Plinth | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Rat Trap Bond | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Reinforced Adobe | **PASS** | ✓ | ✓ | ✓ | ✓ | — |
| Timber Frame | **PASS** | ✓ | ✓ | ✓ | ✓ | — |

## Validation criteria

- Column base Y must equal foundation contact plane (±0.08 m)
- Walls and beams checked against same contact / wall-top levels
- Geometry centered on footprint; ground plane Y = 0
- No export when strict QC fails
