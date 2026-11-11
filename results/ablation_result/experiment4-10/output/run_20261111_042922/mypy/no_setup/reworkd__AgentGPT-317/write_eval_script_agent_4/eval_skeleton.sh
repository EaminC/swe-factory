#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout cff1554f488d75f02ae7acbe5a64f107103da389

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

TEST_FILE="platform/reworkd_platform/tests/test_settings.py"

# Check if test file exists
if [[ -f "$TEST_FILE" ]]; then
  # Check file extension to determine test runner
  case "$TEST_FILE" in
    *.js|*.jsx|*.ts|*.tsx)
      # Run Jest for JS/TS tests
      npx cross-env SKIP_ENV_VALIDATION=1 jest --findRelatedTests "$TEST_FILE" --reporters=default --testLocationInResults
      rc=$?
      ;;
    *.py)
      # Install Python and pytest dynamically as they are not in the base image
      apt-get update && apt-get install -y python3 python3-pip
      pip3 install pytest
      
      # Run pytest on the given Python test file
      pytest "$TEST_FILE"
      rc=$?
      ;;
    *)
      echo "Unsupported test file extension: $TEST_FILE"
      rc=1
      ;;
  esac
else
  echo "Test file $TEST_FILE does not exist."
  rc=1
fi

echo "OMNIGRIL_EXIT_CODE=$rc"

# Undo patch and any changes by resetting repo hard
git reset --hard cff1554f488d75f02ae7acbe5a64f107103da389

exit $rc