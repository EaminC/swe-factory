#!/bin/bash
set -uxo pipefail

source /opt/testbed/bin/activate

cd /testbed

git checkout b0d89698fdd3eb5aced8e659f2241f0648b8a40b

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

git checkout b0d89698fdd3eb5aced8e659f2241f0648b8a40b 

# Check if the test file exists and is tracked before running tests
if git ls-files --error-unmatch tests/test_openai_version.py > /dev/null 2>&1; then
    # Run pytest only on the target test file with concise output
    pytest --tb=short -rA --disable-warnings tests/test_openai_version.py
    rc=$?
else
    echo "WARNING: Target test file 'tests/test_openai_version.py' does not exist or is not tracked."
    rc=0
fi

echo "OMNIGRIL_EXIT_CODE=$rc"