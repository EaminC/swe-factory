#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 985c24e1b2b8e9463aacfbeb2c8a47f27fa4523c

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_gemini_model.py b/tests/test_gemini_model.py
new file mode 100644
index 0000000..e1a2f3b
--- /dev/null
+++ b/tests/test_gemini_model.py
@@ -0,0 +1,33 @@
+import pytest
+import sys
+import types
+
+import mle.model.gemini as gemini_module
+
+class DummyGemini:
+    def __init__(self):
+        self.configured = False
+        self.last_prompt = None
+
+    def configure(self, api_key):
+        self.configured = True
+        self.api_key = api_key
+
+    def chat(self, prompt, temperature=0.7):
+        self.last_prompt = prompt
+        # Return a dummy response mimicking Gemini API
+        return {"candidates": [{"content": '{"result": "success"}'}]}
+
+def test_gemini_model_init_and_chat(monkeypatch):
+    dummy = DummyGemini()
+    monkeypatch.setattr(gemini_module.importlib.util, "find_spec", lambda name: True)
+    monkeypatch.setattr(gemini_module.importlib, "import_module", lambda name: dummy)
+
+    model = gemini_module.GeminiModel(api_key="fake_key", model="gemini-v1")
+    assert dummy.configured
+    assert dummy.api_key == "fake_key"
+
+    response = model.chat("Hello")
+    assert isinstance(response, dict)
+    assert response.get("result") == "success"
+
EOF_114329324912

# Activate venv and run only the specified target test file(s) with unittest
source /testbed/testbed-venv/bin/activate

python -m unittest tests.test_gemini_model
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset patched files to original state
git checkout 985c24e1b2b8e9463aacfbeb2c8a47f27fa4523c