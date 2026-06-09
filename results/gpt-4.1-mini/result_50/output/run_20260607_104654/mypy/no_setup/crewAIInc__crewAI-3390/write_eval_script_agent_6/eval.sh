#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout entire commit to ensure clean state (no individual test file checkout due to probable dependencies)
git checkout 45d0c9912c4ddb04fbd7ee515d63dde6c3e8b2cb

# Apply test patch (replace [CONTENT OF TEST PATCH] with actual patch content at runtime)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/storage/test_mem0_storage.py b/tests/storage/test_mem0_storage.py
--- a/tests/storage/test_mem0_storage.py
+++ b/tests/storage/test_mem0_storage.py
@@ -16,8 +16,7 @@ def __init__(self):
 @pytest.fixture
 def mock_mem0_memory():
     """Fixture to create a mock Memory instance"""
-    mock_memory = MagicMock(spec=Memory)
-    return mock_memory
+    return MagicMock(spec=Memory)
 
 
 @pytest.fixture
@@ -73,8 +72,7 @@ def test_mem0_storage_initialization(mem0_storage_with_mocked_config, mock_mem0_
 @pytest.fixture
 def mock_mem0_memory_client():
     """Fixture to create a mock MemoryClient instance"""
-    mock_memory = MagicMock(spec=MemoryClient)
-    return mock_memory
+    return MagicMock(spec=MemoryClient)
 
 
 @pytest.fixture
@@ -96,8 +94,7 @@ def mem0_storage_with_memory_client_using_config_from_crew(mock_mem0_memory_clie
                     "infer": True
                 }
 
-        mem0_storage = Mem0Storage(type="short_term", crew=crew, config=embedder_config)
-        return mem0_storage
+        return Mem0Storage(type="short_term", crew=crew, config=embedder_config)
 
 
 @pytest.fixture
@@ -111,8 +108,7 @@ def mem0_storage_with_memory_client_using_explictly_config(mock_mem0_memory_clie
         crew = MockCrew()
         new_config = {"provider": "mem0", "config": {"api_key": "new-api-key"}}
 
-        mem0_storage = Mem0Storage(type="short_term", crew=crew, config=new_config)
-        return mem0_storage
+        return Mem0Storage(type="short_term", crew=crew, config=new_config)
 
 
 def test_mem0_storage_with_memory_client_initialization(
@@ -172,14 +168,14 @@ def test_save_method_with_memory_oss(mem0_storage_with_mocked_config):
 
     # Test short_term memory type (already set in fixture)
     test_value = "This is a test memory"
-    test_metadata = {"key": "value"}
+    test_metadata = {'description': 'Respond to user conversation. User message: What do you know about me?', 'messages': [{'role': 'system', 'content': 'You are Friendly chatbot assistant. You are a kind and knowledgeable chatbot assistant. You excel at understanding user needs, providing helpful responses, and maintaining engaging conversations. You remember previous interactions to provide a personalized experience.\nYour personal goal is: Engage in useful and interesting conversations with users while remembering context.\nTo give my best complete final answer to the task respond using the exact following format:\n\nThought: I now can give a great answer\nFinal Answer: Your final answer must be the great and the most complete as possible, it must be outcome described.\n\nI MUST use these formats, my job depends on it!'}, {'role': 'user', 'content': '\nCurrent Task: Respond to user conversation. User message: What do you know about me?\n\nThis is the expected criteria for your final answer: Contextually appropriate, helpful, and friendly response.\nyou MUST return the actual complete content as the final answer, not a summary.\n\n# Useful context: \nExternal memories:\n- User is from India\n- User is interested in the solar system\n- User name is Vidit Ostwal\n- User is interested in French cuisine\n\nBegin! This is VERY important to you, use the tools available and give your best Final Answer, your job depends on it!\n\nThought:'}, {'role': 'assistant', 'content': "I now can give a great answer  \nFinal Answer: Hi Vidit! From our previous conversations, I know you're from India and have a great interest in the solar system. It's fascinating to explore the wonders of space, isn't it? Also, I remember you have a passion for French cuisine, which has so many delightful dishes to explore. If there's anything specific you'd like to discuss or learn about—whether it's about the solar system or some great French recipes—feel free to let me know! I'm here to help."}], 'agent': 'Friendly chatbot assistant'}
 
     mem0_storage.save(test_value, test_metadata)
 
     mem0_storage.memory.add.assert_called_once_with(
-        [{"role": "assistant" , "content": test_value}],
+        [{'role': 'user', 'content': 'What do you know about me?'}, {'role': 'assistant', 'content': "Hi Vidit! From our previous conversations, I know you're from India and have a great interest in the solar system. It's fascinating to explore the wonders of space, isn't it? Also, I remember you have a passion for French cuisine, which has so many delightful dishes to explore. If there's anything specific you'd like to discuss or learn about—whether it's about the solar system or some great French recipes—feel free to let me know! I'm here to help."}],
         infer=True,
-        metadata={"type": "short_term", "key": "value"},
+        metadata={'type': 'short_term', 'description': 'Respond to user conversation. User message: What do you know about me?', 'agent': 'Friendly chatbot assistant'},
         run_id="my_run_id",
         user_id="test_user",
         agent_id='Test_Agent'
@@ -191,14 +187,14 @@ def test_save_method_with_multiple_agents(mem0_storage_with_mocked_config):
     mem0_storage.memory.add = MagicMock()
 
     test_value = "This is a test memory"
-    test_metadata = {"key": "value"}
+    test_metadata = {'description': 'Respond to user conversation. User message: What do you know about me?', 'messages': [{'role': 'system', 'content': 'You are Friendly chatbot assistant. You are a kind and knowledgeable chatbot assistant. You excel at understanding user needs, providing helpful responses, and maintaining engaging conversations. You remember previous interactions to provide a personalized experience.\nYour personal goal is: Engage in useful and interesting conversations with users while remembering context.\nTo give my best complete final answer to the task respond using the exact following format:\n\nThought: I now can give a great answer\nFinal Answer: Your final answer must be the great and the most complete as possible, it must be outcome described.\n\nI MUST use these formats, my job depends on it!'}, {'role': 'user', 'content': '\nCurrent Task: Respond to user conversation. User message: What do you know about me?\n\nThis is the expected criteria for your final answer: Contextually appropriate, helpful, and friendly response.\nyou MUST return the actual complete content as the final answer, not a summary.\n\n# Useful context: \nExternal memories:\n- User is from India\n- User is interested in the solar system\n- User name is Vidit Ostwal\n- User is interested in French cuisine\n\nBegin! This is VERY important to you, use the tools available and give your best Final Answer, your job depends on it!\n\nThought:'}, {'role': 'assistant', 'content': "I now can give a great answer  \nFinal Answer: Hi Vidit! From our previous conversations, I know you're from India and have a great interest in the solar system. It's fascinating to explore the wonders of space, isn't it? Also, I remember you have a passion for French cuisine, which has so many delightful dishes to explore. If there's anything specific you'd like to discuss or learn about—whether it's about the solar system or some great French recipes—feel free to let me know! I'm here to help."}], 'agent': 'Friendly chatbot assistant'}
 
     mem0_storage.save(test_value, test_metadata)
 
     mem0_storage.memory.add.assert_called_once_with(
-        [{"role": "assistant" , "content": test_value}],
+        [{'role': 'user', 'content': 'What do you know about me?'}, {'role': 'assistant', 'content': "Hi Vidit! From our previous conversations, I know you're from India and have a great interest in the solar system. It's fascinating to explore the wonders of space, isn't it? Also, I remember you have a passion for French cuisine, which has so many delightful dishes to explore. If there's anything specific you'd like to discuss or learn about—whether it's about the solar system or some great French recipes—feel free to let me know! I'm here to help."}],
         infer=True,
-        metadata={"type": "short_term", "key": "value"},
+        metadata={'type': 'short_term', 'description': 'Respond to user conversation. User message: What do you know about me?', 'agent': 'Friendly chatbot assistant'},
         run_id="my_run_id",
         user_id="test_user",
         agent_id='Test_Agent_Test_Agent_2_Test_Agent_3'
@@ -212,14 +208,14 @@ def test_save_method_with_memory_client(mem0_storage_with_memory_client_using_co
 
     # Test short_term memory type (already set in fixture)
     test_value = "This is a test memory"
-    test_metadata = {"key": "value"}
+    test_metadata = {'description': 'Respond to user conversation. User message: What do you know about me?', 'messages': [{'role': 'system', 'content': 'You are Friendly chatbot assistant. You are a kind and knowledgeable chatbot assistant. You excel at understanding user needs, providing helpful responses, and maintaining engaging conversations. You remember previous interactions to provide a personalized experience.\nYour personal goal is: Engage in useful and interesting conversations with users while remembering context.\nTo give my best complete final answer to the task respond using the exact following format:\n\nThought: I now can give a great answer\nFinal Answer: Your final answer must be the great and the most complete as possible, it must be outcome described.\n\nI MUST use these formats, my job depends on it!'}, {'role': 'user', 'content': '\nCurrent Task: Respond to user conversation. User message: What do you know about me?\n\nThis is the expected criteria for your final answer: Contextually appropriate, helpful, and friendly response.\nyou MUST return the actual complete content as the final answer, not a summary.\n\n# Useful context: \nExternal memories:\n- User is from India\n- User is interested in the solar system\n- User name is Vidit Ostwal\n- User is interested in French cuisine\n\nBegin! This is VERY important to you, use the tools available and give your best Final Answer, your job depends on it!\n\nThought:'}, {'role': 'assistant', 'content': "I now can give a great answer  \nFinal Answer: Hi Vidit! From our previous conversations, I know you're from India and have a great interest in the solar system. It's fascinating to explore the wonders of space, isn't it? Also, I remember you have a passion for French cuisine, which has so many delightful dishes to explore. If there's anything specific you'd like to discuss or learn about—whether it's about the solar system or some great French recipes—feel free to let me know! I'm here to help."}], 'agent': 'Friendly chatbot assistant'}
 
     mem0_storage.save(test_value, test_metadata)
 
     mem0_storage.memory.add.assert_called_once_with(
-        [{'role': 'assistant' , 'content': test_value}],
+        [{'role': 'user', 'content': 'What do you know about me?'}, {'role': 'assistant', 'content': "Hi Vidit! From our previous conversations, I know you're from India and have a great interest in the solar system. It's fascinating to explore the wonders of space, isn't it? Also, I remember you have a passion for French cuisine, which has so many delightful dishes to explore. If there's anything specific you'd like to discuss or learn about—whether it's about the solar system or some great French recipes—feel free to let me know! I'm here to help."}],
         infer=True,
-        metadata={"type": "short_term", "key": "value"},
+       metadata={'type': 'short_term', 'description': 'Respond to user conversation. User message: What do you know about me?', 'agent': 'Friendly chatbot assistant'},
         version="v2",
         run_id="my_run_id",
         includes="include1",
EOF_114329324912

# Export required environment variables
export OPENAI_API_KEY=""
export SERPER_API_KEY=""
export OTEL_SDK_DISABLED="true"
export share_crew="True"

# Activate the virtual environment and verify mem0 module installation
source /testbed/.venv/bin/activate

# Check if mem0 module is importable before running tests (diagnostic)
python3 -c "import mem0.client.main" || { echo 'mem0 module import failed'; exit 1; }

# Run only the specified test file(s) with proper uv command inside the activated environment
uv run pytest tests/storage/test_mem0_storage.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset repository state to the original commit after tests
git reset --hard 45d0c9912c4ddb04fbd7ee515d63dde6c3e8b2cb