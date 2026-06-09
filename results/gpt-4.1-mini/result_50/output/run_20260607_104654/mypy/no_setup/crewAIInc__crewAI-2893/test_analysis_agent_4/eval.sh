#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the specified commit to ensure a clean state
git checkout 9a6557395595f2491ea253048acf65442ed70418 "tests/storage/test_mem0_storage.py"

# Apply test patch (placeholder content to be replaced)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/storage/test_mem0_storage.py b/tests/storage/test_mem0_storage.py
--- a/tests/storage/test_mem0_storage.py
+++ b/tests/storage/test_mem0_storage.py
@@ -55,10 +55,11 @@ def mem0_storage_with_mocked_config(mock_mem0_memory):
         }
 
         # Instantiate the class with memory_config
+        # Parameters like run_id, includes, and excludes doesn't matter in Memory OSS
         crew = MockCrew(
             memory_config={
                 "provider": "mem0",
-                "config": {"user_id": "test_user", "local_mem0_config": config},
+                "config": {"user_id": "test_user", "local_mem0_config": config, "run_id": "my_run_id", "includes": "include1","excludes": "exclude1", "infer" : True},
             }
         )
 
@@ -95,6 +96,10 @@ def mem0_storage_with_memory_client_using_config_from_crew(mock_mem0_memory_clie
                     "api_key": "ABCDEFGH",
                     "org_id": "my_org_id",
                     "project_id": "my_project_id",
+                    "run_id": "my_run_id",
+                    "includes": "include1",
+                    "excludes": "exclude1",
+                    "infer": True
                 },
             }
         )
@@ -150,12 +155,38 @@ def test_mem0_storage_with_explict_config(
     assert (
         mem0_storage_with_memory_client_using_explictly_config.config == expected_config
     )
-    assert (
-        mem0_storage_with_memory_client_using_explictly_config.memory_config
-        == expected_config
+
+
+def test_mem0_storage_updates_project_with_custom_categories(mock_mem0_memory_client):
+    mock_mem0_memory_client.update_project = MagicMock()
+
+    new_categories = [
+    {"lifestyle_management_concerns": "Tracks daily routines, habits, hobbies and interests including cooking, time management and work-life balance"},
+    ]
+
+    crew = MockCrew(
+        memory_config={
+            "provider": "mem0",
+            "config": {
+                "user_id": "test_user",
+                "api_key": "ABCDEFGH",
+                "org_id": "my_org_id",
+                "project_id": "my_project_id",
+                "custom_categories": new_categories,
+            },
+        }
+    )
+
+    with patch.object(MemoryClient, "__new__", return_value=mock_mem0_memory_client):
+        _ = Mem0Storage(type="short_term", crew=crew)
+
+    mock_mem0_memory_client.update_project.assert_called_once_with(
+        custom_categories=new_categories
     )
 
 
+
+
 def test_save_method_with_memory_oss(mem0_storage_with_mocked_config):
     """Test save method for different memory types"""
     mem0_storage, _, _ = mem0_storage_with_mocked_config
@@ -169,8 +200,7 @@ def test_save_method_with_memory_oss(mem0_storage_with_mocked_config):
     
     mem0_storage.memory.add.assert_called_once_with(
         [{'role': 'assistant' , 'content': test_value}],
-        agent_id="Test_Agent",
-        infer=False,
+        infer=True,
         metadata={"type": "short_term", "key": "value"},
     )
 
@@ -188,10 +218,13 @@ def test_save_method_with_memory_client(mem0_storage_with_memory_client_using_co
     
     mem0_storage.memory.add.assert_called_once_with(
         [{'role': 'assistant' , 'content': test_value}],
-        agent_id="Test_Agent",
-        infer=False,
+        infer=True,
         metadata={"type": "short_term", "key": "value"},
-        output_format="v1.1"
+        version="v2",
+        run_id="my_run_id",
+        includes="include1",
+        excludes="exclude1",
+        output_format='v1.1'
     )
 
 
@@ -206,11 +239,12 @@ def test_search_method_with_memory_oss(mem0_storage_with_mocked_config):
     mem0_storage.memory.search.assert_called_once_with(
         query="test query", 
         limit=5, 
-        agent_id="Test_Agent",
-        user_id="test_user"
+        user_id="test_user",
+        filters={'AND': [{'run_id': 'my_run_id'}]}, 
+        threshold=0.5
     )
 
-    assert len(results) == 1
+    assert len(results) == 2
     assert results[0]["content"] == "Result 1"
 
 
@@ -225,11 +259,14 @@ def test_search_method_with_memory_client(mem0_storage_with_memory_client_using_
     mem0_storage.memory.search.assert_called_once_with(
         query="test query", 
         limit=5, 
-        agent_id="Test_Agent", 
         metadata={"type": "short_term"},
         user_id="test_user",
-        output_format='v1.1'
+        version='v2',
+        run_id="my_run_id",
+        output_format='v1.1',
+        filters={'AND': [{'run_id': 'my_run_id'}]},
+        threshold=0.5
     )
 
-    assert len(results) == 1
+    assert len(results) == 2
     assert results[0]["content"] == "Result 1"
EOF_114329324912

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Ensure the optional 'mem0' extra dependencies are installed to provide mem0 module
pip install -U "crewai[mem0]"

# Run only the specified test file with detailed and concise output
# Use uv run pytest with verbose output and short traceback; disable warnings to keep output clean
uv run pytest -v --tb=short --disable-warnings tests/storage/test_mem0_storage.py

rc=$?  # Capture the exit code immediately after test run

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to the original commit state after testing (clean up)
git checkout 9a6557395595f2491ea253048acf65442ed70418 "tests/storage/test_mem0_storage.py"