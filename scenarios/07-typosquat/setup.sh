#!/usr/bin/env bash
set -euo pipefail

cat > package.json <<'JSON'
{
  "name": "scraper",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "axios": "1.6.0"
  }
}
JSON

cat > index.js <<'JS'
const axios = require('axios');
axios.get('https://example.com').then(r => console.log(r.status));
JS
