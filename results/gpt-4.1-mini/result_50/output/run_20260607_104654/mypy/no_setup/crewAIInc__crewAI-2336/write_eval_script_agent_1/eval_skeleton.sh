#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout b992ee9d6b604993b3cc09ae366e314f68f78705 "tests/config/agents.yaml" "tests/project_test.py"

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate python virtual environment
source /testbed/testbed/bin/activate

# Run only the specified test files with verbose and show summary of each test’s outcome
pytest -v -rA "tests/config/agents.yaml" "tests/project_test.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout b992ee9d6b604993b3cc09ae366e314f68f78705 "tests/config/agents.yaml" "tests/project_test.py"