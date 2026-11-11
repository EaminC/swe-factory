#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 5e8bd105177e08848990d32b9ea636daa639be19

# Apply required test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment
source /testbed/testbed/bin/activate

# Run only the specified test file with pytest
pytest -v --disable-warnings tests/test_llm_config.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset patched files to original state
git checkout 5e8bd105177e08848990d32b9ea636daa639be19