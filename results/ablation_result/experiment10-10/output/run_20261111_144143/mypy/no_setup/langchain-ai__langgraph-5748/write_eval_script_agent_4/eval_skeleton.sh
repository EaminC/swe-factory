#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 18887e9f86a6d8675a2b4aed03a1c190ef6e1581

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run pytest on the specified test file with detailed flags and environment setup
LANGGRAPH_TEST_FAST=1 pytest libs/prebuilt/tests/test_create_react_agent_type.py --strict-markers --strict-config --durations=5 -vv
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset all changes to clean repository state after tests
git reset --hard 18887e9f86a6d8675a2b4aed03a1c190ef6e1581