#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout a78ff2c52f20238958c078f51732ec95b22cd935 tests/test_core/test_llm_ollama.py

# No test patch to apply as none modifies this file

# Activate the virtual environment
source /opt/testbed/bin/activate

# Export PYTHONPATH to include src directory as required by test file's sys.path modification
export PYTHONPATH=/testbed/src

# Display pytest version for debugging
pytest --version

# Output first 40 lines of the test file to confirm contents
head -40 tests/test_core/test_llm_ollama.py

# Run pytest in collection-only mode with no filtering to debug test discovery
pytest tests/test_core/test_llm_ollama.py --collect-only --verbose --tb=short

# Run pytest on the test file with no output capture (-s) and verbose output
pytest tests/test_core/test_llm_ollama.py -s --verbose --tb=short
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: revert test file to original state
git checkout a78ff2c52f20238958c078f51732ec95b22cd935 tests/test_core/test_llm_ollama.py