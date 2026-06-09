#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout be8db4cc484b77d0d3bc60a012e9035c4395bee3 "tests/memory_test.py" "tests/msghub_test.py"

# Apply test patch (content will be inserted here during execution)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment and run specific tests with unittest runner script
source /opt/testbed/bin/activate

python3 tests/run.py --pattern="*_test.py" --test_dir="tests" --list_tests >/dev/null

# Run only the two specified test files using unittest runner script with pattern filter
python3 tests/run.py --pattern="memory_test.py|msghub_test.py" --test_dir="tests"

rc=$?            # Save exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test files to discard changes made by the patch
git checkout be8db4cc484b77d0d3bc60a012e9035c4395bee3 "tests/memory_test.py" "tests/msghub_test.py"