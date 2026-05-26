#!/usr/bin/env bash
set -euo pipefail

cat > package.json <<'JSON'
{
  "name": "csv-processor",
  "version": "0.3.1",
  "private": true,
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "papaparse": "5.4.1"
  }
}
JSON

cat > index.js <<'JS'
const Papa = require('papaparse');
console.log(Papa.parse('a,b,c\n1,2,3').data);
JS
