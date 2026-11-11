#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout c59173a762c7fa7fb1ccad8bee2596131db8f07b

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /testbed/testbed/bin/activate

# Run only the specified target test file with pytest through the uv runner as per collected info
uv run pytest -v tests/test_azure_structured_output.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changes to test file after test execution
git checkout c59173a762c7fa7fb1ccad8bee2596131db8f07b tests/test_azure_structured_output.py