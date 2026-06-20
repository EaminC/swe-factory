#!/bin/bash
set -uxo pipefail

# Activate the virtual environment
source /testbed/venv/bin/activate

# Navigate to the repository root
cd /testbed

# Ensure the target test file is at the correct commit state before applying patch
git checkout 301c4265b76a5b8c4a939acb59314e091cacebec "tests/basic/test_editblock.py"

# Apply the test patch (placeholder will be replaced with actual patch content)
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

# Run the specific target test file using pytest
# Use --no-header to suppress header, -v for verbose output, and capture exit code
pytest --no-header -v "tests/basic/test_editblock.py"
rc=$?

# Output the exit code for the judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the test file to its original state after test execution
git checkout 301c4265b76a5b8c4a939acb59314e091cacebec "tests/basic/test_editblock.py"