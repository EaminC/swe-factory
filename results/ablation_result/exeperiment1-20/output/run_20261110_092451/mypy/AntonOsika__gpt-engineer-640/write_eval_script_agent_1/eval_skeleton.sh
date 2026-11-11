#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout dc7a2bd0f546ea29929faa57b8e618c413c86bb2

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate python virtual environment
source /testbed/testbed/bin/activate

# Run only the specified test file with concise output, show filename and short summary per test.
pytest --tb=short -rA -q tests/test_azure_openai.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout dc7a2bd0f546ea29929faa57b8e618c413c86bb2