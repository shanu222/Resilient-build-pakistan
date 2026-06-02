# BIM Capability Audit (Digital Twin)

This audit summarizes the current viewer capabilities and which models support **component-aware interaction** today, without changing assets.

## Viewer stack

### `DigitalTwinViewport` (GLB via `model_viewer_plus`)
- **Rendering**: WebComponent-based GLB viewer (model-viewer).
- **Component picking**: **Not supported** in current integration (no reliable hit-test/pick API exposed).
- **Best-effort component awareness**: driven by **metadata only** (`DigitalTwinManifest.components`) via component tree + inspector UI.
- **State preservation**: Flutter-side widget recreation is minimized; however changing `src` may still reload the web component’s scene.

### `BimViewport` (procedural BIM)
- **Rendering**: Custom `CustomPaint` pipeline.
- **Component picking**: **Supported** via `BimPicker.pickComponent(...)` and `BimSimulationController.selectedComponentId`.
- **Component highlighting**: **Supported** (selection stroke/tint applied in painter).

## Model support matrix (current repo)

### Dedicated Digital Twin manifests (`assets/data/digital_twin/*.json`)
These models have a dedicated manifest and may include a `components` map for metadata:

- `advanced_interlocking_brick_masonry`
- `bamboo_frame_wattle_daub` (**GLB-only**: not in procedural BIM registry)
- `cement_bamboo_frame`
- `confined_concrete_block_masonry`
- `earthbag_masonry`
- `elevated_flood_resilient_house`
- `floating_amphibious_structure`
- `fly_ash_masonry`
- `geogrid_reinforced_retaining_wall`
- `interlocking_brick_masonry`
- `light_gauge_steel_house`
- `loh_kaat_timber_house`
- `pre_fabricated_house`
- `raised_plinth_flood_resilient_house`
- `rat_trap_bond_masonry`
- `reinforced_adobe_brick_structure`
- `timber_frame_lath_plaster`

### Procedural BIM simulations (`BimSceneRegistry.bimModelIds`)
These models support component-level geometry + picking + highlighting via procedural BIM:

- `advanced_interlocking_brick_masonry`
- `cement_bamboo_frame`
- `confined_concrete_block_masonry`
- `earthbag_masonry`
- `elevated_flood_resilient_house`
- `floating_amphibious_structure`
- `fly_ash_masonry`
- `geogrid_reinforced_retaining_wall`
- `interlocking_brick_masonry`
- `light_gauge_steel_house`
- `loh_kaat_timber_house`
- `pre_fabricated_house`
- `raised_plinth_flood_resilient_house`
- `rat_trap_bond_masonry`
- `reinforced_adobe_brick_structure`
- `timber_frame_lath_plaster`

## Summary: models needing future upgrades for true GLB component picking
- **Any GLB-only models** (not in `BimSceneRegistry`) cannot support click-to-select without:
  - IFC/glTF metadata pipeline + runtime picking support, or
  - migration to the procedural BIM renderer, or
  - a custom GLB renderer with access to mesh/node IDs.
- Current known GLB-only model: `bamboo_frame_wattle_daub`.

