#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the committed state before applying patch
git checkout 1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e "tests/test_project.py"

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the Python virtual environment from the correct path
source /testbed/.venv/bin/activate

# Explicitly ensure pytest is installed
pip install pytest

# Check presence of embedchain package; attempt to install if missing for robustness
if ! python -c "import embedchain" &> /dev/null; then
    echo "embedchain module not found, installing explicitly" >&2
    pip install embedchain || (echo "Failed to install embedchain" >&2; exit 1)
fi

# Export required environment variables (set to defaults or can be overridden at runtime)
export OPENAI_API_KEY="${OPENAI_API_KEY:-}"
export SERPER_API_KEY="${SERPER_API_KEY:-}"
export OTEL_SDK_DISABLED="${OTEL_SDK_DISABLED:-true}"

# Run the specified test file with uv run pytest and concise, informative output
uv run pytest tests/test_project.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to discard patch changes and any test side effects
git checkout 1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e "tests/test_project.py"