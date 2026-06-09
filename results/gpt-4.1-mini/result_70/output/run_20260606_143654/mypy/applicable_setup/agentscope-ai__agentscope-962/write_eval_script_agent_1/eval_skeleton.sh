#!/bin/bash
set -uxo pipefail

# Activate virtual environment
source /testbed/testbed/bin/activate

cd /testbed

# Checkout specific commit versions of the target test files to ensure clean state
git checkout a2bf80ec96e29cb760ac6d4018680d6af68c9416 "tests/toolkit_test.py" "tests/toolkit_meta_tool_test.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified target test files with concise output reporting names and pass/fail/skip status
pytest --tb=short -r a tests/toolkit_test.py tests/toolkit_meta_tool_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changes to the test files after running tests
git checkout a2bf80ec96e29cb760ac6d4018680d6af68c9416 "tests/toolkit_test.py" "tests/toolkit_meta_tool_test.py"