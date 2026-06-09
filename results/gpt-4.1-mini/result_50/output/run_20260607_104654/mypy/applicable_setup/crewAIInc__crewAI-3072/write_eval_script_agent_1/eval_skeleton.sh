#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout the specified test file to reset any changes and avoid pathspec errors
git checkout b09796cd3ff4d5ec3c1870ca6c516b7981d6778a "tests/cli/test_create_crew.py"

# Apply test patch (content replaced programmatically at runtime)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Export required environment variables for the tests to pass
export OPENAI_API_KEY="your_openai_api_key_here"
export SERPER_API_KEY="your_serper_api_key_here"
export OTEL_SDK_DISABLED="true"

# Run only the specified test file using 'uv run pytest', with concise output showing per test file status
uv run pytest tests/cli/test_create_crew.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the modified test file to original state after testing
git checkout b09796cd3ff4d5ec3c1870ca6c516b7981d6778a "tests/cli/test_create_crew.py"