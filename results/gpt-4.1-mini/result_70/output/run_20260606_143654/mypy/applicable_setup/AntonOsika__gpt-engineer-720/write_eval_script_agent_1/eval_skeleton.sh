#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the specified test files to the committed state prior to patching
git checkout 2058edb3cfb8764cf642d73035af4bb6c783b7e5 "tests/steps/test_archive.py" "tests/test_collect.py" "tests/test_db.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /testbed/venv/bin/activate

# Run only the specified test files with concise, clear output of file test results
pytest --no-header -rA --tb=short "tests/steps/test_archive.py" "tests/test_collect.py" "tests/test_db.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore test files to committed state to undo patch changes
git checkout 2058edb3cfb8764cf642d73035af4bb6c783b7e5 "tests/steps/test_archive.py" "tests/test_collect.py" "tests/test_db.py"