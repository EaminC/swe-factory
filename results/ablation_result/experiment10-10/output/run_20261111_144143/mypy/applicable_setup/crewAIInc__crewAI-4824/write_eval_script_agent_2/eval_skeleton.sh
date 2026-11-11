#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 542afe61a8adfca1b9a0434189b9f339dfb07817

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate uv virtual environment and run the specified test file only with pytest options from pyproject.toml
source .venv/bin/activate

uv run pytest -v --tb=short -n auto --timeout=60 --dist=loadfile --max-worker-restart=2 --block-network --import-mode=importlib tests/test_contextvar_threading.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository state & target test file to discard patch and any changes after test run
git checkout 542afe61a8adfca1b9a0434189b9f339dfb07817 tests/test_contextvar_threading.py