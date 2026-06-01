# ResilientBuild Pakistan

National disaster-resilient housing and infrastructure knowledge platform — **Choose Location. Build Safe.**

| Layer | Path |
|-------|------|
| **Production app** | [`mobile/`](mobile/) — Flutter (Android + Web) |
| **UI reference** | [`src/`](src/) — React/Figma prototype (do not redesign) |
| **AWS backend** | [`backend/`](backend/) + [`terraform/`](terraform/) |
| **Documentation** | [`docs/`](docs/) |

## Quick start

```bash
cd mobile
flutter pub get
flutter run -d chrome   # or android device
```

## Capabilities

- **Location intelligence** — GPS / map, flood, earthquake, landslide, GLOF, wind
- **HazardRecommendationEngine** — ranks 16+ resilient housing models
- **BIM 4D simulation** — 16 procedural engineering simulators (timeline, narration, view modes)
- **ResilientModelRegistry** — unified catalog (materials, scores, BIM linkage)
- **Offline-first** — bundled JSON + Hive
- **Admin scaffold** — `/admin` (full CMS via AWS when deployed)

## Production deployment

See [docs/DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md).

| Target | Command / service |
|--------|-------------------|
| Web | Vercel (`vercel.json` → `flutter build web`) |
| Android | `flutter build apk --release` |
| API | Terraform → API Gateway + Lambda |
| Assets | S3 + CloudFront |

## Documentation

- [Project audit](docs/PROJECT_AUDIT.md)
- [System architecture](SYSTEM_ARCHITECTURE.md)
- [API](API_DOCUMENTATION.md)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

## Repository

https://github.com/shanu222/Resilient-build-pakistan.git

## License

Proprietary — Resilient Build Pakistan programme.
