# Implementation Plan: Us Core Product MVP

**Branch**: `001-core-product-mvp` | **Date**: 2026-02-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-core-product-mvp/spec.md`

## Summary

Build a private, one-to-one relationship space where two consenting users can share intentional notes/letters, propose events, express preferences, and curate photo memories. The backend is a Node.js/Express API with Prisma ORM and PostgreSQL for durable storage. The frontend is a React Native mobile app styled with NativeWind (Tailwind for RN). Push notifications are delivered via Expo Notifications. The system enforces mutual consent, note permanence, privacy-by-default, and zero engagement exploitation at every layer.

## Technical Context

**Language/Version**: TypeScript 5.x (both frontend and backend)
**Primary Dependencies**:
- Backend: Node.js 20 LTS, Express 4.x, Prisma 5.x, bcrypt, jsonwebtoken, multer, expo-server-sdk
- Frontend: React Native 0.76+, Expo SDK 52+, NativeWind 4.x, React Navigation 7.x, Expo Notifications, Expo Image Picker, AsyncStorage
**Storage**: PostgreSQL 16 (primary), S3-compatible object store (photos)
**Testing**: Jest + Supertest (backend), Jest + React Native Testing Library (frontend)
**Target Platform**: iOS 15+ and Android 12+ (via React Native/Expo); API on Linux server
**Project Type**: Mobile + API (frontend + backend)
**Performance Goals**: API responses <500ms p95 for all endpoints; push notification delivery <30s from trigger event
**Constraints**: Offline-capable drafts (local-first with sync); photo uploads capped at 10MB per image; zero user content loss
**Scale/Scope**: Initial target 1,000 relationship spaces; ~10 screens in mobile app

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Principle | Gate Question | Status |
|---|-----------|---------------|--------|
| I | Purpose & Scope | Does the feature enable one-to-one meaningful connection without maximizing engagement or becoming social? | PASS — all features serve a single private space between two people |
| II | Trust & Consent | Does the feature require explicit consent and protect privacy, data ownership, and emotional safety? | PASS — invitation requires explicit acceptance; space requires mutual consent |
| III | Privacy & Ownership | Is data treated as belonging to the relationship? No public discovery, no indexing, no sharing without user action? | PASS — all content scoped to relationship space; full export available; no public endpoints |
| IV | Intentional Design | Does the feature encourage thoughtfulness? Is friction used to protect meaning? | PASS — note permanence enforced; memory curation encouraged; no real-time chat |
| V | Simplicity & Restraint | Does every feature justify its existence with emotional value? No surface area without depth? | PASS — 6 user stories, each with clear human narrative and emotional purpose |
| VI | Scalability Without Dehumanization | No dark patterns, engagement loops, or attention harvesting? | PASS — notifications are restrained; no streaks/gamification; FR-019 enforced |
| VII | Maintainability & Longevity | Clarity over cleverness? Stability over novelty? Additive changes? | PASS — standard well-supported stack; Prisma migrations; TypeScript for clarity |
| VIII | Accountability & Governance | Decisions documented, reversible where possible, understandable? | PASS — plan artifacts document all decisions; Prisma migrations are reversible |
| IX | Ethical Boundaries | No monetization of vulnerability? No surveillance of intimacy? | PASS — analytics measure system health only (FR-028); no behavioral tracking |
| X | Evolution & Adaptation | Changes preserve purpose, are explicit and reasoned? | PASS — constitution governance enforced via plan template gates |

**Gate result**: ALL PASS — no violations. Complexity Tracking section not required.

## Project Structure

### Documentation (this feature)

```text
specs/001-core-product-mvp/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── api.md           # REST API contract
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
backend/
├── src/
│   ├── config/          # Database, auth, storage, notification config
│   ├── middleware/       # Auth, error handling, rate limiting, upload
│   ├── models/          # Prisma schema (single source of truth)
│   ├── routes/          # Express route definitions
│   ├── services/        # Business logic (space, note, event, etc.)
│   ├── utils/           # Helpers (token generation, date formatting)
│   └── app.ts           # Express app setup
├── prisma/
│   ├── schema.prisma    # Data model
│   └── migrations/      # Prisma migrations
├── tests/
│   ├── contract/        # API contract tests
│   ├── integration/     # Service integration tests
│   └── unit/            # Unit tests
├── package.json
└── tsconfig.json

mobile/
├── app/                 # Expo Router file-based routing
│   ├── (auth)/          # Auth screens (login, register)
│   ├── (space)/         # Main space screens (notes, events, etc.)
│   └── _layout.tsx      # Root layout with navigation
├── components/          # Reusable UI components
│   ├── notes/           # Note composition, reading
│   ├── events/          # Event proposal, response
│   ├── preferences/     # Preference expression
│   ├── memories/        # Photo upload, album view
│   └── shared/          # Buttons, cards, modals
├── services/            # API client, auth, storage, notifications
├── hooks/               # Custom React hooks
├── stores/              # Local state (AsyncStorage, draft sync)
├── constants/           # Theme, colors, notification config
├── tests/               # Component and hook tests
├── app.json             # Expo config
├── package.json
├── tailwind.config.js   # NativeWind config
└── tsconfig.json
```

**Structure Decision**: Mobile + API structure selected. `backend/` contains the Express API with Prisma ORM. `mobile/` contains the React Native/Expo app using file-based routing (Expo Router) and NativeWind for styling. Separate `package.json` per workspace. Photos stored in S3-compatible object storage referenced by URL in PostgreSQL.

## Complexity Tracking

> No constitution violations detected. This section is intentionally empty.
