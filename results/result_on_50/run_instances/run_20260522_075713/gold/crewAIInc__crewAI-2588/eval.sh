#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the exact commit to ensure clean state
git checkout 40a441f30eebce88b928db875e4309b892a9ac11 "tests/storage/test_mem0_storage.py"

# Apply test patch to update the target test file(s)
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

# Reset test file after applying patch to avoid partial changes if patch fails
git checkout 40a441f30eebce88b928db875e4309b892a9ac11 "tests/storage/test_mem0_storage.py"

# Export necessary environment variable for OpenAI API key (can be replaced or injected at runtime)
export OPENAI_API_KEY="fake_api_key_for_testing"

# Activate the Python virtual environment for running tests
source /testbed/testbed_venv/bin/activate

# Ensure pytest is installed in the venv before running tests
pip install pytest

# Run only the specified test file with pytest under uv run with --active flag to use existing venv
uv run --active pytest tests/storage/test_mem0_storage.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file after running tests to keep repo clean
git checkout 40a441f30eebce88b928db875e4309b892a9ac11 "tests/storage/test_mem0_storage.py"