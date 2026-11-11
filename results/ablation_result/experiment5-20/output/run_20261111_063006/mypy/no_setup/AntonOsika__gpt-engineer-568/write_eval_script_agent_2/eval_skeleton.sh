#!/bin/bash
set -euxo pipefail

cd /testbed
git checkout f84754d54ee311146c4f52b5e3ceb0fa8d0b731b

# Verify if the target test file exists before attempting patch and test
if [[ ! -f tests/test_language_choice.py ]]; then
  echo "ERROR: Specified test file 'tests/test_language_choice.py' does not exist in the repository at commit f84754d54ee311146c4f52b5e3ceb0fa8d0b731b"
  echo "OMNIGRIL_EXIT_CODE=1"
  exit 1
fi

# Apply the test patch and handle failure gracefully
if ! git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912
then
  echo "ERROR: Failed to apply test patch."
  echo "OMNIGRIL_EXIT_CODE=1"
  exit 1
fi

# Activate python venv environment
source /testbed/testbed/bin/activate

# Confirm critical package folder and files before test run
if [[ ! -d gpt_engineer/preprompts ]]; then
  echo "WARNING: gpt_engineer/preprompts directory missing - this may cause import errors."
fi

# Run only the specified test file, show concise output and status
pytest --no-header --tb=short --disable-warnings -r a tests/test_language_choice.py --cov=gpt_engineer
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Attempt to reset patched files cleanly but ignore errors if file missing
git checkout -q -- tests/test_language_choice.py || true