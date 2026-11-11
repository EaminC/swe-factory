#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout bad009c0fab91dfdde20872995f65da9b551d994

# Apply test patch to update target test files
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the Python virtual environment
source /testbed/testbed/bin/activate

# Run only the specified test file with pytest, showing concise test outcomes
pytest --no-header -rA --tb=short tests/test_flow_tool_async.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout bad009c0fab91dfdde20872995f65da9b551d994 tests/test_flow_tool_async.py