#!/bin/bash
set -uxo pipefail

cd /testbed

# Ensure the target test file is at the correct commit version before patch
git checkout 4c55a976c677202cdca6a51da8dbd326de650f9c "tests/metagpt/roles/test_researcher.py"

# Apply the test patch from stdin (placeholder for actual patch content)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the python virtual environment
source /opt/testbed/bin/activate

# Execute only the target test file with pytest and required options for concise output
pytest -v --tb=short tests/metagpt/roles/test_researcher.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to original state
git checkout 4c55a976c677202cdca6a51da8dbd326de650f9c "tests/metagpt/roles/test_researcher.py"