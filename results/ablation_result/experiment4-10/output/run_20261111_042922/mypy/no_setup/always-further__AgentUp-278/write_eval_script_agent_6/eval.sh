#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout a78ff2c52f20238958c078f51732ec95b22cd935 tests/test_core/test_llm_ollama.py

# No test patch to apply as none modifies this file

# Activate the virtual environment
source /opt/testbed/bin/activate

# Display pytest version and configuration for debugging
pytest --version
pytest --showconfig

# Output first 40 lines of the test file to verify contents
head -40 tests/test_core/test_llm_ollama.py

# Run pytest collect-only to confirm test discovery results with full verbosity and no warnings filtered
pytest tests/test_core/test_llm_ollama.py --collect-only -vv --disable-warnings

# Run pytest on target test file with full verbosity, no output capturing, and no warnings filtered
pytest tests/test_core/test_llm_ollama.py -s -vv --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: revert any changes to the test file to ensure clean state
git checkout a78ff2c52f20238958c078f51732ec95b22cd935 tests/test_core/test_llm_ollama.py