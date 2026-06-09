#!/bin/bash
set -uxo pipefail

cd /testbed

# Only checkout the existing test file to avoid pathspec errors
git checkout 1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e "tests/test_project.py"

# Apply test patch (replace [CONTENT OF TEST PATCH] with actual patch content at runtime)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Export required environment variables for the tests to pass
export OPENAI_API_KEY="${OPENAI_API_KEY:-}"
export SERPER_API_KEY="${SERPER_API_KEY:-}"
export OTEL_SDK_DISABLED="${OTEL_SDK_DISABLED:-true}"

# Activate the Python virtual environment from the correct path
source /testbed/.venv/bin/activate

# Run only the specified existing test file with uv run pytest and concise output reporting
uv run pytest tests/test_project.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified test files to original state after testing
git checkout 1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e "tests/test_project.py"