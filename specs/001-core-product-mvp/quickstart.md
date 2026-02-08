# Quickstart: Us Core Product MVP

**Date**: 2026-02-09
**Branch**: `001-core-product-mvp`

## Prerequisites

- Node.js 20 LTS
- PostgreSQL 16 (local or Docker)
- Expo CLI (`npm install -g expo-cli` or use `npx expo`)
- iOS Simulator (macOS) or Android Emulator, or physical device with Expo Go
- S3-compatible storage account (AWS S3, MinIO for local dev)

## Backend Setup

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Edit .env with your values:
#   DATABASE_URL=postgresql://user:pass@localhost:5432/us_dev
#   JWT_SECRET=your-secret-key
#   JWT_REFRESH_SECRET=your-refresh-secret
#   S3_BUCKET=us-photos-dev
#   S3_REGION=us-east-1
#   S3_ACCESS_KEY=your-key
#   S3_SECRET_KEY=your-secret
#   S3_ENDPOINT=http://localhost:9000  (for MinIO)
#   APP_URL=https://us.app

# Generate Prisma client and run migrations
npx prisma generate
npx prisma migrate dev

# Start development server
npm run dev
# API available at http://localhost:3000
```

## Mobile Setup

```bash
# Navigate to mobile app
cd mobile

# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Edit .env with your values:
#   API_URL=http://localhost:3000/api/v1
#   (Use your machine's IP instead of localhost for physical devices)

# Start Expo development server
npx expo start

# Press 'i' for iOS simulator, 'a' for Android emulator
# Or scan QR code with Expo Go on a physical device
```

## Local S3 (MinIO) for Development

```bash
# Run MinIO via Docker
docker run -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  minio/minio server /data --console-address ":9001"

# Create the photos bucket via MinIO console at http://localhost:9001
# Or use the AWS CLI:
aws --endpoint-url http://localhost:9000 s3 mb s3://us-photos-dev
```

## Running Tests

```bash
# Backend tests
cd backend
npm test                    # All tests
npm run test:unit           # Unit tests only
npm run test:integration    # Integration tests only
npm run test:contract       # Contract tests only

# Mobile tests
cd mobile
npm test                    # All tests
```

## Key Commands

| Command | Location | Purpose |
|---------|----------|---------|
| `npm run dev` | backend/ | Start API server (hot reload) |
| `npx expo start` | mobile/ | Start Expo dev server |
| `npx prisma studio` | backend/ | Visual database browser |
| `npx prisma migrate dev` | backend/ | Apply pending migrations |
| `npx prisma migrate reset` | backend/ | Reset database (dev only) |
| `npm test` | either | Run test suite |

## Verification Checklist

After setup, verify the following work end-to-end:

1. Backend starts without errors on port 3000
2. `POST /api/v1/auth/register` returns 201 with tokens
3. `POST /api/v1/auth/login` returns 200 with tokens
4. `POST /api/v1/spaces` creates a pending space with invitation link
5. Mobile app launches and shows the auth screen
6. Registration flow completes and redirects to main screen
7. MinIO/S3 accepts uploads via presigned URL

## Environment Variables Reference

### Backend (.env)

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `JWT_SECRET` | Yes | Access token signing secret |
| `JWT_REFRESH_SECRET` | Yes | Refresh token signing secret |
| `JWT_ACCESS_EXPIRY` | No | Access token TTL (default: 15m) |
| `JWT_REFRESH_EXPIRY` | No | Refresh token TTL (default: 7d) |
| `S3_BUCKET` | Yes | Photo storage bucket name |
| `S3_REGION` | Yes | S3 region |
| `S3_ACCESS_KEY` | Yes | S3 access key |
| `S3_SECRET_KEY` | Yes | S3 secret key |
| `S3_ENDPOINT` | No | Custom S3 endpoint (for MinIO) |
| `APP_URL` | Yes | Public app URL (for invitation links) |
| `PORT` | No | API port (default: 3000) |
| `INVITE_EXPIRY_HOURS` | No | Invitation link TTL (default: 48) |

### Mobile (.env)

| Variable | Required | Description |
|----------|----------|-------------|
| `API_URL` | Yes | Backend API base URL |
