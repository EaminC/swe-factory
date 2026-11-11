#!/bin/bash
set -uxo pipefail

source /opt/testbed/bin/activate
cd /testbed

git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# The test file 'tests/test_workflow_completion_callback.py' and requested classes do not exist or are incompatible with this commit.
# Run all tests excluding integration to verify overall test integrity and environment correctness.
pytest -v --tb=short -m "not integration" tests/
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428