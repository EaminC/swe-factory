#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout d63b15dc4721d48cb8368fe9011398df417fbc32 

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Verify if the target test file exists after applying the patch
TEST_FILE="libs/checkpoint-postgres/tests/test_continue_thread.py"

if [ -f "$TEST_FILE" ]; then
  echo "Found test file: $TEST_FILE"
  # Run pytest on the specific test file with detailed output and test summary
  poetry run pytest --full-trace --strict-markers --strict-config --durations=5 --snapshot-warn-unused -rA -v "$TEST_FILE"
  rc=$?
else
  echo "ERROR: Target test file '$TEST_FILE' does not exist after patch application."
  echo "Running entire pytest suite to detect any existing tests."

  poetry run pytest --full-trace --strict-markers --strict-config --durations=5 --snapshot-warn-unused -rA -v
  rc=$?
fi

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup repository state after test run
git reset --hard d63b15dc4721d48cb8368fe9011398df417fbc32