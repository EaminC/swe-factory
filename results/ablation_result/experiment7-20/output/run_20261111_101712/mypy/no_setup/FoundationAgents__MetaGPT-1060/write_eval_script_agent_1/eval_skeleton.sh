#!/bin/bash
set -uxo pipefail

source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

git checkout 0958cc333ee13d1ce5216ae0bdeaa53b5eacc6ea

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified test file with concise output showing file and status of tests
pytest --no-header -rA --tb=short tests/test_timeout_config.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the test file to original state
git checkout 0958cc333ee13d1ce5216ae0bdeaa53b5eacc6ea -- tests/test_timeout_config.py