# Resilient Build Pakistan — Project Audit

**Audit date:** 2026-06-01  
**Scope:** `mobile/` (production Flutter app), `src/` (React UI reference), deployment & backend readiness

---

## Executive summary

The Flutter application is **functionally rich** for offline-first resilient housing education: location intelligence, 17 housing models in JSON, **16 procedural BIM 4D simulators**, construction guides, academy, PDF viewer, and Riverpod + GoRouter architecture. It is **not yet production-deployed**: no git history in workspace, **no automated tests**, **no AWS backend deployed**, **missing binary assets** (GLB/PDF), and **one housing model** (`bamboo_frame_wattle_daub`) lacks a BIM package.

This audit drove stabilization work: model registry, hazard recommendation facade, backend IaC scaffold, admin UI scaffold, test suite baseline, and deployment documentation.

---

## Repository layout

| Path | Role | Status |
|------|------|--------|
| `mobile/` | Production Flutter app (Android, Web) | Primary |
| `src/` | Figma/React UI prototype | Reference only |
| `backend/` | AWS Lambda + API (new scaffold) | Scaffolded |
| `terraform/` | Infrastructure as Code | Scaffolded |
| `docs/` | Audit, deployment, test reports | Created |

---

## Phase 1 findings

### Implemented capabilities

- **Location intelligence** — GPS + map (`LocationIntelligenceEngine`), regional classification, hazard metrics (flood, earthquake, landslide, GLOF, wind).
- **Model catalog** — 17 models in `assets/data/houses.json`.
- **Recommendation** — `ModelRecommendationEngine` + region rules; wrapped by `HazardRecommendationEngine`.
- **BIM simulation** — 16 models in `BimSceneRegistry` with JSON stages, TTS, view modes, component pick.
- **UI flows** — Splash, onboarding, shell, model details, construction/BIM routes, academy, inspection placeholder, downloads, projects, reports.
- **Offline** — Hive via `LocalStorageRepository`; bundled JSON assets.
- **Firebase (optional)** — `FirebaseAdminRepository` for Firestore sync; graceful fallback without `firebase_options.dart`.

### Missing or incomplete

| Item | Severity | Notes |
|------|----------|-------|
| `bamboo_frame_wattle_daub` BIM package | Medium | Falls back to GLB construction guide; no `bim_*.json` |
| GLB / PDF / image binaries | High | Folders declared; only `assets/data/` populated |
| `GlbSceneAdapter` integration | Low | Stub exists; procedural BIM used instead |
| Automated tests | High | Was empty; baseline added under `mobile/test/` |
| AWS backend runtime | High | Terraform + Lambda scaffold only |
| Admin production UI | Medium | In-app admin scaffold; full CMS needs backend |
| Cognito / JWT in app | Medium | Documented; auth flow not wired in UI |
| `advanced_interlocking_brick_masonry` in user “16 models” list | Info | 17th model; BIM complete |
| Separate `lib/features/bim/` | Info | Aliased to `bim_simulation` via barrel export |
| Git repository | High | Initialized in deployment pass |

### Build & tooling

- **Flutter SDK** must be on PATH for `flutter analyze`, `flutter test`, `flutter build web`.
- **No compile errors** reported by IDE on `lib/` at audit time.
- **Riverpod generators** in `pubspec` but unused (no `.g.dart` in lib) — safe to keep for future.

### Security

- Firebase init wrapped in try/catch — good for dev.
- No secrets in repo — use `.env.*.example` + CI secrets.
- Admin routes should be gated in production (role check via Cognito when enabled).

### Dead / duplicate code

- `riverpod_annotation` / `build_runner` unused — not harmful.
- React `src/` duplicates screens; do not delete (design reference per README).

### Navigation

- GoRouter routes verified: `/`, `/home`, `/location/:id`, `/model/:id`, `/construction/:id`, `/bim/:id`, `/admin` (added).

---

## BIM model coverage

| Model ID | BIM | JSON definition |
|----------|-----|-----------------|
| interlocking_brick_masonry | Yes | bim_interlocking_brick.json |
| advanced_interlocking_brick_masonry | Yes | bim_advanced_interlocking.json |
| bamboo_frame_wattle_daub | **No** | — |
| cement_bamboo_frame | Yes | bim_cement_bamboo.json |
| confined_concrete_block_masonry | Yes | bim_confined_block.json |
| earthbag_masonry | Yes | bim_earthbag.json |
| elevated_flood_resilient_house | Yes | bim_elevated_flood.json |
| floating_amphibious_structure | Yes | bim_amphibious.json |
| fly_ash_masonry | Yes | bim_fly_ash.json |
| geogrid_reinforced_retaining_wall | Yes | bim_geogrid.json |
| light_gauge_steel_house | Yes | bim_light_gauge_steel.json |
| loh_kaat_timber_house | Yes | bim_loh_kaat.json |
| pre_fabricated_house | Yes | bim_prefabricated.json |
| raised_plinth_flood_resilient_house | Yes | bim_raised_plinth.json |
| rat_trap_bond_masonry | Yes | bim_rat_trap_bond.json |
| reinforced_adobe_brick_structure | Yes | bim_reinforced_adobe.json |
| timber_frame_lath_plaster | Yes | bim_timber_frame.json |

---

## Recommendations (post-audit)

1. Add `bamboo_frame_wattle_daub` BIM package or ship GLB to `assets/models/bamboo_wattle/`.
2. Run CI: `flutter analyze`, `flutter test`, `flutter build web` on every PR.
3. Deploy Terraform to staging; point app `API_BASE_URL` to API Gateway.
4. Upload PDFs/GLB to S3; enable CloudFront; switch app to CDN URLs when online.
5. Wire Cognito auth for admin roles before public admin URL.

---

## Audit sign-off

| Check | Result |
|-------|--------|
| Code structure reviewed | Pass |
| Critical gaps documented | Pass |
| Stabilization scaffold added | Pass |
| Production path documented | See `docs/DEPLOYMENT_GUIDE.md` |
