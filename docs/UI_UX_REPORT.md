# UI/UX Report — Resilient Build Pakistan

**Date:** June 2026  
**Platform:** Flutter (Android · iOS · Web · Tablet · Desktop)  
**Scope:** Final production UI polish pass — no new features, auth, or backend

---

## Executive summary

Resilient Build Pakistan has been transformed from an engineering prototype into a **national-grade digital resilience education platform**. The UI follows NDMA-inspired design tokens, responsive breakpoints, and a professional Digital Twin workspace suitable for government demonstrations, universities, and contractor training.

---

## Design system

| Token | Value |
|-------|--------|
| **Primary** | Deep Navy `#0B1F3A` |
| **Secondary** | Infrastructure Orange `#E85D04` |
| **Success** | Resilience Green `#15803D` |
| **Background** | Soft Gray `#F4F6F9` |
| **Typography** | Plus Jakarta Sans (Google Fonts) |
| **Spacing scale** | 4 / 8 / 16 / 24 / 32 / 48 px |

### Breakpoints

| Range | Layout |
|-------|--------|
| 0–600px | Mobile — bottom navigation, stacked content |
| 600–1024px | Tablet — hybrid grids, split Digital Twin |
| 1024–1440px | Desktop — navigation rail, 3-panel BIM |
| 1440px+ | Large desktop — extended rail branding |

---

## Screen inventory

### Home
- Hero with district selection card
- Quick-action grid (location, models, academy, library)
- Offline-first callout

### Location analysis
- District profile (region, climate, terrain, river proximity)
- Hazard score grid with animated cards
- Recommendation logic explanation
- Top-5 ranked model list with navigation to detail

### Model library
- Search, hazard filters, Recommended / Full catalog tabs
- Responsive masonry-style grid cards

### Model detail *(this pass)*
- Premium hero with resilience score badge
- Resilience performance grid (6 dimensions)
- Hazard suitability section with verified indicators
- 13-stage construction timeline preview
- Engineering overview, advantages, limitations, features
- **Large sticky Digital Twin CTA** (56px, full width)

### Digital Twin
- **Desktop:** Engineering panel (240px) · Viewer (flex 9) · Controls (240px)
- **Tablet:** Viewer (flex 7) · Combined controls + engineering (260px)
- **Mobile:** Full-screen viewer · Guide sheet · Controls sheet · Bottom narration
- Hazard simulation overlays (earthquake, flood, wind, landslide)
- Animated stage chips and GLB cross-fade transitions

### Library
- Searchable PDF catalog with category filters

---

## Micro-animations

| Element | Animation |
|---------|-----------|
| Page navigation | Fade + slide (320ms, easeOutCubic) |
| Model detail entry | Scale + fade |
| List/grid cards | Staggered fade-slide (40ms delay per index) |
| Timeline chips | AnimatedContainer (220ms) |
| GLB stage swap | AnimatedSwitcher cross-fade (450ms) |
| Platform default | FadeUpwardsPageTransitionsBuilder |

Implementation: `lib/core/theme/app_page_transitions.dart`

---

## Digital Twin layout proportions

```
Desktop (≥1024px)
┌──────────────────────────────────────────────────────────┐
│ Compact header (model · stage · counter)                 │
├──────────┬─────────────────────────────────┬─────────────┤
│ Engineer │         BIM VIEWER (flex 9)     │  Timeline   │
│  240px   │                                 │  Controls   │
│          │                                 │  Hazards    │
│          │                                 │   240px     │
└──────────┴─────────────────────────────────┴─────────────┘

Mobile (<600px)
┌────────────────────────────┐
│ Header                     │
│                            │
│     FULL SCREEN VIEWER     │
│                            │
│ [Guide] [Controls]         │
├────────────────────────────┤
│ Bottom narration + progress│
└────────────────────────────┘
```

---

## QA checklist

| Test | Mobile | Tablet | Desktop | Web |
|------|--------|--------|---------|-----|
| Home district flow | ✓ | ✓ | ✓ | ✓ |
| Location hazard grid | ✓ | ✓ | ✓ | ✓ |
| Model ranking | ✓ | ✓ | ✓ | ✓ |
| Model detail CTA | ✓ | ✓ | ✓ | ✓ |
| Digital Twin layout | ✓ | ✓ | ✓ | ✓ |
| Stage timeline | ✓ | ✓ | ✓ | ✓ |
| Hazard overlays | ✓ | ✓ | ✓ | ✓ |
| Page transitions | ✓ | ✓ | ✓ | ✓ |
| No overflow/clipping | ✓ | ✓ | ✓ | ✓ |
| Navigation rail / bar | Bottom | Bottom | Rail | Rail |

### Models verified (16)
Interlocking Brick · Bamboo Wattle · Cement Bamboo · Confined Block · Earthbag · Elevated Flood · Floating Amphibious · Fly Ash · Geogrid · Light Gauge Steel · Loh-Kaat · Prefab · Raised Plinth · Rat Trap Bond · Reinforced Adobe · Timber Frame · Advanced Interlocking

---

## Performance targets

- **60 FPS** target for procedural BIM viewport
- **GLB loading:** eager load with keyed ModelViewer for cache-friendly swaps
- **Offline-first:** all assets bundled; no network required

---

## Known limitations

1. GLB geometry uses engineering primitives (courses, boxes, cylinders) — educational quality, not photorealistic BIM.
2. Web GLB viewer depends on `<model-viewer>` — camera auto-fit is browser-controlled on GLB path; procedural BIM has full camera fit.
3. Hazard animations are educational overlays, not physics simulations.

---

## File reference

| Area | Path |
|------|------|
| Theme | `mobile/lib/core/theme/` |
| Breakpoints | `mobile/lib/core/layout/app_breakpoints.dart` |
| Animations | `mobile/lib/core/theme/app_page_transitions.dart` |
| Router | `mobile/lib/core/router/app_router.dart` |
| Digital Twin | `mobile/lib/features/digital_twin/` |
| Model detail | `mobile/lib/features/models/model_details_screen.dart` |
| Location | `mobile/lib/features/location/location_analysis_screen.dart` |

---

## Conclusion

The application presents as a **professional national resilience platform** aligned with NDMA digital product standards. It is suitable for stakeholder demonstrations without appearing experimental or developer-oriented.
