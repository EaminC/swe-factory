#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout a6b729509222c1ad829630452b91685b224689e0 

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

git checkout a6b729509222c1ad829630452b91685b224689e0 

# Activate the virtual environment
source /testbed/testbed_venv/bin/activate

# Run only the specified target test file with detailed but concise output
# -s to avoid capture if needed, -q less verbose but keeping test file names/status
# -rA to show all extra summary, --tb=short for concise tracebacks
pytest -rA --tb=short "lib/crewai-tools/tests/tools/test_tool_usage.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified test file after test
git checkout a6b729509222c1ad829630452b91685b224689e0 "lib/crewai-tools/tests/tools/test_tool_usage.py"