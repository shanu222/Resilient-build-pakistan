# Theme contrast audit (global)

## Phase 1 — Hardcoded color scan (`mobile/lib`)

| Pattern | UI matches | Notes |
|---------|------------|-------|
| `Colors.white` / `Colors.black` / `Colors.grey*` | **0** in UI | Removed from widgets |
| `PdfColors.*` | PDF generator only | Print pipeline — excluded |
| `Color(0xFF…)` in UI | BIM 3D geometry + canvas HUD | Not on-screen Flutter `Text` |
| `AppColors.*` on `Text`/`TextStyle` | **0** after this pass | Icons/backgrounds may still use brand colors |

## Phase 2 — Token migration

All user-facing text should use `context.appTokens`:

- `textPrimary`, `textSecondary`, `textMuted`
- `textOnGlass`, `textOnGlassMuted` (viewer glass / playback)
- `textOnHero`, `textOnHeroMuted` (navy heroes)
- `textOnPrimary` (buttons on orange/navy)
- `success`, `warning`, `danger` (semantic accents)

**Critical fix:** `GlassSidebar` used `navActive`/`navInactive` (white/slate for navy header) on **light glass** — navigation looked faded/invisible. Sidebar now uses `textPrimary` / `textSecondary`.

**Model library:** Metric **values** use `textPrimary`; icons use `success` / `primary` / `warning`.

## Phase 3–8 — Audited surfaces

| Area | Status |
|------|--------|
| Model / library cards | `model_catalog_card.dart` |
| Guideline / PDF panels | `construction_guidelines_screen.dart` |
| Timeline / engineering cards | `model_details_screen.dart`, BIM workspace |
| Hazard cards | `hazard_simulation_overlay.dart` |
| Drawer / inspector | `digital_twin_workspace.dart` |
| Sidebar | `glass_sidebar.dart` |
| Forms | `app_theme.dart` `inputDecorationTheme` |
| Chips | `app_theme.dart` `chipTheme` + per-screen chips |
| Buttons | `primary_button`, `premium_button`, `app_theme` buttons |
| Heroes | `gradient_header`, library screens, `home_dashboard` |

## Phase 9 — `ThemeContrastValidator`

`mobile/lib/core/theme/theme_contrast_validator.dart` — WCAG AA pairs for light/dark tokens.

Tests: `mobile/test/theme/theme_contrast_test.dart`

## Intentional exclusions

- `bim_simulation/engine/geometry/*` — 3D entity colors
- `model_manual_generator.dart` — PDF colors
- `bim_viewport.dart` — CustomPainter HUD

## Build verification

Run locally:

```bash
cd mobile
flutter analyze
flutter test
flutter build web --release
```
