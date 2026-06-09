#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the committed state before applying patch
git checkout 6a1eb10830ac6ab3602bbc4ee07d565bd9eab46f tests/crew_test.py

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Check that required API keys are set, else exit with error
if [[ -z "${OPENAI_API_KEY}" ]]; then
  echo "Error: OPENAI_API_KEY is not set. Please provide a valid OpenAI API key in the environment."
  exit 1
fi

if [[ -z "${SERPER_API_KEY}" ]]; then
  echo "Error: SERPER_API_KEY is not set. Please provide a valid Serper API key in the environment."
  exit 1
fi

# Activate the correct virtual environment and run the specified test file using uv run pytest
source /testbed/.venv/bin/activate
uv run pytest -rA --tb=short --disable-warnings tests/crew_test.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout 6a1eb10830ac6ab3602bbc4ee07d565bd9eab46f tests/crew_test.py