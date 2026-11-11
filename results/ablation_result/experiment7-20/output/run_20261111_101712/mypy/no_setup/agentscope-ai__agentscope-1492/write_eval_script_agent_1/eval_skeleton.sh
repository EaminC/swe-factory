#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 08b047e05b02b27a290ee1b850fb75210f186cdb

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

source /testbed/testbed_env/bin/activate

# Run only the specified target test file with concise output showing test outcomes
pytest -q --disable-warnings --tb=short tests/test_deep_research_agent_blocks.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout 08b047e05b02b27a290ee1b850fb75210f186cdb tests/test_deep_research_agent_blocks.py