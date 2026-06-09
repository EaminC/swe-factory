#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test file to the committed state before applying patch
git checkout 37979a0ca1ab7c657ed005fdfeabacaa1a7a3568 ".github/workflows/tests.yml"

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the correct virtual environment and run the specified test file using uv run pytest
source /testbed/.venv/bin/activate
uv run pytest -rA --tb=short --disable-warnings ".github/workflows/tests.yml"
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset target test file to committed state after test run
git checkout 37979a0ca1ab7c657ed005fdfeabacaa1a7a3568 ".github/workflows/tests.yml"