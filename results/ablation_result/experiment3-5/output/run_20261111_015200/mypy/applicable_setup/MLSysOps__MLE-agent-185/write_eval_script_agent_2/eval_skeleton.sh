#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5

# Activate virtual environment and ensure pytest is installed for running the tests
source /testbed/testbed-venv/bin/activate
pip install --no-cache-dir pytest

# Run only the specified test file with pytest, showing concise result for that file
pytest --maxfail=1 --disable-warnings -q tests/test_github_token.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5 tests/test_github_token.py