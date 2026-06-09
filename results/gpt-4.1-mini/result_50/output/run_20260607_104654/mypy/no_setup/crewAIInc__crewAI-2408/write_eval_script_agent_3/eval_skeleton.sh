#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the specified commit to ensure a clean state
git checkout 4f6054d439c602f93283eda351fe6b67133b9a84 "tests/agent_test.py"

# Apply test patch (placeholder content to be replaced)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment explicitly
source /testbed/testbed_venv/bin/activate

# Install a compatible aiohttp version to avoid AsyncStreamReaderMixin AttributeError
pip install "aiohttp<3.8.0"

# Export required environment variables for the tests to pass
export OPENAI_API_KEY="test_api_key_placeholder"
export SERPER_API_KEY="test_api_key_placeholder"
export OTEL_SDK_DISABLED=true

# Run only the specified test file with uv run pytest, concise output, disable warnings
uv run pytest tests/agent_test.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset patched test file to original state after testing
git checkout 4f6054d439c602f93283eda351fe6b67133b9a84 "tests/agent_test.py"