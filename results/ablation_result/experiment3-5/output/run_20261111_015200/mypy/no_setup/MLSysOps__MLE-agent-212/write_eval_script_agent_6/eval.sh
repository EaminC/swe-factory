#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed
cd /testbed
git checkout a405d8130cbb24e6556fb0125f634c3fb738eb2a

# List contents of the tests/ directory for debug
echo "Listing contents of tests/ directory:"
ls -l tests/

# Check if the target test file exists, else provide a clear message and skip direct run
if [ -f tests/test_deepseek_model.py ]; then
  echo "Found target test file: tests/test_deepseek_model.py"
  # Run only the specified test file
  python -m unittest tests.test_deepseek_model
else
  echo "Target test file 'tests/test_deepseek_model.py' not found."
  echo "Running all discovered tests under tests/ directory (may result in zero tests)."
  python -m unittest discover tests
fi
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"