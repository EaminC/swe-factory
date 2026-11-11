#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout ba6a627de8f756f0c628d4cc0086c08748922eb6

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file with pytest; output concise test results
pytest --no-header -rA --tb=short tests/mem0_utils_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file after running tests
git checkout ba6a627de8f756f0c628d4cc0086c08748922eb6 tests/mem0_utils_test.py