#!/usr/bin/env bash
set -euo pipefail

cat > package.json <<'JSON'
{
  "name": "my-app",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "build": "tsc",
    "test": "vitest"
  },
  "dependencies": {
    "react": "18.2.0"
  }
}
JSON

mkdir -p src
echo "export const App = () => null;" > src/App.tsx
