#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset target test file to committed state before applying patch
git checkout 528d81226361be0f87c9e077ed0d3eb28243120f lib/crewai/tests/agents/test_a2a_trust_completion_status.py

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Reset target test file again to ensure clean state for test execution
git checkout 528d81226361be0f87c9e077ed0d3eb28243120f lib/crewai/tests/agents/test_a2a_trust_completion_status.py

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Run pytest only on the target test file with detailed but concise output
uv run pytest -rA --tb=short --disable-warnings lib/crewai/tests/agents/test_a2a_trust_completion_status.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset target test file after test run to remove patch effects
git checkout 528d81226361be0f87c9e077ed0d3eb28243120f lib/crewai/tests/agents/test_a2a_trust_completion_status.py