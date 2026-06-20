#!/bin/bash
set -uxo pipefail

# Activate the virtual environment
source /testbed/venv/bin/activate

# Navigate to the repository root
cd /testbed

# Ensure we are at the correct commit and the target test file is in its original state
git reset --hard 7dac88a3f8e8c0610e9e3189c867b19d055dab2d
git checkout 7dac88a3f8e8c0610e9e3189c867b19d055dab2d -- "tests/test_chat_to_files.py"

# Apply the test patch
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

# Ensure the package is properly installed in development mode
pip install -e . --no-deps 2>/dev/null || true

# Install test dependencies (including pytest-cov as used in CI)
pip install pytest pytest-cov

# Run only the specified test file with verbose output for debugging
# First run with full traceback to capture any import errors
pytest "tests/test_chat_to_files.py" -v --tb=short 2>&1 | tee /tmp/test_output.txt
rc=$?

# If the test collection failed (exit code 2), show more detailed error
if [ $rc -eq 2 ]; then
    echo "=== Test collection failed, showing detailed error ==="
    # Run pytest in a way that shows import errors without suppressing traceback
    python -m pytest "tests/test_chat_to_files.py" --collect-only 2>&1
fi

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the test file to its original state
git checkout 7dac88a3f8e8c0610e9e3189c867b19d055dab2d -- "tests/test_chat_to_files.py"