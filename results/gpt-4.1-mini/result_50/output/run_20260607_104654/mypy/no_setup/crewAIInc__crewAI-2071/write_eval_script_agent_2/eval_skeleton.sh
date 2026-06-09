#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout b6d668fc664c5f376626f06acdf48f9f462884e2 "tests/crew_test.py"

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

git checkout b6d668fc664c5f376626f06acdf48f9f462884e2 "tests/crew_test.py"

# Source .bashrc safely for non-interactive shells by ignoring errors, avoid PS1 unbound variable issue
# Then activate uv environment and run pytest on target test file only
set +u  # disable unbound variable check temporarily
source /root/.bashrc || true
set -u

uv activate
uv run pytest -r a --tb=short --capture=no tests/crew_test.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"