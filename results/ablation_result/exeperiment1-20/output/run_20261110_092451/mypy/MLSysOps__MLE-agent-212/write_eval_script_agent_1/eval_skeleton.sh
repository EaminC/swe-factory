#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout a405d8130cbb24e6556fb0125f634c3fb738eb2a

# Apply patch if required
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run the specified test file(s) only using unittest module, preserving verbosity and output format
python3 -m unittest -v tests.test_deepseek_model
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the patched test file to original state after test
git checkout a405d8130cbb24e6556fb0125f634c3fb738eb2a tests/test_deepseek_model.py