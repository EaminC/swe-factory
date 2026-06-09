#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout be8db4cc484b77d0d3bc60a012e9035c4395bee3 "tests/memory_test.py" "tests/msghub_test.py"

# Apply test patch (content will be inserted here during execution)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment
source /opt/testbed/bin/activate

# List discovered tests to verify discovery (debug step, can be commented out if verbose)
python3 tests/run.py --list_tests

# Run tests by specifying exact test files as positional arguments to the test runner script
# Since tests/run.py does not seem to filter by pattern correctly for multiple files, run with specific test files as positional args
python3 tests/run.py tests/memory_test.py tests/msghub_test.py

rc=$?            # Save exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changed test files to discard any patch changes
git checkout be8db4cc484b77d0d3bc60a012e9035c4395bee3 "tests/memory_test.py" "tests/msghub_test.py"