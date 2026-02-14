module.exports = {
  extends: ["expo", "plugin:@typescript-eslint/recommended", "prettier"],
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint"],
  root: true,
  env: {
    node: true,
    "react-native/react-native": true,
  },
  rules: {
    // TypeScript specific rules
    "@typescript-eslint/no-unused-vars": [
      "error",
      {
        argsIgnorePattern: "^_",
        varsIgnorePattern: "^_",
      },
    ],
    "@typescript-eslint/no-explicit-any": "warn",
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/explicit-module-boundary-types": "off",

    // React/React Native rules
    "react-hooks/rules-of-hooks": "error",
    "react-hooks/exhaustive-deps": "warn",

    // General best practices
    "no-console": ["warn", { allow: ["warn", "error"] }],
    "prefer-const": "error",
    "no-var": "error",

    // Constitution compliance - ethical boundaries
    "no-restricted-syntax": [
      "error",
      {
        selector: "CallExpression[callee.property.name='track']",
        message:
          "Avoid analytics that track user behavior. System health only.",
      },
    ],
  },
  ignorePatterns: ["node_modules/", "dist/", "build/", ".expo/", "coverage/"],
};
