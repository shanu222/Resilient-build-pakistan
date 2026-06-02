# ResilientBuild Pakistan (Flutter)

**Tagline:** Choose Location. Build Safe.

Offline-first public engineering education app: location hazards → model recommendations → BIM digital twin → hazard simulation. **Not** a SaaS platform, admin portal, or user management system.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable)
- Android Studio / Xcode for device builds

## Quick start

```bash
cd mobile
flutter pub get
flutter run
```

## Navigation

| Tab | Purpose |
|-----|---------|
| Location | District picker + hazard assessment |
| Models | Recommended & full model library |
| Learn | Construction academy |
| Library | Bundled PDFs + materials reference |

## Project structure

```
lib/
  core/           Theme, router (GoRouter), config
  data/           Models, JSON assets, Hive offline storage
  domain/         Location intelligence & recommendation engines
  features/
    digital_twin/ GLB construction sequence + engineering UI
    bim_simulation/ Procedural BIM viewport (structural, exploded, load path)
    location/     Hazard profile screen
    models/       Model library & details
    library/      Offline PDF guidance
  providers/      Riverpod state
assets/data/      JSON (houses, regions, districts, digital_twin manifests)
assets/models/    Per-stage GLB files
assets/pdfs/      Model guideline PDFs
```

## Digital Twin

- Route: `/bim/<model_id>` or **Enter Digital Twin Mode** on model details  
- **GLB layer:** `model_viewer_plus` — orbit, zoom, pan; stage mesh swap on timeline  
- **Engineering layer:** procedural `BimViewport` — structural, exploded, cross-section, load transfer  
- Hazard menu: earthquake, flood, wind, landslide (model-dependent)  
- Component chips: foundation, walls, roof, etc. with bundled explanations  

Generate/update GLBs:

```bash
cd tools/bim_generator
pip install -r requirements.txt
python generate_all.py
```

## Content

All content ships in `assets/`. Edit JSON under `assets/data/` and rebuild the app. Hive caches last location and downloads on device.

## Tests

```bash
flutter test
flutter analyze
```
