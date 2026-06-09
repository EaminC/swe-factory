#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test file to the committed state before applying patch
git checkout 4f6054d439c602f93283eda351fe6b67133b9a84 "tests/agent_test.py"

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the correct Python 3.11 virtual environment and run the specified test file
source /testbed/testbed_venv/bin/activate

# Print aiohttp version for debug purposes
python -c "import aiohttp; print(f'aiohttp version: {aiohttp.__version__}')"

# Run tests using uv run pytest in the activated venv
uv run pytest -rA --tb=short --disable-warnings tests/agent_test.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout 4f6054d439c602f93283eda351fe6b67133b9a84 "tests/agent_test.py"