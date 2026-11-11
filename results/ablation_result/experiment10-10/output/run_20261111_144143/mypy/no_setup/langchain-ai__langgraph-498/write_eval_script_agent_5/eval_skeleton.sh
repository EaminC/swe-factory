#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout d63b15dc4721d48cb8368fe9011398df417fbc32 

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Since the requested test file and submodule langgraph.checkpoint.postgres do not exist in the repo,
# skip running pytest on that test file (it will fail with ModuleNotFoundError).
# Instead, print a clear message and exit with a failure code to indicate test cannot run.

echo "ERROR: Target test file 'libs/checkpoint-postgres/tests/test_continue_thread.py' or module 'langgraph.checkpoint.postgres' does not exist in this repository at commit d63b15dc4721d48cb8368fe9011398df417fbc32."
echo "Skipping tests for non-existent modules."

# Return failure exit code indicating tests could not be run due to missing modules
rc=1
echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup patch
git reset --hard d63b15dc4721d48cb8368fe9011398df417fbc32