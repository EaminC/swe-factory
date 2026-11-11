#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout de5d2eaa9b12167ea14ecf59c70f59227fd63fe3

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

source /testbed/testbed/bin/activate

# Run only the specified test file with pytest via uvx
uvx pytest lib/crewai/tests/agents/test_crew_agent_executor.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout de5d2eaa9b12167ea14ecf59c70f59227fd63fe3 lib/crewai/tests/agents/test_crew_agent_executor.py