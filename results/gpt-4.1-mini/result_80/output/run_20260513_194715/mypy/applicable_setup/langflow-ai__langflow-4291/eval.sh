#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 3131c0ce083e157f5188cea833592c6cf4aad9d2 

# Apply the test patch (content replaced during execution)
git apply -v - <<'EOF_114329324912'
diff --git a/src/backend/tests/unit/components/models/test_huggingface.py b/src/backend/tests/unit/components/models/test_huggingface.py
new file mode 100644
--- /dev/null
+++ b/src/backend/tests/unit/components/models/test_huggingface.py
@@ -0,0 +1,31 @@
+from langflow.inputs.inputs import DictInput, DropdownInput, FloatInput, HandleInput, IntInput, SecretStrInput, StrInput
+
+from src.backend.base.langflow.components.models.huggingface import HuggingFaceEndpointsComponent
+
+
+def test_huggingface_inputs():
+    component = HuggingFaceEndpointsComponent()
+    inputs = component.inputs
+
+    # Define expected input types and their names
+    expected_inputs = {
+        "model_id": StrInput,
+        "max_new_tokens": IntInput,
+        "top_k": IntInput,
+        "top_p": FloatInput,
+        "typical_p": FloatInput,
+        "temperature": FloatInput,
+        "repetition_penalty": FloatInput,
+        "inference_endpoint": StrInput,
+        "task": DropdownInput,
+        "huggingfacehub_api_token": SecretStrInput,
+        "model_kwargs": DictInput,
+        "retry_attempts": IntInput,
+        "output_parser": HandleInput,
+    }
+
+    # Check if all expected inputs are present
+    for name, input_type in expected_inputs.items():
+        assert any(
+            isinstance(inp, input_type) and inp.name == name for inp in inputs
+        ), f"Missing or incorrect input: {name}"
EOF_114329324912

# Activate python virtual environment
source /testbed/.venv/bin/activate

# Ensure pytest is installed in the virtual environment
pip install pytest

# Run pytest on the specified test file only, with requested flags from Makefile logic
pytest --instafail -n auto -rA --durations=10 --disable-warnings --ignore-glob='*integration*' "src/backend/tests/unit/components/models/test_huggingface.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"