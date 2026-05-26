#!/usr/bin/env bash
set -euo pipefail

git init -q .
git config user.email "test@example.invalid"
git config user.name "Test"

cat > package.json <<'JSON'
{
  "name": "tiny-utils",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "lodash": "4.17.21",
    "chalk": "5.3.0"
  }
}
JSON

cat > package-lock.json <<'JSON'
{
  "name": "tiny-utils",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": {
      "name": "tiny-utils",
      "version": "1.0.0",
      "dependencies": {
        "lodash": "4.17.21",
        "chalk": "5.3.0"
      }
    },
    "node_modules/lodash": { "version": "4.17.21", "resolved": "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz" },
    "node_modules/chalk": { "version": "5.3.0", "resolved": "https://registry.npmjs.org/chalk/-/chalk-5.3.0.tgz" }
  }
}
JSON

cat > index.js <<'JS'
const _ = require('lodash');
console.log(_.kebabCase('hello world'));
JS

git add -A
git commit -q -m "initial"
