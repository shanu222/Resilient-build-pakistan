# ResilientBuild Pakistan

**Public engineering education platform** — offline-first resilient construction digital twin for Pakistan.

| Layer | Path |
|-------|------|
| **App** | [`mobile/`](mobile/) — Flutter (Android + Web) |
| **UI reference** | [`src/`](src/) — React/Figma prototype |
| **BIM pipeline** | [`tools/bim_generator/`](tools/bim_generator/) — GLB stage generation |
| **Documentation** | [`docs/`](docs/) |

## User journey

1. Select **district** (or GPS) in Pakistan  
2. Evaluate **flood, earthquake, landslide, GLOF, wind**  
3. View **recommended resilient models**  
4. Enter **Digital Twin Mode** — GLB construction sequence + engineering views  
5. Run **hazard simulations** and tap components to learn  

No login. No backend required after install.

## Quick start

```bash
cd mobile
flutter pub get
flutter run -d chrome   # or android device
```

## Deploy to Vercel

Connect the GitHub repo in Vercel and deploy — configuration is in `vercel.json`.  
Details: [DEPLOYMENT_READY.md](DEPLOYMENT_READY.md)

## Core modules

- Location & district selection  
- Hazard recommendation engine  
- Model library (16+ resilient housing types)  
- Digital Twin (GLB timeline + procedural structural views)  
- Construction animation (per-stage GLB assets)  
- Engineering knowledge (academy, materials, component tap)  
- PDF guidance library (bundled)  
- Offline storage (Hive)

## Repository

https://github.com/shanu222/Resilient-build-pakistan.git

## License

Proprietary — Resilient Build Pakistan programme.
