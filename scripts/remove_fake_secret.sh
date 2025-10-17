#!/usr/bin/env bash
set -euo pipefail
if [[ -f "README.md" ]]; then
  sed -i.bak '/^# DEMO SECRETS (for training only)/,$d' README.md || true
  sed -i.bak '/AKIA1234567890ABCD/d' README.md || true
  sed -i.bak '/wJalrXUtnFEMI\/K7MDENG\/bPxRfiCYEXAMPLEKEY/d' README.md || true
  sed -i.bak '/hooks.slack.com\/services\/T00000000\/B00000000\/XXXXXXXXXXXXXXXXXXXX/d' README.md || true
  rm -f README.md.bak
  echo "Removed fake secrets from README.md."
else
  echo "README.md not found; nothing to clean."
fi
