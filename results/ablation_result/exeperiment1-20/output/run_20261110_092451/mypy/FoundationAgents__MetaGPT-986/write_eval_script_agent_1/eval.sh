#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout bbb9645f7c60c35177922d10ccc7ed4b90d261c3

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/utils/test_text.py b/tests/utils/test_text.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/utils/test_text.py
@@ -0,0 +1,24 @@
+import pytest
+from metagpt.utils.text import reduce_message_length
+
+class DummyModel:
+    def __init__(self, name):
+        self.name = name
+
+def test_reduce_message_length_returns_short_message():
+    # Provide messages with one short enough message
+    msgs = (m for m in ["short message", "a" * 10000])
+    model_name = "gpt-3.5-turbo"
+    system_text = "system"
+    # Should return the first message because it is short enough
+    result = reduce_message_length(msgs, model_name, system_text)
+    assert result == "short message"
+
+def test_reduce_message_length_raises_on_all_long_messages():
+    # Provide messages all too long
+    long_msg = "a" * 100000
+    msgs = (m for m in [long_msg, long_msg])
+    model_name = "gpt-3.5-turbo"
+    system_text = "system"
+    with pytest.raises(RuntimeError, match="fail to reduce message length"):
+        reduce_message_length(msgs, model_name, system_text)
EOF_114329324912

# Activate conda environment metagpt
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate metagpt

# Copy the test config file to expected location before running tests
mkdir -p ~/.metagpt
cp tests/config2.yaml ~/.metagpt/config2.yaml

# Run the test dependencies installation script before executing tests
sh tests/scripts/run_install_deps.sh

# Set environment variable to disable OpenAI API call in tests
export ALLOW_OPENAI_API_CALL=0

# Run only the specified test file with detailed but concise reporting
pytest --tb=short --disable-warnings -q --doctest-modules --cov=./metagpt/ --cov-report=xml:cov.xml --cov-report=html:htmlcov tests/utils/test_text.py | tee unittest.txt

# Output summary of test results in that test file
grep -E "FAILED tests|ERROR tests|[0-9]+ passed," unittest.txt || true  

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the patched test file to original state
git checkout bbb9645f7c60c35177922d10ccc7ed4b90d261c3 tests/utils/test_text.py