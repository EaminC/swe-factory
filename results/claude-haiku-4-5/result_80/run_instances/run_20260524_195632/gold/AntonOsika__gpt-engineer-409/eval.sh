#!/bin/bash
set -uxo pipefail

# Change to testbed directory
cd /testbed

# Activate virtual environment
source /testbed/testbed_venv/bin/activate

# Verify Python and pytest are available
python --version
pytest --version

# Reset target test files to the correct commit state
git checkout 0596b07a39c2c99c46509c17660f5c8aef4b2114 "tests/test_collect.py" "tests/test_db.py" "tests/steps/test_archive.py" 2>/dev/null || true

# Apply test patch if needed
git apply -v - <<'EOF_114329324912'
diff --git a/tests/steps/__init__.py b/tests/steps/__init__.py
new file mode 100644
diff --git a/tests/steps/test_archive.py b/tests/steps/test_archive.py
new file mode 100644
--- /dev/null
+++ b/tests/steps/test_archive.py
@@ -0,0 +1,44 @@
+import datetime
+import os
+
+from unittest.mock import MagicMock
+
+from gpt_engineer.db import DB, DBs
+from gpt_engineer.steps import archive
+
+
+def freeze_at(monkeypatch, time):
+    datetime_mock = MagicMock(wraps=datetime.datetime)
+    datetime_mock.now.return_value = time
+    monkeypatch.setattr(datetime, "datetime", datetime_mock)
+
+
+def setup_dbs(tmp_path, dir_names):
+    directories = [tmp_path / name for name in dir_names]
+
+    # Create DB objects
+    dbs = [DB(dir) for dir in directories]
+
+    # Create DBs instance
+    return DBs(*dbs)
+
+
+def test_archive(tmp_path, monkeypatch):
+    dbs = setup_dbs(
+        tmp_path, ["memory", "logs", "preprompts", "input", "workspace", "archive"]
+    )
+    freeze_at(monkeypatch, datetime.datetime(2020, 12, 25, 17, 5, 55))
+    archive(None, dbs)
+    assert not os.path.exists(tmp_path / "memory")
+    assert not os.path.exists(tmp_path / "workspace")
+    assert os.path.isdir(tmp_path / "archive" / "20201225_170555")
+
+    dbs = setup_dbs(
+        tmp_path, ["memory", "logs", "preprompts", "input", "workspace", "archive"]
+    )
+    freeze_at(monkeypatch, datetime.datetime(2022, 8, 14, 8, 5, 12))
+    archive(None, dbs)
+    assert not os.path.exists(tmp_path / "memory")
+    assert not os.path.exists(tmp_path / "workspace")
+    assert os.path.isdir(tmp_path / "archive" / "20201225_170555")
+    assert os.path.isdir(tmp_path / "archive" / "20220814_080512")
diff --git a/tests/test_collect.py b/tests/test_collect.py
--- a/tests/test_collect.py
+++ b/tests/test_collect.py
@@ -19,7 +19,7 @@ def test_collect_learnings(monkeypatch):
     model = "test_model"
     temperature = 0.5
     steps = [gen_code]
-    dbs = DBs(DB("/tmp"), DB("/tmp"), DB("/tmp"), DB("/tmp"), DB("/tmp"))
+    dbs = DBs(DB("/tmp"), DB("/tmp"), DB("/tmp"), DB("/tmp"), DB("/tmp"), DB("/tmp"))
     dbs.input = {
         "prompt": "test prompt\n with newlines",
         "feedback": "test feedback",
diff --git a/tests/test_db.py b/tests/test_db.py
--- a/tests/test_db.py
+++ b/tests/test_db.py
@@ -27,7 +27,7 @@ def test_DB_operations(tmp_path):
 
 
 def test_DBs_initialization(tmp_path):
-    dir_names = ["memory", "logs", "preprompts", "input", "workspace"]
+    dir_names = ["memory", "logs", "preprompts", "input", "workspace", "archive"]
     directories = [tmp_path / name for name in dir_names]
 
     # Create DB objects
@@ -41,6 +41,7 @@ def test_DBs_initialization(tmp_path):
     assert isinstance(dbs_instance.preprompts, DB)
     assert isinstance(dbs_instance.input, DB)
     assert isinstance(dbs_instance.workspace, DB)
+    assert isinstance(dbs_instance.archive, DB)
 
 
 def test_invalid_path():
@@ -106,11 +107,11 @@ def test_DBs_instantiation_with_wrong_number_of_arguments(tmp_path):
         DBs(db, db, db)
 
     with pytest.raises(TypeError):
-        DBs(db, db, db, db, db, db)
+        DBs(db, db, db, db, db, db, db)
 
 
 def test_DBs_dataclass_attributes(tmp_path):
-    dir_names = ["memory", "logs", "preprompts", "input", "workspace"]
+    dir_names = ["memory", "logs", "preprompts", "input", "workspace", "archive"]
     directories = [tmp_path / name for name in dir_names]
 
     # Create DB objects
EOF_114329324912

# Verify test files exist before running
echo "Checking for target test files..."
test_files_to_run=""

if [ -f "tests/test_collect.py" ]; then
    echo "✓ Found tests/test_collect.py"
    test_files_to_run="$test_files_to_run tests/test_collect.py"
else
    echo "✗ WARNING: tests/test_collect.py not found"
fi

if [ -f "tests/test_db.py" ]; then
    echo "✓ Found tests/test_db.py"
    test_files_to_run="$test_files_to_run tests/test_db.py"
else
    echo "✗ WARNING: tests/test_db.py not found"
fi

if [ -f "tests/steps/test_archive.py" ]; then
    echo "✓ Found tests/steps/test_archive.py"
    test_files_to_run="$test_files_to_run tests/steps/test_archive.py"
else
    echo "✗ WARNING: tests/steps/test_archive.py not found"
fi

# Create a non-root user for running tests to properly trigger permission errors
echo "Creating non-root user for test execution..."
useradd -m -s /bin/bash testuser 2>/dev/null || true

# Copy testbed to a location accessible by testuser
cp -r /testbed /home/testuser/testbed_copy
chown -R testuser:testuser /home/testuser/testbed_copy

echo "========================================"
echo "Running target test files as non-root user..."
echo "========================================"

# Execute tests as non-root user to properly trigger permission errors
# This is essential for test_invalid_path in tests/test_db.py
su - testuser -c "
    cd /home/testuser/testbed_copy
    source /testbed/testbed_venv/bin/activate
    pytest -xvs $test_files_to_run 2>&1
"

rc=$?

echo "========================================"
echo "Test execution completed with exit code: $rc"
echo "========================================"

# Cleanup: reset modified test files
git checkout 0596b07a39c2c99c46509c17660f5c8aef4b2114 "tests/test_collect.py" "tests/test_db.py" "tests/steps/test_archive.py" 2>/dev/null || true

# Remove non-root user and temporary copy
rm -rf /home/testuser/testbed_copy
userdel -r testuser 2>/dev/null || true

# Output the exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"