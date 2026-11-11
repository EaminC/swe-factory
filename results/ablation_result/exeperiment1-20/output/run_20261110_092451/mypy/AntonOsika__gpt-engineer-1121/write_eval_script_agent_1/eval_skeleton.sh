#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 04c71d7d297447479d897b6803206210ed589d53 

# Apply the test patch before running tests
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

git checkout 04c71d7d297447479d897b6803206210ed589d53 

# Execute only the specified test file with Poetry run and pytest, capturing concise output with file names and statuses
poetry run pytest --no-header -rA --tb=short tests/test_vision_model.py
rc=$?            # save exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Clean up by resetting changes to the test file
git checkout 04c71d7d297447479d897b6803206210ed589d53 tests/test_vision_model.py