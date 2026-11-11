#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout b9765e74d8c3e87ba6828fc7f9fc7fe751ef7984

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file using unittest module with detailed output
python -m unittest -v tests/test_memory_cli.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the applied patch by checking out the original commit version of the test file
git checkout b9765e74d8c3e87ba6828fc7f9fc7fe751ef7984 tests/test_memory_cli.py