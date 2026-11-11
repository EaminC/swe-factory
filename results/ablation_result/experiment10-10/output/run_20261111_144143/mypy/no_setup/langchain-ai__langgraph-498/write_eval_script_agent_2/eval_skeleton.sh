#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout d63b15dc4721d48cb8368fe9011398df417fbc32 

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Check if langgraph package can be imported, show poetry installed packages for debugging
echo "=== Poetry show installed packages ==="
poetry show

echo "=== Checking import of langgraph package ==="
python3 -c "import langgraph" 

# Export PYTHONPATH to ensure /testbed is discoverable in case local src imports needed
export PYTHONPATH=/testbed:$PYTHONPATH

# Run only the target test file with pytest, concise output with test status
poetry run pytest --no-header -rA --tb=short libs/checkpoint-postgres/tests/test_continue_thread.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup:
# If test file is a new or modified file introduced by patch, reset with `git restore` which works for tracked and untracked
# Since git checkout failed previously for test file, use 'git restore' or remove untracked files explicitly

# Try git restore first, fallback to git clean -f if needed
git restore libs/checkpoint-postgres/tests/test_continue_thread.py || true
# Remove any untracked files (including newly created test file)
git clean -fd || true

# Finally reset to original commit to ensure clean state
git reset --hard d63b15dc4721d48cb8368fe9011398df417fbc32