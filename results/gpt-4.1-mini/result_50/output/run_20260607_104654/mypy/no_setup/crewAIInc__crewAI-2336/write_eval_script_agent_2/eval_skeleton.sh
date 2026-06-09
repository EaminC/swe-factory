#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout b992ee9d6b604993b3cc09ae366e314f68f78705 "tests/config/agents.yaml" "tests/project_test.py"

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /testbed/testbed/bin/activate

# Run only the valid Python test file with verbose output and short traceback
uv run pytest -v --tb=short tests/project_test.py

rc=$?  # Capture exit code immediately after test run

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the patched test files to original commit state
git checkout b992ee9d6b604993b3cc09ae366e314f68f78705 "tests/config/agents.yaml" "tests/project_test.py"