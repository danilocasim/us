# Tasks: Us Core Product MVP

**Input**: Design documents from `/specs/001-core-product-mvp/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/api.md, quickstart.md

**Testing Approach**: While this task list focuses on implementation, validation occurs through:

1. **E2E Tests**: Detox tests for critical user flows (configured in Phase 1, implemented alongside features)
2. **Unit Tests**: Jest + RNTL for services, hooks, and utilities (70% coverage threshold)
3. **Manual Validation**: Acceptance scenario verification against quickstart.md (see Integration & Validation tasks per user story)
4. **Success Criteria Measurement**: Phase 9 includes explicit validation tasks for SC-001 through SC-008

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

All paths are relative to repository root:

- Mobile app: `mobile/`
- Expo Router screens: `mobile/app/`
- React Native components: `mobile/src/components/`
- Services: `mobile/src/services/`
- Hooks: `mobile/src/hooks/`
- Supabase: `mobile/supabase/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Initialize React Native + Expo project structure in mobile/
- [x] T002 [P] Configure TypeScript 5.x with strict mode in mobile/tsconfig.json
- [x] T003 [P] Setup NativeWind (Tailwind CSS) in mobile/tailwind.config.js and mobile/global.css
- [x] T004 [P] Configure Expo Router in mobile/app/\_layout.tsx with root providers
- [x] T005 [P] Setup ESLint and Prettier in mobile/.eslintrc.js and mobile/.prettierrc
- [x] T006 [P] Initialize Supabase local development in mobile/supabase/config.toml
- [x] T007 [P] Create environment configuration in mobile/.env.example
- [x] T008 [P] Setup React Query client in mobile/src/utils/queryClient.ts
- [x] T009 [P] Configure Jest + React Native Testing Library in mobile/jest.config.js
- [x] T010 [P] Setup Detox E2E testing framework in mobile/.detoxrc.json

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Database Schema & RLS Policies

- [ ] T011 Create initial database migration in mobile/supabase/migrations/20260214000000_initial_schema.sql with all entities (User, Space, SpaceMember, Invitation, Note, Event, EventResponse, Preference, Memory, Reflection, Notification)
- [ ] T012 Define Row-Level Security policies for User table in migration
- [ ] T013 Define Row-Level Security policies for Space and SpaceMember tables in migration
- [ ] T014 Define Row-Level Security policies for Invitation table in migration
- [ ] T015 Create database triggers for space archival on user deletion in migration
- [ ] T016 Create database seed file in mobile/supabase/seed.sql for local testing
- [ ] T017 Run migration and verify schema with npx supabase db reset

### Supabase Client & Authentication

- [ ] T018 [P] Initialize Supabase client in mobile/src/services/supabase.ts with typed client
- [ ] T019 [P] Generate TypeScript types from schema in mobile/src/types/database.types.ts
- [ ] T020 [P] Implement auth service in mobile/src/services/auth.service.ts (register, login, logout, session)
- [ ] T021 [P] Create AuthProvider context in mobile/src/providers/AuthProvider.tsx
- [ ] T022 [P] Implement useAuth hook in mobile/src/hooks/useAuth.ts
- [ ] T023 [P] Setup expo-secure-store integration for token storage in mobile/src/utils/storage.ts

### Auth Screens & Navigation

- [ ] T024 [P] Create auth layout in mobile/app/(auth)/\_layout.tsx
- [ ] T025 [P] Implement login screen in mobile/app/(auth)/login.tsx
- [ ] T026 [P] Implement registration screen in mobile/app/(auth)/register.tsx
- [ ] T027 [P] Implement landing/redirect logic in mobile/app/index.tsx
- [ ] T028 Create protected route guard in mobile/app/(space)/\_layout.tsx

### Core UI Components

- [ ] T029 [P] Create Button component in mobile/src/components/Button.tsx
- [ ] T030 [P] Create Input component in mobile/src/components/Input.tsx
- [ ] T031 [P] Create Card component in mobile/src/components/Card.tsx
- [ ] T032 [P] Create LoadingSpinner component in mobile/src/components/LoadingSpinner.tsx
- [ ] T033 [P] Create ErrorBoundary component in mobile/src/components/ErrorBoundary.tsx

### Core Utilities

- [ ] T034 [P] Implement validation helpers in mobile/src/utils/validation.ts
- [ ] T035 [P] Implement date/text formatting in mobile/src/utils/formatting.ts
- [ ] T036 [P] Setup AsyncStorage helpers for drafts in mobile/src/utils/asyncStorage.ts
- [ ] T037 [P] Create error handling utilities in mobile/src/utils/errors.ts

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Create a Private Relationship Space (Priority: P1) 🎯 MVP

**Goal**: Enable two users to establish a private, consent-based relationship space through invitation and acceptance.

**Independent Test**: Create account → Create space → Generate invitation link → Share link → Partner accepts → Both users see active space.

### RLS Policies for User Story 1

- [ ] T038 Define RLS policies for Note table in mobile/supabase/migrations/20260214000001_note_policies.sql
- [ ] T039 Define RLS policies for Event and EventResponse tables in migration
- [ ] T040 Define RLS policies for Preference table in migration
- [ ] T041 Define RLS policies for Memory and Reflection tables in migration
- [ ] T042 Define RLS policies for Notification table in migration
- [ ] T043 Define Supabase Storage policies for photos in migration
- [ ] T044 Run new migrations with npx supabase db reset

### Space Management Implementation

- [ ] T045 [P] [US1] Implement Space service in mobile/src/services/space.service.ts (createSpace, getActiveSpace, archiveSpace)
- [ ] T046 [P] [US1] Implement Invitation service in mobile/src/services/invitation.service.ts (createInvitation, getInvitation, acceptInvitation, declineInvitation, revokeInvitation)
- [ ] T047 [P] [US1] Create useSpace hook in mobile/src/hooks/useSpace.ts (React Query integration)
- [ ] T048 [P] [US1] Create useInvitation hook in mobile/src/hooks/useInvitation.ts

### Space UI Screens

- [ ] T049 [US1] Implement onboarding screen in mobile/app/(auth)/onboarding.tsx (create space or join via link)
- [ ] T050 [US1] Create space creation flow in mobile/app/(space)/create-space.tsx
- [ ] T051 [US1] Implement invitation share screen in mobile/app/(space)/invite.tsx (generate link, copy to clipboard, share via native share)
- [ ] T052 [US1] Implement invitation acceptance flow in mobile/app/(space)/accept-invitation/[token].tsx (deep linking)
- [ ] T053 [US1] Create space status indicator component in mobile/src/components/SpaceStatus.tsx
- [ ] T054 [US1] Add space archival flow and confirmation in mobile/app/(space)/settings/leave-space.tsx

### Integration & Validation

- [ ] T055 [US1] Configure Expo deep linking for invitation URLs in mobile/app.json
- [ ] T056 [US1] Add invitation link validation and expiration handling in mobile/src/utils/validation.ts
- [ ] T057 [US1] Verify User Story 1 acceptance scenarios against quickstart.md
- [ ] T057a [P] [US1] Implement data export service in mobile/src/services/export.service.ts (export all space content per FR-029)
- [ ] T057b [US1] Add export UI in mobile/app/(space)/settings/export.tsx (download JSON with notes, events, preferences, memories)

**Checkpoint**: At this point, User Story 1 should be fully functional - users can create spaces, invite partners, and establish private relationship spaces.

---

## Phase 4: User Story 2 - Write and Deliver a Note (Priority: P2)

**Goal**: Enable partners to compose, draft, and deliver permanent notes to each other within their shared space.

**Independent Test**: Open app → Navigate to Notes → Compose note → Save draft → Send note → Partner receives and reads note → Permanence enforced (cannot edit/delete).

### Note Implementation

- [ ] T058 [P] [US2] Implement Note service in mobile/src/services/note.service.ts (createDraft, updateDraft, deleteDraft, sendNote, getNotes, getNote)
- [ ] T059 [P] [US2] Create useNotes hook in mobile/src/hooks/useNotes.ts (React Query queries and mutations)
- [ ] T060 [P] [US2] Create useDraft hook in mobile/src/hooks/useDraft.ts (AsyncStorage persistence for offline drafts)
- [ ] T061 [P] [US2] Implement Realtime subscription for note delivery in mobile/src/hooks/useNoteRealtime.ts

### Note UI Screens

- [ ] T062 [US2] Create Notes list screen in mobile/app/(space)/notes/index.tsx (tab navigator item)
- [ ] T063 [US2] Implement note compose screen in mobile/app/(space)/notes/compose.tsx (modal presentation)
- [ ] T064 [US2] Implement note detail/read screen in mobile/app/(space)/notes/[id].tsx (letter-like reading experience)
- [ ] T065 [US2] Create draft management UI in compose screen (save draft, discard draft, resume draft)
- [ ] T066 [US2] Add note permanence enforcement in detail screen (no edit/delete buttons for delivered notes)

### Note Components

- [ ] T067 [P] [US2] Create NoteCard component in mobile/src/components/NoteCard.tsx (list item display)
- [ ] T068 [P] [US2] Create NoteComposer component in mobile/src/components/NoteComposer.tsx (text input with character count)
- [ ] T069 [P] [US2] Create NoteReader component in mobile/src/components/NoteReader.tsx (calm reading format)

### Integration & Validation

- [ ] T070 [US2] Add offline draft sync logic when connectivity restored in mobile/src/utils/syncDrafts.ts
- [ ] T071 [US2] Verify User Story 2 acceptance scenarios against quickstart.md

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - users can create spaces AND exchange permanent notes.

---

## Phase 5: User Story 3 - Propose and Respond to an Event (Priority: P3)

**Goal**: Enable partners to propose events/plans and respond with agreement, decline, or preferences.

**Independent Test**: Open app → Navigate to Events → Create event proposal → Partner views proposal → Partner responds (agree/decline/prefer) → Both see updated status.

### Event Implementation

- [ ] T072 [P] [US3] Implement Event service in mobile/src/services/event.service.ts (createEvent, updateEvent, deleteEvent, getEvents, getEvent, respondToEvent)
- [ ] T073 [P] [US3] Implement EventResponse service in mobile/src/services/event.service.ts (createResponse, getResponses)
- [ ] T074 [P] [US3] Create useEvents hook in mobile/src/hooks/useEvents.ts (React Query integration)
- [ ] T075 [P] [US3] Implement Realtime subscription for event updates in mobile/src/hooks/useEventRealtime.ts

### Event UI Screens

- [ ] T076 [US3] Create Events list screen in mobile/app/(space)/events/index.tsx (tab navigator item, filter by status)
- [ ] T077 [US3] Implement event creation screen in mobile/app/(space)/events/create.tsx (description, date, optional location)
- [ ] T078 [US3] Implement event detail screen in mobile/app/(space)/events/[id].tsx (view proposal, respond, see responses)
- [ ] T079 [US3] Add event response UI in detail screen (agree/decline/express preference buttons)

### Event Components

- [ ] T080 [P] [US3] Create EventCard component in mobile/src/components/EventCard.tsx (list item with status badge)
- [ ] T081 [P] [US3] Create EventProposal component in mobile/src/components/EventProposal.tsx (proposal display with response actions)
- [ ] T082 [P] [US3] Create DateTimePicker component in mobile/src/components/DateTimePicker.tsx (date and time selection)

### Integration & Validation

- [ ] T083 [US3] Add calendar view for confirmed events in mobile/app/(space)/events/calendar.tsx
- [ ] T084 [US3] Verify User Story 3 acceptance scenarios against quickstart.md

**Checkpoint**: User Stories 1, 2, AND 3 are now functional - users can create spaces, exchange notes, AND plan events together.

---

## Phase 6: User Story 4 - Share Preferences (Priority: P4)

**Goal**: Enable partners to express low-pressure preferences (desires, moods, boundaries) visible to their partner without obligation.

**Independent Test**: Open app → Navigate to Preferences → Express preference → Partner views preference → Partner can update own preferences without notifications.

### Preference Implementation

- [ ] T085 [P] [US4] Implement Preference service in mobile/src/services/preference.service.ts (createPreference, updatePreference, deletePreference, getPreferences)
- [ ] T086 [P] [US4] Create usePreferences hook in mobile/src/hooks/usePreferences.ts (React Query integration)
- [ ] T087 [P] [US4] Implement Realtime subscription for new preferences in mobile/src/hooks/usePreferenceRealtime.ts (no update notifications)

### Preference UI Screens

- [ ] T088 [US4] Create Preferences view screen in mobile/app/(space)/preferences/index.tsx (tab navigator item, show partner's preferences)
- [ ] T089 [US4] Implement preference creation/edit screen in mobile/app/(space)/preferences/create.tsx (type selection, text input)
- [ ] T090 [US4] Add preference management UI in index screen (edit own preferences, view partner's without obligation)

### Preference Components

- [ ] T091 [P] [US4] Create PreferenceCard component in mobile/src/components/PreferenceCard.tsx (gentle, non-pressuring display)
- [ ] T092 [P] [US4] Create PreferenceTypeSelector component in mobile/src/components/PreferenceTypeSelector.tsx (desire/mood/boundary)

### Integration & Validation

- [ ] T093 [US4] Ensure preference updates do NOT trigger notifications in mobile/src/services/preference.service.ts
- [ ] T094 [US4] Verify User Story 4 acceptance scenarios against quickstart.md

**Checkpoint**: User Stories 1-4 are functional - space creation, notes, events, AND preferences are working independently.

---

## Phase 7: User Story 5 - Capture and Curate Memories (Priority: P5)

**Goal**: Enable partners to upload photos with context and curate a shared memory collection with reflections.

**Independent Test**: Open app → Navigate to Memories → Upload photo with caption → Partner views memory → Partner adds reflection → Both see curated album.

### Memory & Storage Implementation

- [ ] T095 [P] [US5] Implement Memory service in mobile/src/services/memory.service.ts (createMemory, updateMemory, deleteMemory, getMemories, getMemory)
- [ ] T096 [P] [US5] Implement Reflection service in mobile/src/services/memory.service.ts (createReflection, updateReflection, deleteReflection, getReflections)
- [ ] T097 [P] [US5] Implement photo upload to Supabase Storage in mobile/src/services/storage.service.ts (uploadPhoto, getPhotoUrl, deletePhoto)
- [ ] T098 [P] [US5] Create useMemories hook in mobile/src/hooks/useMemories.ts (React Query integration)
- [ ] T099 [P] [US5] Create usePhotoUpload hook in mobile/src/hooks/usePhotoUpload.ts (progress tracking, size validation)
- [ ] T100 [P] [US5] Implement Realtime subscription for new memories in mobile/src/hooks/useMemoryRealtime.ts

### Memory UI Screens

- [ ] T101 [US5] Create Memories gallery screen in mobile/app/(space)/memories/index.tsx (tab navigator item, album-like grid)
- [ ] T102 [US5] Implement photo upload screen in mobile/app/(space)/memories/upload.tsx (image picker, caption, date)
- [ ] T103 [US5] Implement memory detail screen in mobile/app/(space)/memories/[id].tsx (photo display, caption, reflections from both partners)
- [ ] T104 [US5] Add reflection creation UI in detail screen (add reflection, view both perspectives)

### Memory Components

- [ ] T105 [P] [US5] Create MemoryCard component in mobile/src/components/MemoryCard.tsx (grid item with thumbnail)
- [ ] T106 [P] [US5] Create PhotoViewer component in mobile/src/components/PhotoViewer.tsx (full-screen photo display)
- [ ] T107 [P] [US5] Create ReflectionList component in mobile/src/components/ReflectionList.tsx (show both partners' reflections)
- [ ] T108 [P] [US5] Create ImagePicker component in mobile/src/components/ImagePicker.tsx (Expo image picker integration)

### Photo Validation & Optimization

- [ ] T109 [US5] Add photo size validation (10MB limit) in mobile/src/utils/validation.ts
- [ ] T110 [US5] Add space photo count limit (500 photos) enforcement in mobile/src/services/memory.service.ts
- [ ] T111 [US5] Implement image compression before upload in mobile/src/utils/imageProcessing.ts
- [ ] T112 [US5] Add friction for bulk uploads (encourage one-at-a-time with context) in upload screen

### Integration & Validation

- [ ] T113 [US5] Configure Supabase Storage buckets and CDN in mobile/supabase/config.toml
- [ ] T114 [US5] Verify User Story 5 acceptance scenarios against quickstart.md

**Checkpoint**: User Stories 1-5 are functional - all core features (space, notes, events, preferences, memories) working independently.

---

## Phase 8: User Story 6 - Receive Meaningful Notifications (Priority: P6)

**Goal**: Deliver care-justified notifications for meaningful events without engagement-driven patterns.

**Independent Test**: Trigger event (note delivery, event proposal, memory added) → Partner receives single notification → Verify calm tone → Test batching for multiple events → Verify no streak/gamification patterns.

### Notification Implementation

- [ ] T115 [P] [US6] Implement Notification service in mobile/src/services/notification.service.ts (createNotification, getNotifications, markAsRead, batchNotifications)
- [ ] T116 [P] [US6] Setup Expo push notification infrastructure in mobile/src/services/pushNotification.service.ts (register for push, send notification)
- [ ] T117 [P] [US6] Create useNotifications hook in mobile/src/hooks/useNotifications.ts (React Query integration)
- [ ] T118 [P] [US6] Implement notification batching/throttling logic in mobile/src/utils/notificationBatching.ts

### Notification Triggers

- [ ] T119 [US6] Add notification trigger for note delivery in mobile/src/services/note.service.ts
- [ ] T120 [US6] Add notification trigger for event proposal in mobile/src/services/event.service.ts
- [ ] T121 [US6] Add notification trigger for event response in mobile/src/services/event.service.ts
- [ ] T122 [US6] Add notification trigger for memory addition in mobile/src/services/memory.service.ts
- [ ] T123 [US6] Add notification trigger for partner joining space in mobile/src/services/space.service.ts
- [ ] T124 [US6] Add notification trigger for partner leaving space in mobile/src/services/space.service.ts

### Notification UI

- [ ] T125 [US6] Create notifications screen in mobile/app/(space)/notifications/index.tsx (list of notifications)
- [ ] T126 [US6] Implement notification preferences screen in mobile/app/(space)/settings/notifications.tsx (enable/disable, no dark patterns)
- [ ] T127 [US6] Add notification badges to tab navigator in mobile/app/(space)/\_layout.tsx

### Notification Components & Content

- [ ] T128 [P] [US6] Create NotificationCard component in mobile/src/components/NotificationCard.tsx (calm, non-urgent display)
- [ ] T129 [P] [US6] Define notification message templates in mobile/src/utils/notificationMessages.ts (calm tone, no urgency words)
- [ ] T130 [US6] Implement notification deeplink handling in mobile/app/\_layout.tsx (open relevant screen)

### Notification Validation

- [ ] T131 [US6] Comprehensive dark pattern audit per SC-008 and constitution Article IX:
  - [ ] T131a Audit notification types to ensure zero engagement-driven patterns (no streaks, no "come back")
  - [ ] T131b Review all UI copy for pressure language ("Don't miss", "Hurry", urgency words)
  - [ ] T131c Verify no hidden consent patterns in onboarding flow
  - [ ] T131d Check that all preference updates are truly silent (no partner notifications)
  - [ ] T131e Validate invitation decline doesn't reveal reason to inviter
  - [ ] T131f Document audit findings in mobile/docs/dark-pattern-audit.md
- [ ] T132 [US6] Verify notification batching prevents overwhelming user in mobile/src/utils/notificationBatching.ts
- [ ] T133 [US6] Verify User Story 6 acceptance scenarios against quickstart.md

**Checkpoint**: All 6 user stories are now fully functional and independently testable. MVP is feature-complete.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final production readiness

### Performance & Optimization

- [ ] T134 [P] Optimize React Query cache configuration in mobile/src/utils/queryClient.ts
- [ ] T135 [P] Add image lazy loading in memory gallery in mobile/app/(space)/memories/index.tsx
- [ ] T136 [P] Implement pagination for notes/events/memories lists
- [ ] T137 [P] Add optimistic UI updates for all mutations (notes, events, preferences, memories)
- [ ] T138 [P] Profile and optimize animation performance (target 60fps) with Reanimated

### Error Handling & Resilience

- [ ] T139 [P] Add comprehensive error boundaries for each screen group in layouts
- [ ] T140 [P] Implement retry logic for failed mutations in React Query configuration
- [ ] T141 [P] Add offline detection and user feedback in mobile/src/components/OfflineIndicator.tsx
- [ ] T142 [P] Implement draft recovery on app restart in mobile/app/\_layout.tsx

### Security Hardening

- [ ] T143 [P] Audit all RLS policies for space isolation in mobile/supabase/migrations/
- [ ] T144 [P] Add rate limiting for invitation generation in mobile/src/services/invitation.service.ts
- [ ] T145 [P] Validate all file uploads (size, type, content) in mobile/src/utils/validation.ts
- [ ] T146 [P] Implement secure token storage audit in mobile/src/utils/storage.ts

### User Experience Polish

- [ ] T147 [P] Add loading states for all async operations across all screens
- [ ] T148 [P] Implement smooth transitions between screens with Expo Router
- [ ] T149 [P] Add haptic feedback for important actions (send note, accept invitation) with Expo Haptics
- [ ] T150 [P] Improve form validation feedback with inline error messages
- [ ] T151 [P] Add empty states for all list screens (no notes yet, no events yet, etc.)

### Accessibility

- [ ] T152 [P] Add screen reader support (accessibility labels) for all interactive elements
- [ ] T153 [P] Ensure sufficient color contrast for all text and UI elements
- [ ] T154 [P] Add keyboard navigation support for text inputs and forms
- [ ] T155 [P] Test with VoiceOver (iOS) and TalkBack (Android)

### Documentation & Developer Experience

- [ ] T156 [P] Update README.md with complete setup instructions
- [ ] T157 [P] Document all environment variables in mobile/.env.example
- [ ] T158 [P] Add inline code documentation for services and hooks
- [ ] T159 [P] Create runbook for common development tasks in docs/
- [ ] T160 [P] Run complete quickstart.md validation workflow

### Analytics & Monitoring (Constitution-Compliant)

- [ ] T161 [P] Implement basic error tracking (system health only, no user behavior) with Sentry
- [ ] T161a [P] Configure Sentry to exclude user behavior data per constitution Article VI
- [ ] T162 [P] Add performance monitoring for screen load times
- [ ] T163 [P] Setup logging for authentication failures (security monitoring)
- [ ] T164 Audit analytics implementation against constitution FR-028 (system health only)
- [ ] T164a Verify FR-031 zero data loss compliance through Supabase backup verification
- [ ] T164b Document Supabase durability guarantees (daily backups, point-in-time recovery) in mobile/docs/backup-strategy.md

### User Experience Validation

- [ ] T165 [P] Implement in-app feedback collection for beta users
- [ ] T166 [P] Create privacy perception survey (validate SC-007: 90% report feeling privacy/safety)
- [ ] T167 Collect and analyze SC-007 survey responses from beta testers
- [ ] T168 [P] Validate SC-001 through SC-006 measurable outcomes with test users

### Final Production Preparation

- [ ] T169 Build production iOS app bundle with Expo EAS Build
- [ ] T170 Build production Android app bundle with Expo EAS Build
- [ ] T171 Test production builds on physical devices (iOS and Android)
- [ ] T172 Submit iOS app to App Store TestFlight for beta testing
- [ ] T173 Submit Android app to Google Play Console for internal testing
- [ ] T174 Verify all success criteria (SC-001 to SC-008) from spec.md with documented evidence

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational completion - First feature to implement (P1)
- **User Story 2 (Phase 4)**: Depends on Foundational completion - Can start after US1 or in parallel with adequate team size
- **User Story 3 (Phase 5)**: Depends on Foundational completion - Can start after US1-2 or in parallel
- **User Story 4 (Phase 6)**: Depends on Foundational completion - Can start after US1-3 or in parallel
- **User Story 5 (Phase 7)**: Depends on Foundational completion - Can start after US1-4 or in parallel
- **User Story 6 (Phase 8)**: Depends on all other user stories - Notifications reference notes, events, memories, etc.
- **Polish (Phase 9)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: INDEPENDENT after Foundational - Creates the foundation (space) that all other stories operate within
- **User Story 2 (P2)**: INDEPENDENT after Foundational - Only needs Space to exist, which US1 provides
- **User Story 3 (P3)**: INDEPENDENT after Foundational - Only needs Space to exist, which US1 provides
- **User Story 4 (P4)**: INDEPENDENT after Foundational - Only needs Space to exist, which US1 provides
- **User Story 5 (P5)**: INDEPENDENT after Foundational - Only needs Space to exist, which US1 provides, plus Supabase Storage setup
- **User Story 6 (P6)**: DEPENDENT on US1-5 - Notifications reference entities from all other stories

### Within Each User Story Phase

1. RLS policies and migrations first (where applicable)
2. Services before hooks
3. Hooks before UI screens
4. Core screens before supporting components
5. Components can be built in parallel (marked with [P])
6. Integration and validation last for each story

### Parallel Opportunities

**Setup Phase (Phase 1)**:

- Tasks T002-T010 can all run in parallel (configuration files in different locations)

**Foundational Phase (Phase 2)**:

- T012-T016 (RLS policies) can be developed in parallel within the same migration file
- T018-T023 (Supabase client & auth) can run in parallel
- T024-T027 (auth screens) can run in parallel after T018-T023 complete
- T029-T033 (UI components) can all run in parallel
- T034-T037 (utilities) can all run in parallel

**User Story Phases (Phase 3-8)**:

- Within each story, tasks marked [P] indicate parallel opportunities:
  - Services and hooks can be developed in parallel
  - UI components can be built in parallel
  - Screens can be built in parallel after services/hooks are ready

**Between User Stories**:

- After Foundational (Phase 2) completes, User Stories 1-5 can ALL be worked on in parallel by different team members
- User Story 6 (Notifications) should wait until at least US1-2 are complete to test notification triggers

**Polish Phase (Phase 9)**:

- Almost all tasks in Phase 9 can run in parallel (T134-T164)

### Recommended MVP Execution Path (Solo Developer)

**Week 1**: Phase 1 (Setup) + Phase 2 (Foundational)  
**Week 2**: Phase 3 (User Story 1 - Space Creation) - Get to first working feature  
**Week 3**: Phase 4 (User Story 2 - Notes) - Core value proposition  
**Week 4**: Phase 5 (User Story 3 - Events) - Second core pillar  
**Week 5-6**: Phase 6-8 (Preferences, Memories, Notifications) - Complete feature set  
**Week 7**: Phase 9 (Polish) - Production readiness

**Minimum Viable MVP**: Phase 1 + Phase 2 + Phase 3 + Phase 4 = Space creation + Notes only (delivers core value)

---

## Parallel Example: User Story 1 (Phase 3)

Once Foundational phase completes, User Story 1 can proceed with maximum parallelization:

```bash
# Team of 3 developers can work simultaneously:

# Developer A: Database & Business Logic
T038-T044  # RLS policies (sequential, but isolated work)
T045-T046  # Space and Invitation services
T047-T048  # React Query hooks

# Developer B: UI Screens
T049-T052  # Onboarding, space creation, invite screens
T053-T054  # Space status and leave space UI

# Developer C: Integration & Validation
T055-T057  # Deep linking, validation, quickstart verification

# After individual work completes, integrate and test together
```

---

## Parallel Example: User Story 2 (Phase 4)

```bash
# Team of 2 developers:

# Developer A: Backend & State
T058-T061  # Note service, hooks, draft persistence, realtime

# Developer B: UI
T062-T069  # Screens and components for note composition and reading

# Then integrate:
T070-T071  # Offline sync and validation
```

---

## Parallel Example: Foundational Phase (Phase 2)

```bash
# Team of 4 developers can maximize parallelization:

# Developer A: Database
T011-T017  # All migrations, RLS policies, seed data

# Developer B: Auth
T018-T023  # Supabase client, auth service, provider, hooks

# Developer C: Screens
T024-T028  # Auth screens and navigation guards

# Developer D: UI Foundation
T029-T037  # All base components and utilities (highly parallel)

# Critical path: T011 → T017 → T019 (schema must exist before type generation)
# All other work can proceed in parallel
```

---

## Implementation Strategy

### MVP-First Approach

**Minimum Viable Product (MVP) Scope**:

- Phase 1: Setup ✅
- Phase 2: Foundational ✅
- Phase 3: User Story 1 (Space Creation) ✅
- Phase 4: User Story 2 (Notes) ✅

This delivers the core value proposition: _Two people can establish a private space and exchange meaningful, permanent notes._

**Post-MVP Increments**:

- Increment 2: Add User Story 3 (Events) - Planning capability
- Increment 3: Add User Story 4 (Preferences) - Low-pressure sharing
- Increment 4: Add User Story 5 (Memories) - Photo curation
- Increment 5: Add User Story 6 (Notifications) - Complete experience
- Increment 6: Phase 9 (Polish) - Production readiness

### Each User Story is a Vertical Slice

Every user story phase delivers:

1. Database schema (if needed)
2. Business logic (services)
3. State management (hooks)
4. User interface (screens + components)
5. Integration and validation

This enables continuous delivery: each completed user story immediately adds value.

### Independent Testing Per Story

Each user story includes an "Independent Test" scenario that validates the story works on its own:

- **US1**: Create account → Create space → Invite → Accept → Active space
- **US2**: Compose note → Save draft → Send → Partner reads → Permanence enforced
- **US3**: Create event → Partner responds → Both see result
- **US4**: Express preference → Partner views → Update without notification
- **US5**: Upload photo → Partner views → Add reflection → Both see perspectives
- **US6**: Trigger event → Partner receives notification → Calm tone verified

### Suggested Team Structures

**Solo Developer**: Execute user stories sequentially (P1 → P2 → P3...), prioritize MVP first  
**Team of 2**: One on backend (services, hooks), one on frontend (screens, components)  
**Team of 3**: Backend, frontend, infrastructure/testing split  
**Team of 4+**: Multiple user stories in parallel after Foundational phase completes

---

## Total Task Count

- **Phase 1 (Setup)**: 10 tasks
- **Phase 2 (Foundational)**: 27 tasks
- **Phase 3 (User Story 1)**: 22 tasks (+2 for FR-029 data export)
- **Phase 4 (User Story 2)**: 14 tasks
- **Phase 5 (User Story 3)**: 13 tasks
- **Phase 6 (User Story 4)**: 10 tasks
- **Phase 7 (User Story 5)**: 20 tasks
- **Phase 8 (User Story 6)**: 25 tasks (+6 for comprehensive dark pattern audit)
- **Phase 9 (Polish)**: 47 tasks (+10 for backup verification, analytics compliance, user validation)

**Total**: 188 tasks (+18 from original 170)

**Parallel opportunities**: 95 tasks marked [P] can run in parallel (51% parallelizable)

**MVP subset**: 53 tasks (Phase 1 + Phase 2 + Phase 3 + Phase 4)

**New additions resolve**:

- M1: 500 photo limit enforcement (data-model.md trigger)
- M2: Test validation approach clarified (header note)
- C4: SC-007 privacy perception survey (T166-T167)
- C5: Expanded dark pattern audit (T131a-f)
- L1: Backup verification documented (T164a-b)
- FR-029: Data export implementation (T057a-b)
