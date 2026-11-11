#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 34d299345677c7ce26b1368f240c559596526fa7

# Apply the test patch given via heredoc placeholder
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Set required environment variable for OpenAI API authentication
export OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Run only the specified test file using uv run pytest with output options for concise test results
uv run pytest -rA --tb=short --disable-warnings -- tests/test_knowledge_upsert.py

rc=$?  # Capture pytest exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset repository state to discard patch and any test changes to files
git checkout 34d299345677c7ce26b1368f240c559596526fa7 "tests/test_knowledge_upsert.py"