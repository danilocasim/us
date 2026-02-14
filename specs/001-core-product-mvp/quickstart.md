# Quickstart: Us Core Product MVP

**Date**: 2026-02-15 (Updated)
**Branch**: `001-core-product-mvp`

## Prerequisites

- Node.js 20 LTS
- Docker Desktop (for local Supabase)
- Supabase CLI (`npm install -g supabase` or use `npx supabase`)
- Expo CLI (`npm install -g expo-cli` or use `npx expo`)
- iOS Simulator (macOS) or Android Emulator, or physical device with Expo Go

## Supabase Local Setup

```bash
# Navigate to mobile directory
cd mobile

# Install dependencies
npm install

# Start local Supabase instance (requires Docker Desktop running)
npx supabase start

# Output will show:
#   API URL: http://localhost:54321
#   anon key: eyJh... (copy this)
#   service_role key: eyJh... (keep secret)
#   Studio URL: http://localhost:54323

# Apply database migrations
npx supabase db reset

# Generate TypeScript types from schema
npx supabase gen types typescript --local > src/types/database.types.ts
```

## Mobile App Setup

```bash
# Still in mobile/ directory

# Copy environment template
cp .env.example .env

# Edit .env with values from 'npx supabase start' output:
#   EXPO_PUBLIC_SUPABASE_URL=http://localhost:54321
#   EXPO_PUBLIC_SUPABASE_ANON_KEY=eyJh... (use the anon key from supabase start)
#   EXPO_PUBLIC_INVITATION_EXPIRY_HOURS=168
#   EXPO_PUBLIC_MAX_PHOTO_SIZE_MB=10
#   EXPO_PUBLIC_MAX_PHOTOS_PER_SPACE=500

# Start Expo development server
npx expo start

# Press 'i' for iOS simulator, 'a' for Android emulator
# Or scan QR code with Expo Go on a physical device
```

## Supabase Studio (Database Browser)

```bash
# Access Supabase Studio web UI at:
open http://localhost:54323

# Browse tables, run SQL queries, view logs
# Storage buckets visible under 'Storage' tab
```

## Running Tests

```bash
# Mobile tests (ensure Supabase local is running)
cd mobile
npm test                    # All unit tests
npm run test:watch          # Watch mode
npm run test:coverage       # With coverage report
npm run e2e:ios             # Detox E2E tests (iOS)
npm run e2e:android         # Detox E2E tests (Android)
```

## Key Commands

| Command                                     | Location | Purpose                                                  |
| ------------------------------------------- | -------- | -------------------------------------------------------- |
| `npx supabase start`                        | mobile/  | Start local Supabase (PostgreSQL, Auth, Storage, Studio) |
| `npx supabase stop`                         | mobile/  | Stop local Supabase                                      |
| `npx supabase db reset`                     | mobile/  | Reset database and reapply migrations                    |
| `npx supabase gen types typescript --local` | mobile/  | Generate TypeScript types from schema                    |
| `npx expo start`                            | mobile/  | Start Expo dev server                                    |
| `npm test`                                  | mobile/  | Run unit tests                                           |
| `npm run type-check`                        | mobile/  | Type check without emitting                              |

## Verification Checklist

After setup, verify the following work end-to-end:

1. `npx supabase status` shows all services healthy (PostgreSQL, Auth, Storage, Studio)
2. Supabase Studio accessible at http://localhost:54323
3. Mobile app launches and shows auth/onboarding screen
4. TypeScript compilation succeeds: `npm run type-check` (0 errors)
5. Unit tests pass: `npm test`
6. Can view database schema in Studio 'Table Editor' tab
7. Storage bucket 'memories' exists in Studio 'Storage' tab

## Environment Variables Reference

### Mobile (.env)

| Variable                              | Required | Description                                            |
| ------------------------------------- | -------- | ------------------------------------------------------ |
| `EXPO_PUBLIC_SUPABASE_URL`            | Yes      | Supabase API URL (local: http://localhost:54321)       |
| `EXPO_PUBLIC_SUPABASE_ANON_KEY`       | Yes      | Supabase anonymous key (from `npx supabase start`)     |
| `EXPO_PUBLIC_INVITATION_EXPIRY_HOURS` | No       | Invitation link TTL (default: 168 = 7 days per FR-030) |
| `EXPO_PUBLIC_MAX_PHOTO_SIZE_MB`       | No       | Maximum photo upload size (default: 10)                |
| `EXPO_PUBLIC_MAX_PHOTOS_PER_SPACE`    | No       | Maximum photos per relationship space (default: 500)   |
| `EXPO_PUBLIC_ENABLE_ANALYTICS`        | No       | Enable analytics (default: false)                      |

### Production (.env for Supabase Cloud)

| Variable                        | Required | Description                                    |
| ------------------------------- | -------- | ---------------------------------------------- |
| `EXPO_PUBLIC_SUPABASE_URL`      | Yes      | Supabase project URL (https://xxx.supabase.co) |
| `EXPO_PUBLIC_SUPABASE_ANON_KEY` | Yes      | Production anon key (from Supabase dashboard)  |
