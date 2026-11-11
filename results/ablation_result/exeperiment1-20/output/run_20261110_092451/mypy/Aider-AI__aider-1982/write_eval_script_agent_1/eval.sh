#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 0fe5247d4c8aa9ceff28f65c6e7fc04b4ce53ec4

# Apply test patch before running tests
git apply -v - <<'EOF_114329324912'
diff --git a/tests/basic/test_io.py b/tests/basic/test_io.py
new file mode 100644
index 00000000..d1e2f3a4
--- /dev/null
+++ b/tests/basic/test_io.py
@@ -0,0 +1,48 @@
+import pytest
+from pathlib import Path
+from aider.io import InputOutput
+
+class DummyIO(InputOutput):
+    def __init__(self):
+        pass
+
+def test_format_files_for_input_minimal_unique_ids():
+    io = DummyIO()
+    # Files with unique names
+    rel_fnames = [
+        "foo.py",
+        "bar.py",
+        "baz/qux.py"
+    ]
+    rel_read_only_fnames = ["bar.py"]
+    output = io.format_files_for_input(rel_fnames, rel_read_only_fnames)
+    lines = output.strip().split('\n')
+    # Read-only files prefixed with ' R '
+    assert any(line.startswith(' R ') and 'bar.py' in line for line in lines)
+    # Editable files prefixed with '   '
+    assert any(line.startswith('   ') and 'foo.py' in line for line in lines)
+    assert any(line.startswith('   ') and 'qux.py (baz)' in line for line in lines)
+
+def test_compute_minimal_fileids_shared_prefix():
+    io = DummyIO()
+    rel_fnames = [
+        "a/b/c/file.txt",
+        "a/b/d/file.txt",
+        "a/x/file.txt"
+    ]
+    minimal_ids = io.compute_minimal_fileids(rel_fnames)
+    # The minimal unique ids should disambiguate the files
+    assert minimal_ids["a/b/c/file.txt"] == "c/file.txt"
+    assert minimal_ids["a/b/d/file.txt"] == "d/file.txt"
+    assert minimal_ids["a/x/file.txt"] == "file.txt"
+
+def test_format_files_for_input_with_shared_prefix():
+    io = DummyIO()
+    rel_fnames = ["a/b/c/file.txt", "a/b/d/file.txt"]
+    rel_read_only_fnames = ["a/b/d/file.txt"]
+    output = io.format_files_for_input(rel_fnames, rel_read_only_fnames)
+    lines = output.strip().split('\n')
+    # Read-only file should be prefixed with ' R ' and show minimal unique id
+    assert any(line.startswith(' R ') and 'file.txt (d)' in line for line in lines)
+    # Editable file should be prefixed with '   ' and show minimal unique id
+    assert any(line.startswith('   ') and 'file.txt (c)' in line for line in lines)
EOF_114329324912

# Activate the virtual environment
source /testbed/testbed/bin/activate

# Run the specified test file only, print concise test results with file and status per test
pytest -q --disable-warnings --tb=short --maxfail=1 tests/basic/test_io.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset any changes caused by patch or tests
git checkout 0fe5247d4c8aa9ceff28f65c6e7fc04b4ce53ec4 tests/basic/test_io.py