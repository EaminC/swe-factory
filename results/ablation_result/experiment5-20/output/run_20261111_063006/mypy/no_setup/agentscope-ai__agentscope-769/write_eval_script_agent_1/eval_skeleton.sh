#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 811fb28a3dfd8c514e1b3f9fc10585069b35950d

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the Python virtual environment
source /opt/venv/bin/activate

# Run only the specified test file with coverage and concise output,
# showing all test outcomes with short traceback
pytest --no-header -rA --tb=short --cov=agentscope tests/test_token_usage_vllm.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset only the modified test file to clean patch effects
git checkout 811fb28a3dfd8c514e1b3f9fc10585069b35950d tests/test_token_usage_vllm.py