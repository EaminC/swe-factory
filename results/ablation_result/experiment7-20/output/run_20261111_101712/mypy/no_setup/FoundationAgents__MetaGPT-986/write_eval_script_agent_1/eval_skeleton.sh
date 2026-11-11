#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout bbb9645f7c60c35177922d10ccc7ed4b90d261c3

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate conda environment and run specified test files only
source /opt/conda/etc/profile.d/conda.sh
conda activate testbed

# Run pytest on the provided test file (tests/utils/test_text.py) only with concise output and clear status
pytest -q --tb=short --disable-warnings tests/utils/test_text.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout bbb9645f7c60c35177922d10ccc7ed4b90d261c3