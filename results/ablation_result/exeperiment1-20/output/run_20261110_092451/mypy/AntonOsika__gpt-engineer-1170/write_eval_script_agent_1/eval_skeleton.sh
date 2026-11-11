#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 3e589bf1356024fb471a9d17738e4626f21a953b

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate poetry virtual environment and run the specific test file with pytest
# We show file name, result summary and avoid unrelated verbosity
source /testbed/.venv/bin/activate

poetry run pytest --no-header -rA --tb=short tests/test_azure_deployment_name.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Revert patch after test run to clean workspace
git checkout 3e589bf1356024fb471a9d17738e4626f21a953b tests/test_azure_deployment_name.py