# Theme contrast audit

## Root causes fixed

1. **AppTypography** hardcoded `AppColors.foreground` in dark mode — all body/title text was near-black on dark cards.
2. **textOnGlass** was white in light theme — unreadable on light glass panels (BIM toolbar, docks).
3. **ChipTheme** lacked `chipForeground` per brightness.
4. **Navigation rail** inactive icons used low-contrast `#94A3B8` on navy.
5. **Glass cards / guidelines ref panels** used `Colors.white` text in light theme.

## Token additions

- `textOnHero`, `textOnHeroMuted` — navy gradient heroes
- `chipForeground`, `navInactive`, `navActive`, `shadow`, `fillSubtle`
- Light `textOnGlass` → dark foreground; dark `textOnGlass` → light slate

## Validation

`ThemeContrastValidator.auditTokens()` — run via `test/theme/theme_contrast_test.dart`

## Remaining non-UI hardcoded colors (intentional)

- `bim_simulation/engine/geometry/*` — 3D entity colors (not text)
- `model_manual_generator.dart` — PDF generation (print colors)
- `bim_viewport.dart` painter — canvas HUD uses fixed light-on-dark panel

## UI files migrated to tokens (this pass)

- `app_theme.dart`, `app_theme_extensions.dart`, `app_typography.dart`
- `theme_contrast_validator.dart`, `theme_text_styles.dart`
- `glass_sidebar.dart`, `government_header.dart`, `gradient_header.dart`
- `model_catalog_card.dart`, `model_thumbnail.dart`
- `home_dashboard_screen.dart`, `offline_library_screen.dart`, `recommended_models_screen.dart`
- `location_analysis_screen.dart`, `model_details_screen.dart`, `construction_guidelines_screen.dart`
- `engineering_detail_screen.dart`, `materials_library_screen.dart`, `onboarding_screen.dart`
- `digital_twin_viewport.dart`, `hazard_simulation_overlay.dart`
- `bim_engineering_workspace.dart`, `model_viewer_widget.dart`
- `premium_button.dart`, `app_brand_logo.dart`, `zoomable_asset_image.dart`

## Pages audited

Home, model library, model details, construction guidelines/PDF, location analysis, offline library, engineering detail, materials, onboarding, BIM workspace, digital twin viewport/hazards, sidebar navigation.
