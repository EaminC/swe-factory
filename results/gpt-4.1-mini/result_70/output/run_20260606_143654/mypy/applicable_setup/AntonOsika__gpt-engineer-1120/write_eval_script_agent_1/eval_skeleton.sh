#!/bin/bash
set -uxo pipefail
cd /testbed

# Restore target test files to exact commit state before patching
git checkout 04c71d7d297447479d897b6803206210ed589d53 "tests/applications/cli/test_learning.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified test file with pytest inside poetry virtual environment
# Use poetry run to ensure correct environment activation
poetry run pytest -q --tb=short --disable-warnings --color=yes "tests/applications/cli/test_learning.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Revert test files to clean state after test run
git checkout 04c71d7d297447479d897b6803206210ed589d53 "tests/applications/cli/test_learning.py"