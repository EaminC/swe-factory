#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout the specific commit version of the test file to ensure a clean state before applying patch
git checkout fbf87327841dd7b92bb04a23fd1575881a3ad3fa tests/flow_test.py

# Apply test patch (placeholder content will be replaced during evaluation)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the Python virtual environment from the correct path
source /testbed/.venv/bin/activate

# Install pytest explicitly inside the virtual environment to ensure availability
pip install pytest

# Export required environment variables (empty here, can be set by runtime environment)
export OPENAI_API_KEY=""
export SERPER_API_KEY=""

# Run only the specified test file with uv run pytest and concise output reporting
uv run pytest tests/flow_test.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to discard patch changes and any test side effects
git checkout fbf87327841dd7b92bb04a23fd1575881a3ad3fa tests/flow_test.py