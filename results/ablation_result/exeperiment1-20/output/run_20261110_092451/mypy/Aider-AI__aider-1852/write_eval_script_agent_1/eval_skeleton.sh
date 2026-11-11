#!/bin/bash
set -uxo pipefail

# Activate Python virtual environment
source /opt/testbed/bin/activate

cd /testbed

# Checkout the exact commit version for the test files to ensure clean slate
git checkout 9789668ca4d14d3b6c24e56f3fe956147ea78039 "file.py" "tests/basic/test_commit_messages.py"

# Apply test patch (content replaced during execution)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified test files efficiently in one pytest invocation:
# Using: pytest with no header, all report info (-rA), no traceback (--tb=no),
# to keep output concise for analysis.
pytest --no-header -rA --tb=no file.py tests/basic/test_commit_messages.py

# Capture test command exit status
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modifications to test files back to original commit state to clean up
git checkout 9789668ca4d14d3b6c24e56f3fe956147ea78039 "file.py" "tests/basic/test_commit_messages.py"