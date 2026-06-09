#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset target test files to match the commit before patching
git checkout b0958115c1887d93bfd25229b307406920038cc4 "libs/checkpoint-postgres/tests/test_async.py" "libs/checkpoint-postgres/tests/test_sync.py"

# Apply test patch from heredoc
git apply -v - <<'EOF_114329324912'
diff --git a/libs/checkpoint-postgres/tests/test_async.py b/libs/checkpoint-postgres/tests/test_async.py
--- a/libs/checkpoint-postgres/tests/test_async.py
+++ b/libs/checkpoint-postgres/tests/test_async.py
@@ -187,13 +187,11 @@ def test_data():
     metadata_1: CheckpointMetadata = {
         "source": "input",
         "step": 2,
-        "writes": {},
         "score": 1,
     }
     metadata_2: CheckpointMetadata = {
         "source": "loop",
         "step": 1,
-        "writes": {"foo": "bar"},
         "score": None,
     }
     metadata_3: CheckpointMetadata = {}
@@ -220,7 +218,6 @@ async def test_combined_metadata(saver_name: str, test_data) -> None:
         metadata: CheckpointMetadata = {
             "source": "loop",
             "step": 1,
-            "writes": {"foo": "bar"},
             "score": None,
         }
         await saver.aput(config, chkpnt, metadata, {})
@@ -246,7 +243,6 @@ async def test_asearch(saver_name: str, test_data) -> None:
         query_1 = {"source": "input"}  # search by 1 key
         query_2 = {
             "step": 1,
-            "writes": {"foo": "bar"},
         }  # search by multiple keys
         query_3: dict[str, Any] = {}  # search by no keys, return all checkpoints
         query_4 = {"source": "update", "step": 1}  # no match
diff --git a/libs/checkpoint-postgres/tests/test_sync.py b/libs/checkpoint-postgres/tests/test_sync.py
--- a/libs/checkpoint-postgres/tests/test_sync.py
+++ b/libs/checkpoint-postgres/tests/test_sync.py
@@ -169,13 +169,11 @@ def test_data():
     metadata_1: CheckpointMetadata = {
         "source": "input",
         "step": 2,
-        "writes": {},
         "score": 1,
     }
     metadata_2: CheckpointMetadata = {
         "source": "loop",
         "step": 1,
-        "writes": {"foo": "bar"},
         "score": None,
     }
     metadata_3: CheckpointMetadata = {}
@@ -202,7 +200,6 @@ def test_combined_metadata(saver_name: str, test_data) -> None:
         metadata: CheckpointMetadata = {
             "source": "loop",
             "step": 1,
-            "writes": {"foo": "bar"},
             "score": None,
         }
         saver.put(config, chkpnt, metadata, {})
@@ -228,7 +225,6 @@ def test_search(saver_name: str, test_data) -> None:
         query_1 = {"source": "input"}  # search by 1 key
         query_2 = {
             "step": 1,
-            "writes": {"foo": "bar"},
         }  # search by multiple keys
         query_3: dict[str, Any] = {}  # search by no keys, return all checkpoints
         query_4 = {"source": "update", "step": 1}  # no match
EOF_114329324912

# Change to the poetry project directory to access pyproject.toml
cd /testbed/libs/checkpoint-postgres

# Since docker daemon is not running inside the container,
# assume external postgres is available or pre-started.
# Run tests directly using poetry & pytest on target test files only.
poetry run pytest --maxfail=1 --disable-warnings --tb=short tests/test_async.py tests/test_sync.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the target test files after test run
git checkout b0958115c1887d93bfd25229b307406920038cc4 "libs/checkpoint-postgres/tests/test_async.py" "libs/checkpoint-postgres/tests/test_sync.py"