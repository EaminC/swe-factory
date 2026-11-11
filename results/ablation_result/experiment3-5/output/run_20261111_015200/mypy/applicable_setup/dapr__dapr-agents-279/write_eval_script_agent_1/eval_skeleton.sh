#!/bin/bash
set -uxo pipefail

# Activate python virtual environment
source /opt/testbed/bin/activate

cd /testbed

# Reset to the specified commit to ensure clean state
git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428

# Apply the test patch (placeholder for the actual patch content)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified test file with pytest
pytest -v --tb=short tests/test_workflow_completion_callback.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore test file state by resetting to the commit
git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428 tests/test_workflow_completion_callback.py