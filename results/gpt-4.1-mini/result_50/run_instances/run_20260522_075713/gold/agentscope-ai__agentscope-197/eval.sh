#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout the specific commit for the target test files
git checkout be8db4cc484b77d0d3bc60a012e9035c4395bee3 "tests/memory_test.py" "tests/msghub_test.py"

# Apply the test patch before running tests
git apply -v - <<'EOF_114329324912'
diff --git a/tests/memory_test.py b/tests/memory_test.py
--- a/tests/memory_test.py
+++ b/tests/memory_test.py
@@ -3,10 +3,11 @@
 Unit tests for memory classes and functions
 """
 
+import os
 import unittest
 from unittest.mock import patch, MagicMock
 
-from agentscope.message import Msg
+from agentscope.message import Msg, Tht
 from agentscope.memory import TemporaryMemory
 
 
@@ -17,6 +18,8 @@ class TemporaryMemoryTest(unittest.TestCase):
 
     def setUp(self) -> None:
         self.memory = TemporaryMemory()
+        self.file_name_1 = "tmp_mem_file1.txt"
+        self.file_name_2 = "tmp_mem_file2.txt"
         self.msg_1 = Msg("user", "Hello", role="user")
         self.msg_2 = Msg(
             "agent",
@@ -29,19 +32,15 @@ def setUp(self) -> None:
             role="assistant",
         )
 
-        self.dict_1 = {
-            "name": "dict1",
-            "content": "dict 1",
-            "role": "assistant",
-        }
-        self.dict_2 = {
-            "name": "dict2",
-            "content": "dict 2",
-            "role": "assistant",
-        }
-
         self.invalid = {"invalid_key": "invalid_value"}
 
+    def tearDown(self) -> None:
+        """Clean up before & after tests."""
+        if os.path.exists(self.file_name_1):
+            os.remove(self.file_name_1)
+        if os.path.exists(self.file_name_2):
+            os.remove(self.file_name_2)
+
     def test_add(self) -> None:
         """Test add different types of object"""
         # add msg
@@ -51,18 +50,11 @@ def test_add(self) -> None:
             [self.msg_1],
         )
 
-        # add dict
-        self.memory.add(self.dict_1)
-        self.assertEqual(
-            self.memory.get_memory(),
-            [self.msg_1, self.dict_1],
-        )
-
         # add list
         self.memory.add([self.msg_2, self.msg_3])
         self.assertEqual(
             self.memory.get_memory(),
-            [self.msg_1, self.dict_1, self.msg_2, self.msg_3],
+            [self.msg_1, self.msg_2, self.msg_3],
         )
 
     @patch("loguru.logger.warning")
@@ -84,17 +76,11 @@ def test_delete(self, mock_logging: MagicMock) -> None:
 
     def test_invalid(self) -> None:
         """Test invalid operations for memory"""
-        self.memory.add(self.invalid)
         # test invalid add
-        self.assertEqual(
-            self.memory.get_memory(),
-            [self.invalid],
-        )
-
-        # test print
-        self.assertEqual(
-            self.memory.get_memory(),
-            [{"invalid_key": "invalid_value"}],
+        with self.assertRaises(Exception) as context:
+            self.memory.add(self.invalid)
+        self.assertTrue(
+            f"Cannot add {self.invalid} to memory" in str(context.exception),
         )
 
     def test_load_export(self) -> None:
@@ -102,11 +88,11 @@ def test_load_export(self) -> None:
         Test load and export function of TemporaryMemory
         """
         memory = TemporaryMemory()
-        user_input = {"name": "user", "content": "Hello"}
-        agent_input = {
-            "name": "agent",
-            "content": "Hello! How can I help you?",
-        }
+        user_input = Msg(name="user", content="Hello")
+        agent_input = Msg(
+            name="agent",
+            content="Hello! How can I help you?",
+        )
         memory.load([user_input, agent_input])
         retrieved_mem = memory.export(to_mem=True)
         self.assertEqual(
@@ -114,6 +100,44 @@ def test_load_export(self) -> None:
             [user_input, agent_input],
         )
 
+        memory.export(file_path=self.file_name_1)
+        memory.clear()
+        self.assertEqual(
+            memory.get_memory(),
+            [],
+        )
+        memory.load(self.file_name_1)
+        self.assertEqual(
+            memory.get_memory(),
+            [user_input, agent_input],
+        )
+
+    def test_tht_memory(self) -> None:
+        """
+        Test temporary memory with Tht,
+        add, clear, export, loading
+        """
+        memory = TemporaryMemory()
+        thought = Tht("testing")
+        memory.add(thought)
+
+        self.assertEqual(
+            memory.get_memory(),
+            [thought],
+        )
+
+        memory.export(file_path=self.file_name_2)
+        memory.clear()
+        self.assertEqual(
+            memory.get_memory(),
+            [],
+        )
+        memory.load(self.file_name_2)
+        self.assertEqual(
+            memory.get_memory(),
+            [thought],
+        )
+
 
 if __name__ == "__main__":
     unittest.main()
diff --git a/tests/msghub_test.py b/tests/msghub_test.py
--- a/tests/msghub_test.py
+++ b/tests/msghub_test.py
@@ -5,6 +5,7 @@
 
 from agentscope.agents import AgentBase
 from agentscope import msghub
+from agentscope.message import Msg
 
 
 class TestAgent(AgentBase):
@@ -33,10 +34,10 @@ def setUp(self) -> None:
 
     def test_msghub_operation(self) -> None:
         """Test add, delete and broadcast operations"""
-        msg1 = {"msg": 1}
-        msg2 = {"msg": 2}
-        msg3 = {"msg": 3}
-        msg4 = {"msg": 4}
+        msg1 = Msg(name="a1", content="msg1")
+        msg2 = Msg(name="a2", content="msg2")
+        msg3 = Msg(name="a3", content="msg3")
+        msg4 = Msg(name="a4", content="msg4")
 
         with msghub(participants=[self.agent1, self.agent2]) as hub:
             self.agent1(msg1)
@@ -68,11 +69,12 @@ def test_msghub(self) -> None:
         """msghub test."""
 
         ground_truth = [
-            {
-                "role": "wisper",
-                "content": "This secret that my password is 123456 can't be"
+            Msg(
+                name="w1",
+                content="This secret that my password is 123456 can't be"
                 " leaked!",
-            },
+                role="wisper",
+            ),
         ]
 
         with msghub(participants=[self.wisper, self.agent1, self.agent2]):
EOF_114329324912

# Run the specified test files programmatically with coverage as per context info
# The project runs tests via `coverage run tests/run.py` and test command runs tests programmatically
# We will pass the test file paths as environment variable or arguments if supported
# Since context says tests run programmatically via tests/run.py, and no direct CLI test commands available,
# we simulate run.py filtering by setting an environment variable TEST_FILES or rewriting run.py is out of scope,
# so instead we dynamically patch run.py invocation to target specific test files using pytest directly.

# To restrict to specific test files, run pytest with those files and measure coverage manually:
coverage run -m pytest -q --tb=short --disable-warnings tests/memory_test.py tests/msghub_test.py
rc=$?            # Save exit code

# Output coverage report summary to log for completeness
coverage report -m

echo "OMNIGRIL_EXIT_CODE=$rc" # Required, echo test status

# Clean up: Restore original test files to avoid patch effects
git checkout be8db4cc484b77d0d3bc60a012e9035c4395bee3 "tests/memory_test.py" "tests/msghub_test.py"