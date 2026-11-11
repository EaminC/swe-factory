#!/bin/bash
set -uxo pipefail

cd /testbed

# Verify that the test file exists at the specified commit before proceeding
if ! git ls-tree -r --name-only 71fab2dc51f9944a521a403af1924e0cf5bef76b | grep -q '^tests/test_cli_report.py$'; then
    echo "ERROR: Test file 'tests/test_cli_report.py' not found at commit 71fab2dc51f9944a521a403af1924e0cf5bef76b"
    echo "OMNIGRIL_EXIT_CODE=1"
    exit 1
fi

git checkout 71fab2dc51f9944a521a403af1924e0cf5bef76b

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

# Install pytest if missing, as tests require it
source /opt/testbed/bin/activate
if ! python -c "import pytest" &> /dev/null; then
    pip install pytest
fi

# Run only the specified test file using pytest to capture detailed per-test file output
pytest -v tests/test_cli_report.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the repository to original state
git checkout 71fab2dc51f9944a521a403af1924e0cf5bef76b