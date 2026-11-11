#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 249e38976508007aeda1c74344c83e1e37ec8e14

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/basic/test_model_settings.py b/tests/basic/test_model_settings.py
new file mode 100644
index 00000000..e69de29bb
--- /dev/null
+++ b/tests/basic/test_model_settings.py
@@ -0,0 +1,20 @@
+import yaml
+import pytest
+
+def test_bedrock_claude_sonnet_4_5_in_model_settings():
+    with open("aider/resources/model-settings.yml", "r", encoding="utf-8") as f:
+        data = yaml.safe_load(f)
+    # Find the entry for the new model
+    model_names = [entry.get('name') for entry in data if isinstance(entry, dict) and 'name' in entry]
+    target_name = "bedrock/global.anthropic.claude-sonnet-4-5-20250929-v1:0"
+    assert target_name in model_names, f"Model name {target_name} not found in model-settings.yml"
+    # Check some expected keys for this model
+    for entry in data:
+        if entry.get('name') == target_name:
+            assert entry.get('edit_format') == 'diff'
+            assert 'extra_params' in entry
+            assert 'extra_headers' in entry['extra_params']
+            assert 'anthropic-beta' in entry['extra_params']['extra_headers']
+            break
+    else:
+        pytest.fail(f"Model entry {target_name} not found")
EOF_114329324912

# Activate python virtual environment
source /testbed/testbed_venv/bin/activate

# Run only the specified test file with pytest, showing concise output with test file names and results
pytest --no-header -rA --tb=short tests/basic/test_model_settings.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the repository state to discard patch changes
git checkout 249e38976508007aeda1c74344c83e1e37ec8e14