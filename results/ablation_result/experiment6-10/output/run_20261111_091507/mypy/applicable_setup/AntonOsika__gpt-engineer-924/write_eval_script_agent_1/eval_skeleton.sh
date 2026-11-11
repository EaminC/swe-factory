#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout a74c5ebcf0abf9db63abf3ba39ac123f6f74eb82

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified target test files using poetry and pytest, showing concise output with test names and status
poetry run pytest --cov=gpt_engineer --disable-warnings --maxfail=1 -v tests/core/test_token_usage.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changes after test run
git checkout a74c5ebcf0abf9db63abf3ba39ac123f6f74eb82