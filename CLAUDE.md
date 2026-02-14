# us Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-02-14

## Active Technologies

- TypeScript 5.x (mobile app and Supabase integrations) (001-core-product-mvp)
- React Native (cross-platform mobile development) (001-core-product-mvp)
- Expo (managed build workflow and native modules) (001-core-product-mvp)
- Expo Router (file-based routing) (001-core-product-mvp)
- Supabase (PostgreSQL database, Authentication, Storage, Realtime) (001-core-product-mvp)
- React Query (data fetching and offline caching) (001-core-product-mvp)
- NativeWind (Tailwind CSS for React Native) (001-core-product-mvp)
- Jest + React Native Testing Library (unit testing) (001-core-product-mvp)
- Detox (end-to-end testing) (001-core-product-mvp)

## Project Structure

```text
mobile/
├── app/                      # Expo Router screens (file-based routing)
│   ├── _layout.tsx           # Root layout
│   ├── (auth)/               # Auth screens route group
│   └── (space)/              # Main app route group
├── src/
│   ├── components/           # Reusable UI components
│   ├── hooks/                # Custom React hooks
│   ├── services/             # Supabase client calls
│   ├── types/                # TypeScript types (including generated)
│   └── utils/                # Helper functions
├── supabase/
│   ├── migrations/           # Database migrations
│   └── seed.sql              # Test data
└── tests/                    # Test files
```

## Commands

```bash
# Local Development
npx supabase start           # Start local Supabase backend
npx expo start               # Start mobile dev server
npm test                     # Run unit tests

# Database
npx supabase db reset        # Reset and apply migrations
npx supabase gen types typescript --local > src/types/database.types.ts  # Generate types

# Testing
npm test -- --watch          # Watch mode
npm test -- --coverage       # With coverage

# Linting
npm run lint                 # Run ESLint
npx tsc --noEmit            # Type check
```

## Code Style

- TypeScript 5.x: Follow strict mode, enable all checks
- React Native: Use functional components with hooks
- File organization: Group by feature, not by type
- Naming: PascalCase for components, camelCase for functions/variables
- Imports: Absolute imports using path aliases (`@/components/...`)
- Async: Use async/await, not promises chains
- Error handling: Use try/catch with proper error types
- RLS First: All database access filtered by Row-Level Security
- Offline First: Use React Query for caching, AsyncStorage for drafts
- Supabase Client: Use typed client with generated Database types

## Recent Changes

- 001-core-product-mvp: Added TypeScript 5.x (both frontend and backend)
- 001-core-product-mvp: Added React Native + Expo for mobile development
- 001-core-product-mvp: Added Supabase as integrated backend platform
- 001-core-product-mvp: Added React Query for offline-first data fetching
- 001-core-product-mvp: Added NativeWind for styling with Tailwind CSS

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
