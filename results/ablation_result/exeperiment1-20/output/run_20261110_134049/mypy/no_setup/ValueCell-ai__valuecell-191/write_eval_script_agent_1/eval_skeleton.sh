#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 0e4b1ffbc3a9d2ac3a4d0d381766b9d929e42dad

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the python virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file using uv run pytest from the python folder
# This ensures only target tests execute, printing concise status of the tests
uv run pytest server/api/routers/tests/test_user_profile_api.py --tb=short -q --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modification to keep repo clean
git checkout 0e4b1ffbc3a9d2ac3a4d0d381766b9d929e42dad server/api/routers/tests/test_user_profile_api.py