#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 77126b12032fdf38a35368cfa6d6dd34ab552c10 

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Reactivate clean state to avoid partial patch residues if any
git checkout 77126b12032fdf38a35368cfa6d6dd34ab552c10 

# Activate the Python virtual environment
source /testbed_env/bin/activate

# Check if the target test file exists before running tests
if [[ ! -f "tests/test_api_url_forwarding.py" ]]; then
    echo "ERROR: Target test file 'tests/test_api_url_forwarding.py' does not exist."
    echo "OMNIGRIL_EXIT_CODE=1"
    exit 1
fi

# Run tests using pytest to improve test discovery and output for the specified test file
pytest --tb=short -q --disable-warnings tests/test_api_url_forwarding.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"