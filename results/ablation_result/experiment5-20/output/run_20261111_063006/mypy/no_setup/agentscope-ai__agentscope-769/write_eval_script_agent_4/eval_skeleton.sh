#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 811fb28a3dfd8c514e1b3f9fc10585069b35950d

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the Python virtual environment
source /opt/venv/bin/activate

# Verify installed mcp version and contents for debugging
pip show mcp || true
# List contents of mcp.client package to check available modules
python -c "import pkgutil; print([name for _, name, _ in pkgutil.iter_modules(__import__('mcp.client').__path__)])" || true

# Check if test file exists before running tests
if [[ -f "tests/test_token_usage_vllm.py" ]]; then
    pytest -q --tb=short --disable-warnings tests/test_token_usage_vllm.py
    rc=$?
else
    echo "Warning: tests/test_token_usage_vllm.py not found after applying patch, skipping pytest."
    rc=1
fi

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset patched file or full repository state safely ignoring errors if files missing
git checkout 811fb28a3dfd8c514e1b3f9fc10585069b35950d || true