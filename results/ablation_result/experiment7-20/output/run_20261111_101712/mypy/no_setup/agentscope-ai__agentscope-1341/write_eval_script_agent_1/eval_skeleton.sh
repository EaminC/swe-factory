#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout c19b8bc5723ec562fff77d3386f10de3e426f8da 

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified test file with pytest, showing concise structured output
pytest --no-header -rA --tb=short --disable-warnings tests/test_openai_formatter.py
rc=$?            #Required, save exit code

echo "OMNIGRIL_EXIT_CODE=$rc" #Required, echo test status

# Reset the target test file changes after test run
git checkout c19b8bc5723ec562fff77d3386f10de3e426f8da tests/test_openai_formatter.py