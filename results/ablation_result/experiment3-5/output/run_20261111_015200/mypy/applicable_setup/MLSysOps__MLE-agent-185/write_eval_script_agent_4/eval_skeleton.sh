#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5

source /testbed/testbed-venv/bin/activate

# Since tests/test_github_token.py does not exist in this commit,
# run unittest discovery only on existing tests directory to avoid errors
python -m unittest discover -s tests
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# No specific test files to reset since test_github_token.py is missing