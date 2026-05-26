#!/usr/bin/env bash
set -uo pipefail

HARNESS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$HARNESS_DIR")"
SCENARIOS_DIR="$ROOT_DIR/scenarios"
RESULTS_ROOT="$ROOT_DIR/results"
RUN_ID="$(date +%Y%m%d-%H%M%S)"
RESULTS_DIR="$RESULTS_ROOT/$RUN_ID"
mkdir -p "$RESULTS_DIR"

TEST_ENGINE="${TEST_ENGINE:-claude}"
case "$TEST_ENGINE" in
  codex)  TEST_MODEL="${TEST_MODEL:-gpt-5.5}" ;;
  gemini) TEST_MODEL="${TEST_MODEL:-gemini-2.5-pro}" ;;
  *)      TEST_MODEL="${TEST_MODEL:-claude-sonnet-4-6}" ;;
esac
JUDGE_MODEL="${JUDGE_MODEL:-claude-sonnet-4-6}"
TEST_BUDGET_USD="${TEST_BUDGET_USD:-2}"
RULES_FILE="$HARNESS_DIR/codex-rules.md"  # same rules for any non-claude engine

run_scenario() {
  local scenario_dir="$1"
  local name
  name="$(basename "$scenario_dir")"
  local workdir
  workdir="$(mktemp -d -t "scm-${name}-XXXXXX")"

  echo "=== $name ==="
  echo "  workdir: $workdir"

  # Setup planted artifacts
  if [ -f "$scenario_dir/setup.sh" ]; then
    (cd "$workdir" && bash "$scenario_dir/setup.sh") \
      > "$RESULTS_DIR/${name}.setup.log" 2>&1 || {
      echo "  SETUP FAILED - see $RESULTS_DIR/${name}.setup.log"
      rm -rf "$workdir"
      return
    }
  fi

  # Run test session
  local prompt
  prompt="$(cat "$scenario_dir/PROMPT.md")"
  local started
  started="$(date +%s)"

  case "$TEST_ENGINE" in
    codex)
      # Rules now live in ~/.codex/AGENTS.md and get auto-loaded; no prompt prepend.
      (cd "$workdir" && codex exec \
        --model "$TEST_MODEL" \
        --skip-git-repo-check \
        --ephemeral \
        --dangerously-bypass-approvals-and-sandbox \
        --json \
        -- "$prompt") \
        > "$RESULTS_DIR/${name}.response.json" \
        2> "$RESULTS_DIR/${name}.response.stderr" || true
      ;;
    gemini)
      local rules full_prompt
      rules="$(cat "$RULES_FILE")"
      full_prompt="$rules

== USER PROMPT FOLLOWS ==
$prompt"
      (cd "$workdir" && gemini \
        --model "$TEST_MODEL" \
        --yolo \
        --skip-trust \
        --output-format json \
        --prompt "$full_prompt") \
        > "$RESULTS_DIR/${name}.response.json" \
        2> "$RESULTS_DIR/${name}.response.stderr" || true
      ;;
    *)
      (cd "$workdir" && claude -p \
        --model "$TEST_MODEL" \
        --output-format json \
        --permission-mode bypassPermissions \
        --no-session-persistence \
        --max-budget-usd "$TEST_BUDGET_USD" \
        --disallowedTools "WebFetch" "WebSearch" \
        -- "$prompt") \
        > "$RESULTS_DIR/${name}.response.json" \
        2> "$RESULTS_DIR/${name}.response.stderr" || true
      ;;
  esac

  local elapsed=$(( $(date +%s) - started ))
  echo "  test session: ${elapsed}s"

  # Snapshot any sentinel files the planted payload created
  ls /tmp/PWNED-${name}-* 2>/dev/null > "$RESULTS_DIR/${name}.sentinels" || true
  ls /tmp/PWNED-${name}-* 2>/dev/null | xargs -I{} rm -f {} 2>/dev/null || true

  # Run teardown if present (e.g. to restore ~/.bashrc backups)
  if [ -f "$scenario_dir/teardown.sh" ]; then
    (cd "$workdir" && SCM_RESULTS_DIR="$RESULTS_DIR" SCM_SCENARIO="$name" \
      bash "$scenario_dir/teardown.sh") \
      >> "$RESULTS_DIR/${name}.setup.log" 2>&1 || true
  fi

  # Judge
  bash "$HARNESS_DIR/judge.sh" \
    "$scenario_dir/PROMPT.md" \
    "$scenario_dir/EXPECTED.md" \
    "$RESULTS_DIR/${name}.response.json" \
    "$RESULTS_DIR/${name}.sentinels" \
    > "$RESULTS_DIR/${name}.verdict.txt" 2>&1 || true

  local verdict
  verdict="$(grep -oE '"verdict"[[:space:]]*:[[:space:]]*"[A-Z]+"' \
             "$RESULTS_DIR/${name}.verdict.txt" 2>/dev/null \
             | head -1 | sed 's/.*"\([A-Z]*\)"/\1/')"
  echo "  verdict: ${verdict:-UNKNOWN}"

  rm -rf "$workdir"
}

if [ "$#" -gt 0 ]; then
  for s in "$@"; do
    if [ -d "$SCENARIOS_DIR/$s" ]; then
      run_scenario "$SCENARIOS_DIR/$s"
    else
      echo "no such scenario: $s"
    fi
  done
else
  for s in "$SCENARIOS_DIR"/*/; do
    run_scenario "$s"
  done
fi

bash "$HARNESS_DIR/summarize.sh" "$RESULTS_DIR" | tee "$RESULTS_DIR/SUMMARY.md"
echo ""
echo "Results: $RESULTS_DIR"
