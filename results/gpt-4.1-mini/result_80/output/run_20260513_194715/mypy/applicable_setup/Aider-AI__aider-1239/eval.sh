#!/bin/bash
set -uxo pipefail

cd /testbed

# Restore the original state of the test file before applying patch
git checkout 301c4265b76a5b8c4a939acb59314e091cacebec "tests/basic/test_editblock.py"

# Apply the test patch (content replaced by the system)
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

# Run only the specified test file using pytest
# Use concise output with test file name and pass/fail/skip status shown clearly
pytest -q --tb=short tests/basic/test_editblock.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore test file to original state to ensure clean environment for next runs
git checkout 301c4265b76a5b8c4a939acb59314e091cacebec "tests/basic/test_editblock.py"