#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout f93b928219f5218a93f1651dc7ba486794061860

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Run minimal test script as the specified test file is missing,
# this aligns with the repository's CI test approach
python tests/minimal.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes made by patch (no specific test file to reset)
git checkout f93b928219f5218a93f1651dc7ba486794061860