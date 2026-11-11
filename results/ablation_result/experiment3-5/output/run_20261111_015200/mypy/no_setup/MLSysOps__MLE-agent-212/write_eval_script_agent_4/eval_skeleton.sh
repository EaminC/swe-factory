#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed
cd /testbed
git checkout a405d8130cbb24e6556fb0125f634c3fb738eb2a

# List contents of tests directory to verify existing test files
echo "Listing contents of the tests/ directory:"
ls -l tests/

# Inform that the specific test file does not exist and will run all tests discovered instead
echo "Note: 'tests/test_deepseek_model.py' does not exist in this commit."
echo "Running all available tests under the 'tests/' directory using unittest discover."

# Run all tests in the tests directory
python -m unittest discover tests
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"