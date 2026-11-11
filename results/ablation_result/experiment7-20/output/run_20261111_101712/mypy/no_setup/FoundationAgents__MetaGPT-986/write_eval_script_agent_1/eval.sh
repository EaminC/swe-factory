#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout bbb9645f7c60c35177922d10ccc7ed4b90d261c3

git apply -v - <<'EOF_114329324912'
diff --git a/tests/utils/test_text.py b/tests/utils/test_text.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/utils/test_text.py
@@ -0,0 +1,24 @@
+import pytest
+from metagpt.utils.text import reduce_message_length
+
+class DummyModel:
+    def __init__(self, name):
+        self.name = name
+
+def test_reduce_message_length_returns_short_message():
+    # Provide messages with one short enough message
+    msgs = (m for m in ["short message", "a" * 10000])
+    model_name = "gpt-3.5-turbo"
+    system_text = "system"
+    # Should return the first message because it is short enough
+    result = reduce_message_length(msgs, model_name, system_text)
+    assert result == "short message"
+
+def test_reduce_message_length_raises_on_all_long_messages():
+    # Provide messages all too long
+    long_msg = "a" * 100000
+    msgs = (m for m in [long_msg, long_msg])
+    model_name = "gpt-3.5-turbo"
+    system_text = "system"
+    with pytest.raises(RuntimeError, match="fail to reduce message length"):
+        reduce_message_length(msgs, model_name, system_text)
EOF_114329324912

# Activate conda environment and run specified test files only
source /opt/conda/etc/profile.d/conda.sh
conda activate testbed

# Run pytest on the provided test file (tests/utils/test_text.py) only with concise output and clear status
pytest -q --tb=short --disable-warnings tests/utils/test_text.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout bbb9645f7c60c35177922d10ccc7ed4b90d261c3