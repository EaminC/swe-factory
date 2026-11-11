#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 04c71d7d297447479d897b6803206210ed589d53

# Apply test patch before running the tests
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate Poetry virtual environment created in .venv folder
source /testbed/.venv/bin/activate

# Run only the specified test file with pytest, concise output with test file shown and status
pytest -q --tb=short --disable-warnings --maxfail=1 tests/test_vision_model.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file repository state after test run
git checkout 04c71d7d297447479d897b6803206210ed589d53 tests/test_vision_model.py