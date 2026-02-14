# Research & Technology Decisions

**Feature**: Us Core Product MVP  
**Date**: 2026-02-14  
**Status**: Phase 0 Complete

## Overview

This document consolidates research findings and rationale for all major technology decisions in the Us MVP. All technical unknowns from the planning phase have been resolved through this research.

## 1. Backend Platform Selection

### Decision

**Supabase** (full platform: PostgreSQL, Auth, Storage, Realtime)

### Rationale

1. **Integrated Security Model**: Row-level security (RLS) policies in PostgreSQL align perfectly with the privacy requirement that each relationship space must be completely isolated (FR-022). Every table can enforce `user_id` or `space_id` checks at the database level.

2. **Free Tier Sufficiency**: 500MB database, 1GB storage, 2GB bandwidth/month, 50K monthly active users supports MVP validation without upfront infrastructure costs.

3. **Unified Authentication**: Supabase Auth handles email/password registration (assumption in spec) with built-in JWT management, reducing custom auth code.

4. **Storage Integration**: Supabase Storage provides CDN, automatic image transformations, and shares the same RLS security model as the database, simplifying photo access control.

5. **Real-time Capabilities**: Built-in PostgreSQL change data capture enables live updates (e.g., partner sees new note delivery immediately) without custom WebSocket infrastructure.

6. **TypeScript-First**: Official `@supabase/supabase-js` client has excellent TypeScript support, matching our stack choice.

### Alternatives Considered

- **Firebase**: NoSQL data model less suitable for relational data (users ↔ spaces ↔ notes). Security rules syntax more complex for relationship isolation.
- **AWS (RDS + S3 + Cognito)**: More flexible but requires integrating multiple services. Higher operational complexity and no free tier at comparable scale.
- **Self-hosted PostgreSQL + MinIO**: Maximum control but MVP-inappropriate operational burden (monitoring, backups, scaling).

### Best Practices for This Project

1. **Row-Level Security Policies**: Define RLS policies for every table that ensure users can only access data from their relationship space:

   ```sql
   -- Example: notes table
   CREATE POLICY "Users can only see notes in their space"
   ON notes FOR SELECT
   USING (
     space_id IN (
       SELECT id FROM spaces WHERE user1_id = auth.uid() OR user2_id = auth.uid()
     )
   );
   ```

2. **Database Migrations**: Use Supabase CLI for version-controlled migrations (`supabase db diff`, `supabase migration new`). Track all schema changes in repo.

3. **Type Generation**: Use `supabase gen types typescript` to auto-generate TypeScript types from database schema, ensuring client-server type safety.

4. **Connection Pooling**: Supabase handles connection pooling automatically via PgBouncer. No custom pool management needed for MVP scale.

5. **Backup Strategy**: Supabase provides daily backups on paid tier. For MVP, export capability (FR-029) acts as user-driven backup mechanism.

---

## 2. Mobile Platform Selection

### Decision

**React Native with Expo**

### Rationale

1. **Single Codebase**: TypeScript codebase shared across iOS and Android reduces development time by ~60% compared to native development for both platforms.

2. **TypeScript Consistency**: Matches backend integration language (TypeScript 5.x per CLAUDE.md), enabling shared types and validation logic between client and Supabase.

3. **Expo Benefits**:
   - **Managed Build Workflow**: `eas build` handles native compilation without local Xcode/Android Studio setup
   - **OTA Updates**: Push non-native code updates without app store review for rapid iteration
   - **Standard Components**: Expo SDK includes camera, file picker, notifications, secure storage out-of-box

4. **Supabase Integration**: `@supabase/supabase-js` works seamlessly in React Native. Established patterns for auth state persistence and offline sync.

5. **Expo Router**: File-based routing with layout groups for clean auth/main app separation.

### Alternatives Considered

- **Native iOS/Android**: Maximum performance and platform integration, but 2x development effort and separate Swift/Kotlin codebases. Unjustified for MVP's UI complexity (~15 screens).
- **Flutter**: Strong performance but introduces Dart language (vs. TypeScript everywhere). Smaller package ecosystem than React Native for Supabase integration.
- **PWA**: Limited native capability access (especially push notifications on iOS). No app store presence reduces discoverability for relationship-focused app.

### Best Practices for This Project

1. **Project Structure (Expo Router)**:

   ```
   app/
   ├── _layout.tsx          # Root layout with providers
   ├── (auth)/              # Route group: auth screens
   │   ├── login.tsx
   │   └── onboarding.tsx
   └── (space)/             # Route group: main app
       ├── _layout.tsx      # Tab navigator
       ├── notes/
       ├── events/
       ├── memories/
       └── preferences/

   src/
   ├── components/          # Reusable UI
   ├── hooks/               # Custom hooks
   ├── services/            # Supabase calls
   ├── types/               # Generated + domain types
   └── utils/               # Helpers
   ```

2. **Authentication State**:

   ```typescript
   import { createClient } from '@supabase/supabase-js';
   import * as SecureStore from 'expo-secure-store';

   // Custom SecureStore adapter for Supabase
   const ExpoSecureStoreAdapter = {
     getItem: (key: string) => SecureStore.getItemAsync(key),
     setItem: (key: string, value: string) =>
       SecureStore.setItemAsync(key, value),
     removeItem: (key: string) => SecureStore.deleteItemAsync(key),
   };

   const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
     auth: {
       storage: ExpoSecureStoreAdapter,
       autoRefreshToken: true,
       persistSession: true,
     },
   });
   ```

3. **Offline-First Architecture**:
   - Use **React Query** for cache-first data fetching with automatic background sync
   - **AsyncStorage** for draft persistence (notes, events in progress)
   - Queue mutations (note delivery, photo upload) when offline, process when online

4. **Image Optimization**:
   - Use `expo-image-picker` with `quality: 0.8` to compress before upload
   - Leverage Supabase Storage transformations for thumbnails: `?width=300&quality=80`
   - Show upload progress via upload events

5. **Testing Strategy**:
   - **Jest + React Native Testing Library**: Unit tests for hooks, utils, component rendering
   - **Mock Supabase Client**: Use `jest.mock('@supabase/supabase-js')` for isolated tests
   - **Detox (E2E)**: Critical flows (create space, send note, upload photo)

---

## 3. Photo Storage Strategy

### Decision

**Supabase Storage** with client-side optimization and CDN delivery

### Rationale

1. **Integrated Access Control**: Storage buckets inherit RLS policies, ensuring photos are only accessible to users in the relationship space.

2. **CDN & Transformations**: Built-in CDN reduces latency. Automatic image transformations (`?width=X`) eliminate need for server-side processing.

3. **Free Tier Alignment**: 1GB storage accommodates ~200-300 high-quality photos (3-5MB typical JPEG). Sufficient for MVP validation before paid tier ($0.021/GB/month).

4. **Direct Upload**: React Native client can upload directly to Supabase Storage, reducing backend complexity.

### Photo Upload Flow

```typescript
// 1. Pick image with quality compression
const result = await ImagePicker.launchImageLibraryAsync({
  mediaTypes: ImagePicker.MediaTypeOptions.Images,
  quality: 0.8, // Compress to ~80% quality
  allowsEditing: true,
});

// 2. Upload to Supabase Storage
const { data, error } = await supabase.storage.from('memories').upload(
  `${spaceId}/${memoryId}.jpg`,
  {
    uri: result.uri,
    type: 'image/jpeg',
    name: `${memoryId}.jpg`,
  },
  {
    cacheControl: '3600',
    upsert: false,
  },
);

// 3. Get public URL with transformation
const {
  data: { publicUrl },
} = supabase.storage
  .from('memories')
  .getPublicUrl(`${spaceId}/${memoryId}.jpg`, {
    transform: { width: 800, quality: 85 },
  });
```

### Best Practices

1. **Size Limits**: Enforce 10MB client-side before upload (FR-014). Show friendly error if exceeded.
2. **Space Limits**: Track photo count per space (500 max per FR-017). Disable upload when approaching limit with gentle warning.
3. **Progressive Enhancement**: Show low-res thumbnail immediately, load high-res on tap.
4. **Failure Handling**: Use exponential backoff retry for failed uploads. Preserve failed upload in queue with visual indicator.
5. **EXIF Stripping**: Use `expo-image-manipulator` to strip location metadata before upload for privacy.

---

## 4. Offline Synchronization Strategy

### Decision

**Cache-first reads + queued writes** using React Query with AsyncStorage persistence

### Rationale

1. **User Experience**: Drafts never lost (FR-025). App remains functional during network interruptions.
2. **React Query**: Provides automatic background sync, cache invalidation, and optimistic updates with rollback.
3. **Constraint Satisfaction**: Meets "offline draft preservation" requirement without custom sync engine.

### Implementation Pattern

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Read with cache
const { data: notes } = useQuery({
  queryKey: ['notes', spaceId],
  queryFn: async () => {
    const { data, error } = await supabase
      .from('notes')
      .select('*')
      .eq('space_id', spaceId);
    if (error) throw error;
    return data;
  },
  staleTime: 30000, // Consider fresh for 30s
});

// Write with queue
const { mutate: sendNote } = useMutation({
  mutationFn: async (note) => {
    const { data, error } = await supabase.from('notes').insert(note);
    if (error) throw error;
    return data;
  },
  onError: async (error, variables) => {
    // Queue for retry if network issue
    if (error.message.includes('network')) {
      await AsyncStorage.setItem(
        `draft_${variables.id}`,
        JSON.stringify(variables),
      );
    }
  },
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['notes', spaceId] });
  },
});
```

### Draft Handling

- **Note Drafts**: Save to AsyncStorage on every text change (debounced 500ms)
- **Event Drafts**: Persist form state on unmount
- **Photo Uploads**: Queue failed uploads with metadata, retry on app foreground

---

## 5. Invitation Link Security

### Decision

**Database-backed tokens** with 7-day expiration, single-use enforcement

### Rationale

1. **Security**: Tokens stored in `invitations` table with cryptographically random IDs. Cannot be forged.
2. **Single-Use**: Database tracks redemption status. Accepting invitation sets `accepted_at` timestamp and invalidates token.
3. **Expiration**: 7 days balances security (FR-030) with real-world communication patterns (weekends, travel).

### Implementation

```typescript
// Generation (inviter)
const token = crypto.randomUUID();
await supabase.from('invitations').insert({
  id: token,
  space_id: pendingSpaceId,
  invited_by: userId,
  expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
});

const inviteLink = `us://invite/${token}`;

// Validation (invitee)
const { data: invitation, error } = await supabase
  .from('invitations')
  .select('*')
  .eq('id', token)
  .single();

if (!invitation) throw new Error('Invalid invitation');
if (invitation.accepted_at) throw new Error('Invitation already used');
if (new Date() > new Date(invitation.expires_at))
  throw new Error('Invitation expired');
```

### Best Practices

1. **Deep Linking**: Use Expo's `Linking` API to handle `us://invite/{token}` URLs from any channel (SMS, email, messaging apps).
2. **Revocation**: Inviter can set `revoked_at` timestamp to cancel pending invitation.
3. **Clear Messaging**: Show "This invitation has expired" with option to request new one if expired.

---

## 6. Push Notifications

### Decision

**Expo Push Notification Service (EPNS)** with server-side throttling via Supabase Edge Functions

### Rationale

1. **Simplicity**: EPNS abstracts APNs/FCM complexity. Handles token management and delivery.
2. **Privacy**: No third-party notification service (e.g., OneSignal) needed, keeping user data with Supabase.
3. **Calm Notifications**: Server-side throttling (30s delay + batching) aligns with calm notification philosophy (FR-018, FR-021).
4. **Cost**: Free for unlimited notifications.

### Implementation

```typescript
// Store push token in users table
await supabase
  .from('users')
  .update({ push_token: expoPushToken })
  .eq('id', userId);

// Send notification via Edge Function
await supabase.functions.invoke('send-notification', {
  body: {
    to: partnerPushToken,
    title: 'New Note',
    body: 'You have a new note',
    data: { noteId, spaceId },
  },
});
```

### Best Practices

1. **Permission Timing**: Request notification permission after login, not before (respects user choice).
2. **Foreground Handling**: Show subtle in-app indicator for notifications when app is open.
3. **Token Refresh**: Re-register token on app launch (OS can rotate tokens).
4. **Receipt Tracking**: Use Expo's receipt API to remove invalid tokens.

---

## 7. NativeWind 4.x for Styling

### Decision

**NativeWind v4** with Tailwind CSS for design system

### Rationale

1. **Consistency**: Tailwind utility classes provide consistent spacing, colors, typography across the app.
2. **Velocity**: No need to write custom StyleSheet.create for every component.
3. **Design Tokens**: `tailwind.config.js` serves as single source of truth for design decisions.
4. **Dark Mode**: Built-in support for `dark:` variant (though MVP may not need it immediately).

### Setup

```javascript
// tailwind.config.js
module.exports = {
  content: ['./app/**/*.{js,jsx,ts,tsx}', './src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#...',
        // Define Us-specific color palette
      },
    },
  },
};
```

```typescript
// app/_layout.tsx
import '../global.css';
```

### Best Practices

1. **Custom Components**: Wrap third-party components with `cssInterop()` to accept `className`.
2. **Calm Aesthetic**: Use muted colors, generous spacing, large touch targets (min 44px).
3. **Typography**: Define custom font scales in `tailwind.config.js` for letter-like note reading experience.

---

## 8. Testing Strategy

### Unit Testing

- **Framework**: Jest + React Native Testing Library
- **Coverage Target**: 80% for services, hooks, utilities
- **Mock Strategy**: Mock `@supabase/supabase-js` client, test business logic in isolation

### Integration Testing

- **Supabase Local**: Use `supabase start` to run local PostgreSQL for integration tests
- **Seed Data**: Test fixtures for users, spaces, notes with known states
- **RLS Testing**: Verify RLS policies block unauthorized access

### E2E Testing

- **Framework**: Detox (official React Native E2E)
- **Critical Paths**:
  - Create space + invite partner + accept invitation
  - Compose note + send + partner reads
  - Create event + partner responds
  - Upload photo + add caption + partner views
- **Devices**: Test on iOS simulator + Android emulator (different screen sizes)

### Manual Testing Checklist

- [ ] Network interruption during note send (airplane mode)
- [ ] Photo upload with poor connectivity
- [ ] Push notification delivery and tap handling
- [ ] Deep link handling from multiple apps (Messages, WhatsApp, Email)
- [ ] Account deletion flow with archive verification

---

## 9. Performance Benchmarks

### Targets

- **Screen Transitions**: <500ms (perception of instant)
- **Photo Upload**: <2s for 3MB typical photo on WiFi
- **Sync**: <1s to fetch latest notes/events when app opens
- **Animations**: 60fps (no jank on note composition, photo gallery swipe)

### Measurement Tools

- **React Native Performance Monitor**: Enable in debug mode for FPS tracking
- **Flipper**: Inspect network requests, AsyncStorage
- **Sentry Performance**: Track screen load times, network latency in production

### Optimization Techniques

1. **Memoization**: Use `React.memo`, `useMemo`, `useCallback` for expensive renders
2. **Lazy Loading**: Load photos on scroll with `FlashList` (faster than FlatList)
3. **Image Caching**: Use `expo-image` with disk cache for repeated photo views
4. **Bundle Splitting**: Lazy load screens with dynamic imports

---

## 10. Security Considerations

### Authentication

- **Session Management**: Supabase handles JWT refresh automatically
- **Secure Storage**: Tokens stored in `expo-secure-store` (hardware-backed encryption)
- **Logout**: Clear SecureStore + revoke Supabase session on signout

### Data Validation

- **Client-Side**: Validate inputs before API calls (max lengths, required fields)
- **Server-Side**: PostgreSQL constraints + RLS enforce data integrity
- **RLS Enforcement**: Every query filtered by authenticated user's space access

### Photo Privacy

- **Storage Bucket**: Private by default, requires authentication
- **RLS Policies**: Bucket policies check space membership before granting access
- **No Metadata Leaks**: Strip EXIF location data before upload using `expo-image-manipulator`

---

## 11. Deployment Strategy

### MVP Phase

- **Backend**: Supabase Cloud (free tier)
- **Mobile Distribution**: TestFlight (iOS) + Google Play Internal Testing (Android)
- **CI/CD**: GitHub Actions for linting, tests, Expo EAS build
- **Monitoring**: Sentry for error tracking, Supabase Dashboard for DB performance

### Scaling Plan

- **Database**: Upgrade to Supabase Pro when >500MB data (~5,000 active relationships)
- **Storage**: Upgrade when >1GB photos (~200-300 photos per space × 5 spaces)
- **CDN**: Supabase CDN included; no additional config needed

---

## Open Questions (None Remaining)

All technical unknowns resolved through clarifications and research. Ready to proceed to Phase 1 (design).

---

## References

- [Supabase Documentation](https://supabase.com/docs)
- [React Native Best Practices](https://reactnative.dev/docs/performance)
- [Expo Documentation](https://docs.expo.dev/)
- [React Query Offline Support](https://tanstack.com/query/latest/docs/react/guides/offline)
- [PostgreSQL Row-Level Security](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Expo Router Documentation](https://docs.expo.dev/router/introduction/)
- [NativeWind Documentation](https://www.nativewind.dev/)
