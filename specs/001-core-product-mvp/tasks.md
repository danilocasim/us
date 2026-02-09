# Tasks: Us Core Product MVP

**Input**: Design documents from `/specs/001-core-product-mvp/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/api.md, quickstart.md

**Tests**: Tests are NOT explicitly requested in the feature specification, so test tasks are omitted per workflow rules.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `- [ ] [ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Mobile + Web + API architecture:
- **Backend API**: `backend/src/`
- **Mobile App**: `mobile/` (Expo Router + React Native)
- **Web** (future): `web/src/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure per plan.md decisions

- [X] T001 Create monorepo structure with backend/, mobile/, and infra/ directories at repository root
- [X] T002 Initialize backend Node.js/TypeScript project with Express and Prisma dependencies in backend/
- [X] T003 Initialize mobile Expo/TypeScript project with Expo Router and NativeWind in mobile/
- [X] T004 [P] Configure ESLint and Prettier for backend/ with TypeScript rules
- [X] T005 [P] Configure ESLint and Prettier for mobile/ with React/TypeScript rules
- [X] T006 [P] Setup Docker Compose for local PostgreSQL 16 and MinIO in infra/docker/
- [X] T007 Create backend/.env.example with all required environment variables per quickstart.md
- [X] T008 Create mobile/.env.example with API_URL configuration per quickstart.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Database & ORM

- [X] T009 Define Prisma schema with User, Space, SpaceMember entities in backend/prisma/schema.prisma per data-model.md
- [X] T010 [P] Add Invitation entity with token, expiresAt, status to Prisma schema
- [X] T011 [P] Add Note entity with title, body, status, deliveredAt to Prisma schema
- [X] T012 [P] Add Event and EventResponse entities to Prisma schema
- [X] T013 [P] Add Preference entity with category, content, isActive to Prisma schema
- [X] T014 [P] Add Memory and Reflection entities to Prisma schema
- [X] T015 [P] Add Notification entity with type, referenceId, isRead to Prisma schema
- [X] T016 Add indexes per data-model.md: User.email, SpaceMember(spaceId,userId), Invitation.token, etc.
- [X] T017 Generate Prisma client and create initial migration in backend/

### Authentication Infrastructure

- [ ] T018 Create JWT utilities for access/refresh token generation in backend/src/utils/jwt.ts
- [ ] T019 Implement bcrypt password hashing utilities in backend/src/utils/password.ts
- [ ] T020 Create authMiddleware for JWT verification in backend/src/middleware/auth.ts
- [ ] T021 Create token refresh interceptor pattern for API client in mobile/src/services/api-client.ts
- [ ] T022 [P] Create SecureStore wrapper for token storage in mobile/src/utils/secure-storage.ts
- [ ] T023 [P] Create AuthContext provider for mobile app in mobile/src/contexts/AuthContext.tsx

### API Infrastructure

- [ ] T024 Setup Express app with helmet, CORS, and JSON body parser in backend/src/app.ts
- [ ] T025 [P] Create error handling middleware in backend/src/middleware/error-handler.ts
- [ ] T026 [P] Create rate limiting middleware using express-rate-limit in backend/src/middleware/rate-limiter.ts
- [ ] T027 [P] Create zod validation middleware in backend/src/middleware/validate.ts
- [ ] T028 Setup database connection with connection pooling in backend/src/config/database.ts
- [ ] T029 [P] Create S3 client configuration for presigned URLs in backend/src/config/s3.ts
- [ ] T030 [P] Create Expo Push Notification service wrapper in backend/src/config/expo-push.ts

### Mobile App Infrastructure

- [ ] T031 Setup Expo Router with (auth) and (space) route groups in mobile/app/_layout.tsx
- [ ] T032 Configure NativeWind v4 with tailwind.config.js and global.css in mobile/
- [ ] T033 Create base API client with fetch wrapper and error handling in mobile/src/services/api-client.ts
- [ ] T034 [P] Create AsyncStorage wrapper for draft storage with useDraft hook in mobile/src/hooks/useDraft.ts
- [ ] T035 [P] Create offline detection utility with NetInfo in mobile/src/utils/network.ts
- [ ] T036 Configure react-native-reanimated and safe-area-context in mobile/app.json

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Create a Private Relationship Space (Priority: P1) 🎯 MVP

**Goal**: Enable two people to create a private relationship space through explicit mutual consent. One user creates a pending space and generates an invitation link. The second user accepts, activating the space for both.

**Independent Test**: User A registers, creates space, generates invitation link. User B registers, opens invitation link, accepts. Both users see their active shared space with partner information.

### Implementation for User Story 1

#### Backend - Space Creation & Management

- [ ] T037 [P] [US1] Create User model service in backend/src/services/user-service.ts with findById, findByEmail methods
- [ ] T038 [P] [US1] Create Space model service in backend/src/services/space-service.ts with createPendingSpace, getByUserId methods
- [ ] T039 [US1] Implement Invitation service in backend/src/services/invitation-service.ts with generateInvitation, validateToken, markAsConsumed
- [ ] T040 [US1] Implement SpaceMember service in backend/src/services/space-member-service.ts with addMember, enforceMaxTwoMembers constraint
- [ ] T041 [US1] Implement notification service for partner_joined events in backend/src/services/notification-service.ts

#### Backend - Auth Endpoints

- [ ] T042 [P] [US1] Implement POST /auth/register endpoint with email/password validation in backend/src/routes/auth.routes.ts
- [ ] T043 [P] [US1] Implement POST /auth/login endpoint with credential verification in backend/src/routes/auth.routes.ts
- [ ] T044 [P] [US1] Implement POST /auth/refresh endpoint with refresh token rotation in backend/src/routes/auth.routes.ts
- [ ] T045 [US1] Implement GET /users/me endpoint in backend/src/routes/user.routes.ts

#### Backend - Space & Invitation Endpoints

- [ ] T046 [US1] Implement POST /spaces endpoint to create pending space in backend/src/routes/space.routes.ts
- [ ] T047 [US1] Implement GET /spaces/current endpoint to retrieve user's space in backend/src/routes/space.routes.ts
- [ ] T048 [US1] Implement DELETE /spaces/current endpoint for leaving space in backend/src/routes/space.routes.ts
- [ ] T049 [US1] Implement GET /invitations/current endpoint in backend/src/routes/invitation.routes.ts
- [ ] T050 [US1] Implement POST /invitations/regenerate endpoint in backend/src/routes/invitation.routes.ts
- [ ] T051 [US1] Implement DELETE /invitations/current endpoint for revoking invitation in backend/src/routes/invitation.routes.ts
- [ ] T052 [US1] Implement GET /invitations/accept/:token endpoint (public - no auth) in backend/src/routes/invitation.routes.ts
- [ ] T053 [US1] Implement POST /invitations/accept/:token endpoint with space activation logic in backend/src/routes/invitation.routes.ts
- [ ] T054 [US1] Implement POST /invitations/decline/:token endpoint with space archival in backend/src/routes/invitation.routes.ts

#### Mobile - Authentication Screens

- [ ] T055 [P] [US1] Create registration screen in mobile/app/(auth)/register.tsx with email/password form and validation
- [ ] T056 [P] [US1] Create login screen in mobile/app/(auth)/login.tsx with credential input and error handling
- [ ] T057 [US1] Create auth layout with conditional routing based on AuthContext in mobile/app/(auth)/_layout.tsx
- [ ] T058 [US1] Implement token persistence on login/register using SecureStore in AuthContext

#### Mobile - Space Creation Flow

- [ ] T059 [US1] Create empty state screen for users without a space in mobile/app/(space)/index.tsx
- [ ] T060 [US1] Create space creation screen with "Create Space" action in mobile/app/(space)/create-space.tsx
- [ ] T061 [US1] Create invitation display screen showing shareable link and QR code in mobile/app/(space)/invitation.tsx
- [ ] T062 [US1] Implement share invitation link functionality using Expo Sharing in mobile invitation screen

#### Mobile - Invitation Acceptance Flow

- [ ] T063 [US1] Create invitation preview screen showing inviter name and consent message in mobile/app/invite/[token].tsx
- [ ] T064 [US1] Implement invitation acceptance flow with API call and space activation in mobile invite screen
- [ ] T065 [US1] Implement invitation decline flow with confirmation dialog in mobile invite screen
- [ ] T066 [US1] Add deep linking configuration for invitation URLs in mobile/app.json

#### Mobile - Active Space Display

- [ ] T067 [US1] Create active space home screen showing partner info and content tabs in mobile/app/(space)/home.tsx
- [ ] T068 [US1] Add space status badge (pending/active/archived) to space home screen
- [ ] T069 [US1] Implement leave space action with confirmation dialog and archive warning in space settings

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently. Two users can establish a mutual relationship space.

---

## Phase 4: User Story 2 - Write and Deliver a Note (Priority: P2)

**Goal**: Enable users to compose intentional notes, save them as drafts, and deliver them to their partner. Delivered notes are permanent and presented as letter-like content, not chat messages.

**Independent Test**: User A composes a note with title and body, saves as draft, edits it, then delivers it. User B opens the space and sees the note in a reading-focused format. User B marks it as read. User A attempts to edit delivered note and is prevented.

### Implementation for User Story 2

#### Backend - Note Service & Endpoints

- [ ] T070 [P] [US2] Create Note service in backend/src/services/note-service.ts with createDraft, updateDraft, deliverNote, listNotes methods
- [ ] T071 [US2] Implement immutability enforcement in Note service (prevent edits after delivery)
- [ ] T072 [US2] Implement notification dispatch for note_delivered events in Note service
- [ ] T073 [US2] Implement GET /spaces/current/notes endpoint with pagination in backend/src/routes/note.routes.ts
- [ ] T074 [US2] Implement GET /spaces/current/notes/drafts endpoint in backend/src/routes/note.routes.ts
- [ ] T075 [US2] Implement POST /spaces/current/notes endpoint with deliver flag in backend/src/routes/note.routes.ts
- [ ] T076 [US2] Implement PATCH /spaces/current/notes/:id endpoint (drafts only) in backend/src/routes/note.routes.ts
- [ ] T077 [US2] Implement POST /spaces/current/notes/:id/deliver endpoint in backend/src/routes/note.routes.ts
- [ ] T078 [US2] Implement DELETE /spaces/current/notes/:id endpoint (drafts only) in backend/src/routes/note.routes.ts
- [ ] T079 [US2] Implement POST /spaces/current/notes/:id/read endpoint for read receipts in backend/src/routes/note.routes.ts

#### Mobile - Note Composition

- [ ] T080 [US2] Create note list screen showing delivered notes in mobile/app/(space)/notes/index.tsx
- [ ] T081 [US2] Create note composition screen with title and body fields in mobile/app/(space)/notes/compose.tsx
- [ ] T082 [US2] Implement draft auto-save with useDraft hook (2-second debounce) in note composition screen
- [ ] T083 [US2] Create draft list screen showing user's unsent notes in mobile/app/(space)/notes/drafts.tsx
- [ ] T084 [US2] Implement send note action with confirmation dialog in composition screen
- [ ] T085 [US2] Implement discard draft action with confirmation in composition screen

#### Mobile - Note Reading Experience

- [ ] T086 [US2] Create note detail screen with letter-like reading format (not chat bubbles) in mobile/app/(space)/notes/[id].tsx
- [ ] T087 [US2] Implement read receipt tracking when partner opens note
- [ ] T088 [US2] Add visual indicator for read/unread status on note list
- [ ] T089 [US2] Display author name and delivery timestamp on note detail screen

#### Mobile - Offline Draft Support

- [ ] T090 [US2] Implement offline draft storage in AsyncStorage with conflict resolution
- [ ] T091 [US2] Add sync queue for drafts created/edited offline to be sent when online
- [ ] T092 [US2] Display offline indicator on composition screen when connectivity is lost
- [ ] T093 [US2] Show pending sync status for drafts awaiting upload

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently. Users can exchange permanent, intentional notes.

---

## Phase 5: User Story 3 - Propose and Respond to an Event (Priority: P3)

**Goal**: Enable users to propose shared events/plans with description, date, and optional location. Partners can agree, decline, or suggest preferences. Proposals become confirmed events when agreed upon.

**Independent Test**: User A creates event proposal with title, description, date. User B views proposal and responds with agreement. Both users see confirmed event. User A creates another proposal, User B declines with no pressure language. User B creates proposal with preference message, User A views and updates the proposal.

### Implementation for User Story 3

#### Backend - Event Service & Endpoints

- [ ] T094 [P] [US3] Create Event service in backend/src/services/event-service.ts with createProposal, respondToEvent, updateEvent methods
- [ ] T095 [US3] Create EventResponse service in backend/src/services/event-response-service.ts with recordResponse, getResponseHistory methods
- [ ] T096 [US3] Implement notification dispatch for event_proposed and event_responded events in Event service
- [ ] T097 [US3] Implement GET /spaces/current/events endpoint with status filter in backend/src/routes/event.routes.ts
- [ ] T098 [US3] Implement POST /spaces/current/events endpoint for creating proposals in backend/src/routes/event.routes.ts
- [ ] T099 [US3] Implement PATCH /spaces/current/events/:id endpoint (proposer only, proposed/modified status only) in backend/src/routes/event.routes.ts
- [ ] T100 [US3] Implement POST /spaces/current/events/:id/respond endpoint with agree/decline/preference types in backend/src/routes/event.routes.ts

#### Mobile - Event Proposal Creation

- [ ] T101 [US3] Create event list screen with tabs for proposed/agreed/all events in mobile/app/(space)/events/index.tsx
- [ ] T102 [US3] Create event creation screen with title, description, date picker, location fields in mobile/app/(space)/events/create.tsx
- [ ] T103 [US3] Implement date/time picker using @react-native-community/datetimepicker in event creation screen
- [ ] T104 [US3] Add optional location field with text input (no map integration in MVP) in event creation screen
- [ ] T105 [US3] Implement send proposal action with validation in event creation screen

#### Mobile - Event Response Interface

- [ ] T106 [US3] Create event detail screen showing proposal details and response options in mobile/app/(space)/events/[id].tsx
- [ ] T107 [US3] Implement agree response action with immediate status update in event detail screen
- [ ] T108 [US3] Implement decline response action with gentle, non-pressure language in event detail screen
- [ ] T109 [US3] Implement preference response with optional text message in event detail screen
- [ ] T110 [US3] Display response history with timestamps and messages in event detail screen

#### Mobile - Confirmed Events Display

- [ ] T111 [US3] Create confirmed events view showing agreed-upon plans in mobile/app/(space)/events/confirmed.tsx
- [ ] T112 [US3] Add upcoming events section sorted by eventDate on space home screen
- [ ] T113 [US3] Display event status badge (proposed/agreed/declined/modified) on event list items
- [ ] T114 [US3] Implement event update flow for proposer when status is proposed or modified

**Checkpoint**: All core communication features (spaces, notes, events) are now functional and independently testable.

---

## Phase 6: User Story 4 - Share Preferences (Priority: P4)

**Goal**: Enable users to express preferences (desires, moods, boundaries) in a low-pressure format. Partners can view preferences but have no obligation to respond. Updates are silent (no partner notification).

**Independent Test**: User A creates preference with category "desire" and content. User B views User A's preferences in their profile. User A updates preference content silently. User B sees updated content without notification. User A removes preference. User B no longer sees it.

### Implementation for User Story 4

#### Backend - Preference Service & Endpoints

- [ ] T115 [P] [US4] Create Preference service in backend/src/services/preference-service.ts with create, update, delete, listActive methods
- [ ] T116 [US4] Implement silent update logic (no notifications on preference changes) in Preference service
- [ ] T117 [US4] Implement GET /spaces/current/preferences endpoint with authorId filter in backend/src/routes/preference.routes.ts
- [ ] T118 [US4] Implement POST /spaces/current/preferences endpoint for creating preferences in backend/src/routes/preference.routes.ts
- [ ] T119 [US4] Implement PATCH /spaces/current/preferences/:id endpoint (author only) in backend/src/routes/preference.routes.ts
- [ ] T120 [US4] Implement DELETE /spaces/current/preferences/:id endpoint (soft delete via isActive) in backend/src/routes/preference.routes.ts

#### Mobile - Preference Management

- [ ] T121 [US4] Create preference list screen showing active preferences grouped by author in mobile/app/(space)/preferences/index.tsx
- [ ] T122 [US4] Create preference creation screen with category picker (desire/mood/boundary) in mobile/app/(space)/preferences/create.tsx
- [ ] T123 [US4] Implement category selection UI with clear icons and gentle descriptions
- [ ] T124 [US4] Add content text area with max 500 character limit and character counter
- [ ] T125 [US4] Create preference edit screen for updating content (author only) in mobile/app/(space)/preferences/edit/[id].tsx

#### Mobile - Preference Display

- [ ] T126 [US4] Create partner preferences view showing their current preferences in mobile/app/(space)/preferences/partner.tsx
- [ ] T127 [US4] Display preferences with category badges and gentle formatting (no pressure indicators)
- [ ] T128 [US4] Implement remove preference action with confirmation (author only)
- [ ] T129 [US4] Add "no preferences yet" empty state with calm messaging
- [ ] T130 [US4] Add preference count badge to preferences tab on space home screen

**Checkpoint**: Users can now express and view low-pressure preferences without obligation dynamics.

---

## Phase 7: User Story 5 - Capture and Curate Memories (Priority: P5)

**Goal**: Enable users to upload photos with contextual information (caption, date) to create curated memories. Both partners can add reflections to any memory. Presentation is album-like, not feed-like. Individual curation is encouraged over bulk uploads.

**Independent Test**: User A picks photo from library, compresses it, adds caption and memory date, uploads to create memory. User B views memory in album format and adds reflection. Both users see photo with both reflections. User A attempts bulk upload and experiences friction (must add context per photo).

### Implementation for User Story 5

#### Backend - Memory & Photo Management

- [ ] T131 [P] [US5] Create Memory service in backend/src/services/memory-service.ts with createMemory, listMemories, addReflection methods
- [ ] T132 [P] [US5] Create presigned URL generation utility for S3 uploads in backend/src/services/photo-upload-service.ts
- [ ] T133 [US5] Implement photo metadata enforcement (requires caption OR memoryDate minimum) in Memory service
- [ ] T134 [US5] Implement notification dispatch for memory_added events in Memory service
- [ ] T135 [US5] Implement GET /spaces/current/memories endpoint with pagination in backend/src/routes/memory.routes.ts
- [ ] T136 [US5] Implement POST /spaces/current/memories/upload-url endpoint for presigned URLs in backend/src/routes/memory.routes.ts
- [ ] T137 [US5] Implement POST /spaces/current/memories endpoint to create memory after upload in backend/src/routes/memory.routes.ts
- [ ] T138 [US5] Implement POST /spaces/current/memories/:id/reflections endpoint in backend/src/routes/memory.routes.ts

#### Mobile - Photo Upload Flow

- [ ] T139 [US5] Create memory list screen with album-style grid layout in mobile/app/(space)/memories/index.tsx
- [ ] T140 [US5] Create memory upload screen with image picker using expo-image-picker in mobile/app/(space)/memories/upload.tsx
- [ ] T141 [US5] Implement client-side image compression using expo-image-manipulator (max 1920px, quality 0.7)
- [ ] T142 [US5] Implement EXIF data stripping for privacy before upload
- [ ] T143 [US5] Implement presigned URL request and direct S3 upload with FileSystem.uploadAsync
- [ ] T144 [US5] Add upload progress indicator with percentage and cancel option
- [ ] T145 [US5] Implement 10MB file size check at client before requesting presigned URL

#### Mobile - Memory Contextualization

- [ ] T146 [US5] Create memory context screen for adding caption and date after photo selection in mobile memory upload flow
- [ ] T147 [US5] Implement date picker for memoryDate (optional, defaults to upload date) in memory context screen
- [ ] T148 [US5] Add caption text input with 500 character limit and placeholder guidance
- [ ] T149 [US5] Enforce "caption OR memoryDate required" validation before allowing upload
- [ ] T150 [US5] Show friction message when user tries to upload without context

#### Mobile - Memory Viewing & Reflection

- [ ] T151 [US5] Create memory detail screen showing full photo with caption and date in mobile/app/(space)/memories/[id].tsx
- [ ] T152 [US5] Display uploader name and creation timestamp on memory detail screen
- [ ] T153 [US5] Create reflection list section showing all reflections with author names below photo
- [ ] T154 [US5] Create add reflection interface with 1000 character text area in memory detail screen
- [ ] T155 [US5] Implement submit reflection action with immediate local update
- [ ] T156 [US5] Add empty state for memories with calm "no memories yet" messaging

**Checkpoint**: All five core user stories are now complete and independently testable. The MVP feature set is fully functional.

---

## Phase 8: User Story 6 - Receive Meaningful Notifications (Priority: P6)

**Goal**: Implement restrained, care-justified push notifications for meaningful events only. Support batching/throttling to prevent overwhelming users. Respect notification preferences without dark patterns.

**Independent Test**: User A delivers note to User B. User B (with app closed) receives single calm notification. User B opens app and sees note. User A creates three events rapidly. User B receives batched notification, not three separate alerts. User B disables notifications in settings. User A sends note. User B receives no notification. No re-enablement prompts appear.

### Implementation for User Story 6

#### Backend - Notification Service

- [ ] T157 [US6] Enhance notification service with Expo Push Notification client initialization in backend/src/services/notification-service.ts
- [ ] T158 [US6] Implement notification batching logic (30-second delay, group by recipient) in notification service
- [ ] T159 [US6] Implement notification throttling (max 5 notifications per hour per user) in notification service
- [ ] T160 [US6] Create notification queue processor with scheduled job runner in backend/src/services/notification-queue.ts
- [ ] T161 [US6] Implement receipt polling to remove invalid push tokens using getPushNotificationReceiptsAsync
- [ ] T162 [US6] Add notification preference check before dispatching push notifications

#### Backend - Notification Endpoints

- [ ] T163 [US6] Implement PUT /users/me/push-token endpoint for token registration in backend/src/routes/user.routes.ts
- [ ] T164 [US6] Implement GET /notifications endpoint with unreadOnly filter in backend/src/routes/notification.routes.ts
- [ ] T165 [US6] Implement POST /notifications/read endpoint for bulk mark as read in backend/src/routes/notification.routes.ts
- [ ] T166 [US6] Add PATCH /users/me endpoint support for notificationsEnabled toggle

#### Mobile - Push Notification Setup

- [ ] T167 [US6] Request push notification permissions after login (not before) in mobile AuthContext
- [ ] T168 [US6] Register Expo push token on app launch using getExpoPushTokenAsync in mobile/src/utils/push-notifications.ts
- [ ] T169 [US6] Implement token re-registration on every app launch to handle OS token rotation
- [ ] T170 [US6] Create push notification event listener for foreground notifications using expo-notifications
- [ ] T171 [US6] Configure Android notification channel with default priority and calm sound

#### Mobile - Notification Display

- [ ] T172 [US6] Create notification list screen showing recent notifications in mobile/app/(space)/notifications/index.tsx
- [ ] T173 [US6] Implement foreground notification display as subtle in-app banner (not system alert)
- [ ] T174 [US6] Add notification badge count to space home tab bar
- [ ] T175 [US6] Implement notification tap handling to navigate to referenced content (note/event/memory)
- [ ] T176 [US6] Create notification settings screen with global toggle in mobile/app/(space)/settings/notifications.tsx

#### Notification Content & Restraint

- [ ] T177 [US6] Create calm notification message templates for each event type in backend/src/utils/notification-templates.ts
- [ ] T178 [US6] Verify zero engagement patterns: no streaks, no "come back" messages, no gamification in templates
- [ ] T179 [US6] Implement full respect for notification disabled state with no re-enablement prompts
- [ ] T180 [US6] Add notification preferences explanation screen with clear consent language

**Checkpoint**: Complete notification system with restrained, care-justified interruptions. All six user stories fully implemented.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories, security hardening, and deployment readiness

### Security & Privacy

- [ ] T181 [P] Implement rate limiting on all backend routes per research.md (5/15min on auth, 100/min general)
- [ ] T182 [P] Add zod validation schemas for all API request bodies in backend/src/schemas/
- [ ] T183 [P] Implement soft delete middleware for Prisma to filter deletedAt records globally
- [ ] T184 [P] Configure CORS to restrict to mobile app origin only (no wildcard) in backend
- [ ] T185 [P] Add security headers with helmet configuration in backend
- [ ] T186 Enable PostgreSQL WAL archiving for point-in-time recovery per quickstart.md
- [ ] T187 Enable S3 bucket versioning for photos to prevent accidental deletion

### User Account Management

- [ ] T188 [P] Implement DELETE /users/me endpoint with soft delete and space archival in backend/src/routes/user.routes.ts
- [ ] T189 [P] Implement POST /spaces/export endpoint generating JSON export with presigned URL in backend/src/routes/space.routes.ts
- [ ] T190 Implement partner_left notification dispatch when user deletes account or leaves space
- [ ] T191 Create account deletion confirmation screen with archive consequences warning in mobile/app/(space)/settings/delete-account.tsx
- [ ] T192 Create space export screen with download action in mobile/app/(space)/settings/export.tsx

### Error Handling & Logging

- [ ] T193 [P] Implement standardized error response format per contracts/api.md in backend error handler
- [ ] T194 [P] Add structured logging with Winston or Pino for backend operations in backend/src/config/logger.ts
- [ ] T195 [P] Implement Sentry error tracking for backend exceptions in backend
- [ ] T196 [P] Implement Sentry error tracking for mobile crashes in mobile
- [ ] T197 Add user-friendly error messages for common failures (network, validation, auth) in mobile

### Performance & Optimization

- [ ] T198 [P] Implement cursor-based pagination for all list endpoints (notes, events, memories, notifications)
- [ ] T199 [P] Add database query optimization with Prisma includeAll() review and select pruning
- [ ] T200 [P] Implement image caching with expo-image for mobile app
- [ ] T201 [P] Add React Query for API request caching and optimistic updates in mobile
- [ ] T202 Test API response time p95 < 500ms per plan.md performance goals
- [ ] T203 Test photo upload time < 2s for 5MB compressed images per plan.md performance goals

### User Experience Polish

- [ ] T204 [P] Create onboarding flow explaining the product purpose and consent model in mobile/app/(auth)/onboarding.tsx
- [ ] T205 [P] Add loading states and skeleton screens for all async operations in mobile
- [ ] T206 [P] Implement pull-to-refresh on all list screens (notes, events, memories, notifications)
- [ ] T207 [P] Add empty states with calm, helpful messaging for all content types
- [ ] T208 [P] Implement haptic feedback for key actions (send note, agree to event) using expo-haptics
- [ ] T209 Create app icon and splash screen with branding in mobile/assets/

### Documentation & Deployment

- [ ] T210 [P] Create API documentation from OpenAPI/Swagger schema in backend/docs/
- [ ] T211 [P] Write deployment guide for backend (AWS/Heroku/Railway) in backend/README.md
- [ ] T212 [P] Write mobile build and submission guide for iOS/Android in mobile/README.md
- [ ] T213 [P] Document environment variable configuration for production in quickstart.md
- [ ] T214 Validate quickstart.md setup instructions with fresh environment
- [ ] T215 Create runbook for common operations (backup/restore, token refresh, notification debugging) in docs/

### Constitution Compliance Verification

- [ ] T216 Audit notification system for engagement patterns (Article VI compliance check)
- [ ] T217 Audit data export functionality for both partners (Article III compliance check)
- [ ] T218 Audit invitation consent flow for explicit approval requirement (Article II compliance check)
- [ ] T219 Verify no dark patterns exist anywhere in the UX (Article VI compliance check)
- [ ] T220 Verify permanence of delivered notes (Article IV compliance check)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-8)**: All depend on Foundational phase completion
  - US1 (Space creation): Can start immediately after Foundational
  - US2 (Notes): Can start immediately after Foundational (no dependency on US1 infrastructure, but requires active space to use)
  - US3 (Events): Can start immediately after Foundational (no dependency on US1/US2)
  - US4 (Preferences): Can start immediately after Foundational (no dependency on prior stories)
  - US5 (Memories): Can start immediately after Foundational (no dependency on prior stories)
  - US6 (Notifications): Depends on US1-US5 being complete (integrates with all event types)
- **Polish (Phase 9)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Foundation only - no dependencies on other stories
- **User Story 2 (P2)**: Foundation only - technically independent but requires active space from US1 for actual use
- **User Story 3 (P3)**: Foundation only - technically independent but requires active space from US1 for actual use
- **User Story 4 (P4)**: Foundation only - technically independent but requires active space from US1 for actual use
- **User Story 5 (P5)**: Foundation only - technically independent but requires active space from US1 for actual use
- **User Story 6 (P6)**: Depends on US1-US5 completion - must integrate with all event types

### Within Each User Story

- Backend services before backend endpoints
- Backend endpoints before mobile screens that consume them
- Core implementation before integration with other stories
- Story complete before moving to next priority

### Parallel Opportunities

- **Phase 1 (Setup)**: T004-T005, T006 can run in parallel
- **Phase 2 (Foundational)**: 
  - Database entities T010-T015 can run in parallel after T009
  - Auth infrastructure T022-T023 can run in parallel
  - API infrastructure T025-T027, T029-T030 can run in parallel
  - Mobile infrastructure T034-T035 can run in parallel
- **User Stories 1-5**: Can work on multiple stories in parallel with separate developers after Foundational completes
- **Within each story**: Tasks marked [P] can run in parallel (different files)
- **Phase 9 (Polish)**: Most tasks marked [P] can run in parallel

---

## Parallel Example: User Story 2 (Notes)

```bash
# Backend: These services can be built in parallel:
Task T070: "Create Note service in backend/src/services/note-service.ts"
Task T041: "Implement notification service for note events" (if not done in US1)

# Backend: These endpoints can be built in parallel after services exist:
Task T073: "GET /spaces/current/notes endpoint"
Task T074: "GET /spaces/current/notes/drafts endpoint"
Task T075: "POST /spaces/current/notes endpoint"

# Mobile: These screens can be built in parallel after endpoints exist:
Task T080: "Note list screen in mobile/app/(space)/notes/index.tsx"
Task T081: "Note composition screen in mobile/app/(space)/notes/compose.tsx"
Task T083: "Draft list screen in mobile/app/(space)/notes/drafts.tsx"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (~8 tasks, ~1-2 days)
2. Complete Phase 2: Foundational (~28 tasks, ~3-5 days) - CRITICAL PATH
3. Complete Phase 3: User Story 1 (~33 tasks, ~4-6 days)
4. **STOP and VALIDATE**: Test two users creating and joining a space end-to-end
5. Deploy to staging and demo the core value proposition

**MVP Scope**: 69 tasks total (T001-T069)
**MVP Deliverable**: Two people can establish a private, mutually-consented relationship space

### Incremental Delivery (Recommended)

1. **Sprint 1**: Setup + Foundational → Foundation ready (T001-T036, ~5-7 days)
2. **Sprint 2**: User Story 1 → Relationship space creation works (T037-T069, ~4-6 days) - **MVP DEPLOYED**
3. **Sprint 3**: User Story 2 → Note exchange works (T070-T093, ~3-4 days)
4. **Sprint 4**: User Story 3 → Event planning works (T094-T114, ~3-4 days)
5. **Sprint 5**: User Story 4 → Preferences work (T115-T130, ~2-3 days)
6. **Sprint 6**: User Story 5 → Memories work (T131-T156, ~3-4 days)
7. **Sprint 7**: User Story 6 → Notifications work (T157-T180, ~3-4 days)
8. **Sprint 8**: Polish + Deploy (T181-T220, ~3-5 days)

**Total**: 220 tasks across 8 sprints, approximately 28-37 days of development

### Parallel Team Strategy

With 3 developers after Foundational phase completes:

- **Developer A**: User Story 1 (spaces) → User Story 4 (preferences)
- **Developer B**: User Story 2 (notes) → User Story 5 (memories)
- **Developer C**: User Story 3 (events) → User Story 6 (notifications)

Stories complete and integrate independently. Can reduce timeline to ~4-5 weeks with parallel work.

---

## Summary Statistics

- **Total Tasks**: 220
- **Setup Phase**: 8 tasks
- **Foundational Phase**: 28 tasks (BLOCKS all stories)
- **User Story 1 (Spaces)**: 33 tasks - **MVP CORE**
- **User Story 2 (Notes)**: 24 tasks
- **User Story 3 (Events)**: 21 tasks
- **User Story 4 (Preferences)**: 16 tasks
- **User Story 5 (Memories)**: 26 tasks
- **User Story 6 (Notifications)**: 24 tasks
- **Polish Phase**: 40 tasks

**Parallel Opportunities**: 42 tasks marked [P] can run in parallel
**MVP Scope**: 69 tasks (T001-T069) delivers core value proposition
**Full Feature Set**: All 220 tasks deliver complete MVP per spec.md

---

## Notes

- [P] tasks = different files, no dependencies, safe to parallelize
- [Story] label (US1-US6) maps task to specific user story for traceability
- Each user story is independently completable and testable after Foundational phase
- Tests are NOT included per spec.md (no explicit test request found)
- Constitution compliance checks included in Polish phase (Articles II, III, IV, VI)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- All file paths follow plan.md Mobile + Web + API architecture
