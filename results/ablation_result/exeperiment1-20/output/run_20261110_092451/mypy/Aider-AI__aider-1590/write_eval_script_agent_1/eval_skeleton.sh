#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout ca4141564f86dd1b7dee3082959042dc05d5d471

# Apply the required test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the python virtual environment
source /testbed/testbed-venv/bin/activate

# Run the specified test file only, output concise results with names and pass/fail/skip statuses
pytest --no-header -rA --tb=no tests/basic/test_sendchat.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the patched files to original state
git checkout ca4141564f86dd1b7dee3082959042dc05d5d471