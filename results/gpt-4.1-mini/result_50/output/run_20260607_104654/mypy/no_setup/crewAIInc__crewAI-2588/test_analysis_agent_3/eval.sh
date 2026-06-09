#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test file to the committed state before applying patch
git checkout 40a441f30eebce88b928db875e4309b892a9ac11 "tests/storage/test_mem0_storage.py"

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/storage/test_mem0_storage.py b/tests/storage/test_mem0_storage.py
--- a/tests/storage/test_mem0_storage.py
+++ b/tests/storage/test_mem0_storage.py
@@ -29,7 +29,7 @@ def mem0_storage_with_mocked_config(mock_mem0_memory):
     """Fixture to create a Mem0Storage instance with mocked dependencies"""
 
     # Patch the Memory class to return our mock
-    with patch("mem0.memory.main.Memory.from_config", return_value=mock_mem0_memory):
+    with patch("mem0.memory.main.Memory.from_config", return_value=mock_mem0_memory) as mock_from_config:
         config = {
             "vector_store": {
                 "provider": "mock_vector_store",
@@ -66,13 +66,15 @@ def mem0_storage_with_mocked_config(mock_mem0_memory):
         )
 
         mem0_storage = Mem0Storage(type="short_term", crew=crew)
-        return mem0_storage
+        return mem0_storage, mock_from_config, config
 
 
 def test_mem0_storage_initialization(mem0_storage_with_mocked_config, mock_mem0_memory):
     """Test that Mem0Storage initializes correctly with the mocked config"""
-    assert mem0_storage_with_mocked_config.memory_type == "short_term"
-    assert mem0_storage_with_mocked_config.memory is mock_mem0_memory
+    mem0_storage, mock_from_config, config = mem0_storage_with_mocked_config
+    assert mem0_storage.memory_type == "short_term"
+    assert mem0_storage.memory is mock_mem0_memory
+    mock_from_config.assert_called_once_with(config)
 
 
 @pytest.fixture
EOF_114329324912

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Install or upgrade mem0ai package inside the venv and verify installation
pip install --upgrade mem0ai>=0.1.29
pip show mem0ai
pip list | grep mem0ai || true

# Run the specified test file using uv run pytest
uv run pytest -rA --tb=short --disable-warnings tests/storage/test_mem0_storage.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout 40a441f30eebce88b928db875e4309b892a9ac11 "tests/storage/test_mem0_storage.py"