# System Architecture — Resilient Build Pakistan

## Overview

National resilient construction advisory platform: **location intelligence → hazard-aware model recommendations → BIM 4D education → PDF/engineering content**.

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Client (mobile/)                  │
│  UI (GoRouter) · Riverpod · Hive offline · Procedural BIM   │
└───────────────┬─────────────────────────────┬───────────────┘
                │                             │
        Bundled JSON (offline)          AWS (online)
                │                             │
                ▼                             ▼
     assets/data/*.json              API Gateway → Lambda
                                     S3 + CloudFront (CDN)
                                     DynamoDB · Cognito
```

## Client layers

| Layer | Path | Responsibility |
|-------|------|----------------|
| Presentation | `lib/features/*` | Screens, widgets |
| BIM engine | `lib/features/bim_simulation/` | 4D simulation, registry pattern |
| Model catalog | `lib/features/models/` | `ResilientModelRegistry`, details UI |
| Domain | `lib/domain/services/` | `LocationIntelligenceEngine`, `HazardRecommendationEngine` |
| Data | `lib/data/` | JSON repo, Hive, Firebase optional |
| Core | `lib/core/` | Router, theme, `AppConfig` |

## BIM engine (reusable)

- **Registry:** `BimSceneRegistry` maps `modelId` → `BimScenePackage`
- **Definition:** `assets/data/bim_<model>.json` (stages, narration, components)
- **Scene:** Procedural `*SceneBuilder` per model (replaceable via `GlbSceneAdapter`)
- **UI:** `BimSimulationScreen` + `BimSimulationController`

Public import path: `package:.../features/bim/bim_engine.dart`

## Backend (AWS)

See `terraform/` and `backend/README.md`.

## Content flow

1. **Offline:** `JsonAssetRepository` loads bundled data.
2. **Online (future):** API returns model metadata; CDN serves GLB/PDF.
3. **Admin:** In-app `/admin` + future authenticated API for CRUD.

## Security

- Cognito user pool (Terraform) for Admin/Editor/Viewer
- JWT validation on API Gateway authorizer (to be attached in production)
- No secrets in repository — `dart-define` + CI secrets

## Reference UI

`src/` React prototype — design reference only; not deployed.
