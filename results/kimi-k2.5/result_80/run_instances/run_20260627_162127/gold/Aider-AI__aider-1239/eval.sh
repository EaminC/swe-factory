#!/bin/bash
set -uxo pipefail

# Activate virtual environment
source /opt/testbed/bin/activate

cd /testbed

# Checkout the target test file to ensure clean state
git checkout 301c4265b76a5b8c4a939acb59314e091cacebec "tests/basic/test_editblock.py"

# Apply test patch
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

# Run the target test file with concise output
pytest --no-header -rA --tb=no -p no:cacheprovider tests/basic/test_editblock.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the test file to original state
git checkout 301c4265b76a5b8c4a939acb59314e091cacebec "tests/basic/test_editblock.py"