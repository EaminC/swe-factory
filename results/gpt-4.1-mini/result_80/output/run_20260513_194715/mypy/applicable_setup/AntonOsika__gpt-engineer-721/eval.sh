#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout target commit and test file; fallback to HEAD if commit not found
if git rev-parse --verify 7dac88a3f8e8c0610e9e3189c867b19d055dab2d >/dev/null 2>&1; then
    git checkout 7dac88a3f8e8c0610e9e3189c867b19d055dab2d "tests/test_chat_to_files.py"
else
    git checkout HEAD "tests/test_chat_to_files.py"
fi

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_chat_to_files.py b/tests/test_chat_to_files.py
--- a/tests/test_chat_to_files.py
+++ b/tests/test_chat_to_files.py
@@ -13,7 +13,7 @@ class DummyDBs:
     project_metadata = {}
 
 
-def test_to_files():
+def test_to_files_and_memory():
     chat = textwrap.dedent(
         """
     This is a sample program.
EOF_114329324912

# Activate virtual environment
source /testbed/venv/bin/activate

# Reinstall langchain pinned to known compatible version with MODEL_COST_PER_1K_TOKENS to avoid import error
pip install "langchain==0.0.130"

# Install pytest-cov to support coverage argument
pip install pytest-cov

# Run only the specified test file with coverage output
pytest --cov=gpt_engineer tests/test_chat_to_files.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file changes
if git rev-parse --verify 7dac88a3f8e8c0610e9e3189c867b19d055dab2d >/dev/null 2>&1; then
    git checkout 7dac88a3f8e8c0610e9e3189c867b19d055dab2d "tests/test_chat_to_files.py"
else
    git checkout HEAD "tests/test_chat_to_files.py"
fi