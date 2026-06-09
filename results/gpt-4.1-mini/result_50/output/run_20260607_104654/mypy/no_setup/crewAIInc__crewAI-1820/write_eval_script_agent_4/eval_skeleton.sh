#!/bin/bash
set -uxo pipefail

cd /testbed

# Define test files and verify which exist in git at the commit
TEST_FILES=("tests/crew_test.py" "tests/test_manager_llm_delegation.py")
EXISTING_TEST_FILES=()

for file in "${TEST_FILES[@]}"; do
  if git cat-file -e "73f328860b4a477a6d3736e646783d7493841cb4:$file" 2>/dev/null; then
    EXISTING_TEST_FILES+=("$file")
  fi
done

# Checkout only files that exist in the repo at the specified commit to avoid git errors
if [ ${#EXISTING_TEST_FILES[@]} -gt 0 ]; then
  git checkout 73f328860b4a477a6d3736e646783d7493841cb4 -- "${EXISTING_TEST_FILES[@]}"
fi

# Apply test patch (replace [CONTENT OF TEST PATCH] with actual patch content at runtime)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate correct virtual environment as set up in Dockerfile
source /testbed/testbed_venv/bin/activate

# Export required environment variables to avoid authentication and connection errors
# These should be set securely in the docker environment or CI runtime; 
# here they can be passed through if already set, or set to empty to prevent errors
export OPENAI_API_KEY="${OPENAI_API_KEY:-}"
export SERPER_API_KEY="${SERPER_API_KEY:-}"
export OTEL_SDK_DISABLED="true"

# Run tests only for the requested test files, including those not tracked by git (in filesystem)
uv run pytest -rA --tb=short --disable-warnings "${TEST_FILES[@]}"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified test files only if they exist in git
if [ ${#EXISTING_TEST_FILES[@]} -gt 0 ]; then
  git checkout 73f328860b4a477a6d3736e646783d7493841cb4 -- "${EXISTING_TEST_FILES[@]}"
fi