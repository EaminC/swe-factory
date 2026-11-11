#!/bin/bash
set -uxo pipefail

# Activate the virtual environment
source /testbed/venv/bin/activate
cd /testbed

# Ensure correct commit checked out
git checkout 27e2566cff7e3dcf79f37b5271efbc1c0c01c3e0

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified test file with pytest
pytest tests/test_self_heal.py -v --tb=short
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: restore patched test file to original state
git restore tests/test_self_heal.py