#!/bin/bash
set -uxo pipefail
cd /testbed

# Activate the UV-managed virtual environment
source /testbed/.venv/bin/activate

# Ensure we are at the correct commit
git checkout 40a441f30eebce88b928db875e4309b892a9ac11

# Apply the test patch (if any)
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

# Run only the specified test file using uv run pytest (as per CI command with verbose output)
# Use --no-header, -rA for summary, --tb=no to keep output concise, and -p no:cacheprovider to avoid cache issues
uv run pytest --no-header -rA --tb=no -p no:cacheprovider tests/storage/test_mem0_storage.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes made by the patch (if applied) to return to the original commit state
git checkout 40a441f30eebce88b928db875e4309b892a9ac11