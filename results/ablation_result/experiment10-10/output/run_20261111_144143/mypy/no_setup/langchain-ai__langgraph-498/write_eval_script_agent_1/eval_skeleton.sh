#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout d63b15dc4721d48cb8368fe9011398df417fbc32

# Apply the patch for the tests
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the target test file
# Use poetry run pytest as from Makefile usage (poetry run pytest)
# Keep output concise but show file and test status
poetry run pytest --no-header -rA --tb=short libs/checkpoint-postgres/tests/test_continue_thread.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the modified files to clean working directory after test run
git checkout d63b15dc4721d48cb8368fe9011398df417fbc32 libs/checkpoint-postgres/tests/test_continue_thread.py