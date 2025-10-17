#!/usr/bin/env bash
set -euo pipefail
touch README.md
cat >> README.md <<'EOF'

# DEMO SECRETS (for training only)
AWS_ACCESS_KEY_ID=AKIA1234567890ABCD
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXX
EOF
echo "Added fake secrets to README.md (for demo only)."
