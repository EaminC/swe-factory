#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout dd7da4e5ac4085fb8324cac3ac0b4c104b9007cb

# Apply the test patch to update target tests
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Install pytest in the virtual environment to ensure test dependencies are met
pip install --no-cache-dir pytest

# Run only the specified test file using pytest to avoid ModuleNotFoundError and to match test requirements
pytest -q --tb=short --disable-warnings tests/test_memory_api.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout dd7da4e5ac4085fb8324cac3ac0b4c104b9007cb tests/test_memory_api.py