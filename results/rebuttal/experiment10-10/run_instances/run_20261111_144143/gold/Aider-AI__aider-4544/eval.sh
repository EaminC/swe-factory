#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 249e38976508007aeda1c74344c83e1e37ec8e14

# Apply the test patch
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

# Activate the virtual environment
source /opt/testbed/bin/activate

# Run pytest only on the specified test file with concise output showing test names and results
# Use -p no:warnings to suppress warnings as recommended in pytest config
# Use -rA to show all extra test summary info (skip, fail, pass)
# Use --maxfail=1 (optionally) to stop at first fail (commented out here for full run)
pytest -p no:warnings -rA tests/basic/test_model_settings.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the patched test file to clean state
git checkout 249e38976508007aeda1c74344c83e1e37ec8e14 tests/basic/test_model_settings.py