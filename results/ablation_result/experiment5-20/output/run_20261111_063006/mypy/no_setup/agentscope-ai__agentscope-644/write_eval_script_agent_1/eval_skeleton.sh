#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout f93b928219f5218a93f1651dc7ba486794061860 "tests/reactv2_agent_with_mcp/test_streamable_http_client.py"

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment provided by the Docker image
source /opt/testbed/bin/activate

# Run only the specified test file using pytest with coverage, concise output, no header, showing all outcomes and short tracebacks
pytest --no-header -rA --tb=short --cov=agentscope tests/reactv2_agent_with_mcp/test_streamable_http_client.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to clean state
git checkout f93b928219f5218a93f1651dc7ba486794061860 "tests/reactv2_agent_with_mcp/test_streamable_http_client.py"