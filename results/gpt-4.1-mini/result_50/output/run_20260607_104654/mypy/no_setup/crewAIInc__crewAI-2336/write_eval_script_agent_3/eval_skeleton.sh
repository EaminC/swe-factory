#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test files to the specified commit to ensure a clean state
git checkout b992ee9d6b604993b3cc09ae366e314f68f78705 "tests/config/agents.yaml" "tests/project_test.py"

# Apply test patch (placeholder content to be replaced)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Export required environment variables for tests (can be overwritten at runtime)
export OPENAI_API_KEY="${OPENAI_API_KEY:-fake_openai_api_key}"
export SERPER_API_KEY="${SERPER_API_KEY:-fake_serper_api_key}"

# Activate the virtual environment
source /testbed/testbed/bin/activate

# Run only the valid Python test file with verbose output, short traceback, and warnings disabled
uv run pytest -v -rA --tb=short --disable-warnings tests/project_test.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the patched test files to original commit state
git checkout b992ee9d6b604993b3cc09ae366e314f68f78705 "tests/config/agents.yaml" "tests/project_test.py"