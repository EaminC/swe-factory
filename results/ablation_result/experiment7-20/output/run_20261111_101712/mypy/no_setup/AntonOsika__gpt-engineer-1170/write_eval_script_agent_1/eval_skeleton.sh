#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 3e589bf1356024fb471a9d17738e4626f21a953b

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified test file with coverage and exclude the "installed_main_execution" tests, showing concise output with test names and status
poetry run pytest --cov=gpt_engineer --cov-report=xml -k "not installed_main_execution" tests/test_azure_deployment_name.py

rc=$?   # Save exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the modified test file after test run
git checkout 3e589bf1356024fb471a9d17738e4626f21a953b tests/test_azure_deployment_name.py