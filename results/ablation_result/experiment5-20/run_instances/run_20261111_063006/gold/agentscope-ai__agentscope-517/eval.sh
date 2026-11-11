#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout e616e52f444d01dbb249ea3d2e205cbd1c8fb848

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_encoding_support.py b/tests/test_encoding_support.py
new file mode 100644
index 00000000..e69de29bb
--- /dev/null
+++ b/tests/test_encoding_support.py
@@ -0,0 +1,28 @@
+# -*- coding: utf-8 -*-
+import subprocess
+import sys
+import tempfile
+import os
+
+import pytest
+
+def test_utf8_encoding_declaration():
+    # This test verifies that a script containing Chinese characters runs without SyntaxError
+    script_content = '''
+# -*- coding: utf-8 -*-
+def main():
+    prompt = '这是一个测试'  # Chinese characters
+    print(prompt)
+
+if __name__ == '__main__':
+    main()
+'''
+    with tempfile.NamedTemporaryFile('w', suffix='.py', delete=False, encoding='utf-8') as f:
+        f.write(script_content)
+        temp_path = f.name
+    try:
+        result = subprocess.run([sys.executable, temp_path], capture_output=True, text=True)
+        assert result.returncode == 0
+        assert '这是一个测试' in result.stdout
+    finally:
+        os.remove(temp_path)
EOF_114329324912

# Activate the virtual environment
source /testbed/testbed_venv/bin/activate

# Run only the specified test file with pytest, output concise results with test file names and status
pytest -q --tb=short --disable-warnings tests/test_encoding_support.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changes made by the patch after test execution
git checkout e616e52f444d01dbb249ea3d2e205cbd1c8fb848 tests/test_encoding_support.py