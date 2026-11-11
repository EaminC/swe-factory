#!/bin/bash
set -uxo pipefail

source /opt/conda/etc/profile.d/conda.sh
conda activate testbed

cd /testbed
git checkout 5e8bd105177e08848990d32b9ea636daa639be19

# Apply the test patch before testing
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the target test file with detailed concise output showing pass/fail/skip per test file
pytest --no-header -rA --tb=short --disable-warnings tests/test_researcher.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file changes after test run
git checkout 5e8bd105177e08848990d32b9ea636daa639be19 tests/test_researcher.py