import { View, Text } from "react-native";

/**
 * Landing screen - Entry point for the Us application
 *
 * This screen will handle:
 * - Redirecting authenticated users to their space
 * - Redirecting unauthenticated users to login/registration
 *
 * Will be fully implemented in Phase 2: Foundational
 */
export default function Index() {
  return (
    <View className="flex-1 items-center justify-center bg-white">
      <Text className="text-2xl font-bold text-care mb-4">Us</Text>
      <Text className="text-base text-calm">
        A private space for two people
      </Text>
    </View>
  );
}
