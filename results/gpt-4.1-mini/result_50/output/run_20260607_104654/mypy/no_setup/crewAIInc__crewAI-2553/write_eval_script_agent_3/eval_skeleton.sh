#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test files to the committed state before applying patch
git checkout 37979a0ca1ab7c657ed005fdfeabacaa1a7a3568 tests/memory/external/external_memory_test.py tests/memory/user_memory_test.py tests/storage/test_mem0_storage.py

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the correct virtual environment, ensure mem0 optional dependency is installed, and run the specified test files
source /testbed/.venv/bin/activate

# Install mem0 optional dependency required by tests
pip install mem0ai>=0.1.29

uv run pytest -rA --tb=short --disable-warnings tests/memory/external/external_memory_test.py tests/memory/user_memory_test.py tests/storage/test_mem0_storage.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test files to committed state after test run
git checkout 37979a0ca1ab7c657ed005fdfeabacaa1a7a3568 tests/memory/external/external_memory_test.py tests/memory/user_memory_test.py tests/storage/test_mem0_storage.py