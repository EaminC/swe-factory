#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 811fb28a3dfd8c514e1b3f9fc10585069b35950d

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the Python virtual environment
source /opt/venv/bin/activate

# Reinstall 'mcp' to ensure required minimal version (>=1.13) is installed and force reinstall to avoid version conflicts
pip install --upgrade pip setuptools wheel
pip install --force-reinstall "mcp>=1.13"

# Debug: show installed version of mcp to validate
pip show mcp

# Check if the test file exists after patch application before running tests
if [[ -f "tests/test_token_usage_vllm.py" ]]; then
    # Run pytest on the specified test file with concise output and without coverage (to avoid missing pytest-cov issues)
    pytest --no-header -rA --tb=short tests/test_token_usage_vllm.py
    rc=$?
else
    echo "Warning: tests/test_token_usage_vllm.py not found after applying patch, skipping pytest."
    rc=1
fi

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository to original commit, ignore errors if test file does not exist after patch
git checkout 811fb28a3dfd8c514e1b3f9fc10585069b35950d || true