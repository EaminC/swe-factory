#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout ca4141564f86dd1b7dee3082959042dc05d5d471

# Apply test patch if required
git apply -v - <<'EOF_114329324912'
diff --git a/tests/basic/test_sendchat.py b/tests/basic/test_sendchat.py
new file mode 100644
index 00000000..e1a2f3b4
--- /dev/null
+++ b/tests/basic/test_sendchat.py
@@ -0,0 +1,35 @@
+import pytest
+
+from aider.sendchat import send_completion
+
+class DummyModel:
+    def __init__(self):
+        self.extra_headers = None
+        self.extra_body = {"foo": "bar"}
+        self.max_tokens = None
+
+def test_send_completion_passes_extra_body(monkeypatch):
+    called_kwargs = {}
+
+    def fake_send_completion(**kwargs):
+        called_kwargs.update(kwargs)
+        class Response:
+            class Choice:
+                def __init__(self):
+                    self.message = type('Msg', (), {'content': 'ok'})()
+            choices = [Choice()]
+        return (None, Response())
+
+    monkeypatch.setattr('aider.sendchat.send_completion', fake_send_completion)
+
+    extra_body = {"test_key": "test_value"}
+    response = send_completion(
+        model_name="dummy",
+        messages=[{"role": "user", "content": "Hello"}],
+        functions=None,
+        stream=False,
+        extra_body=extra_body
+    )
+    assert response.choices[0].message.content == 'ok'
+    assert 'extra_body' in called_kwargs
+    assert called_kwargs['extra_body'] == extra_body
EOF_114329324912

# Activate virtual environment
source ./testbed-venv/bin/activate

# Run only the specified test file with pytest, showing concise test results and test file names
pytest --no-header -rA --tb=no tests/basic/test_sendchat.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes after test run
git checkout ca4141564f86dd1b7dee3082959042dc05d5d471