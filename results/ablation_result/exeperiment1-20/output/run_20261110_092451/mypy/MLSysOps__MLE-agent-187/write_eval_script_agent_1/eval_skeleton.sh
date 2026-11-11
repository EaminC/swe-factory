#!/bin/bash
set -uxo pipefail

cd /testbed

# Ensure we are on the target commit and reset any changes before starting
git checkout b95f56b446a2fe55247eee717ab85fe45f857d27

# Apply test patch (content replaced at runtime)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the required test files using unittest in verbose mode to show test names and results
# Activate the virtual environment explicitly (though $PATH is set in Dockerfile, be explicit here)
source /opt/testbed/bin/activate

# Run unittest for the target test file(s) only, with verbose for detailed output
python -m unittest -v tests/test_clarify_dataset.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changes after test run to cleanup environment
git checkout b95f56b446a2fe55247eee717ab85fe45f857d27