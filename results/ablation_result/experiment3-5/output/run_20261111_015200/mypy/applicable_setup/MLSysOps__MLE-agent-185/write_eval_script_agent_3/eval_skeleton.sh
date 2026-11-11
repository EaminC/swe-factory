#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5

# Activate virtual environment
source /testbed/testbed-venv/bin/activate

# Since tests/test_github_token.py is missing and likely causing errors,
# run pytest only if the file exists to avoid failures from missing tests
if [[ -f tests/test_github_token.py ]]; then
    pytest --maxfail=1 --disable-warnings -q tests/test_github_token.py
    rc=$?
else
    echo "Warning: tests/test_github_token.py not found, skipping test run."
    rc=1
fi

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes to the test file if it exists
if [[ -f tests/test_github_token.py ]]; then
    git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5 tests/test_github_token.py
fi