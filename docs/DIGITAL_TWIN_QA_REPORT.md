# DIGITAL TWIN QA REPORT

Generated: 2026-06-01 (BIM Quality Stabilization Pass)

## Scope

Validation of procedural BIM (Digital Twin structural view) across all **16 resilient models** in `BimSceneRegistry`, plus regenerated GLB assets from `engineering_bim_generator.py`.

## Executive summary

| Check | Result |
|-------|--------|
| Dart `EngineeringConstraintEngine` — 16/16 models | **PASS** |
| Column float (strict export gate) — Python GLB pipeline | **PASS (16/16)** |
| Render blocked on constraint failure | **Enabled** |
| Viewport auto-fit (desktop / tablet / mobile) | **Tuned** |
| Assembly animation (travel → align → install → lock) | **Improved** |
| Load path + foundation reactions overlay | **Improved** |

## Procedural BIM validation (Flutter)

Automated test: `mobile/test/bim/engineering_constraint_test.dart`

All models validated with:

- Local foundation contact detection (post-centering geometry)
- Per-column bearing surface at pedestal / plinth / footing
- No false positives on stacked masonry blocks or wall panels
- Deck-mounted columns (amphibious) use platform deck top as bearing

| Model | Constraint QA |
|-------|----------------|
| Interlocking Brick | PASS |
| Earthbag | PASS |
| Cement Bamboo | PASS |
| Confined Block | PASS |
| Elevated Flood | PASS |
| Floating Amphibious | PASS |
| Fly Ash | PASS |
| Geogrid | PASS |
| Light Gauge Steel | PASS |
| Loh-Kaat | PASS |
| Prefab | PASS |
| Raised Plinth | PASS |
| Rat Trap Bond | PASS |
| Reinforced Adobe | PASS |
| Timber Frame | PASS |
| Advanced Interlocking | PASS |

## GLB pipeline validation (Python)

See [MODEL_QA_REPORT.md](MODEL_QA_REPORT.md) for per-model export QA.

Strict export gate: **column float** must be zero before deploy. Non-critical warnings (wall footprint, grid drift) are logged but do not block export.

## Digital Twin viewer behavior

### Validation gate

If `EngineeringConstraintEngine` reports errors, the viewport shows a red engineering panel and **does not render** structural geometry until resolved.

### Camera occupancy targets

| Viewport | Fill target |
|----------|-------------|
| Desktop (≥1024px) | ~85% |
| Tablet (600–1023px) | ~80% |
| Mobile (&lt;600px) | ~90% |

Structural bounds exclude terrain, excavation, and flood water for fit.

### Assembly animation

Phased motion per component:

1. Travel from staging yard  
2. Horizontal align above slot  
3. Vertical lower into place  
4. Snap / lock settle  

Includes eased rotation during align phase.

### Load transfer mode

- Model-specific load arrows (existing)  
- Green **foundation reaction** arrows at footing corners  
- Dynamic path from scene center

## Geometry fixes applied

- **Elevated flood / timber frame columns:** `BimMesh.box` `center.y` is the bottom face; column meshes corrected so bases sit on pedestals / plinth beams.
- **Python engine:** `center_meshes`, `snap_structural_to_foundation`, `compute_world_levels` — validation uses world-space levels after centering (fixes false column float on GLB export).

## Screenshots

Screenshots should be captured manually in the running app for stakeholder reports:

1. Open each model → Digital Twin → Structural view  
2. Load Transfer mode (load arrows + foundation reactions)  
3. Stage scrub mid-assembly (assembly motion visible)  
4. Desktop and mobile widths (camera fill)

> Automated screenshot capture was not run in this pass; validation results above are from unit tests and the Python QA script.

## Verification commands

```bash
cd mobile
flutter test test/bim/engineering_constraint_test.dart

cd tools/bim_generator
python engineering_bim_generator.py --deploy
python model_qa.py
```

## Sign-off

BIM quality stabilization pass complete: **zero column-float failures** on procedural scenes; GLB pipeline exports with strict column anchoring; viewer blocks invalid scenes.
