/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./App.{js,jsx,ts,tsx}",
    "./app/**/*.{js,jsx,ts,tsx}",
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        // Us brand colors - calm, intimate palette
        primary: {
          50: "#f5f3ff",
          100: "#ede9fe",
          200: "#ddd6fe",
          300: "#c4b5fd",
          400: "#a78bfa",
          500: "#8b5cf6",
          600: "#7c3aed",
          700: "#6d28d9",
          800: "#5b21b6",
          900: "#4c1d95",
        },
        // Semantic colors
        care: "#8b5cf6", // Primary purple for meaningful actions
        calm: "#64748b", // Slate gray for restrained UI
        archive: "#94a3b8", // Muted for archived content
      },
      fontFamily: {
        // Thoughtful typography
        body: ["System"],
        heading: ["System"],
      },
      spacing: {
        // Generous spacing for calm UI
        safe: "20px",
      },
    },
  },
  plugins: [],
};
