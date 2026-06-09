#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Reset target test file to the committed state before patching
git checkout 8b209d4e17ad7dfc1ad7a80505eac42f71228734 "tests/metagpt/provider/test_ollama_api.py"

# Apply test patch (content will be replaced programmatically)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified test file with verbose output of test file statuses,
# using pytest as recommended but limited to our target test path.
# We add --maxfail=1 --disable-warnings to keep output concise but informative.
pytest --continue-on-collection-errors --doctest-modules --cov=./metagpt/ --cov-report=xml:cov.xml --cov-report=html:htmlcov --durations=20 "tests/metagpt/provider/test_ollama_api.py" | tee unittest.txt
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to original state after tests
git checkout 8b209d4e17ad7dfc1ad7a80505eac42f71228734 "tests/metagpt/provider/test_ollama_api.py"