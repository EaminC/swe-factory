#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout a78ff2c52f20238958c078f51732ec95b22cd935 tests/test_core/test_llm_ollama.py

# No test patch needed as none modifies this file and patch apply fails if already applied

# Activate the virtual environment
source /opt/testbed/bin/activate

# Output first few lines of the test file for debug to confirm content
head -40 tests/test_core/test_llm_ollama.py

# Run pytest on the specified test file with verbose output and strict options per config
pytest tests/test_core/test_llm_ollama.py --verbose --tb=short
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Clean up by resetting the test file (in case it was modified externally)
git checkout a78ff2c52f20238958c078f51732ec95b22cd935 tests/test_core/test_llm_ollama.py