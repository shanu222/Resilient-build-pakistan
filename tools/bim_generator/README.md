# BIM Generator — Professional Engineering Pipeline

Generates **grid-aligned, centered, cumulative** GLB construction sequences for all 16 resilient housing models.

## Architecture

```
Structural Grid → Foundation → Columns → Beams → Walls → Roof
         ↓
ProfessionalBimEngine (13 cumulative stages)
         ↓
Center at origin (0,0,0) + QC validation
         ↓
GLB per stage + digital_twin JSON
```

## Regenerate all models

```bash
cd tools/bim_generator
pip install -r requirements.txt
python generate_all.py
```

This writes:

- `generated_models/<model_id>/stage_XX_*.glb` (13 stages each)
- `construction_sequences/<model_id>.json`
- Deploys to `mobile/assets/models/` and `mobile/assets/data/digital_twin/`

## Single model

```bash
python engineering_model_generator.py --model interlocking_brick_masonry --deploy
```

## Stages (cumulative)

1. Site Layout  
2. Excavation  
3. Foundation  
4. Foundation Reinforcement  
5. Columns / Structural Supports  
6. Beams  
7. Wall Construction  
8. Openings  
9. Bands / Bracing  
10. Roof Structure  
11. Roof Covering  
12. Finishing  
13. Completed Structure  

Each stage **retains all previous geometry** — only new components are added.
