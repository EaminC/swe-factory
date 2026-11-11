#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout a74c5ebcf0abf9db63abf3ba39ac123f6f74eb82

# Apply the test patch to update target tests
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the venv environment before running pytest
source /testbed/testbed-venv/bin/activate

# Run only the specified test file with pytest showing concise pass/fail/skip statuses
pytest --maxfail=1 --disable-warnings -q --tb=short tests/core/test_token_usage.py
rc=$?            # Required, save exit code

echo "OMNIGRIL_EXIT_CODE=$rc" # Required, echo test status

# Reset any changes in the test file after running tests
git checkout a74c5ebcf0abf9db63abf3ba39ac123f6f74eb82 tests/core/test_token_usage.py