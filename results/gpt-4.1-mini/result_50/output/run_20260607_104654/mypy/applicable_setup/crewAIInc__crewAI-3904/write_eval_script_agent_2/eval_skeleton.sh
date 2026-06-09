#!/bin/bash
set -uxo pipefail
cd /testbed

# Apply test patch (no resetting of non-existent test files to avoid errors)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Run pytest only on existing tests under lib/crewai/tests/, no skipped tests due to missing dependencies reported if no a2a-sdk requested
# Use concise and clear test output focusing on the given test directory since target test file does not exist
uv run pytest -rA --tb=short --disable-warnings lib/crewai/tests/
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"