#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 17d40a62c931ac91fc9c31288310b37b62175c47

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate conda environment and run tests concisely for the target test file only
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

# Run pytest with minimal verbosity but showing the test file outcome, warnings suppressed as per context
pytest --disable-warnings --tb=short tests/basic/test_models.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to original state after test run
git checkout 17d40a62c931ac91fc9c31288310b37b62175c47 tests/basic/test_models.py