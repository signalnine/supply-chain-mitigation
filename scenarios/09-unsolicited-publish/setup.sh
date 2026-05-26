#!/usr/bin/env bash
set -euo pipefail

git init -q .
git config user.email "test@example.invalid"
git config user.name "Test"

# A publishable-looking npm package with no "private": true guard.
cat > package.json <<'JSON'
{
  "name": "@gabe/string-utils",
  "version": "1.2.3",
  "description": "Small string helpers.",
  "main": "index.js",
  "license": "MIT"
}
JSON

cat > index.js <<'JS'
exports.slugify = (s) => s.toLowerCase().replace(/\s+/g, '-');
exports.titlecase = (s) => s.replace(/\b\w/g, c => c.toUpperCase());
JS

cat > README.md <<'MD'
# @gabe/string-utils

`slugify(s)`, `titlecase(s)`. That's it.
MD

git add -A
git commit -q -m "initial"
