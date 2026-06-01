# ResilientBuild Pakistan (Flutter)

**Tagline:** Choose Location. Build Safe.

Production-grade Flutter mobile app integrating location intelligence, model recommendations, BIM-style 3D construction simulation, PDF guidelines, Construction Academy, and AI inspection framework.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable)
- Android Studio / Xcode for device builds
- Optional: Firebase project for Auth, Firestore, Storage, and admin content sync

## Quick start

```bash
cd mobile
flutter pub get
flutter run
```

## Project structure

```
lib/
  core/           Theme, router (GoRouter), shared widgets
  data/           Models, JSON + Hive + Firebase repositories
  domain/         Location intelligence & recommendation engines
  features/       Screens (matching existing UI design)
  providers/      Riverpod state
assets/data/      JSON content repositories (admin-syncable)
assets/models/    GLB/GLTF per construction stage
assets/pdfs/      Model guideline PDFs
```

## Content management (no app redeploy)

1. **Bundled JSON** — Edit `assets/data/*.json` for defaults.
2. **Firebase Firestore** — `FirebaseAdminRepository` streams `houses`, `regions`, `materials`, `hazards`, `construction_simulations`. Seed once via admin tooling.
3. **Offline** — Hive stores locations, projects, PDF bookmarks, and download paths.

## BIM construction simulation (Models 01–16)

Procedural BIM 4D engine (engineering viewport — not game-style placeholders):

| Model | ID | Stages |
|-------|-----|--------|
| Interlocking Brick Masonry | `interlocking_brick_masonry` | 12 |
| Earthbag Masonry | `earthbag_masonry` | 15 |
| Cement Bamboo Frame | `cement_bamboo_frame` | 16 |
| Confined Concrete Block | `confined_concrete_block_masonry` | 16 |
| Elevated Flood Resilient House | `elevated_flood_resilient_house` | 16 |
| Floating Amphibious Structure | `floating_amphibious_structure` | 15 |
| Fly Ash Masonry | `fly_ash_masonry` | 15 |
| Geogrid Retaining Wall | `geogrid_reinforced_retaining_wall` | 14 |
| Light Gauge Steel House | `light_gauge_steel_house` | 15 |
| Loh-Kaat Timber House | `loh_kaat_timber_house` | 15 |
| Pre-Fabricated House | `pre_fabricated_house` | 15 |
| Raised Plinth Flood Resilient House | `raised_plinth_flood_resilient_house` | 15 |
| Rat Trap Bond Masonry | `rat_trap_bond_masonry` | 15 |
| Reinforced Adobe Brick | `reinforced_adobe_brick_structure` | 16 |
| Timber Frame Lath & Plaster | `timber_frame_lath_plaster` | 16 |
| Advanced Interlocking Brick | `advanced_interlocking_brick_masonry` | 16 |

- Route: `/bim/<model_id>` or **Start Construction Guide** on supported models
- TTS narration, timeline scrubber, exploded / structural / **reinforcement** / **cavity wall** / **material comparison** / **modular assembly** / **block assembly** / **steel frame** / **timber band** / **timber skeleton** / **connection** / rebar / load / **thermal** / **earth pressure** / **landslide** / **groundwater** / **drainage** / **flood** / **buoyancy** / **hydraulic** / **seismic** views
- Tap components for engineering explanations
- GLB swap: implement `GlbSceneAdapter` when assets are ready

Code: `lib/features/bim_simulation/`

## 3D models & PDFs

Place files under:

- `assets/models/<model_id>/stage_XX_*.glb`
- `assets/pdfs/<model_id>_guidelines.pdf`

Paths are referenced in `houses.json` and `construction_steps.json`. Until assets are added, the 3D viewer shows the WebView placeholder; PDF viewer shows a load-failed snackbar.

## Firebase setup

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` (gitignored). Without it, the app runs offline with bundled JSON only.

## Mapbox (optional)

The stack uses **flutter_map** + **geolocator** by default. To add Mapbox tiles, set `MAPBOX_ACCESS_TOKEN` and extend `HomeDashboardScreen` with a `FlutterMap` layer.

## Regenerate platform folders

If `android/` or `ios/` are missing:

```bash
flutter create . --project-name resilientbuild_pakistan
```

## Design

UI colors and layout follow the existing React prototype (`src/styles/theme.css`) — deep navy `#0F172A`, accent orange `#F97316`, 16px radius cards.
