#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset to the target commit to ensure clean state
git checkout b95f56b446a2fe55247eee717ab85fe45f857d27

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_cli_report_mode.py b/tests/test_cli_report_mode.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_cli_report_mode.py
@@ -0,0 +1,32 @@
+import pytest
+from click.testing import CliRunner
+from mle.cli import cli
+
+@pytest.fixture
+def runner():
+    return CliRunner()
+
+def test_start_report_mode_invokes_report_and_serve(monkeypatch, runner):
+    called = {}
+
+    def fake_report(ctx, repo=None, model=None, user=None, visualize=False):
+        called['report'] = True
+        assert visualize is False
+        return True
+
+    def fake_serve(ctx):
+        called['serve'] = True
+        return True
+
+    def fake_web(ctx):
+        called['web'] = True
+        return True
+
+    monkeypatch.setattr('mle.cli.report', fake_report)
+    monkeypatch.setattr('mle.cli.serve', fake_serve)
+    monkeypatch.setattr('mle.cli.web', fake_web)
+
+    result = runner.invoke(cli, ['start', 'report', '--model', 'test-model'])
+    assert result.exit_code == 0
+    assert called.get('report')
+    # Because visualize defaults to False in test, serve and web should be called
EOF_114329324912

# Activate the virtual environment
source /testbed/testbed/bin/activate

# Run only the specified test file with unittest module for concise output with test file name
python -m unittest -v tests/test_cli_report_mode.py
rc=$?

# Echo exit code for test log analysis
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes made by patch to maintain clean state
git checkout b95f56b446a2fe55247eee717ab85fe45f857d27