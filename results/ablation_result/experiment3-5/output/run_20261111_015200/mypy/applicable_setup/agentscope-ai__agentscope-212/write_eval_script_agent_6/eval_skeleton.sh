#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 8b817541dac5128db2e47e55c920a289d02037a0

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

source /opt/testbed/bin/activate
export PYTHONPATH=/testbed${PYTHONPATH:+:$PYTHONPATH}

# The original target test file does not exist in the repo, and tests are run via tests/run.py script.
# Run the centralized test execution script as per CI workflow to run all tests.
python tests/run.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout 8b817541dac5128db2e47e55c920a289d02037a0