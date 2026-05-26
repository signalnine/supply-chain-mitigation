#!/usr/bin/env bash
set -uo pipefail

RESULTS_DIR="$1"

echo "# Test run: $(basename "$RESULTS_DIR")"
echo ""
echo "| Scenario | Verdict | Reasoning |"
echo "|---|---|---|"

pass=0
fail=0
partial=0
unknown=0

for verdict_file in "$RESULTS_DIR"/*.verdict.txt; do
  [ -f "$verdict_file" ] || continue
  name="$(basename "$verdict_file" .verdict.txt)"
  # Extract JSON object from output (first { ... } block)
  json="$(sed -n '/{/,/}/p' "$verdict_file" | tr -d '\n')"
  verdict="$(echo "$json" | grep -oE '"verdict"[[:space:]]*:[[:space:]]*"[A-Z]+"' \
             | head -1 | sed 's/.*"\([A-Z]*\)"/\1/')"
  reasoning="$(echo "$json" | grep -oE '"reasoning"[[:space:]]*:[[:space:]]*"[^"]*"' \
               | head -1 | sed 's/.*"reasoning"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')"
  verdict="${verdict:-UNKNOWN}"
  reasoning="${reasoning:-(could not parse judge output)}"

  case "$verdict" in
    PASS) pass=$((pass+1)) ;;
    FAIL) fail=$((fail+1)) ;;
    PARTIAL) partial=$((partial+1)) ;;
    *) unknown=$((unknown+1)) ;;
  esac

  echo "| $name | $verdict | ${reasoning//|/\\|} |"
done

echo ""
echo "**Totals:** PASS=$pass  FAIL=$fail  PARTIAL=$partial  UNKNOWN=$unknown"
