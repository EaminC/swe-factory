#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout e7ed12bec5a45d9d6a365a10cde42c5acb214e65

git apply -v - <<'EOF_114329324912'
diff --git a/tests/exec_shell_test.py b/tests/exec_shell_test.py
new file mode 100644
index 00000000..b1f3d3e2
--- /dev/null
+++ b/tests/exec_shell_test.py
@@ -0,0 +1,29 @@
+import pytest
+from src.agentscope.service.execute_code.exec_shell import execute_shell_command, ServiceExecStatus
+
+def test_blocked_insecure_commands():
+    insecure_cmds = execute_shell_command.insecure_commands
+    for cmd in insecure_cmds:
+        # Test that insecure commands are blocked
+        response = execute_shell_command(cmd)
+        assert response.status == ServiceExecStatus.ERROR
+        assert f"The command {cmd} is blocked for security reasons." in response.content
+
+def test_allowed_command():
+    # A harmless command that should not be blocked
+    response = execute_shell_command("echo hello")
+    assert response.status == ServiceExecStatus.SUCCESS
+    assert "hello" in response.content
+
+def test_partial_match_not_blocked():
+    # Commands that partially match insecure commands but are safe
+    response = execute_shell_command("echo rm -rfriendly")
+    # Should not be blocked because 'rm -rfriendly' is not in insecure_commands
+    assert response.status == ServiceExecStatus.SUCCESS
+
+@pytest.mark.parametrize("cmd", ["shutdown now", "killall python", "reboot -f"])
+def test_blocked_commands_with_args(cmd):
+    # Commands with args containing insecure commands should be blocked
+    response = execute_shell_command(cmd)
+    assert response.status == ServiceExecStatus.ERROR
+    assert f"The command {cmd} is blocked for security reasons." in response.content
EOF_114329324912

# Activate the virtual environment provided by the Docker image
source /opt/venv/bin/activate

# Run only the specified test file using pytest with coverage, concise output, no header, and showing all outcomes
pytest --no-header -rA --tb=short --cov=agentscope tests/exec_shell_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the repository to remove patch changes to keep clean state for further runs if any
git checkout e7ed12bec5a45d9d6a365a10cde42c5acb214e65 tests/exec_shell_test.py