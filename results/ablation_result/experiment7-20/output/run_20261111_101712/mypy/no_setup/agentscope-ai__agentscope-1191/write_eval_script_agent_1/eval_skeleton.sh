#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout 9745c308740712f2734c0b3d04e27dd02ceaead3

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the requested test file with detailed output for test file status and minimal noise
# -rA: show all test outcomes (pass, fail, skip)
# --tb=no: no traceback to reduce noise
# --disable-warnings: optional to reduce output clutter
pytest --no-header -rA --tb=no tests/test_mem0_long_term_memory.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the modified test files to pristine state
git checkout 9745c308740712f2734c0b3d04e27dd02ceaead3 tests/test_mem0_long_term_memory.py