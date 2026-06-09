#!/bin/bash
set -uxo pipefail

cd /testbed

# Define requested test files and check existence in git at commit
TEST_FILES=("tests/crew_test.py" "tests/test_manager_llm_delegation.py")
EXISTING_TEST_FILES=()

for file in "${TEST_FILES[@]}"; do
  if git cat-file -e "73f328860b4a477a6d3736e646783d7493841cb4:$file" 2>/dev/null; then
    EXISTING_TEST_FILES+=("$file")
  fi
done

# Checkout only existing test files to avoid git pathspec errors
if [ ${#EXISTING_TEST_FILES[@]} -gt 0 ]; then
  git checkout 73f328860b4a477a6d3736e646783d7493841cb4 -- "${EXISTING_TEST_FILES[@]}"
fi

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment installed in Dockerfile
source /testbed/testbed_venv/bin/activate

# Verify that crewai_tools is installed, reinstall if missing (optional sanity check)
if ! python -c "import crewai_tools" &>/dev/null; then
  pip install 'crewai[tools]'
fi

# Export environment variables for authentication, ensure non-empty values are provided externally
export OPENAI_API_KEY="${OPENAI_API_KEY:?Set OPENAI_API_KEY env var with valid key}"
export SERPER_API_KEY="${SERPER_API_KEY:?Set SERPER_API_KEY env var with valid key}"
export OTEL_SDK_DISABLED="true"
export OPTIONAL_share_crew=true

# Run tests only on the specified files, even if not in git index but present on filesystem
uv run pytest -rA --tb=short --disable-warnings "${TEST_FILES[@]}"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified test files if they existed in the repo at commit to avoid git errors
if [ ${#EXISTING_TEST_FILES[@]} -gt 0 ]; then
  git checkout 73f328860b4a477a6d3736e646783d7493841cb4 -- "${EXISTING_TEST_FILES[@]}"
fi