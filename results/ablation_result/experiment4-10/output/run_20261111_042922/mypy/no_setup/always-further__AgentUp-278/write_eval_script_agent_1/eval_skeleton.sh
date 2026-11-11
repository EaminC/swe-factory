#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout a78ff2c52f20238958c078f51732ec95b22cd935 tests/test_core/test_llm_ollama.py

# Apply the test patch to update target test file(s)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file with pytest, using collected addopts for verbosity and strictness
pytest -v --strict-markers --strict-config --tb=short tests/test_core/test_llm_ollama.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: revert any changes to the test file to keep repo clean
git checkout a78ff2c52f20238958c078f51732ec95b22cd935 tests/test_core/test_llm_ollama.py