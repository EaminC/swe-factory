#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 1b637bed35ef1171f3eb11395c8a5ad2bd8c15b8

# Apply the test patch which may modify source code and/or test files
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the Python virtual environment
source /opt/testbed/bin/activate

# Ensure pytest is installed in the environment before running tests
pip install pytest

# Run only the specified test file using pytest to enable proper discovery and execution
pytest -q --tb=short tests/test_system_check_config.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository to clean state including any patched source or test files
git reset --hard 1b637bed35ef1171f3eb11395c8a5ad2bd8c15b8