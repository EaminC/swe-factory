#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5

source /testbed/testbed-venv/bin/activate

# Install pytest to ensure test dependencies are met
pip install --no-cache-dir pytest

# Run the specific test file with pytest to make sure the patched tests run
pytest -q --disable-warnings tests/test_github_token.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"