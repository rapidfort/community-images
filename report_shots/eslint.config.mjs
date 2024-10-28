import globals from "globals";
import pluginJs from "@eslint/js";



export default [
  // Main configuration for JavaScript files
  {
    files: ["**/*.js"],
    languageOptions: {
      sourceType: "script",
      globals: globals.node,
    },
    rules: {
      "no-unused-vars": "warn", // Explicitly set as warning
    },
  },

  // Ensure this part also has `no-unused-vars` set to "warn"
  {
    ...pluginJs.configs.recommended,
    rules: {
      ...pluginJs.configs.recommended.rules,
      "no-unused-vars": "warn", // Override here as well
    },
  },
];