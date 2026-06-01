# BIM Generator — Engineering GLB Pipeline

Produces **construction-stage GLB** assets and synchronized narration JSON for the Flutter Digital Twin engine.

## Setup

```powershell
powershell -ExecutionPolicy Bypass -File tools/bim_generator/setup.ps1
```

Installs: Python (`trimesh`, `pygltflib`, `numpy`), optional Blender/FFmpeg via Chocolatey, Node preview deps.

## Generate all 16 models

```bash
python tools/bim_generator/generate_all.py
```

Outputs:

| Folder | Content |
|--------|---------|
| `generated_models/<id>/` | `stage_00_site.glb` … `stage_07_complete.glb`, `construction_master.glb` |
| `construction_sequences/<id>.json` | Narration, inspection, hazards |
| `mobile/assets/models/` | Deployed GLBs (after `--deploy`) |
| `mobile/assets/data/digital_twin/` | Manifest JSON per model |

## Single model

```bash
python tools/bim_generator/engineering_model_generator.py --model earthbag_masonry --deploy
```

## Blender (higher fidelity)

```bash
blender --background --python tools/bim_generator/blender/generate_construction.py -- interlocking_brick_masonry
```

## Three.js preview

```bash
cd tools/bim_generator/preview && npm install && npm run preview
# http://localhost:4177/?model=earthbag_masonry&stage=stage_07_complete
```

## Archetypes

| Archetype | Models |
|-----------|--------|
| `masonry_bands` | Interlocking, confined block, fly ash, rat trap |
| `earthbag` | Earthbag |
| `elevated_rc` | Elevated flood |
| `amphibious` | Floating amphibious |
| `geogrid` | Geogrid wall |
| `steel_frame` | Light gauge steel |
| `timber_frame` / `timber_wattle` | Timber, bamboo wattle |
| `adobe_bands` | Reinforced adobe |
| `prefab` | Pre-fabricated |
| `raised_plinth` | Raised plinth |

Regenerate after editing `engineering_specs/_catalog.json`.
