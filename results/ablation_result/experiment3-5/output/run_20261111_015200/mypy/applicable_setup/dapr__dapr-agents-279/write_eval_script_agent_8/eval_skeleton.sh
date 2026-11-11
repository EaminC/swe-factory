#!/bin/bash
set -uxo pipefail

source /opt/testbed/bin/activate
cd /testbed

git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428

# Apply the test patch ensuring compatibility with the codebase at the specified commit
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run the specific target test file despite the known incompatibility, per requirements.
# Note that the test may fail due to incompatibility in constructor arguments.
pytest -v --tb=short tests/test_workflow_completion_callback.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository to clean state after tests
git checkout 13feed2c2c00249344c4e5151a1e3b2cdaf6d428