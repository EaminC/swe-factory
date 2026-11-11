#!/bin/bash
set -uxo pipefail

source /opt/testbed/bin/activate

cd /testbed

git checkout b0d89698fdd3eb5aced8e659f2241f0648b8a40b

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_openai_version.py b/tests/test_openai_version.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_openai_version.py
@@ -0,0 +1,13 @@
+import openai
+import pytest
+
+def test_openai_version_support():
+    # This test ensures that the openai package version is at least 1.78.0
+    version = tuple(map(int, openai.__version__.split('.')))
+    assert version >= (1, 78, 0), f"OpenAI version is {openai.__version__}, expected >= 1.78.0"
+
+@pytest.mark.xfail(strict=True, reason="Fails if openai version < 1.78.0")
+def test_openai_feature_available():
+    # Example test that would fail on older openai versions
+    # Here we just check the version again as a proxy for feature availability
+    assert openai.__version__.startswith("1.78") or openai.__version__ > "1.78"
EOF_114329324912

# Run the tests immediately after applying the patch, before any reset
pytest --tb=short -rA --disable-warnings tests/test_openai_version.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"