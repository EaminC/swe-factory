#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 409892d65fab88e4a390f05c46b399b5a9260463

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Run only the specified test file using uv run pytest command
uv run pytest -vv tests/test_knowledge_embedder.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Instead of checking out only the test file which may no longer exist or was renamed,
# reset the entire repository to the original commit to clean up all changes robustly
git reset --hard 409892d65fab88e4a390f05c46b399b5a9260463