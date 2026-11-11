#!/bin/bash
set -uxo pipefail

# Activate the python virtual environment
source /opt/testbed/bin/activate

cd /testbed
git checkout c245029a6f1094fbe72f58b353908127bea8269b 

# Apply the test patch (content replaced programmatically)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

git checkout c245029a6f1094fbe72f58b353908127bea8269b 

# Run only the specified test files with pytest
pytest -o log_cli=false --maxfail=5 --disable-warnings --tb=short --capture=no --color=yes -rA tests/react_agent_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test files after running tests to clean any patch effect
git checkout c245029a6f1094fbe72f58b353908127bea8269b "tests/react_agent_test.py"