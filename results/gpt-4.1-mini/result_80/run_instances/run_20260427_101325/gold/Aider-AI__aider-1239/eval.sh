#!/bin/bash
set -uxo pipefail

# Change to repository directory
cd /testbed

# Reset the target test file to the committed state before patch
git checkout 301c4265b76a5b8c4a939acb59314e091cacebec "tests/basic/test_editblock.py"

# Apply the test patch (content replaced programmatically)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/basic/test_editblock.py b/tests/basic/test_editblock.py
--- a/tests/basic/test_editblock.py
+++ b/tests/basic/test_editblock.py
@@ -456,6 +456,43 @@ def test_deepseek_coder_v2_filename_mangling(self):
             ],
         )
 
+    def test_new_file_created_in_same_folder(self):
+        edit = """
+Here's the change:
+
+path/to/a/file2.txt
+```python
+<<<<<<< SEARCH
+=======
+three
+>>>>>>> REPLACE
+```
+
+another change
+
+path/to/a/file1.txt
+```python
+<<<<<<< SEARCH
+one
+=======
+two
+>>>>>>> REPLACE
+```
+
+Hope you like it!
+"""
+
+        edits = list(
+            eb.find_original_update_blocks(edit, valid_fnames=["path/to/a/file1.txt"])
+        )
+        self.assertEqual(
+            edits,
+            [
+                ("path/to/a/file2.txt", "", "three\n"),
+                ("path/to/a/file1.txt", "one\n", "two\n"),
+            ],
+        )
+
 
 if __name__ == "__main__":
     unittest.main()
EOF_114329324912

# Activate the virtual environment
source /opt/venv/bin/activate

# Run only the specified test file with pytest
# Use options to be concise and show test names with pass/fail/skip status
pytest --tb=short -rA --disable-warnings tests/basic/test_editblock.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the test file to original committed state after test execution
git checkout 301c4265b76a5b8c4a939acb59314e091cacebec "tests/basic/test_editblock.py"