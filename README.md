# Leak Guard — Secrets Prevention and Detection (Template)

Leak Guard — Secrets Prevention and Detection (Template)

Leak Guard is a ready-to-use template for stopping secrets from slipping into source control. It gives you three guardrails:

Pre-commit — fast scan of staged changes on developer laptops

Pre-push — full working-tree scan on developer laptops

Pull Request scan (GitHub Actions) — checks PRs, uploads a JSON report, and opens an Issue when a leak is found

It ships with a comprehensive .gitleaks.toml ruleset that covers common cloud providers, service tokens, webhooks, database URLs, JWTs, and generic patterns.

Who this is for

Teams who want a practical, low-friction way to prevent and detect leaked keys and tokens

Individual developers who want better safety checks on their machine

Security champions who need evidence of continuous improvement and reduced exposure time

What you get
leak-guard/
├─ .gitleaks.toml                    # Comprehensive ruleset
├─ .gitleaksignore                   # Optional allow-list (empty)
├─ .pre-commit-config.yaml           # Pre-commit + pre-push hooks
├─ .github/workflows/
│  └─ secret-scan.yml                # PR scan + JSON artifact + auto-issue
├─ scripts/
│  ├─ dev-bootstrap.sh               # One-liner to install hooks on laptops
│  ├─ add_fake_secret.sh             # Safe drill script (adds fake secret)
│  └─ remove_fake_secret.sh          # Cleans up the fake secret
├─ docs/
│  ├─ MTTR-metrics.md                # Simple table to track time to fix
│  └─ REVOCATION-PLAYBOOK.md         # First-hour response checklist
├─ SECURITY.md
├─ CODEOWNERS
├─ PULL_REQUEST_TEMPLATE.md
├─ .gitignore
└─ LICENSE

Quick start (as a template)
Make this repository a template

Push this repository to GitHub as leak-guard

On GitHub: Settings → General → Template repository → tick it

Optional hardening: Settings → Branches → Add rule for main

Require pull request before merging

Require status checks to pass (select secret-scan)

Restrict who can push to main if you wish

Use the template

Click Use this template → Create a new repository

Clone your new repository

Run the developer setup below

Developer setup (laptop guardrails)

From the repository root:

pip install pre-commit
pre-commit install --hook-type pre-commit --hook-type pre-push
# optional one-off full audit
pre-commit run --hook-stage manual gitleaks-full --all-files || true


Commit guard runs on git commit and scans staged changes

Push guard runs on git push and scans the working tree

Both use the rules in .gitleaks.toml at the repo root

Tip: If pre-commit is not available, install it with pipx install pre-commit or pip install --user pre-commit.

Pull Request scan (GitHub Actions)

The workflow at .github/workflows/secret-scan.yml runs on each pull request. When a leak is found it will:

Fail the check

Upload a gitleaks-report.json artifact

Open a GitHub Issue with links to the failing run

Required job permissions are set in the workflow:

permissions:
  contents: read
  pull-requests: write
  issues: write


If actions are disabled for your organisation, enable them for this repository under the Actions tab.

Prove it works (safe drill)

Run the following to show all three guards in action:

# add a fake secret to README.md
bash scripts/add_fake_secret.sh

# 1) Commit guard should block
git add README.md
git commit -m "demo: add fake secret"   # expect: blocked

# 2) Bypass commit guard (demo only) and try to push
git commit -m "demo: bypass commit guard" --no-verify
git push                                  # expect: blocked by pre-push

# 3) CI guard proof
bash scripts/remove_fake_secret.sh
git add README.md && git commit -m "cleanup: remove fake secret"
git checkout -b demo/reintroduce
bash scripts/add_fake_secret.sh
git add README.md && git commit -m "demo: reintroduce fake secret"
git push -u origin demo/reintroduce
# Open a PR → the Action fails, JSON artifact is uploaded, an Issue is opened

Tuning the rules

The rules live in .gitleaks.toml. The default is broad to catch many patterns. You can reduce noise using these steps:

Allow-list safe folders
Add paths to [allowlist].paths for tutorials, examples and fixtures

Tighten noisy rules
If a rule matches harmless text, add context words or shorten the scope

Use .gitleaksignore sparingly
Record the file and a brief reason. Keep this short to avoid masking real problems

Review monthly
Tweak rules and keep a short changelog in your security notes

Do not remove high-value rules without a plan. It is safer to narrow them.

Tracking time to fix

Use docs/MTTR-metrics.md to record:

How many leaks the PR scan caught this month

Time from detection to fix

Top rules that fired and any tuning that was needed

The pull request Issue that is opened on failure gives you useful timestamps to copy across.

Recommended governance

Add security reviewers for important files in CODEOWNERS

.gitleaks.toml

.github/workflows/*

.pre-commit-config.yaml

Protect main so changes flow through pull requests and checks

Make security scanning part of your standard pull request review

Day-to-day use

Developers

Work as normal. If a secret pattern appears in your staged changes, git commit will fail with a clear message

If you bypass the commit guard, the pre-push guard scans the whole tree and blocks the push if a secret is present

If it still reaches a pull request, the workflow fails, uploads a report and opens an Issue

Reviewers

Check the pull request status. If the secret scan failed, open the artifact for detail and follow the Issue to coordinate the fix

Security

Tune the rules as the stack changes

Track time to fix once a month and share trends

Fixing a real leak

Remove the secret from code
Replace with configuration that reads from an environment variable or a managed secret store

Rotate or revoke at the source
Follow docs/REVOCATION-PLAYBOOK.md for common services

Check logs around the window of exposure
Look for unusual use

Record detection and fix times
Update the auto-opened Issue and docs/MTTR-metrics.md

If the secret was committed to history, consider using a history-rewrite tool such as BFG Repo-Cleaner to strip old commits, then force push. Coordinate this with your team first as it changes commit history.

Running a one-off full audit

You can run a full repository audit locally at any time:

pre-commit run --hook-stage manual gitleaks-full --all-files


Or run Gitleaks directly if you have the binary installed:

gitleaks detect --config .gitleaks.toml --redact --exit-code 1

Updating Gitleaks

Local hooks: update .pre-commit-config.yaml to the new tag, then run:

pre-commit autoupdate


Workflow: update the version in secret-scan.yml in the install step

Commit both changes in one pull request.

Common questions

Can developers bypass the commit guard?
Yes, with --no-verify, which is why there is a pre-push guard that scans the whole tree, and a pull request guard in CI.

Why did commit pass but the push failed?
The commit guard scans staged changes only. The push guard scans the working tree. It likely found something un-staged or outside the original diff.

Why did the workflow fail to open an Issue?
Check the job permissions in the workflow. They must include issues: write and pull-requests: write.

We keep getting false alarms. What should we do?
Add safe folders to the allow-list, then narrow or adjust the rule. Avoid blanket ignores.

Troubleshooting

Pre-push is not running
Reinstall hooks:

pre-commit install --hook-type pre-push


The workflow cannot download Gitleaks
Verify network egress, and that the release URL in the workflow is correct

The workflow shows success but there was a leak
Check that .gitleaks.toml is at the repository root and not renamed, and confirm your patterns cover the secret type

Contributing

Propose rule changes in pull requests

Keep .gitleaks.toml changes small and well explained

Update docs/MTTR-metrics.md if your change affects reporting

Use the pull request template to confirm you did not add credentials

Security

Do not add real secrets to this repository or to pull requests. If you accidentally do, follow the revocation playbook and contact the maintainers privately.

See SECURITY.md.

Licence

MIT. See LICENSE.

Credits

Leak Guard is built around pre-commit and Gitleaks, and uses a GitHub Actions workflow to automate checks on pull requests.

If you need a version tailored to your organisation’s stack, you can extend .gitleaks.toml with vendor-specific patterns and adjust the allow-list to suit your repo layout.
