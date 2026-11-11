#!/bin/bash
set -uxo pipefail

source /opt/testbed/bin/activate
cd /testbed

git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run pytest specifically on the target test file as requested
pytest -v --tb=short tests/test_workflow_completion_callback.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428