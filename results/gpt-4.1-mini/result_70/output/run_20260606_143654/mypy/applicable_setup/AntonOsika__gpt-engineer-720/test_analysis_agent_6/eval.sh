#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the specified test files to the committed state prior to patching
git checkout 2058edb3cfb8764cf642d73035af4bb6c783b7e5 "tests/steps/test_archive.py" "tests/test_collect.py" "tests/test_db.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/steps/test_archive.py b/tests/steps/test_archive.py
--- a/tests/steps/test_archive.py
+++ b/tests/steps/test_archive.py
@@ -24,7 +24,16 @@ def setup_dbs(tmp_path, dir_names):
 
 def test_archive(tmp_path, monkeypatch):
     dbs = setup_dbs(
-        tmp_path, ["memory", "logs", "preprompts", "input", "workspace", "archive"]
+        tmp_path,
+        [
+            "memory",
+            "logs",
+            "preprompts",
+            "input",
+            "workspace",
+            "archive",
+            "project_metadata",
+        ],
     )
     freeze_at(monkeypatch, datetime.datetime(2020, 12, 25, 17, 5, 55))
     archive(dbs)
@@ -33,7 +42,16 @@ def test_archive(tmp_path, monkeypatch):
     assert os.path.isdir(tmp_path / "archive" / "20201225_170555")
 
     dbs = setup_dbs(
-        tmp_path, ["memory", "logs", "preprompts", "input", "workspace", "archive"]
+        tmp_path,
+        [
+            "memory",
+            "logs",
+            "preprompts",
+            "input",
+            "workspace",
+            "archive",
+            "project_metadata",
+        ],
     )
     freeze_at(monkeypatch, datetime.datetime(2022, 8, 14, 8, 5, 12))
     archive(dbs)
diff --git a/tests/test_collect.py b/tests/test_collect.py
--- a/tests/test_collect.py
+++ b/tests/test_collect.py
@@ -19,7 +19,9 @@ def test_collect_learnings(monkeypatch):
     model = "test_model"
     temperature = 0.5
     steps = [gen_code_after_unit_tests]
-    dbs = DBs(DB("/tmp"), DB("/tmp"), DB("/tmp"), DB("/tmp"), DB("/tmp"), DB("/tmp"))
+    dbs = DBs(
+        DB("/tmp"), DB("/tmp"), DB("/tmp"), DB("/tmp"), DB("/tmp"), DB("/tmp"), DB("/tmp")
+    )
     dbs.input = {
         "prompt": "test prompt\n with newlines",
         "feedback": "test feedback",
diff --git a/tests/test_db.py b/tests/test_db.py
--- a/tests/test_db.py
+++ b/tests/test_db.py
@@ -19,7 +19,15 @@ def test_DB_operations(tmp_path):
 
 
 def test_DBs_initialization(tmp_path):
-    dir_names = ["memory", "logs", "preprompts", "input", "workspace", "archive"]
+    dir_names = [
+        "memory",
+        "logs",
+        "preprompts",
+        "input",
+        "workspace",
+        "archive",
+        "project_metadata",
+    ]
     directories = [tmp_path / name for name in dir_names]
 
     # Create DB objects
@@ -34,6 +42,7 @@ def test_DBs_initialization(tmp_path):
     assert isinstance(dbs_instance.input, DB)
     assert isinstance(dbs_instance.workspace, DB)
     assert isinstance(dbs_instance.archive, DB)
+    assert isinstance(dbs_instance.project_metadata, DB)
 
 
 def test_invalid_path():
@@ -97,7 +106,15 @@ def test_error_messages(tmp_path):
 
 
 def test_DBs_dataclass_attributes(tmp_path):
-    dir_names = ["memory", "logs", "preprompts", "input", "workspace", "archive"]
+    dir_names = [
+        "memory",
+        "logs",
+        "preprompts",
+        "input",
+        "workspace",
+        "archive",
+        "project_metadata",
+    ]
     directories = [tmp_path / name for name in dir_names]
 
     # Create DB objects
@@ -111,3 +128,5 @@ def test_DBs_dataclass_attributes(tmp_path):
     assert dbs_instance.preprompts == dbs[2]
     assert dbs_instance.input == dbs[3]
     assert dbs_instance.workspace == dbs[4]
+    assert dbs_instance.archive == dbs[5]
+    assert dbs_instance.project_metadata == dbs[6]
EOF_114329324912

# Activate the virtual environment
source /testbed/venv/bin/activate

# Run only the specified test files with concise, clear output of file test results
pytest --no-header -rA --tb=short "tests/steps/test_archive.py" "tests/test_collect.py" "tests/test_db.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore test files to committed state to undo patch changes
git checkout 2058edb3cfb8764cf642d73035af4bb6c783b7e5 "tests/steps/test_archive.py" "tests/test_collect.py" "tests/test_db.py"