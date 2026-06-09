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

# Export required environment variables for tests to avoid authentication errors
# These should be securely set in the evaluation environment; placeholder values below must be replaced.
export OPENAI_API_KEY="${OPENAI_API_KEY:-your_real_openai_api_key_here}"
export SERPER_API_KEY="${SERPER_API_KEY:-your_real_serper_api_key_here}"
export OTEL_SDK_DISABLED="true"
export OPTIONAL_share_crew=true

# Run tests only for the requested test files, including untracked ones if present
uv run pytest -rA --tb=short --disable-warnings "${TEST_FILES[@]}"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified test files only if they exist in git
if [ ${#EXISTING_TEST_FILES[@]} -gt 0 ]; then
  git checkout 73f328860b4a477a6d3736e646783d7493841cb4 -- "${EXISTING_TEST_FILES[@]}"
fi