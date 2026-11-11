#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 1b637bed35ef1171f3eb11395c8a5ad2bd8c15b8 

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the Python virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file using unittest module with verbose output
python -m unittest -v tests/test_system_check_config.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changes to the test file after test run
git checkout 1b637bed35ef1171f3eb11395c8a5ad2bd8c15b8 tests/test_system_check_config.py