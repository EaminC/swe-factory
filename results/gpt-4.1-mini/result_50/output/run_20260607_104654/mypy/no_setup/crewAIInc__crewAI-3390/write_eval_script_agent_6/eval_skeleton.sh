#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout entire commit to ensure clean state (no individual test file checkout due to probable dependencies)
git checkout 45d0c9912c4ddb04fbd7ee515d63dde6c3e8b2cb

# Apply test patch (replace [CONTENT OF TEST PATCH] with actual patch content at runtime)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Export required environment variables
export OPENAI_API_KEY=""
export SERPER_API_KEY=""
export OTEL_SDK_DISABLED="true"
export share_crew="True"

# Activate the virtual environment and verify mem0 module installation
source /testbed/.venv/bin/activate

# Check if mem0 module is importable before running tests (diagnostic)
python3 -c "import mem0.client.main" || { echo 'mem0 module import failed'; exit 1; }

# Run only the specified test file(s) with proper uv command inside the activated environment
uv run pytest tests/storage/test_mem0_storage.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository state to the original commit after tests
git reset --hard 45d0c9912c4ddb04fbd7ee515d63dde6c3e8b2cb