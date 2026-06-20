#!/bin/bash
set -uxo pipefail

# Change to the checkpoint-postgres directory where the target test files are located
cd /testbed/libs/checkpoint-postgres

# Ensure uv and virtual environment are in PATH
export PATH="/root/.local/bin:/testbed/.venv/bin:$PATH"
source /testbed/.venv/bin/activate

# Restore the original test files to ensure a clean state
git checkout b0958115c1887d93bfd25229b307406920038cc4 "tests/test_async.py" "tests/test_sync.py"

# Apply the test patch
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

# Set environment variables for test execution
export NO_DOCKER=1
export POSTGRES_VERSION=16
export DEFAULT_POSTGRES_URI="postgres://postgres:postgres@localhost:5441/"

# Start PostgreSQL service (not Docker container)
echo "Starting PostgreSQL service..."
service postgresql start

# Wait for PostgreSQL to be ready on port 5441
echo "Waiting for PostgreSQL to be ready..."
for i in $(seq 1 30); do
    if pg_isready -h localhost -p 5441 -U postgres > /dev/null 2>&1; then
        echo "PostgreSQL is ready on port 5441"
        break
    fi
    echo "Waiting for PostgreSQL... ($i/30)"
    sleep 2
    if [ $i -eq 30 ]; then
        echo "ERROR: PostgreSQL failed to start within 60 seconds"
        exit 1
    fi
done

# Run the target test files using uv run pytest (as per the project's Makefile pattern)
# Combine both test files into a single command to optimize execution efficiency
# Use the pytest configuration from pyproject.toml: --strict-markers --strict-config --durations=5 -vv
echo "Running target test files..."
uv run pytest \
    --strict-markers \
    --strict-config \
    --durations=5 \
    -vv \
    --no-header \
    -rA \
    --tb=no \
    -p no:cacheprovider \
    tests/test_async.py tests/test_sync.py

# Capture the exit code
rc=$?

# Stop PostgreSQL service
echo "Stopping PostgreSQL service..."
service postgresql stop

# Output the exit code for the judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the original test files to clean up
git checkout b0958115c1887d93bfd25229b307406920038cc4 "tests/test_async.py" "tests/test_sync.py"