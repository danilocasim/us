import { QueryClient } from "@tanstack/react-query";

/**
 * Default React Query configuration for Us
 *
 * Optimized for offline-first experience:
 * - Prioritizes cached data
 * - Retries failed requests
 * - Longer stale time for better offline experience
 * - Does not refetch on window focus (mobile doesn't have window focus)
 */
export const queryClientConfig = {
  defaultOptions: {
    queries: {
      // Keep data fresh but prioritize cached data
      staleTime: 1000 * 60, // 1 minute
      gcTime: 1000 * 60 * 60 * 24, // 24 hours

      // Retry configuration
      retry: 2,
      retryDelay: (attemptIndex: number) =>
        Math.min(1000 * 2 ** attemptIndex, 30000),

      // Mobile-specific: Don't refetch on window focus
      refetchOnWindowFocus: false,
      refetchOnMount: true,
      refetchOnReconnect: true,

      // Network mode: Always try cache first
      networkMode: "online" as const,
    },
    mutations: {
      // Retry failed mutations once
      retry: 1,

      // Network mode for mutations
      networkMode: "online" as const,
    },
  },
};

/**
 * Create a new QueryClient instance with Us defaults
 *
 * Use this function in your root layout to initialize React Query:
 *
 * ```tsx
 * const [queryClient] = useState(() => createQueryClient());
 * ```
 */
export function createQueryClient(): QueryClient {
  return new QueryClient(queryClientConfig);
}

/**
 * Query key factory for consistent cache keys across the app
 *
 * Usage:
 * ```tsx
 * const { data } = useQuery({
 *   queryKey: queryKeys.notes.list(spaceId),
 *   // ...
 * });
 * ```
 */
export const queryKeys = {
  // Auth queries
  auth: {
    session: ["auth", "session"] as const,
    user: ["auth", "user"] as const,
  },

  // Space queries
  spaces: {
    all: ["spaces"] as const,
    active: ["spaces", "active"] as const,
    detail: (id: string) => ["spaces", id] as const,
  },

  // Invitation queries
  invitations: {
    all: ["invitations"] as const,
    detail: (token: string) => ["invitations", token] as const,
  },

  // Note queries
  notes: {
    all: ["notes"] as const,
    list: (spaceId: string) => ["notes", "list", spaceId] as const,
    detail: (id: string) => ["notes", id] as const,
    drafts: ["notes", "drafts"] as const,
  },

  // Event queries
  events: {
    all: ["events"] as const,
    list: (spaceId: string) => ["events", "list", spaceId] as const,
    detail: (id: string) => ["events", id] as const,
  },

  // Preference queries
  preferences: {
    all: ["preferences"] as const,
    list: (spaceId: string) => ["preferences", "list", spaceId] as const,
  },

  // Memory queries
  memories: {
    all: ["memories"] as const,
    list: (spaceId: string) => ["memories", "list", spaceId] as const,
    detail: (id: string) => ["memories", id] as const,
  },

  // Notification queries
  notifications: {
    all: ["notifications"] as const,
    list: (userId: string) => ["notifications", "list", userId] as const,
    unread: (userId: string) => ["notifications", "unread", userId] as const,
  },
};
