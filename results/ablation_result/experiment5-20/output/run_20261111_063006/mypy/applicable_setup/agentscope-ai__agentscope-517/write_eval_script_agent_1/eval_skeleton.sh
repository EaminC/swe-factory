#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout e616e52f444d01dbb249ea3d2e205cbd1c8fb848

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /testbed/testbed_venv/bin/activate

# Run only the specified test file with pytest, output concise results with test file names and status
pytest -q --tb=short --disable-warnings tests/test_encoding_support.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changes made by the patch after test execution
git checkout e616e52f444d01dbb249ea3d2e205cbd1c8fb848 tests/test_encoding_support.py