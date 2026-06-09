#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout b6d668fc664c5f376626f06acdf48f9f462884e2 "tests/crew_test.py"

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate UV venv 'testbed' and run only the specified test file with pytest via uv
# Output test names and pass/fail/skip with concise but informative pytest options
source ~/.bashrc
uv activate testbed
uv run pytest -r a --tb=short --capture=no tests/crew_test.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout b6d668fc664c5f376626f06acdf48f9f462884e2 "tests/crew_test.py"