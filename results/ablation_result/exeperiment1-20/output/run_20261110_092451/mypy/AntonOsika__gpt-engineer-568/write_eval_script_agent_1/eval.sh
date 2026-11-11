#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout f84754d54ee311146c4f52b5e3ceb0fa8d0b731b 

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_language_choice.py b/tests/test_language_choice.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_language_choice.py
@@ -0,0 +1,16 @@
+import pytest
+
+from gpt_engineer.preprompts import philosophy
+
+def test_philosophy_includes_language_choice():
+    # The philosophy prompt should enforce using the user-requested language, not default to Python
+    prompt = philosophy
+    assert "Always use the programming language the user asks for." in prompt
+    # It should mention requirements.txt for Python
+    assert "For Python, you always create an appropriate requirements.txt file." in prompt
+    # It should mention package.json for NodeJS
+    assert "For NodeJS, you always create an appropriate package.json file." in prompt
+
+    # Check that the prompt no longer says "You almost always put different classes in different files."
+    assert "You almost always put different classes in different files." not in prompt
+
EOF_114329324912

# Activate virtual environment and run specified test file(s)
source /testbed/venv/bin/activate

pytest --no-header -rA --tb=short tests/test_language_choice.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the repository state to discard applied patch
git checkout f84754d54ee311146c4f52b5e3ceb0fa8d0b731b