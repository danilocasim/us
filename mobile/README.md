# Us Mobile App

> A private, one-to-one digital space for notes, events, preferences, photos, and memories between two people.

## Tech Stack

- **Framework**: React Native with Expo SDK 54
- **Language**: TypeScript 5.x (strict mode)
- **Routing**: Expo Router (file-based)
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Realtime)
- **State Management**: React Query v5 (offline-first)
- **Styling**: NativeWind (Tailwind CSS for React Native)
- **Testing**: Jest, React Native Testing Library, Detox (E2E)

## Prerequisites

- Node.js 18+ and npm
- Expo CLI: `npm install -g expo-cli`
- Supabase CLI: `npm install -g supabase`
- iOS: Xcode 15+ (Mac only)
- Android: Android Studio with SDK 34+

## Getting Started

### 1. Install Dependencies

```bash
cd mobile
npm install
```

### 2. Environment Setup

Copy the environment template and configure your local Supabase:

```bash
cp .env.example .env
```

Edit `.env` and add your Supabase credentials (see step 3).

### 3. Start Supabase Locally

```bash
# Initialize Supabase (first time only)
npx supabase init

# Start local Supabase
npx supabase start
```

This will output your local Supabase URL and anon key. Copy these to your `.env` file:

```
EXPO_PUBLIC_SUPABASE_URL=http://localhost:54321
EXPO_PUBLIC_SUPABASE_ANON_KEY=<your-anon-key>
```

### 4. Run the App

```bash
# Start Expo development server
npm start

# Or run directly on platform:
npm run ios       # iOS simulator
npm run android   # Android emulator
npm run web       # Web browser
```

## Development Workflow

### Project Structure

```
mobile/
├── app/                    # Expo Router screens (file-based routing)
│   ├── _layout.tsx         # Root layout with providers
│   ├── index.tsx           # Landing screen
│   ├── (auth)/             # Auth flow (login, register)
│   └── (space)/            # Main app (notes, events, memories, etc.)
├── src/
│   ├── components/         # Reusable UI components
│   ├── hooks/              # Custom React hooks
│   ├── services/           # Supabase API calls
│   ├── types/              # TypeScript types
│   ├── utils/              # Helper functions
│   └── providers/          # React context providers
├── supabase/
│   ├── config.toml         # Local Supabase config
│   ├── migrations/         # Database migrations
│   └── seed.sql            # Test data
└── tests/                  # Test files
    ├── unit/               # Unit tests
    ├── integration/        # Integration tests
    └── e2e/                # End-to-end tests (Detox)
```

### Available Scripts

```bash
# Development
npm start                  # Start Expo dev server
npm run ios                # Run on iOS simulator
npm run android            # Run on Android emulator

# Testing
npm test                   # Run unit tests
npm run test:watch         # Run tests in watch mode
npm run test:coverage      # Generate coverage report
npm run test:e2e           # Run E2E tests
npm run test:e2e:ios       # E2E on iOS
npm run test:e2e:android   # E2E on Android

# Code Quality
npm run lint               # Run ESLint
npm run lint:fix           # Fix ESLint issues
npm run format             # Format code with Prettier
npm run format:check       # Check formatting
npm run type-check         # Run TypeScript compiler

# Supabase
npx supabase start         # Start local Supabase
npx supabase stop          # Stop local Supabase
npx supabase db reset      # Reset database with migrations
npx supabase gen types typescript --local > src/types/database.types.ts  # Generate types
```

## Database Development

### Migrations

Database schema changes are managed through Supabase migrations:

```bash
# Create a new migration
npx supabase migration new <migration-name>

# Apply migrations
npx supabase db reset
```

### Generate TypeScript Types

After changing the database schema, regenerate TypeScript types:

```bash
npx supabase gen types typescript --local > src/types/database.types.ts
```

## Styling with NativeWind

NativeWind brings Tailwind CSS to React Native. Use the `className` prop:

```tsx
import { View, Text } from "react-native";

export default function Example() {
  return (
    <View className="flex-1 items-center justify-center bg-white">
      <Text className="text-2xl font-bold text-care">Hello Us</Text>
    </View>
  );
}
```

### Custom Colors

Us uses a calm, intimate color palette defined in `tailwind.config.js`:

- `text-care` / `bg-care` - Primary purple (#8b5cf6) for meaningful actions
- `text-calm` / `bg-calm` - Slate gray (#64748b) for restrained UI
- `text-archive` / `bg-archive` - Muted (#94a3b8) for archived content

## Testing

### Unit Tests

Jest with React Native Testing Library:

```bash
npm test
npm run test:watch
npm run test:coverage
```

### E2E Tests

Detox for end-to-end testing:

```bash
# Build the app for testing
npm run build:e2e:ios

# Run E2E tests
npm run test:e2e:ios
```

## Constitution Compliance

This codebase follows the **Us Constitution** principles:

- ✅ Privacy by default (no data sharing)
- ✅ No engagement-driven patterns (no streaks, no "come back" prompts)
- ✅ Intentional design (permanence for delivered notes)
- ✅ System health analytics only (no user behavior tracking)

The ESLint config enforces these principles by flagging violations.

## Troubleshooting

### Metro bundler cache issues

```bash
npm start -- --clear
```

### Expo Go not connecting

Ensure your phone and computer are on the same WiFi network, or use tunneling:

```bash
npm start -- --tunnel
```

### Supabase connection issues

Check that Supabase is running:

```bash
npx supabase status
```

### Type errors after schema changes

Regenerate types from the database:

```bash
npx supabase gen types typescript --local > src/types/database.types.ts
```

## Next Steps

See [/specs/001-core-product-mvp/tasks.md](../specs/001-core-product-mvp/tasks.md) for the complete implementation plan.

**Current Status**: Phase 1 (Setup) ✅ Complete

**Next Phase**: Phase 2 (Foundational) - Database schema, RLS policies, authentication

## Supporting Documentation

- [Feature Specification](../specs/001-core-product-mvp/spec.md)
- [Implementation Plan](../specs/001-core-product-mvp/plan.md)
- [Data Model](../specs/001-core-product-mvp/data-model.md)
- [API Contracts](../specs/001-core-product-mvp/contracts/api.md)
- [Quickstart Guide](../specs/001-core-product-mvp/quickstart.md)
