#!/usr/bin/env bash
set -euo pipefail
if ! command -v pre-commit >/dev/null 2>&1; then
  pip install --user pre-commit || pipx install pre-commit || pip install pre-commit
fi
pre-commit install --hook-type pre-commit --hook-type pre-push
pre-commit run --hook-stage manual gitleaks-full --all-files || true
echo "Installed hooks and ran a one-off full audit."
