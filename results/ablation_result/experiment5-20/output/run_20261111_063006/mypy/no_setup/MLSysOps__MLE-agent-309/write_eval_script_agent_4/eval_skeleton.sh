#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout cf9762d3abd3cad227bbd859a3ef4f95dff164a3

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate python venv environment
source /testbed/testbed-venv/bin/activate

# Install dependencies and explicitly install pytest
pip install --upgrade pip setuptools wheel
pip install -e .
pip install pytest

# Run all tests using unittest discover only in 'tests' folder
python -m unittest discover -v tests
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup patch by resetting all changes
git checkout cf9762d3abd3cad227bbd859a3ef4f95dff164a3