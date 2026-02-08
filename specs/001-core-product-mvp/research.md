# Research: Us Core Product MVP

**Date**: 2026-02-09
**Branch**: `001-core-product-mvp`

## 1. Project Structure (Expo Router)

**Decision**: Use Expo Router's file-based routing with `(auth)` and `(space)` route groups. Non-route code (components, services, hooks) lives outside `app/`.

**Rationale**: Route groups use parentheses so they don't appear in the URL path but allow separate layout trees. This is the canonical Expo Router pattern for auth vs. main app separation. Expo Router treats every file inside `app/` as a route, so non-route code must live outside.

**Alternatives considered**:
- Single flat `app/` directory — doesn't scale past 5-6 screens; makes auth separation harder
- `src/screens/` + React Navigation manual config — loses file-based routing benefits; more boilerplate
- Feature-based folders with screens and components together — mixes routing concerns with component concerns

## 2. Authentication Architecture

**Decision**: JWT with short-lived access token (15min, in memory) + long-lived refresh token (7 days, in `expo-secure-store`). React Context provider gates navigation. API client interceptor handles token refresh transparently.

**Rationale**:
- `expo-secure-store` uses iOS Keychain and Android Keystore (hardware-backed encryption), critical for a privacy-focused app. AsyncStorage stores data as unencrypted plain text — unacceptable for tokens.
- Access token in memory minimizes exposure window. Refresh token in SecureStore persists across app restarts securely.
- Context-based auth state integrates naturally with Expo Router's layout system.
- Interceptor pattern centralizes retry behavior, preventing every API call from needing manual token-refresh logic.

**Alternatives considered**:
- Store JWT in AsyncStorage — insecure, data is unencrypted on disk
- Single long-lived token — security risk, cannot revoke without invalidating all sessions
- MMKV for token storage — fast but not a secure keychain wrapper, doesn't use hardware-backed secure enclave
- Zustand/Redux for auth state — unnecessary dependency for a simple boolean + token state

**Notes**: SecureStore has a 2KB value limit per key (sufficient for JWTs). Not available on web — abstract behind interface if web companion planned later.

## 3. Backend Architecture (Express + TypeScript)

**Decision**: Routes/services/middleware pattern. Routes define HTTP endpoints, services contain business logic, middleware handles cross-cutting concerns (auth, validation, error handling).

**Rationale**: Clean separation of concerns. Routes are thin (parse request, call service, return response). Services are testable without HTTP. Middleware is composable and reusable.

**Structure**:
```
backend/src/
├── config/          # Database, auth, S3, notification config
├── middleware/       # authMiddleware, errorHandler, rateLimiter, validate
├── routes/          # auth.routes.ts, space.routes.ts, note.routes.ts, etc.
├── services/        # spaceService, noteService, eventService, etc.
├── utils/           # token generation, date formatting, etc.
└── app.ts           # Express app setup, middleware registration, route mounting
```

## 4. Prisma Schema Design Patterns

**Decision**: Use Prisma's enum types for status fields (state machines), soft deletes via `deletedAt` nullable DateTime, and application-layer enforcement for relationship constraints (max 2 members per space).

**Rationale**:
- Enums provide type-safe status fields and enforce valid state transitions at the database level.
- Soft deletes preserve data for the archive use case (departing partner's content remains visible).
- Prisma doesn't support CHECK constraints directly, so max-member-per-space is enforced in the service layer with a transaction.

**Key patterns**:
- `@@unique([spaceId, userId])` on SpaceMember prevents duplicate membership
- `@@index([spaceId, status, createdAt])` on Note for efficient listing
- `deletedAt DateTime?` on User with Prisma middleware to filter soft-deleted records by default

## 5. Photo Upload Strategy

**Decision**: Presigned S3 URLs. Client picks image, compresses with `expo-image-manipulator`, requests a presigned URL from the backend, uploads directly to S3, then confirms with the backend.

**Rationale**:
- Client uploads directly to S3, bypassing the backend for heavy data transfer. Reduces backend load and avoids request body size limits.
- Client-side compression (resize to max 1920px, JPEG quality 0.7) reduces typical 5-8MB phone photos to 300-600KB.
- EXIF stripping critical for privacy — prevents leaking GPS coordinates and device metadata.
- `FileSystem.uploadAsync()` from `expo-file-system` provides progress tracking (unlike `fetch`).

**Alternatives considered**:
- Upload through backend (multipart) — backend becomes bottleneck for large files
- Cloudinary/imgix for processing — adds third-party data processor, against privacy principles
- Base64 encoding in API request — inflates payload by 33%, hits body size limits

**Enforcement**: 10MB cap enforced at three points: (1) client after compression, (2) presigned URL content-length-range condition, (3) S3 bucket policy.

## 6. Push Notifications

**Decision**: Expo Push Notification service (EPNS) via `expo-server-sdk` on the backend. Server-side batching/throttling with 30-second delay before sending.

**Rationale**:
- EPNS abstracts APNs/FCM complexity. Free and handles token translation, delivery, and receipt tracking.
- Server-side throttling aligns with the "calm notification" philosophy — backend knows the full event stream and can batch intelligently.
- Request permissions only after login (not before), respecting user choice.
- Foreground notifications shown as subtle in-app indicators, not system alerts (maintains calm UX).

**Key implementation**:
- Token re-registration on every app launch (OS can rotate tokens)
- Receipt polling via `getPushNotificationReceiptsAsync()` — remove invalid tokens
- Single Android notification channel ("Us Updates") with default priority
- Expo SDK 52+ requires `projectId` parameter for `getExpoPushTokenAsync()`

**Alternatives considered**:
- Firebase Cloud Messaging directly — requires development build, not compatible with Expo Go for dev
- OneSignal — third-party data processor, against privacy minimization
- Client-side batching — client doesn't have full event picture

## 7. Offline Draft Storage

**Decision**: AsyncStorage with debounced auto-save (every 2 seconds of inactivity). Write-local-first, sync on explicit send. No server-side draft storage.

**Rationale**:
- Drafts are not security-sensitive (user's own unfinished content). AsyncStorage's simplicity is appropriate.
- FR-025 requires local preservation when connectivity is lost. Write-local-first ensures zero content loss.
- No sync conflicts possible — drafts belong to a single author and are not collaboratively edited.
- No complex sync queue needed — drafts transition to "sent" (one-way operation).

**Custom hook**: `useDraft(type, id?)` — loads draft, provides `updateDraft()`, `saveDraft()`, `sendDraft()` and status flags (`isSaving`, `isSending`, `isOffline`).

**Alternatives considered**:
- MMKV — faster I/O but adds native dependency, unnecessary for expected draft volume
- WatermelonDB/SQLite — overkill for single-user key-value draft storage
- Server-side draft persistence — adds API complexity, requires connectivity to save, creates sync conflicts

**Notes**: AsyncStorage has 6MB limit on Android. Do not store images — reference by local file URI only.

## 8. NativeWind 4.x Setup

**Decision**: NativeWind v4 with Metro CSS interop, `nativewind/babel` preset, and `tailwind.config.js` as the design token source.

**Rationale**: NativeWind v4 uses a CSS interop architecture (not StyleSheet.create). Supports CSS variables, media queries, and animations natively. Tailwind utility classes enable rapid, consistent UI development.

**Setup requirements**:
1. Install: `npx expo install nativewind tailwindcss react-native-reanimated react-native-safe-area-context`
2. `tailwind.config.js` with content paths for `app/` and `components/`
3. `global.css` with Tailwind directives, imported in root `_layout.tsx`
4. `metro.config.js` with `withNativeWind(config, { input: './global.css' })`
5. `nativewind-env.d.ts` for TypeScript className support

**Known issues**:
- Custom components need `cssInterop()` wrapping to accept `className`
- Dark mode: import `useColorScheme` from `nativewind`, not `react-native`
- Hot reload may miss `tailwind.config.js` changes — restart Metro with `--clear`
- Layout transitions may flicker — use Reanimated layout animations instead

**Alternatives considered**:
- StyleSheet.create — verbose, no design system integration
- Tamagui — heavier learning curve, larger bundle, better suited for web+native
- Unistyles — promising but smaller community
- Gluestack/NativeBase — opinionated component libraries, harder to achieve custom calm aesthetic

## 9. Security Hardening

**Decision**: Helmet, CORS, express-rate-limit, input validation with zod, parameterized queries (Prisma handles this), HTTPS everywhere.

**Key measures**:
- `helmet()` — sets security headers (CSP, HSTS, etc.)
- CORS — restrict to mobile app origin only; no wildcard
- Rate limiting — `/auth/login`: 5 attempts per 15 min per IP; general API: 100 requests per min per user
- Input validation — zod schemas for all request bodies, validated in middleware
- Parameterized queries — Prisma prevents SQL injection by default
- Password hashing — bcrypt with cost factor 12

## 10. Database Backup & Durability

**Decision**: PostgreSQL with WAL archiving, daily automated backups with point-in-time recovery (PITR), S3 versioning for photos.

**Rationale**: Zero content loss requirement (FR-031). WAL archiving enables recovery to any point in time. S3 versioning prevents accidental photo deletion. Daily full backups + continuous WAL streaming provides comprehensive protection.

**Implementation**: Use managed PostgreSQL (e.g., AWS RDS, Supabase) which provides automated backups and PITR out of the box. For S3, enable versioning on the photos bucket.
