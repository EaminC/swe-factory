#!/bin/bash
set -uxo pipefail

cd /testbed

# Activate virtual environment
source /testbed/.venv/bin/activate

# Verify Python and pytest are available
python --version
pytest --version

# Initialize and start PostgreSQL service
echo "=== Setting up PostgreSQL ==="
if [ ! -d /var/lib/postgresql/data/base ]; then
    echo "Initializing PostgreSQL cluster..."
    PG_VERSION=$(ls /etc/postgresql/ | head -1)
    sudo -u postgres /usr/lib/postgresql/$PG_VERSION/bin/initdb -D /var/lib/postgresql/data -A trust --no-locale
fi

echo "Starting PostgreSQL service..."
sudo service postgresql start

# Wait for PostgreSQL to be ready on port 5441
echo "Waiting for PostgreSQL to be ready on port 5441..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if sudo -u postgres psql -p 5441 -c "SELECT 1" >/dev/null 2>&1; then
        echo "PostgreSQL is ready on port 5441"
        break
    fi
    attempt=$((attempt + 1))
    echo "Waiting for PostgreSQL... ($attempt/$max_attempts)"
    sleep 1
done

if [ $attempt -eq $max_attempts ]; then
    echo "PostgreSQL failed to start after $max_attempts attempts"
    exit 1
fi

# Verify PostgreSQL connection
echo "=== Verifying PostgreSQL connection ==="
sudo -u postgres psql -p 5441 -c "SELECT version();" || true

# Checkout the target test files to ensure clean state
git checkout b0958115c1887d93bfd25229b307406920038cc4 "libs/checkpoint-postgres/tests/test_async.py" "libs/checkpoint-postgres/tests/test_sync.py"

# Apply test patch if needed
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

# Set environment variables for PostgreSQL connection
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5441
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=
export POSTGRES_DB=postgres

# Run the target test files with verbose output and pytest configuration
echo "=== Running target tests ==="
pytest \
    libs/checkpoint-postgres/tests/test_async.py \
    libs/checkpoint-postgres/tests/test_sync.py \
    -v \
    --tb=short \
    --strict-markers \
    -p no:cacheprovider

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

exit $rc