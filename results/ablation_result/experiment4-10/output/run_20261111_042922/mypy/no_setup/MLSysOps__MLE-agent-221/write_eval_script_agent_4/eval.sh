#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 1b637bed35ef1171f3eb11395c8a5ad2bd8c15b8

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_system_check_config.py b/tests/test_system_check_config.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_system_check_config.py
@@ -0,0 +1,40 @@
+import os
+import tempfile
+import yaml
+import pytest
+from unittest.mock import MagicMock
+import mle.utils.system as system
+
+class DummyConsole:
+    def __init__(self):
+        self.logged = []
+    def log(self, msg):
+        self.logged.append(msg)
+
+def test_check_config_missing_file(monkeypatch):
+    console = DummyConsole()
+    # Point config_path to a non-existent file
+    monkeypatch.setattr(system, 'config_path', '/nonexistent/config.yaml')
+    result = system.check_config(console)
+    assert result is False
+    assert any("not found" in msg for msg in console.logged)
+
+def test_check_config_invalid_yaml(tmp_path, monkeypatch):
+    console = DummyConsole()
+    config_file = tmp_path / "config.yaml"
+    config_file.write_text("not: [valid: yaml")
+    monkeypatch.setattr(system, 'config_path', str(config_file))
+    result = system.check_config(console)
+    assert result is False
+    assert any("could not be loaded" in msg for msg in console.logged)
+
+def test_check_config_valid_with_search_key(tmp_path, monkeypatch):
+    console = DummyConsole()
+    config_file = tmp_path / "config.yaml"
+    yaml.safe_dump({'search_key': 'dummykey'}, open(config_file, 'w'))
+    monkeypatch.setattr(system, 'config_path', str(config_file))
+    if "SEARCH_API_KEY" in os.environ:
+        del os.environ["SEARCH_API_KEY"]
+    result = system.check_config(console)
+    assert result is True
+    assert os.environ.get("SEARCH_API_KEY") == 'dummykey'
EOF_114329324912

# Activate the Python virtual environment
source /opt/testbed/bin/activate

# Ensure pytest is installed in the environment before running tests
pip install pytest

# Run only the specified test file using pytest to ensure test discovery
pytest -q --tb=short tests/test_system_check_config.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset all local changes to clean the working tree
git reset --hard 1b637bed35ef1171f3eb11395c8a5ad2bd8c15b8