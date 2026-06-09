#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 3131c0ce083e157f5188cea833592c6cf4aad9d2

# Apply the test patch before running tests
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate poetry virtual environment and run only the specified test file using make unit_tests with args
source ~/.bashrc
poetry env use python3.10
poetry shell || true

make unit_tests args=src/backend/tests/unit/components/models/test_huggingface.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the applied patch
git checkout 3131c0ce083e157f5188cea833592c6cf4aad9d2 src/backend/tests/unit/components/models/test_huggingface.py