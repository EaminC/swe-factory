#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout b9765e74d8c3e87ba6828fc7f9fc7fe751ef7984

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_memory_cli.py b/tests/test_memory_cli.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_memory_cli.py
@@ -0,0 +1,31 @@
+import os
+import tempfile
+import pytest
+from click.testing import CliRunner
+from mle.cli import memory
+
+def create_temp_py_file(content="print('hello world')\n"):
+    fd, path = tempfile.mkstemp(suffix='.py')
+    with os.fdopen(fd, 'w') as f:
+        f.write(content)
+    return path
+
+@pytest.mark.parametrize("cmd_option", ['--add', '--rm', '--update'])
+def test_memory_cli_add_rm_update(cmd_option):
+    runner = CliRunner()
+    temp_file = create_temp_py_file()
+    try:
+        # Run the CLI command with the temp file
+        result = runner.invoke(memory, [cmd_option, temp_file])
+        # The command should exit without error
+        assert result.exit_code == 0
+        # Since no exception, memory operations likely succeeded
+    finally:
+        os.remove(temp_file)
+
+def test_memory_cli_no_path():
+    runner = CliRunner()
+    result = runner.invoke(memory, [])
+    # Should exit normally and do nothing
+    assert result.exit_code == 0
+    assert result.output == ''
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file using unittest module with detailed output
python -m unittest -v tests/test_memory_cli.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the applied patch by checking out the original commit version of the test file
git checkout b9765e74d8c3e87ba6828fc7f9fc7fe751ef7984 tests/test_memory_cli.py