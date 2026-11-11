#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 5e8bd105177e08848990d32b9ea636daa639be19

# Apply required test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_llm_config.py b/tests/test_llm_config.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_llm_config.py
@@ -0,0 +1,20 @@
+import pytest
+from metagpt.configs.llm_config import LLMConfig
+from pydantic import ValidationError
+
+def test_check_llm_key_raises_on_default_key(monkeypatch):
+    # Patch METAGPT_ROOT and CONFIG_ROOT to simulate config file presence
+    from pathlib import Path
+    import metagpt.configs.llm_config as llm_config
+
+    class DummyPath(Path):
+        def exists(self):
+            return True
+
+    monkeypatch.setattr(llm_config, "METAGPT_ROOT", DummyPath("/fake/metagpt_root"))
+    monkeypatch.setattr(llm_config, "CONFIG_ROOT", DummyPath("/fake/config_root"))
+
+    # The key is 'YOUR_API_KEY' which should raise ValidationError
+    with pytest.raises(ValidationError) as excinfo:
+        LLMConfig(api_key="YOUR_API_KEY")
+    assert "Please set your API key" in str(excinfo.value)
EOF_114329324912

# Activate virtual environment
source /testbed/testbed/bin/activate

# Run only the specified test file with pytest
pytest -v --disable-warnings tests/test_llm_config.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset patched files to original state
git checkout 5e8bd105177e08848990d32b9ea636daa639be19