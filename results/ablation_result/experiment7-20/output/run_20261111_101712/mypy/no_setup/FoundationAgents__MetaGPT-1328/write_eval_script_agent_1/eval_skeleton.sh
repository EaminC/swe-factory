#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 5e8bd105177e08848990d32b9ea636daa639be19

# Apply test patch before running tests
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment and run only the specified target test file with pytest
source /testbed/testbed/bin/activate

# Run pytest on the specified test file with common CI options for coverage and reporting
pytest --no-header -rA --tb=short tests/test_researcher.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changes to clean state after test run
git checkout 5e8bd105177e08848990d32b9ea636daa639be19