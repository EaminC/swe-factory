#!/bin/bash
set -uxo pipefail

cd /testbed

# Ensure we are on the correct commit
git checkout ea7393b7c5e6009b77bcac00f41dd5dcfd41df7a

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified test file using unittest discover and pattern option
python -m unittest discover -s tests -p test_lancedbmemory.py -v
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the repository to discard patch changes
git checkout ea7393b7c5e6009b77bcac00f41dd5dcfd41df7a