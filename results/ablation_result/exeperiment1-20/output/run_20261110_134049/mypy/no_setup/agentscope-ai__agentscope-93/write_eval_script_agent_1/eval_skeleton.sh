#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed
git checkout 17676eaaf2346ff936fc2df78ec098fa7a81e3e0 

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified test file with concise output of test names and statuses
pytest --tb=short -r a --disable-warnings -q tests/test_text_to_image_agent.py
rc=$?            # Save exit code immediately after test run

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any modified files to clean state after test execution
git checkout 17676eaaf2346ff936fc2df78ec098fa7a81e3e0 tests/test_text_to_image_agent.py