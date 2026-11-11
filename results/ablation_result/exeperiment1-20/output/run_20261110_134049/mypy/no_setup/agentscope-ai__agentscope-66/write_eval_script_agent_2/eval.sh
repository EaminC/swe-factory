#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout the specified commit to ensure clean state
git checkout 0b4bf85481d3cde1f4a5f16d6faeb6e9c9d2a49c 

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_logging_unicode.py b/tests/test_logging_unicode.py
new file mode 100644
index 00000000..d4f5c2a1
--- /dev/null
+++ b/tests/test_logging_unicode.py
@@ -0,0 +1,29 @@
+import logging
+import json
+import pytest
+
+from src.agentscope.utils import logging_utils
+
+logger = logging.getLogger("agentscope")
+
+def test_logger_outputs_unicode(capsys):
+    # Prepare a message with Chinese characters
+    message = {"text": "测试中文日志输出"}
+
+    # Use the logging_utils _chat function which uses json.dumps with ensure_ascii=False
+    logging_utils._chat(message)
+
+    # Capture the log output
+    captured = capsys.readouterr()
+
+    # The output should contain the Chinese characters, not escaped unicode
+    assert "测试中文日志输出" in captured.out or "测试中文日志输出" in captured.err
+
+@pytest.mark.parametrize("obj", [
+    {"key": "值"},
+    {"nested": {"inner": "中文内容"}},
+])
+def test_json_dumps_ensure_ascii_false(obj):
+    s = json.dumps(obj, ensure_ascii=False)
+    assert any(ord(c) > 127 for c in s)
+    assert "\\u" not in s
EOF_114329324912

# Activate the virtual environment
source /testbed/testbed-venv/bin/activate

# Pre-import or setup custom loguru levels before running tests to avoid ValueError for CHAT_SAVE
# Run a short Python snippet that imports the logging utils to register custom levels
python3 -c "from src.agentscope.utils import logging_utils; logging_utils.setup_logger()"

# Run only the specified test file with pytest, showing concise output with test file and pass/fail/skip for each test
pytest -q --tb=short -rA tests/test_logging_unicode.py

rc=$?  # capture exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset patched test file to clean state after test run
git checkout 0b4bf85481d3cde1f4a5f16d6faeb6e9c9d2a49c tests/test_logging_unicode.py