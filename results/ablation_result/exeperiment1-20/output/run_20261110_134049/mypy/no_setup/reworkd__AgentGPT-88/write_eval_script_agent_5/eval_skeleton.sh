#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 9bae29c0727b7af51e0715ba6c20b00f7adefe33

# Install Python3 and pip, and pytest for running Python tests
apt-get update && apt-get install -y python3 python3-pip
python3 -m pip install --upgrade pip
pip3 install pytest

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# List files after patch to confirm existence
echo "Listing files under platform/reworkd_platform/tests/agent/:"
ls -l platform/reworkd_platform/tests/agent/ || echo "No such directory or files."

# Set PYTHONPATH to /testbed to correctly resolve imports (including 'src' package)
export PYTHONPATH=/testbed

# Run the specific Python test file with pytest
pytest --tb=short --disable-warnings platform/reworkd_platform/tests/agent/test_autonomous_agent_model_option.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository to original state to clean up modified files
git checkout 9bae29c0727b7af51e0715ba6c20b00f7adefe33