#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 71fab2dc51f9944a521a403af1924e0cf5bef76b tests/test_cli_report.py

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

source /opt/testbed/bin/activate

# Run only the specified test file using unittest with detailed output on test results
python -m unittest -v tests/test_cli_report.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the modified test file to original state to avoid side effects
git checkout 71fab2dc51f9944a521a403af1924e0cf5bef76b tests/test_cli_report.py