#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 8b817541dac5128db2e47e55c920a289d02037a0

# Apply test patch (placeholder)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment, set PYTHONPATH, and run specified test file(s)
source /opt/testbed/bin/activate
export PYTHONPATH=/testbed:$PYTHONPATH

pytest --tb=short --disable-warnings --maxfail=5 examples/game_gomoku/tests/test_board_agent.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes after tests
git checkout 8b817541dac5128db2e47e55c920a289d02037a0 "examples/game_gomoku/tests/test_board_agent.py"