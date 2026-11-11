#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout cc7d248e9ec8f9359d7454017ddc6a31bde840b4

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the venv environment (already set in PATH and VIRTUAL_ENV by Dockerfile)
# Run unittest on the specified test file only
python -m unittest tests.test_cache
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout cc7d248e9ec8f9359d7454017ddc6a31bde840b4