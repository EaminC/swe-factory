#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout target test files to ensure clean state
git checkout b0958115c1887d93bfd25229b307406920038cc4 "libs/checkpoint-postgres/tests/test_async.py" "libs/checkpoint-postgres/tests/test_sync.py"

# Apply test patch
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

# Start PostgreSQL service directly (configured to run on port 5441 in Dockerfile)
su - postgres -c "/usr/lib/postgresql/16/bin/pg_ctl -D /var/lib/postgresql/data -l /var/lib/postgresql/logfile start"

# Wait for PostgreSQL to be ready on port 5441
for i in {1..30}; do
    if pg_isready -h localhost -p 5441 -U postgres > /dev/null 2>&1; then
        echo "PostgreSQL is ready on port 5441"
        break
    fi
    sleep 1
done

# Ensure pgvector extension is created
su - postgres -c "psql -p 5441 -c 'CREATE EXTENSION IF NOT EXISTS vector;'"

# Navigate to the package directory and run tests
cd /testbed/libs/checkpoint-postgres

# Run only the target test files
uv run pytest tests/test_async.py tests/test_sync.py --no-header -rA --tb=short -p no:cacheprovider
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Stop PostgreSQL service
su - postgres -c "/usr/lib/postgresql/16/bin/pg_ctl -D /var/lib/postgresql/data stop"

# Reset test files to original state
cd /testbed
git checkout b0958115c1887d93bfd25229b307406920038cc4 "libs/checkpoint-postgres/tests/test_async.py" "libs/checkpoint-postgres/tests/test_sync.py"