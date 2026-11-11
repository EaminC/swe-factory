#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 9b589c65fed699a48d1c93fe74c9e57bc361b70d 

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate Poetry virtual environment and run the requested test file only.
# The working directory is /testbed, and test file relative to root is provided.
# Use poetry run just test with path limitation by passing pytest args.
source /testbed/.venv/bin/activate

# Run only the specified test file explicitly through pytest via just test command
# just test command internally runs pytest, we add the test file argument after --
# to ensure only the target test file executes.
poetry run just test -- tests/test_sql_correction_instructions.py

rc=$?            #Required, save exit code

echo "OMNIGRIL_EXIT_CODE=$rc" #Required, echo test status

# Reset the patch to clean changes to test files
git checkout 9b589c65fed699a48d1c93fe74c9e57bc361b70d "tests/test_sql_correction_instructions.py"