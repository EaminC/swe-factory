#!/bin/bash
set -uxo pipefail

# Change to testbed directory
cd /testbed

# Ensure we're on the correct commit
git checkout 35c35b3ffab89cfa0eb714f5d5c28c6eb2aa7faa

# Apply test patch if provided (placeholder for actual patch content)
# This patch should create or add the test_chat_to_files.py test file
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_chat_to_files.py b/tests/test_chat_to_files.py
new file mode 100644
--- /dev/null
+++ b/tests/test_chat_to_files.py
@@ -0,0 +1,94 @@
+import textwrap
+
+from gpt_engineer.chat_to_files import to_files
+
+
+def test_to_files():
+    chat = textwrap.dedent(
+        """
+    This is a sample program.
+
+    file1.py
+    ```python
+    print("Hello, World!")
+    ```
+
+    file2.py
+    ```python
+    def add(a, b):
+        return a + b
+    ```
+    """
+    )
+
+    workspace = {}
+    to_files(chat, workspace)
+
+    assert workspace["all_output.txt"] == chat
+
+    expected_files = {
+        "file1.py": 'print("Hello, World!")\n',
+        "file2.py": "def add(a, b):\n    return a + b\n",
+        "README.md": "\nThis is a sample program.\n\nfile1.py\n",
+    }
+
+    for file_name, file_content in expected_files.items():
+        assert workspace[file_name] == file_content
+
+
+def test_to_files_with_square_brackets():
+    chat = textwrap.dedent(
+        """
+    This is a sample program.
+
+    [file1.py]
+    ```python
+    print("Hello, World!")
+    ```
+
+    [file2.py]
+    ```python
+    def add(a, b):
+        return a + b
+    ```
+    """
+    )
+    workspace = {}
+    to_files(chat, workspace)
+
+    assert workspace["all_output.txt"] == chat
+
+    expected_files = {
+        "file1.py": 'print("Hello, World!")\n',
+        "file2.py": "def add(a, b):\n    return a + b\n",
+        "README.md": "\nThis is a sample program.\n\n[file1.py]\n",
+    }
+
+    for file_name, file_content in expected_files.items():
+        assert workspace[file_name] == file_content
+
+
+def test_files_with_brackets_in_name():
+    chat = textwrap.dedent(
+        """
+    This is a sample program.
+
+    [id].jsx
+    ```javascript
+    console.log("Hello, World!")
+    ```
+    """
+    )
+
+    workspace = {}
+    to_files(chat, workspace)
+
+    assert workspace["all_output.txt"] == chat
+
+    expected_files = {
+        "[id].jsx": 'console.log("Hello, World!")\n',
+        "README.md": "\nThis is a sample program.\n\n[id].jsx\n",
+    }
+
+    for file_name, file_content in expected_files.items():
+        assert workspace[file_name] == file_content
EOF_114329324912

# Activate the virtual environment
source /testbed/venv/bin/activate

# Verify Python and pytest are available
echo "=== Python and Test Framework Verification ==="
python --version
pytest --version

# List available test files for verification
echo ""
echo "=== Available Test Files in Repository ==="
find /testbed/tests -name "test_*.py" -type f | sort
ls -la /testbed/tests/ 2>/dev/null || echo "tests directory not found"

# Run the target test file
echo ""
echo "=== Running Target Test: tests/test_chat_to_files.py ==="
pytest -xvs tests/test_chat_to_files.py 2>&1
rc=$?

# Echo the exit code for evaluation
echo ""
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset to the original commit state
git checkout 35c35b3ffab89cfa0eb714f5d5c28c6eb2aa7faa

exit $rc