#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout d662bec3aa81316115336b7eba573c3e33e2930b

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate python virtual environment
source /opt/testbed/bin/activate

# Set PYTHONPATH so pytest can find the src package correctly
export PYTHONPATH=/testbed

# Run only the specified target test file from the tests folder
pytest --no-header -rA --tb=short --disable-warnings tests/mem0_utils_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes or applied patch
git checkout d662bec3aa81316115336b7eba573c3e33e2930b