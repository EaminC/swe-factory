#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 985c24e1b2b8e9463aacfbeb2c8a47f27fa4523c

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate venv and run only the specified target test file(s) with unittest
source /testbed/testbed-venv/bin/activate

python -m unittest tests.test_gemini_model
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset patched files to original state
git checkout 985c24e1b2b8e9463aacfbeb2c8a47f27fa4523c