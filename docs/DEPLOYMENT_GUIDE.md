# Deployment Guide — Resilient Build Pakistan (Vercel)

Static, offline-first **Flutter Web** deployment. No AWS backend required.

---

## Quick deploy (Vercel + GitHub)

1. Push to https://github.com/shanu222/Resilient-build-pakistan
2. In [Vercel](https://vercel.com): **Add New Project** → import the repo
3. Leave **Root Directory** as `.` (repository root)
4. Confirm settings match `vercel.json`:
   - Build: `bash scripts/vercel-build.sh`
   - Output: `mobile/build/web`
5. **Deploy** (no environment variables required)

See [DEPLOYMENT_READY.md](../DEPLOYMENT_READY.md) for full audit and smoke-test checklist.

---

## Local production build

```bash
cd mobile
flutter pub get
flutter build web --release --base-href / --pwa-strategy=none
```

Output: `mobile/build/web/`

Serve locally:

```bash
cd mobile/build/web
npx serve -s .
```

---

## React prototype (not deployed)

The repo root contains a **Vite + React** Figma reference (`npm run build` → `dist/`). It is **not** the production app and is **not** used by Vercel for this project.

---

## Android (optional)

```bash
cd mobile
flutter build apk --release
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Vercel build timeout | Retry; first build downloads Flutter SDK (~15 min) |
| 404 on refresh | Ensure `vercel.json` rewrites are deployed |
| GLB not loading | Check browser network tab for `/assets/assets/models/...` |
| PDF fails | Add file under `mobile/assets/pdfs/` and reference in `houses.json` |
