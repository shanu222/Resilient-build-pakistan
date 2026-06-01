# API Documentation — Resilient Build Pakistan

Base URL: `{API_BASE_URL}` (see `.env.production.example`)

## Authentication (planned)

```
Authorization: Bearer <Cognito JWT>
```

Roles: `admin`, `editor`, `viewer`

---

## Models

### `GET /models`

List all resilient housing models.

**Response 200**

```json
{
  "models": [
    { "modelId": "interlocking_brick_masonry", "name": "Interlocking Brick Masonry" }
  ]
}
```

### `GET /models/{id}`

Single model metadata.

**Response 200**

```json
{
  "modelId": "earthbag_masonry",
  "name": "Earthbag Masonry",
  "resilienceScore": 78,
  "pdfKey": "pdfs/earthbag_guidelines.pdf",
  "glbKey": "models/earthbag/base.glb"
}
```

---

## Content upload (admin)

### `POST /admin/models`

Create model (Admin only).

### `PUT /admin/models/{id}`

Update metadata, scores, narration references.

### `POST /admin/upload`

Multipart upload → S3 presigned URL for PDF/GLB.

---

## Hazard (client-side today)

Hazard analysis runs on-device via `HazardRecommendationEngine`. Future endpoint:

### `POST /hazards/analyze`

```json
{ "latitude": 31.52, "longitude": 74.35 }
```

**Response:** `HazardProfile` + ranked `ModelRecommendationResult[]`

---

## Local development

```bash
cd backend/lambda && npm install && npm run dev
curl http://localhost:3000/models
```
