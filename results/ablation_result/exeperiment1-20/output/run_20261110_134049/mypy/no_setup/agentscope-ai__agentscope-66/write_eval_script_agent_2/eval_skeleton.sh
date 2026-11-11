#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout the specified commit to ensure clean state
git checkout 0b4bf85481d3cde1f4a5f16d6faeb6e9c9d2a49c 

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /testbed/testbed-venv/bin/activate

# Pre-import or setup custom loguru levels before running tests to avoid ValueError for CHAT_SAVE
# Run a short Python snippet that imports the logging utils to register custom levels
python3 -c "from src.agentscope.utils import logging_utils; logging_utils.setup_logger()"

# Run only the specified test file with pytest, showing concise output with test file and pass/fail/skip for each test
pytest -q --tb=short -rA tests/test_logging_unicode.py

rc=$?  # capture exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset patched test file to clean state after test run
git checkout 0b4bf85481d3cde1f4a5f16d6faeb6e9c9d2a49c tests/test_logging_unicode.py