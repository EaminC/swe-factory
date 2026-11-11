#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

git checkout 77126b12032fdf38a35368cfa6d6dd34ab552c10

# Apply the test patch (content replaced during execution)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified target test file using unittest module
python -m unittest tests/test_api_url_forwarding.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modifications to leave repo clean
git checkout 77126b12032fdf38a35368cfa6d6dd34ab552c10 "tests/test_api_url_forwarding.py"