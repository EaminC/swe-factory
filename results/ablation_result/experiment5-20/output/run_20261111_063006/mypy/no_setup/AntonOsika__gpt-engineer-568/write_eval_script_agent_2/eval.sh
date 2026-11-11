#!/bin/bash
set -euxo pipefail

cd /testbed
git checkout f84754d54ee311146c4f52b5e3ceb0fa8d0b731b

# Verify if the target test file exists before attempting patch and test
if [[ ! -f tests/test_language_choice.py ]]; then
  echo "ERROR: Specified test file 'tests/test_language_choice.py' does not exist in the repository at commit f84754d54ee311146c4f52b5e3ceb0fa8d0b731b"
  echo "OMNIGRIL_EXIT_CODE=1"
  exit 1
fi

# Apply the test patch and handle failure gracefully
if ! git apply -v - <<'EOF_114329324912'
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
then
  echo "ERROR: Failed to apply test patch."
  echo "OMNIGRIL_EXIT_CODE=1"
  exit 1
fi

# Activate python venv environment
source /testbed/testbed/bin/activate

# Confirm critical package folder and files before test run
if [[ ! -d gpt_engineer/preprompts ]]; then
  echo "WARNING: gpt_engineer/preprompts directory missing - this may cause import errors."
fi

# Run only the specified test file, show concise output and status
pytest --no-header --tb=short --disable-warnings -r a tests/test_language_choice.py --cov=gpt_engineer
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Attempt to reset patched files cleanly but ignore errors if file missing
git checkout -q -- tests/test_language_choice.py || true