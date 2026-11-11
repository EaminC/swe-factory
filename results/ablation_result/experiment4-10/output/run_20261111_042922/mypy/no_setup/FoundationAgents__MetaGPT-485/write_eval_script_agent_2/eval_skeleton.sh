#!/bin/bash
set -uxo pipefail

# Activate virtual environment
source /opt/testbed/bin/activate

cd /testbed
git checkout 384f5ee08b6defef2adfb22274283e8bd0ef4314 

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Export required environment variable for tests to run
export OPENAI_API_KEY="sk-REPLACE_WITH_VALID_KEY"

# Run all existing tests under tests/ directory that were found (run all since specified test file does not exist)
pytest --no-header -rA --tb=short tests/test_llm.py tests/test_role.py tests/test_message.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository state to clean (without specifying nonexistent test file)
git checkout 384f5ee08b6defef2adfb22274283e8bd0ef4314