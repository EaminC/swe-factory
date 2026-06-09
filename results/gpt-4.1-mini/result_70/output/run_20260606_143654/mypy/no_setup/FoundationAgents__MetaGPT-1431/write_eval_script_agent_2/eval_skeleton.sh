#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout the specified commit and reset the target test files before patching
git checkout 22e100912839965231144ae25790d643180ddc57 \
    "tests/metagpt/actions/test_action_node.py" \
    "tests/metagpt/test_config.py" \
    "tests/metagpt/test_context.py"

# Apply the test patch if required
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the python virtual environment
source /opt/testbed/bin/activate

# Ensure pytest is installed before running tests (in case it's missing)
pip install pytest

# Run only the specified test files in one pytest command with concise output
pytest -v --maxfail=1 --disable-warnings \
    tests/metagpt/actions/test_action_node.py \
    tests/metagpt/test_config.py \
    tests/metagpt/test_context.py

rc=$?  # capture exit code of pytest

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test files to original committed state after tests
git checkout 22e100912839965231144ae25790d643180ddc57 \
    "tests/metagpt/actions/test_action_node.py" \
    "tests/metagpt/test_config.py" \
    "tests/metagpt/test_context.py"