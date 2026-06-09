#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 2a95b52e06769d70fd9f0671cfcc6734ee41f0ef 

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment
source /testbed/venv/bin/activate

# Run only the specified test file using pytest with concise output of test file and result
pytest --tb=short --disable-warnings -q src/backend/tests/unit/components/models/test_baidu_qianfan.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup/reset the patched test file to original
git checkout 2a95b52e06769d70fd9f0671cfcc6734ee41f0ef src/backend/tests/unit/components/models/test_baidu_qianfan.py