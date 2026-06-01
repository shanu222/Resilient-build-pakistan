# Deployment Guide — Resilient Build Pakistan

## Prerequisites

- Flutter 3.22+ (`flutter doctor`)
- Node.js 20+ (backend local API)
- Terraform 1.5+ (AWS)
- Vercel account (web frontend)
- AWS account with IAM deploy rights

---

## 1. Flutter Web (Vercel)

Root `vercel.json` builds from `mobile/`:

```bash
cd mobile
flutter pub get
flutter build web --release \
  --dart-define=ENV=production \
  --dart-define=API_BASE_URL=https://YOUR_API.execute-api.ap-south-1.amazonaws.com \
  --dart-define=CDN_BASE_URL=https://YOUR_CDN.cloudfront.net
```

Connect GitHub repo to Vercel; set root directory to repository root (uses `vercel.json`).

---

## 2. Android

```bash
cd mobile
flutter build apk --release \
  --dart-define=ENV=production \
  --dart-define=API_BASE_URL=...
```

Sign with your keystore; upload to Play Console internal track first.

---

## 3. AWS Backend

```bash
cd backend/lambda
npm install
# Package Lambda (required before terraform apply):
mkdir -p dist && cd dist && zip -r ../dist.zip . && cd ..
# Copy src into dist or use build script — then:

cd ../../terraform
terraform init
terraform apply -var-file=environments/staging.tfvars
```

Upload content to S3:

```bash
aws s3 sync mobile/assets/pdfs s3://BUCKET/pdfs/
aws s3 sync mobile/assets/models s3://BUCKET/models/
```

---

## 4. Environment variables

Copy `.env.staging.example` / `.env.production.example` to CI secrets.

Flutter uses `--dart-define` (see `lib/core/config/app_config.dart`).

---

## 5. Firebase (optional)

```bash
cd mobile
dart pub global activate flutterfire_cli
flutterfire configure
```

Commit is **not** required for `firebase_options.dart` (gitignored).

---

## 6. Pre-push checklist

```bash
cd mobile
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build web
```

---

## 7. Post-deploy verification

- [ ] Home → Location analysis → recommendations load
- [ ] Open each core model → BIM or construction guide
- [ ] PDF viewer (when assets uploaded)
- [ ] `/admin` route (restrict in production via Cognito)
