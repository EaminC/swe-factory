#!/bin/bash
set -uxo pipefail

# Activate the virtual environment created by uv
source /opt/testbed/bin/activate

cd /testbed

git checkout c4f7eaf2599c5709260d660d48e810aae7a8c124

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified target test file with uv run pytest and output concise results
uv run pytest -v --tb=short tests/memory/test_rag_storage_reset.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any modifications to the repository after test run
git checkout c4f7eaf2599c5709260d660d48e810aae7a8c124 tests/memory/test_rag_storage_reset.py