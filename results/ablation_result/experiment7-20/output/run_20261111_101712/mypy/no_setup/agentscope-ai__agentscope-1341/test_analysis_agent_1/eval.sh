#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout c19b8bc5723ec562fff77d3386f10de3e426f8da 

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_openai_formatter.py b/tests/test_openai_formatter.py
new file mode 100644
index 0000000..e1c3d7a
--- /dev/null
+++ b/tests/test_openai_formatter.py
@@ -0,0 +1,25 @@
+import os
+import base64
+import tempfile
+import pytest
+from src.agentscope.formatter._openai_formatter import _to_openai_image_url
+
+def test_to_openai_image_url_local_file_no_extension():
+    # Create a temporary PNG image file without extension
+    png_header = b'\x89PNG\r\n\x1a\n'
+    with tempfile.NamedTemporaryFile(delete=False) as tmp:
+        tmp.write(png_header + b'\x00' * 100)  # minimal PNG content
+        tmp_path = tmp.name
+
+    try:
+        # The file has no extension
+        assert not os.path.splitext(tmp_path)[1]
+        # _to_openai_image_url should detect the image type and return a data URI
+        data_uri = _to_openai_image_url(tmp_path)
+        assert data_uri.startswith('data:image/png;base64,')
+        # The base64 part should decode back to the file content
+        b64_data = data_uri.split(',', 1)[1]
+        decoded = base64.b64decode(b64_data)
+        assert decoded.startswith(png_header)
+    finally:
+        os.remove(tmp_path)
EOF_114329324912

# Run only the specified test file with pytest, showing concise structured output
pytest --no-header -rA --tb=short --disable-warnings tests/test_openai_formatter.py
rc=$?            #Required, save exit code

echo "OMNIGRIL_EXIT_CODE=$rc" #Required, echo test status

# Reset the target test file changes after test run
git checkout c19b8bc5723ec562fff77d3386f10de3e426f8da tests/test_openai_formatter.py