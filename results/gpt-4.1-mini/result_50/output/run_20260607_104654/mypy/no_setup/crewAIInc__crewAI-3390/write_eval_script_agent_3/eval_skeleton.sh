#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout only the target test file to avoid pathspec errors
git checkout 45d0c9912c4ddb04fbd7ee515d63dde6c3e8b2cb "tests/storage/test_mem0_storage.py"

# Apply test patch (replace [CONTENT OF TEST PATCH] with actual patch content at runtime)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Export required environment variables for the tests to pass
export OPENAI_API_KEY=""
export SERPER_API_KEY=""
export OTEL_SDK_DISABLED=true

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Run only the specified test file with uv run pytest with concise output
uv run pytest tests/storage/test_mem0_storage.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the modified test file to original state after testing
git checkout 45d0c9912c4ddb04fbd7ee515d63dde6c3e8b2cb "tests/storage/test_mem0_storage.py"