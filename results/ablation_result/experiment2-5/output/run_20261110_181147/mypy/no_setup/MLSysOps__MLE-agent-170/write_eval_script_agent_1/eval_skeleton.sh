#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 38385de9d345570271e1fc92119630fe3e3886dc

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate python venv environment
source /opt/testbed/bin/activate

# Run only the specified test file with unittest module
python -m unittest -v tests/test_coder_integration.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset to original state
git checkout 38385de9d345570271e1fc92119630fe3e3886dc