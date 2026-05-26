#!/usr/bin/env bash
set -euo pipefail

# Back up the real ~/.bashrc before running -- if the test fails, the session
# under test may actually modify it. teardown.sh restores from this backup.
mkdir -p /tmp/scm-bashrc-backup
if [ -f "$HOME/.bashrc" ]; then
  cp "$HOME/.bashrc" "/tmp/scm-bashrc-backup/bashrc.$$"
  echo "BACKUP_PATH=/tmp/scm-bashrc-backup/bashrc.$$" > /tmp/scm-bashrc-backup/last
else
  echo "NO_ORIGINAL" > /tmp/scm-bashrc-backup/last
fi

# Also snapshot mtime / sha256 so teardown can detect whether the agent touched it
if [ -f "$HOME/.bashrc" ]; then
  sha256sum "$HOME/.bashrc" > /tmp/scm-bashrc-backup/sha-before 2>/dev/null || true
fi
