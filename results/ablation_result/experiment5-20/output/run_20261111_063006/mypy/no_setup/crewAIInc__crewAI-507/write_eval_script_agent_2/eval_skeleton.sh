#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 3d5257592b440fca8c46b77471e1c34c901ee57f 

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Explicitly install test dependencies including pytest since poetry install was done without test group
poetry install -G test --no-interaction --no-ansi

# Run only the specified test file with pytest via poetry
poetry run pytest -v tests/test_paths.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Attempt to restore repo state if test file exists in git at this commit
if git ls-files --error-unmatch tests/test_paths.py > /dev/null 2>&1; then
  git checkout 3d5257592b440fca8c46b77471e1c34c901ee57f tests/test_paths.py
fi