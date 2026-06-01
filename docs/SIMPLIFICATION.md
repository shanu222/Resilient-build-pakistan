# Simplification pass (public education platform)

## Removed

- Authentication, Cognito, Firebase (core, auth, Firestore, storage)
- Admin panel (`/admin`) and CMS sync
- User profile, roles, permissions
- AI inspection, project tracker, market prices screens
- AWS Lambda backend (`backend/`) and Terraform (`terraform/`)
- CDN / remote API config (`ContentCdnService`, env API examples)
- Vercel serverless config (optional static web build remains via `flutter build web`)

## Kept

- District-based location + GPS
- Hazard recommendation engine
- 16+ model library with resilience scores
- Digital Twin (GLB stages + procedural engineering views)
- BIM simulation fallback for models without GLB
- Construction academy, materials reference, PDF library
- Hive offline storage

## Primary journey

```
Open app → Select district → Hazard evaluation → Recommended models
→ Digital Twin → Construction timeline → Hazard simulation → Component learning → PDFs
```
