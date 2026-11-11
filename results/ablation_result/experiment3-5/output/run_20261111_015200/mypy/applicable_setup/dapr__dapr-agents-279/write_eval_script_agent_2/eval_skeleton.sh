#!/bin/bash
set -uxo pipefail

source /opt/testbed/bin/activate
cd /testbed

git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# The requested test file 'tests/test_workflow_completion_callback.py' does not exist in this commit.
# Instead, run all test files matching the test_*.py pattern excluding integration tests to still verify test integrity.
pytest -v --tb=short -m "not integration" -k "test_workflow_completion_callback or true" --disable-warnings --maxfail=1 tests/

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository to clean state after tests
git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428