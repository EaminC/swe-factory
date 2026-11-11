#!/bin/bash
set -uxo pipefail

cd /testbed

# Configure git to consider /testbed a safe directory to avoid ownership issues
git config --global --add safe.directory /testbed

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

# Note: Removed second git checkout to preserve patch changes during test execution

# Activate python virtual environment
source /testbed/testbed-env/bin/activate

# Ensure pytest is installed for running the tests
pip install pytest

# Run tests using pytest for correct test discovery and execution
pytest tests/test_cli_report_mode.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the applied patch changes on test files after tests run
git checkout b95f56b446a2fe55247eee717ab85fe45f857d27