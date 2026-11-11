#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 2b8e056d5d4d14665b88a01c41356253c94b9259 

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

source /testbed/testbed/bin/activate

pytest --no-header -rA --tb=short tests/test_token_usage_log.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout 2b8e056d5d4d14665b88a01c41356253c94b9259