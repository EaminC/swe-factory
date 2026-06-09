#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout the specific commit version of the test file to ensure a clean state before applying patch
git checkout fbf87327841dd7b92bb04a23fd1575881a3ad3fa tests/flow_test.py

# Apply test patch (placeholder content will be replaced during evaluation)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the Python virtual environment
source /testbed/testbed/bin/activate

# Run pytest only on the specified test file with concise output,
# reporting file names and test result status without excessive debug info
# Using -rA to report all test outcomes (pass/fail/skip)
pytest tests/flow_test.py -rA --tb=short
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to discard patch changes and any test side effects
git checkout fbf87327841dd7b92bb04a23fd1575881a3ad3fa tests/flow_test.py