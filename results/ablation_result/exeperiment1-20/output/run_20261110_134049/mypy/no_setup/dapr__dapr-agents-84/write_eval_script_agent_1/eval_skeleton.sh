#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout c872c5a8bd1d5cd9de745b1a680b1e5e1fb6c0c5

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the python venv environment
source /testbed/testbed/bin/activate

# Run the specific test file with pytest, showing concise output with pass/fail/skip per test file
python -m pip install pytest > /dev/null
pytest --tb=short -q --disable-warnings --maxfail=1 tests/agents/agent/test_mcp_client_error_handling.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout c872c5a8bd1d5cd9de745b1a680b1e5e1fb6c0c5