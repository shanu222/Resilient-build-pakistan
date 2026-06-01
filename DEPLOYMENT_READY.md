# Deployment Ready Report — Resilient Build Pakistan

**Repository:** https://github.com/shanu222/Resilient-build-pakistan  
**Date:** 2026-06-01  
**Deployment target:** Vercel (static hosting)  
**Status:** **PASS**

---

## Phase 1 — Project audit

| Item | Finding |
|------|---------|
| **Production app** | **Flutter Web** in `mobile/` |
| **UI prototype** | Vite + React 18 in repo root (`src/`, `vite.config.ts`) — reference only, **not** deployed to Vercel |
| **Backend** | None (removed; offline-first) |
| **Auth** | None |

The Vercel deployment serves the **Flutter** engineering education app (digital twin, GLB stages, PDFs, hazard engine).

---

## Phase 2–3 — Build verification

### Flutter Web (production)

| Step | Command | Result |
|------|---------|--------|
| Dependencies | `cd mobile && flutter pub get` | Pass |
| Production build | `flutter build web --release --base-href / --pwa-strategy=none` | **Pass** (verified locally with Flutter 3.44.1) |

Build fixes applied for web compile: theme API, scene-builder static dimensions, `model_viewer_plus` API, web asset URLs, dev dependency conflicts.

### Vite React (prototype — optional)

| Step | Command | Result |
|------|---------|--------|
| Install | `npm install` (repo root) | Pass |
| Build | `npm run build` | Pass → `dist/` |

Not used by `vercel.json`. Kept for Figma/UI reference.

---

## Phase 4 — Static deployment

- No Cognito, DynamoDB, Lambda, API Gateway, admin, or remote APIs.
- Content: bundled under `mobile/assets/` (JSON, GLB, PDFs).
- Offline storage: Hive (browser IndexedDB on web).

---

## Phase 5 — Routing (SPA)

Flutter `go_router` with **path URL strategy** (`usePathUrlStrategy()`).

| Route | Screen |
|-------|--------|
| `/` | Splash |
| `/onboarding` | Onboarding |
| `/home` | District / location |
| `/location/:id` | Hazard analysis |
| `/models` | Model library |
| `/model/:id` | Model details |
| `/bim/:id` | Digital Twin Mode |
| `/construction/:id` | Same entry as BIM |
| `/library` | PDF guidance |
| `/academy` | Construction academy |
| `/materials` | Materials reference |
| `/engineering/:component` | Component detail |

**Vercel:** `vercel.json` rewrites all paths to `index.html` (static files served first).

---

## Phase 6 — Assets

| Asset type | Location | Web loading |
|------------|----------|-------------|
| JSON | `mobile/assets/data/` | `rootBundle` |
| GLB | `mobile/assets/models/` | `webAssetUrl()` → `/assets/...` for ModelViewer |
| PDFs | `mobile/assets/pdfs/` | `SfPdfViewer.asset` |
| Digital twin manifests | `mobile/assets/data/digital_twin/` | Bundled |

Total bundled assets ≈ **3 MB** (well within Vercel limits).

---

## Phase 7 — Vercel configuration

**File:** `vercel.json` (repository root)

| Setting | Value |
|---------|--------|
| **Framework** | None (custom) |
| **Install command** | `echo "Static Flutter Web — no npm install"` |
| **Build command** | `bash scripts/vercel-build.sh` |
| **Output directory** | `mobile/build/web` |
| **SPA fallback** | Rewrite `/(.*)` → `/index.html` |
| **Caching** | Long-cache headers for `/assets/*`, `.glb`, `.wasm`, `.json` |

**Build script:** `scripts/vercel-build.sh` — installs Flutter stable (shallow clone), `flutter precache --web`, `flutter build web`.

---

## Phase 8 — Production smoke checklist

After deploy, verify in browser:

- [ ] `/` → splash → onboarding → home
- [ ] District selection → hazard report
- [ ] `/models` → open model → **Enter Digital Twin Mode**
- [ ] `/bim/<model_id>` → GLB viewport + timeline
- [ ] `/library` → open a PDF
- [ ] `/academy` loads
- [ ] Hard refresh on `/models`, `/library`, `/bim/interlocking_brick_masonry` (no 404)

**Note:** TTS narration is disabled on web (text still shown). GPS may require browser permission.

---

## Vercel setup (one-time)

1. Import https://github.com/shanu222/Resilient-build-pakistan in Vercel.
2. **Root directory:** repository root (default).
3. Vercel reads `vercel.json` automatically.
4. Click **Deploy** — no extra env vars required.
5. Expect **first build 12–20 minutes** (Flutter SDK download + web precache).

Optional: set project **Node.js Version** to **20.x** (install step is a no-op for Flutter).

---

## Known issues / limitations

| Issue | Severity | Notes |
|-------|----------|-------|
| Long first Vercel build | Low | Flutter clone on each cold build; consider Vercel build cache or self-hosted runner later |
| `model_viewer_plus` on web | Low | Uses WebView + Google model-viewer script in `index.html` |
| Syncfusion PDF on web | Low | May show evaluation watermark on web |
| React prototype not deployed | Info | Use Flutter URL for production |
| WASM dry-run warnings | Info | Informational only; build uses JS compilation |

---

## Summary

| Field | Value |
|-------|--------|
| **Framework** | Flutter Web 3.44+ (Dart 3.12+) |
| **Build command** | `bash scripts/vercel-build.sh` |
| **Output directory** | `mobile/build/web` |
| **Node version** | 20.x (optional; not used for main build) |
| **Deployment status** | **PASS** |

The repository is configured for **Import → Deploy** on Vercel without manual code changes.
