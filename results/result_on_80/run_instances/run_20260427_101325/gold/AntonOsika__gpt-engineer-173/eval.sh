#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 35c35b3ffab89cfa0eb714f5d5c28c6eb2aa7faa tests/test_chat_to_files.py

# Apply the required test patch
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

# Run only the specified test file using the virtual environment (venv) already set up in Docker
# The PATH already includes venv/bin, so pytest is directly available
pytest --no-header -rA --tb=short -p no:cacheprovider tests/test_chat_to_files.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any modifications to the test file after running tests
git checkout 35c35b3ffab89cfa0eb714f5d5c28c6eb2aa7faa tests/test_chat_to_files.py