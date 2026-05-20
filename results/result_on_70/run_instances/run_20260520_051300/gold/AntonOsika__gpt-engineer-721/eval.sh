#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset target test file to specified commit state before patching
git checkout 7dac88a3f8e8c0610e9e3189c867b19d055dab2d "tests/test_chat_to_files.py"

# Apply test patch (placeholder content)
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

# Activate the virtual environment
source /opt/testbed-venv/bin/activate

# Install exact compatible version of langchain to avoid ImportError
pip install "langchain==0.0.232"

# Run only the specified test file with concise output showing test file name and pass/fail/skip status
pytest --no-header -rA --tb=short tests/test_chat_to_files.py
rc=$?

# Output exit code for test log analysis
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset target test file to original state after test run
git checkout 7dac88a3f8e8c0610e9e3189c867b19d055dab2d "tests/test_chat_to_files.py"