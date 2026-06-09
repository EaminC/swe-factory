#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout the specific commit version of the test file to ensure a clean state before applying patch
git checkout 2ab79a7dd5623fe3adde03469afb61caefed528b tests/storage/test_mem0_storage.py

# Apply test patch (placeholder content will be replaced during evaluation)
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

# Activate the Python virtual environment from the correct path
source /testbed/.venv/bin/activate

# Install pytest explicitly inside the virtual environment to ensure availability
pip install pytest

# Export required environment variables (set as empty placeholders here)
export OPENAI_API_KEY=""
export SERPER_API_KEY=""
export OPTIONAL_OTEL_SDK_DISABLED=true
export OPTIONAL_share_crew=true

# Print installed packages for debugging module import issues
pip list

# Run only the specified test file with uv run pytest and concise output reporting
uv run pytest tests/storage/test_mem0_storage.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to discard patch changes and any test side effects
git checkout 2ab79a7dd5623fe3adde03469afb61caefed528b tests/storage/test_mem0_storage.py