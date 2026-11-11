#!/bin/bash
set -euxo pipefail

cd /testbed
git checkout 17d40a62c931ac91fc9c31288310b37b62175c47

# Try to apply patch; if it fails because already applied, continue gracefully
if ! git apply -v - <<'EOF_114329324912'
diff --git a/tests/basic/test_models.py b/tests/basic/test_models.py
new file mode 100644
index 00000000..e69de29bb
--- /dev/null
+++ b/tests/basic/test_models.py
@@ -0,0 +1,23 @@
+import pytest
+from aider.models import Model
+
+def test_vertex_ai_model_name_normalization():
+    # Model name with -language-models/ should be normalized to /
+    raw_model_name = "vertex_ai-language-models/vertex_ai/gemini-2.5-flash-preview-04-17"
+    model = Model(raw_model_name)
+    # The Model class should normalize the model name to use '/' instead of '-language-models/'
+    assert "-language-models/" not in model.name
+    assert model.name == "vertex_ai/vertex_ai/gemini-2.5-flash-preview-04-17" or model.name == "vertex_ai/gemini-2.5-flash-preview-04-17"
+
+    # Also test that a model name without the pattern remains unchanged
+    normal_model_name = "vertex_ai/gemini-2.5-pro-preview-05-06"
+    model2 = Model(normal_model_name)
+    assert model2.name == normal_model_name
+
+@pytest.mark.parametrize("input_name,expected", [
+    ("vertex_ai-language-models/vertex_ai/claude-3-7-sonnet@20250219", "vertex_ai/vertex_ai/claude-3-7-sonnet@20250219"),
+    ("vertex_ai/claude-3-7-sonnet@20250219", "vertex_ai/claude-3-7-sonnet@20250219"),
+])
+def test_model_name_aliases(input_name, expected):
+    model = Model(input_name)
+    assert model.name == expected
EOF_114329324912
then
  echo "Patch failed to apply, trying to continue assuming it is already applied."
fi

# Activate conda environment using provided helper script for reliable activation
source /opt/conda/etc/profile.d/conda.sh
conda activate testbed

# Run tests only on the specified test file with minimal warning output and concise traceback
pytest --disable-warnings --tb=short tests/basic/test_models.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file after running tests to ensure clean state
git checkout 17d40a62c931ac91fc9c31288310b37b62175c47 tests/basic/test_models.py