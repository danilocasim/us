# Implementation Plan: Us Core Product MVP

**Branch**: `001-core-product-mvp` | **Date**: 2025-02-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-core-product-mvp/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Build a private, one-to-one digital relationship space enabling two people to share notes, events, preferences, photos, and memories with mutual consent as the foundational trust contract. The MVP prioritizes intentional interaction over engagement, permanence over editability, and emotional safety over virality. Core technical approach uses modern web technologies with mobile-first design, end-to-end encryption for privacy, and strict access controls ensuring content isolation per relationship space.

## Technical Context

**Language/Version**: Node.js 20 LTS (backend), TypeScript 5+ (full stack), React 18 (web), React Native 0.73 (mobile)  
**Primary Dependencies**: NestJS (backend API), Next.js 14 (web), Expo SDK 50 (mobile), Prisma (ORM), @noble/ciphers (encryption)  
**Storage**: PostgreSQL 15+ (relational data for users, spaces, notes, events) + S3-compatible object storage (Cloudflare R2 for photos/memories)  
**Testing**: Vitest (unit/integration), Playwright (E2E web), React Native Testing Library (mobile), Supertest (API contracts)  
**Target Platform**: Mobile-first (iOS 15+ & Android 10+ via React Native/Expo) + Web companion (Next.js SSR)  
**Project Type**: Mobile + Web + API (monorepo with api/, mobile/, web/ directories)  
**Performance Goals**: <500ms API response time p95, <2s photo upload for 5MB compressed images, 60fps UI interactions  
**Constraints**: Offline-capable (drafts in AsyncStorage/IndexedDB), <100MB memory footprint mobile, client-side E2E encryption (ChaCha20-Poly1305), zero data loss tolerance (WAL archiving + daily backups)  
**Scale/Scope**: MVP target 1k-10k users, ~15 core screens (onboarding, space creation, notes, events, preferences, memories), ~28 REST API endpoints

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Article I: Purpose & Scope ✅
- **Requirement**: Support one private relationship per space with mutual consent
- **Status**: COMPLIANT — Feature spec enforces exactly one space per user pair (FR-002), requires explicit consent from both parties (FR-001)
- **Evidence**: User Story 1 acceptance scenario #5 prevents multiple spaces

### Article II: Trust & Consent ✅
- **Requirement**: No relationship space without explicit approval from both parties
- **Status**: COMPLIANT — Invitation system requires explicit acceptance (FR-001), single-use secure links with expiration (FR-030)
- **Evidence**: User Story 1 scenarios #1-3 enforce consent workflow

### Article III: Privacy & Ownership ✅
- **Requirement**: Data belongs to relationship, not platform; privacy by default
- **Status**: COMPLIANT — Content isolated per space (FR-022), no public indexing (FR-023), independent export rights (FR-029)
- **Evidence**: User Story 1 scenario #4 denies third-party access; FR-024 treats content as relationship-owned

### Article IV: Intentional Design ✅
- **Requirement**: Encourage thoughtful actions; respect permanence
- **Status**: COMPLIANT — Notes are immutable after delivery (FR-006), memories require individual curation (FR-017)
- **Evidence**: User Story 2 scenario #2 enforces permanence; User Story 5 scenario #4 adds friction to bulk uploads

### Article V: Simplicity & Restraint ✅
- **Requirement**: Features must justify emotional value and complexity
- **Status**: COMPLIANT — Each user story has explicit "Why this priority" rationale; scope limited to 5 core features
- **Evidence**: User stories 1-5 each provide justification; preferences (Story 4) require no response obligation (FR-012)

### Article VI: Scalability Without Dehumanization ✅
- **Requirement**: No dark patterns, engagement loops, or attention harvesting
- **Status**: COMPLIANT — Explicit prohibition in FR-019, FR-027; notifications only for meaningful events (FR-018)
- **Evidence**: User Story 6 scenarios #3-4 prevent engagement patterns; SC-005 requires 100% care-justified notifications

### Article VII: Maintainability & Longevity ✅
- **Requirement**: Favor clarity, stability, maintainability; additive change only
- **Status**: COMPLIANT — Spec includes migration paths (account deletion → archive, FR-003); preserves drafts offline (FR-025)
- **Evidence**: Edge case handling for partner departure maintains data access; constitution versioning in place

### Article VIII: Accountability & Governance ✅
- **Requirement**: Document decisions; take responsibility for consequences
- **Status**: COMPLIANT — All technology choices documented in research.md with rationale and alternatives considered
- **Evidence**: Research document sections 1-10 provide explicit decision documentation; agent context updated with finalized stack

### Article IX: Ethical Boundaries ✅
- **Requirement**: No exploitation of emotion; analytics measure system health only
- **Status**: COMPLIANT — FR-027 prohibits monetizing vulnerability; FR-028 restricts analytics to system health
- **Evidence**: User Story 3 scenario #3 uses no pressure language for declines

### Article X: Evolution & Adaptation ✅
- **Requirement**: Purpose overrides trend; changes preserve original intent
- **Status**: COMPLIANT — Feature scope tied to product purpose; no viral or social features
- **Evidence**: Boundaries section (FR-026) explicitly prohibits relationship comparison features

### Gate Decision: **PASSED — READY FOR PHASE 2** ✅
**Status**: All constitution checks passed. Technical context resolved. Design artifacts complete.
**Next Step**: Generate tasks.md via `/speckit.tasks` command to create implementation task breakdown.
**Re-check Completed**: Technology choices align with Article VII (maintainability via TypeScript + established frameworks) and Article VIII (all decisions documented with rationale).

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
```

### Source Code (repository root)

```text
# Mobile + Web + API Architecture
api/
├── src/
│   ├── models/           # User, Space, Note, Event, Preference, Memory
│   ├── services/         # Business logic (consent, encryption, notifications)
│   ├── routes/           # REST/GraphQL endpoints
│   ├── middleware/       # Auth, rate limiting, error handling
│   └── db/               # Migrations, connection pooling
├── tests/
│   ├── contract/         # API contract tests (OpenAPI compliance)
│   ├── integration/      # End-to-end flows (space creation, note delivery)
│   └── unit/             # Service/model tests
└── config/               # Environment, secrets management

mobile/
├── shared/               # Platform-agnostic business logic
│   ├── models/           # Data models matching API schemas
│   ├── services/         # API client, local storage, sync engine
│   └── utils/            # Encryption helpers, validation
├── ios/                  # (if native)
│   ├── Us/
│   │   ├── Views/        # Onboarding, Space, Notes, Events, Memories
│   │   ├── ViewModels/   # MVVM pattern
│   │   └── Services/     # Platform-specific (push notifications)
│   └── UsTests/
├── android/              # (if native)
│   └── [similar structure]
└── react-native/         # (if cross-platform)
    ├── src/
    │   ├── screens/      # Navigation structure
    │   ├── components/   # Reusable UI (NoteCard, EventProposal)
    │   └── hooks/        # State management, API integration
    └── __tests__/

web/
├── src/
│   ├── pages/            # Next.js/SvelteKit routes or SPA pages
│   ├── components/       # Shared UI components
│   ├── lib/              # API client, auth helpers
│   └── stores/           # Client-side state (if applicable)
└── tests/
    ├── e2e/              # Playwright/Cypress tests
    └── unit/             # Component tests

infra/
├── docker/               # Local development environment
├── terraform/            # Cloud infrastructure (if applicable)
└── k8s/                  # Kubernetes manifests (if applicable)
```

**Structure Decision**: Mobile + Web + API architecture selected to support mobile-first requirement with web companion. API provides unified backend with strict access control. Mobile app(s) handle offline-first requirements with local draft storage. Shared mobile code reduces duplication between iOS/Android if native paths chosen. Web companion provides optional desktop access using same API.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

**Status**: No violations requiring justification. All constitution checks passed or flagged for Phase 0 research verification.
