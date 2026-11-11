#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 3878daffd68d14ee0379d11c19bef63c4dc02edc

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_parser.py b/tests/test_parser.py
new file mode 100644
index 0000000..e3b0c44
--- /dev/null
+++ b/tests/test_parser.py
@@ -0,0 +1,18 @@
+import pytest
+import re
+from crewai.agents.parser import _extract_thought
+
+def test_extract_thought_with_none_input():
+    # _extract_thought expects a string, passing None should be handled gracefully
+    with pytest.raises(TypeError):
+        _extract_thought(None)
+
+def test_extract_thought_with_valid_string():
+    text = "This is a thought.\n\nAnswer: something"
+    result = _extract_thought(text)
+    assert isinstance(result, str)
+    assert "This is a thought" in result
+
+def test_extract_thought_with_empty_string():
+    result = _extract_thought("")
+    assert result == ""
EOF_114329324912

# Activate the python virtual environment
source /testbed/testbed-venv/bin/activate

# Run only the specified test file using uv run pytest, with concise output of tests in that file
uv run pytest --tb=short -rA --disable-warnings tests/test_parser.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the applied patch after test run
git checkout 3878daffd68d14ee0379d11c19bef63c4dc02edc