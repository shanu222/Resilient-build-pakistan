# Test Report — Resilient Build Pakistan

**Generated:** 2026-06-01

## Summary

| Suite | Files | Status |
|-------|-------|--------|
| Unit — recommendation | `test/domain/model_recommendation_engine_test.dart` | Added |
| Unit — hazard engine | `test/domain/hazard_recommendation_engine_test.dart` | Added |
| Unit — BIM registry | `test/bim/bim_scene_registry_test.dart` | Added |
| Widget smoke | `test/widget/app_smoke_test.dart` | Added |

## Run locally

```bash
cd mobile
flutter pub get
flutter test
flutter test --coverage
```

## Coverage target

Production target: **80%+** line coverage on `lib/domain`, `lib/features/bim_simulation/engine`, and `lib/features/models`.

Current baseline establishes tests for critical engines; expand with:

- `JsonAssetRepository` parsing tests
- `BimSimulationController` stage progression tests
- Golden tests for `BimViewport` (optional)

## CI recommendation

```yaml
- run: cd mobile && flutter analyze
- run: cd mobile && flutter test
- run: cd mobile && flutter build web
```

## Known gaps

- Integration tests (Firebase, GPS) not included — require device/emulator.
- Backend Lambda tests in `backend/lambda` — add `npm test` when handlers grow.
