#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 3d5257592b440fca8c46b77471e1c34c901ee57f 

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_paths.py b/tests/test_paths.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_paths.py
@@ -0,0 +1,26 @@
+import os
+import pytest
+from src.crewai.utilities import paths
+
+def test_get_project_directory_name_with_env(monkeypatch):
+    # Set environment variable to simulate AWS Lambda writable directory
+    monkeypatch.setenv("CREWAI_STORAGE_DIR", "tmp_lambda_dir")
+    result = paths.get_project_directory_name()
+    assert result == "tmp_lambda_dir"
+
+def test_get_project_directory_name_without_env(monkeypatch, tmp_path):
+    # Remove environment variable if set
+    monkeypatch.delenv("CREWAI_STORAGE_DIR", raising=False)
+    # Change cwd to tmp_path
+    monkeypatch.chdir(tmp_path)
+    # The project directory name should be the name of the cwd
+    expected = tmp_path.name
+    result = paths.get_project_directory_name()
+    assert result == expected
+
+def test_db_storage_path_uses_env(monkeypatch):
+    monkeypatch.setenv("CREWAI_STORAGE_DIR", "tmp_lambda_dir")
+    # db_storage_path indirectly depends on get_project_directory_name
+    project_dir = paths.get_project_directory_name()
+    assert project_dir == "tmp_lambda_dir"
+
EOF_114329324912

# Explicitly install test dependencies including pytest since poetry install was done without test group
poetry install -G test --no-interaction --no-ansi

# Run only the specified test file with pytest via poetry
poetry run pytest -v tests/test_paths.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Attempt to restore repo state if test file exists in git at this commit
if git ls-files --error-unmatch tests/test_paths.py > /dev/null 2>&1; then
  git checkout 3d5257592b440fca8c46b77471e1c34c901ee57f tests/test_paths.py
fi