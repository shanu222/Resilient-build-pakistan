# Contributing

## Setup

```bash
cd mobile
flutter pub get
flutter run
```

## Code style

- Follow `flutter analyze` / `analysis_options.yaml`
- Match existing feature folder layout
- Do not redesign UI without approval — use `src/` React prototype as reference

## Adding a resilient model

1. Add entry to `assets/data/houses.json`
2. Add `assets/data/bim_<model>.json` stages
3. Create `*SceneBuilder` + `*Package` under `lib/features/bim_simulation/`
4. Register ID in `BimSceneRegistry`
5. Add tests in `test/bim/`
6. Update `docs/PROJECT_AUDIT.md` coverage table

## Commits

Use conventional prefixes: `feat:`, `fix:`, `docs:`, `test:`, `chore:`

## Pull requests

- `flutter analyze` clean
- `flutter test` passing
- Update CHANGELOG.md
