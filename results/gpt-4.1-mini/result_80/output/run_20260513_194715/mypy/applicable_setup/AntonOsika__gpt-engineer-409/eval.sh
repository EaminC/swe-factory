#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 0596b07a39c2c99c46509c17660f5c8aef4b2114 "tests/test_collect.py" "tests/test_db.py"

# Apply test patch
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

# Activate virtual environment
source /testbed/venv/bin/activate

# Run only the specified test files with coverage output
pytest --cov=gpt_engineer tests/test_collect.py tests/test_db.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file changes to clean state
git checkout 0596b07a39c2c99c46509c17660f5c8aef4b2114 "tests/test_collect.py" "tests/test_db.py"