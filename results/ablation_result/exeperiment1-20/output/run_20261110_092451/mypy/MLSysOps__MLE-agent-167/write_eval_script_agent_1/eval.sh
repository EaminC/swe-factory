#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 71fab2dc51f9944a521a403af1924e0cf5bef76b

# Apply the test patch; placeholder for actual patch content
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_cli_report.py b/tests/test_cli_report.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_cli_report.py
@@ -0,0 +1,27 @@
+import os
+import pytest
+from click.testing import CliRunner
+from mle import cli
+
+@pytest.fixture(autouse=True)
+def chdir_tmp(tmp_path):
+    orig_cwd = os.getcwd()
+    os.chdir(tmp_path)
+    yield
+    os.chdir(orig_cwd)
+
+def test_report_invalid_repo():
+    runner = CliRunner()
+    result = runner.invoke(cli.report, ['invalidrepo'])
+    assert result.exit_code == 0
+    assert "Invalid github repository" in result.output
+
+def test_report_no_repo(monkeypatch):
+    runner = CliRunner()
+    monkeypatch.setattr('questionary.text', lambda *a, **k: 'MLSysOps/MLE-agent')
+    monkeypatch.setattr('mle.cli.check_config', lambda: False)
+    monkeypatch.setattr('mle.cli.workflow.report', lambda work_dir, repo, model=None: True)
+    monkeypatch.setattr('mle.cli.cli.invoke', lambda ctx, name: None)
+    result = runner.invoke(cli.report, [])
+    assert result.exit_code == 0
+
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file with unittest and concise output:
python -m unittest -v tests/test_cli_report.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changes made by patch to keep environment clean
git checkout 71fab2dc51f9944a521a403af1924e0cf5bef76b