#!/bin/bash
set -uxo pipefail

# Ensure we are in the testbed directory and activate the UV virtual environment
cd /testbed
source /testbed/.venv/bin/activate

# Verify we are on the correct commit (safety step)
git checkout 2ab79a7dd5623fe3adde03469afb61caefed528b

# Apply the test patch (if any) to update the target test file
git apply -v - <<'EOF_114329324912'
diff --git a/tests/storage/test_mem0_storage.py b/tests/storage/test_mem0_storage.py
--- a/tests/storage/test_mem0_storage.py
+++ b/tests/storage/test_mem0_storage.py
@@ -1,14 +1,10 @@
-import os
 from unittest.mock import MagicMock, patch
 
 import pytest
 from mem0.client.main import MemoryClient
 from mem0.memory.main import Memory
 
-from crewai.agent import Agent
-from crewai.crew import Crew
 from crewai.memory.storage.mem0_storage import Mem0Storage
-from crewai.task import Task
 
 
 # Define the class (if not already defined)
@@ -172,7 +168,7 @@ def test_save_method_with_memory_oss(mem0_storage_with_mocked_config):
     mem0_storage.save(test_value, test_metadata)
     
     mem0_storage.memory.add.assert_called_once_with(
-        test_value,
+        [{'role': 'assistant' , 'content': test_value}],
         agent_id="Test_Agent",
         infer=False,
         metadata={"type": "short_term", "key": "value"},
@@ -191,7 +187,7 @@ def test_save_method_with_memory_client(mem0_storage_with_memory_client_using_co
     mem0_storage.save(test_value, test_metadata)
     
     mem0_storage.memory.add.assert_called_once_with(
-        test_value,
+        [{'role': 'assistant' , 'content': test_value}],
         agent_id="Test_Agent",
         infer=False,
         metadata={"type": "short_term", "key": "value"},
EOF_114329324912

# Run only the specified test file using the exact command from CI/test execution information
# Use --no-header, -rA for summary, --tb=no to keep output concise,
# and -p no:cacheprovider to avoid cache issues.
# The flags --block-network and --timeout=30 are from the CI workflow.
uv run pytest tests/storage/test_mem0_storage.py \
    --block-network \
    --timeout=30 \
    -vv \
    --no-header \
    -rA \
    --tb=no \
    -p no:cacheprovider
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes made by the patch to return to the original commit state
git checkout 2ab79a7dd5623fe3adde03469afb61caefed528b "tests/storage/test_mem0_storage.py"