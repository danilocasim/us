# Implementation Plan: Us Core Product MVP

**Branch**: `001-core-product-mvp` | **Date**: 2026-02-14 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-core-product-mvp/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Us is a private, one-to-one digital space for notes, events, preferences, photos, and memories between two people. The MVP establishes the foundational relationship model with mutual consent, intentional communication through permanent notes, event planning, preference sharing, curated memories, and restrained notifications. Technical implementation uses React Native with Expo for cross-platform mobile delivery and Supabase (PostgreSQL, Auth, Storage, Realtime) as the integrated backend platform.

## Technical Context

**Language/Version**: TypeScript 5.x (both mobile and backend integrations)  
**Primary Dependencies**: React Native, Expo SDK, Supabase JS Client (@supabase/supabase-js), React Navigation  
**Storage**: Supabase PostgreSQL (relational data), Supabase Storage (photos with CDN)  
**Testing**: Jest + React Native Testing Library (unit/integration), Detox (E2E), Supabase local development  
**Target Platform**: iOS 15+ and Android 10+ (React Native mobile apps via Expo)
**Project Type**: Mobile application with cloud backend (Supabase)  
**Performance Goals**: <500ms typical screen transitions, <2s photo upload (3MB typical), 60fps UI animations  
**Constraints**: 10MB max per photo, 500 photos per relationship space, offline draft preservation, zero data loss on sync  
**Scale/Scope**: MVP targets 100-1000 early users, ~15 screens, single relationship space per user, free-tier infrastructure (Supabase 500MB DB, 1GB storage)

## Constitution Check

_GATE: Must pass before Phase 0 research. Re-check after Phase 1 design._

**Evaluation against Us Constitution v1.0.0**

| Principle                                  | Status  | Evidence                                                                                                                               |
| ------------------------------------------ | ------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **I. Purpose & Scope**                     | ✅ PASS | Feature strictly enforces one-to-one relationship spaces (FR-002). No multi-party expansion, no social network features.               |
| **II. Trust & Consent**                    | ✅ PASS | Mutual consent is mandatory (FR-001). Both parties must explicitly accept invitation before space becomes active.                      |
| **III. Privacy & Ownership**               | ✅ PASS | No public discovery (FR-022, FR-023). Data belongs to relationship (FR-024). Export available to both partners independently (FR-029). |
| **IV. Intentional Design**                 | ✅ PASS | Delivered notes are permanent (FR-006), creating intentional friction. Curated memories over bulk uploads (FR-017).                    |
| **V. Simplicity & Restraint**              | ✅ PASS | Limited to 6 core user stories (P1-P6). Each feature has clear emotional purpose. No feature bloat.                                    |
| **VI. Scalability Without Dehumanization** | ✅ PASS | No engagement metrics. No relationship comparison features (FR-026). Analytics measure system health only (FR-028).                    |
| **VII. Maintainability & Longevity**       | ✅ PASS | Standard TypeScript stack. Well-documented APIs. Supabase provides stable, versioned platform.                                         |
| **VIII. Accountability & Governance**      | ✅ PASS | All decisions documented in spec clarifications. Clear requirements traceability.                                                      |
| **IX. Ethical Boundaries**                 | ✅ PASS | Zero dark patterns (FR-019, SC-008). No emotion monetization (FR-027). Privacy-first storage.                                          |
| **X. Evolution & Adaptation**              | ✅ PASS | Clear migration path when user leaves (FR-003). Graceful archive behavior preserves trust.                                             |

**Gate Status**: ✅ **PASS** — All constitution principles satisfied. No violations requiring justification.

**Pre-Phase-0 Check**: ✅ CLEARED  
**Post-Phase-1 Recheck**: ✅ CLEARED — Design phase completed. All principles remain satisfied. Supabase RLS policies enforce privacy requirements. React Native + Expo provide stable, maintainable foundation. No new violations introduced.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
mobile/
├── app/                      # Expo Router screens (file-based routing)
│   ├── _layout.tsx           # Root layout with providers (AuthProvider, QueryClientProvider)
│   ├── index.tsx             # Landing/redirect screen
│   ├── (auth)/               # Auth route group (not in URL path)
│   │   ├── _layout.tsx       # Auth layout
│   │   ├── login.tsx         # Login screen
│   │   ├── register.tsx      # Registration screen
│   │   └── onboarding.tsx    # Post-registration onboarding
│   └── (space)/              # Main app route group (requires auth)
│       ├── _layout.tsx       # Tab navigator (Notes, Events, Memories, Preferences)
│       ├── notes/
│       │   ├── index.tsx     # Notes list
│       │   ├── [id].tsx      # Note detail/read
│       │   └── compose.tsx   # Compose note (modal)
│       ├── events/
│       │   ├── index.tsx     # Events list
│       │   ├── [id].tsx      # Event detail
│       │   └── create.tsx    # Create event
│       ├── memories/
│       │   ├── index.tsx     # Memory gallery
│       │   ├── [id].tsx      # Memory detail
│       │   └── upload.tsx    # Upload photo
│       └── preferences/
│           ├── index.tsx     # Preferences view
│           └── create.tsx    # Add preference
├── src/
│   ├── components/           # Reusable UI components
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Card.tsx
│   │   └── ...
│   ├── hooks/                # Custom React hooks
│   │   ├── useAuth.ts        # Auth state and methods
│   │   ├── useSpace.ts       # Active space data
│   │   ├── useNotes.ts       # Notes queries and mutations
│   │   ├── useDraft.ts       # Draft persistence
│   │   └── ...
│   ├── services/             # Supabase API calls
│   │   ├── supabase.ts       # Supabase client setup
│   │   ├── auth.service.ts   # Auth operations
│   │   ├── space.service.ts  # Space operations
│   │   ├── note.service.ts   # Note operations
│   │   ├── event.service.ts  # Event operations
│   │   ├── memory.service.ts # Memory/photo operations
│   │   └── ...
│   ├── types/                # TypeScript types
│   │   ├── database.types.ts # Auto-generated from Supabase schema
│   │   └── domain.types.ts   # Domain-specific types
│   └── utils/                # Helper functions
│       ├── validation.ts     # Input validation
│       ├── formatting.ts     # Date/text formatting
│       └── storage.ts        # AsyncStorage helpers
├── supabase/
│   ├── config.toml           # Supabase local config
│   ├── migrations/           # Database migrations (SQL)
│   │   └── 20260214000000_initial_schema.sql
│   └── seed.sql              # Test data
├── tests/
│   ├── unit/                 # Jest unit tests
│   ├── integration/          # Integration tests with local Supabase
│   └── e2e/                  # Detox E2E tests
├── .env                      # Environment variables (gitignored)
├── .env.example              # Environment template
├── app.json                  # Expo configuration
├── tailwind.config.js        # NativeWind/Tailwind config
├── global.css                # Global styles
├── package.json
├── tsconfig.json
└── README.md
```

**Structure Decision**: Mobile + Cloud Backend (Supabase) architecture. Expo Router provides file-based routing with layout groups for clean auth/main app separation. Supabase directory contains database migrations and seeds for local development. All business logic in `src/services/`, keeping screens thin and focused on presentation.

## Complexity Tracking

**No violations found**. All architecture decisions align with constitution principles. No complexity justification required.
