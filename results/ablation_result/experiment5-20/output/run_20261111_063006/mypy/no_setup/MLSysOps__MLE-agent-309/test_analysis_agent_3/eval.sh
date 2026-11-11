#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout cf9762d3abd3cad227bbd859a3ef4f95dff164a3

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_gemini_model.py b/tests/test_gemini_model.py
new file mode 100644
index 0000000..e3f1a2b
--- /dev/null
+++ b/tests/test_gemini_model.py
@@ -0,0 +1,35 @@
+import pytest
+from unittest.mock import patch, MagicMock
+import mle.model.gemini as gemini_module
+
+@pytest.fixture
+def dummy_api_key():
+    return "dummy_api_key"
+
+@pytest.fixture
+def dummy_model():
+    return "gemini-2.5-flash"
+
+def test_gemini_model_init(dummy_api_key, dummy_model):
+    model = gemini_module.GeminiModel(api_key=dummy_api_key, model=dummy_model)
+    assert model.model == dummy_model
+    assert model.temperature == 0.7
+    assert model.model_type == 'Gemini'
+    assert hasattr(model, 'client')
+
+@patch('mle.model.gemini.client.Client')
+def test_create_gemini_tools_none_and_valid(mock_client_class, dummy_api_key, dummy_model):
+    model = gemini_module.GeminiModel(api_key=dummy_api_key, model=dummy_model)
+    # Test with None input
+    assert model._create_gemini_tools(None) is None
+
+    # Test with a simple function dict
+    functions = [{
+        "name": "test_func",
+        "description": "A test function",
+        "parameters": {"type": "object", "properties": {"param1": {"type": "string"}}}
+    }]
+    tools = model._create_gemini_tools(functions)
+    assert tools is not None
+    assert hasattr(tools, 'function_declarations')
+    assert len(tools.function_declarations) == 1
EOF_114329324912

# Activate python venv environment
source /testbed/testbed-venv/bin/activate

# Install dependencies and ensure environment is ready
pip install --upgrade pip setuptools wheel
pip install -e .

# Run all tests using unittest discover only in 'tests' folder as no individual tests are runnable directly
python -m unittest discover -v tests
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup patch by resetting all changes
git checkout cf9762d3abd3cad227bbd859a3ef4f95dff164a3