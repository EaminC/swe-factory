#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout ba00896c5673990923abd0e99dba147938871512

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate python virtual environment and run only the specified test file with pytest
source /opt/testbed/bin/activate

pytest --no-header -rA --tb=short tests/test_benchmark_feedback.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout ba00896c5673990923abd0e99dba147938871512 tests/test_benchmark_feedback.py