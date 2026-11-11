#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout ca4141564f86dd1b7dee3082959042dc05d5d471

# Apply test patch if required
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment
source ./testbed-venv/bin/activate

# Run only the specified test file with pytest, showing concise test results and test file names
pytest --no-header -rA --tb=no tests/basic/test_sendchat.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes after test run
git checkout ca4141564f86dd1b7dee3082959042dc05d5d471