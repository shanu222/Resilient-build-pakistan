# Changelog

## [1.0.0] - 2026-06-01

### Added

- Production deployment scaffold: Terraform (AWS), Lambda API stub, Vercel config
- `HazardRecommendationEngine` — unified location + model recommendation API
- `ResilientModelRegistry` — catalog with BIM linkage
- `lib/features/bim/bim_engine.dart` public barrel
- Admin dashboard route (`/admin`)
- Unit and widget smoke tests
- Documentation: audit, deployment, architecture, API, test report

### Existing (pre-release)

- 16 procedural BIM 4D simulators + advanced interlocking
- 17 housing models in JSON
- Location intelligence, academy, PDF viewer, offline Hive

### Known limitations

- `bamboo_frame_wattle_daub` — no BIM package yet
- GLB/PDF binary assets not bundled — placeholders in UI
- Cognito auth not wired in mobile UI
