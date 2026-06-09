#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout only the target test files to ensure a clean state before patching
git checkout 667713f6c04fbc208fb7eefba70f101562070c9e \
  "src/frontend/tests/core/features/chatInputOutputUser-shard-0.spec.ts" \
  "src/backend/tests/unit/utils/test_rewrite_file_path.py" \
  "src/frontend/tests/extended/regression/general-bugs-shard-3836.spec.ts"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the python virtual environment (venv)
source /opt/testbed-venv/bin/activate

# Run backend python test file with pytest (unit test)
# Run frontend playwright tests with correct sharding + file inputs
# We combine the Playwright commands for frontend TS test files, grouping them by directory

# Backend python test command
backend_test="pytest --no-header -rA --tb=short src/backend/tests/unit/utils/test_rewrite_file_path.py"

# Frontend playwright command base
frontend_base_cmd="cd src/frontend && npx playwright test --trace on --workers 2"

# Frontend test files grouped by shard though here we have 2 separate shards
# We'll run each shard command separately because shard indices differ (0 and 3836)
# and it's safer to run them independently, but combine tests in one shard if multiple

frontend_test_shard_0="tests/core/features/chatInputOutputUser-shard-0.spec.ts --shard 0/128"
frontend_test_shard_3836="tests/extended/regression/general-bugs-shard-3836.spec.ts --shard 3836/3840"

# Execute all tests with output of test file names and status
# Run backend python tests first, then each frontend shard test
set +x
echo "=== RUNNING BACKEND PYTHON TESTS ==="
$backend_test
rc_backend=$?
echo "=== RUNNING FRONTEND PLAYWRIGHT TESTS SHARD 0 ==="
cd src/frontend && npx playwright test $frontend_test_shard_0 --trace on --workers 2
rc_frontend_0=$?
echo "=== RUNNING FRONTEND PLAYWRIGHT TESTS SHARD 3836 ==="
npx playwright test $frontend_test_shard_3836 --trace on --workers 2
rc_frontend_3836=$?
set -x

# Determine aggregate exit code (fail if any failure)
rc=0
if [[ $rc_backend -ne 0 || $rc_frontend_0 -ne 0 || $rc_frontend_3836 -ne 0 ]]; then
  rc=1
fi

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the patched test files after the run
git checkout 667713f6c04fbc208fb7eefba70f101562070c9e \
  "src/frontend/tests/core/features/chatInputOutputUser-shard-0.spec.ts" \
  "src/backend/tests/unit/utils/test_rewrite_file_path.py" \
  "src/frontend/tests/extended/regression/general-bugs-shard-3836.spec.ts"