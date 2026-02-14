import "../global.css";
import { Slot } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { QueryClientProvider } from "@tanstack/react-query";
import { useState } from "react";
import { createQueryClient } from "../src/utils/queryClient";

/**
 * Root layout for the Us application
 *
 * This layout wraps the entire app and provides:
 * - React Query client for data fetching and caching
 * - NativeWind CSS support (imported via global.css)
 * - Status bar configuration
 *
 * Future additions:
 * - AuthProvider (Phase 2: Foundational)
 * - Error boundaries
 */
export default function RootLayout() {
  // Create Query Client instance with default options
  const [queryClient] = useState(() => createQueryClient());

  return (
    <QueryClientProvider client={queryClient}>
      <StatusBar style="auto" />
      <Slot />
    </QueryClientProvider>
  );
}
