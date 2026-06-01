# Resilient Build Pakistan — AWS Backend

REST API for content management, admin operations, and optional mobile sync.

## Stack

- **API Gateway** — HTTP API
- **Lambda** — Node.js handlers (`backend/lambda/`)
- **DynamoDB** — models, materials, scores
- **S3** — PDFs, GLB, images, narration audio
- **CloudFront** — CDN for public assets
- **Cognito** — Admin / Editor / Viewer groups

## Deploy

```bash
cd terraform
terraform init
terraform workspace select staging || terraform workspace new staging
terraform apply -var-file=environments/staging.tfvars
```

Set outputs in mobile build:

```bash
flutter build web --dart-define=API_BASE_URL=https://xxx.execute-api.region.amazonaws.com \
  --dart-define=CDN_BASE_URL=https://xxx.cloudfront.net \
  --dart-define=ENV=staging
```

## Local API

```bash
cd backend/lambda
npm install
npm run dev
```

## Collections (DynamoDB)

| Table | Partition key | Purpose |
|-------|---------------|---------|
| `rbp-models` | `modelId` | House metadata |
| `rbp-content` | `modelId#type` | PDF/GLB S3 keys, narration |

## Roles (Cognito)

- `admin` — full CRUD, uploads
- `editor` — edit content, no IAM
- `viewer` — read-only
