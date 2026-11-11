#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 04c71d7d297447479d897b6803206210ed589d53 

# Apply the test patch before running tests
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_vision_model.py b/tests/test_vision_model.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_vision_model.py
@@ -0,0 +1,23 @@
+import pytest
+from gpt_engineer.core.ai import AI
+
+def test_vision_flag_for_gpt_4_turbo():
+    # The vision flag should be True for 'gpt-4-turbo' model
+    ai = AI(model_name="gpt-4-turbo")
+    assert ai.vision is True
+
+    # Also True for 'gpt-4-turbo-2024-04-09'
+    ai2 = AI(model_name="gpt-4-turbo-2024-04-09")
+    assert ai2.vision is True
+
+    # Should be False for 'gpt-4-turbo-preview'
+    ai3 = AI(model_name="gpt-4-turbo-preview")
+    assert ai3.vision is False
+
+    # Should be True for 'vision-preview' in model name
+    ai4 = AI(model_name="gpt-4-vision-preview")
+    assert ai4.vision is True
+
+    # Should be False for unrelated model
+    ai5 = AI(model_name="gpt-3.5-turbo")
+    assert ai5.vision is False
EOF_114329324912

git checkout 04c71d7d297447479d897b6803206210ed589d53 

# Execute only the specified test file with Poetry run and pytest, capturing concise output with file names and statuses
poetry run pytest --no-header -rA --tb=short tests/test_vision_model.py
rc=$?            # save exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Clean up by resetting changes to the test file
git checkout 04c71d7d297447479d897b6803206210ed589d53 tests/test_vision_model.py