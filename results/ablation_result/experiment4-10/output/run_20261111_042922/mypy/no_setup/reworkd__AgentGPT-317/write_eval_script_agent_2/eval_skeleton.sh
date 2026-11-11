#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout cff1554f488d75f02ae7acbe5a64f107103da389

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified test file with Jest using npx cross-env to ensure command availability
npx cross-env SKIP_ENV_VALIDATION=1 jest platform/reworkd_platform/tests/test_settings.py --reporters=default --testLocationInResults

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the whole repo to the specified commit to undo patch and changes safely
git reset --hard cff1554f488d75f02ae7acbe5a64f107103da389