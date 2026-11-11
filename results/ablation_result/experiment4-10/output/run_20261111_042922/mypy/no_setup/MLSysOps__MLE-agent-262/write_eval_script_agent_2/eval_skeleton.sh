#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 96a84c48ce271d37749c6304866e42a24e6647ac

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the python virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file with pytest for proper test discovery
pytest -v tests/test_memory_lancedb.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes after test run
git checkout 96a84c48ce271d37749c6304866e42a24e6647ac