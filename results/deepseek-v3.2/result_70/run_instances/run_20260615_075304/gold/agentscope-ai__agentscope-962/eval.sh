#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# First, check what test files actually exist in the target commit
# This helps debug if files have been renamed
echo "Checking test files in target commit..."
git ls-tree -r a2bf80ec96e29cb760ac6d4018680d6af68c9416 --name-only tests/ | grep -E "(toolkit|meta)" || true

# Based on context retrieval agent findings:
# - toolkit_test.py exists
# - toolkit_meta_tool_test.py does NOT exist
# - The patch may rename toolkit_test.py to toolkit_basic_test.py

# Ensure test file is at the target commit state before applying patch
# Only checkout the file that exists (toolkit_test.py)
git checkout a2bf80ec96e29cb760ac6d4018680d6af68c9416 "tests/toolkit_test.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/toolkit_test.py b/tests/toolkit_basic_test.py
similarity index 86%
rename from tests/toolkit_test.py
rename to tests/toolkit_basic_test.py
--- a/tests/toolkit_test.py
+++ b/tests/toolkit_basic_test.py
@@ -1,6 +1,5 @@
 # -*- coding: utf-8 -*-
 # mypy: disable-error-code="index"
-# pylint: disable=too-many-lines
 """Test toolkit module in agentscope."""
 import asyncio
 import time
@@ -147,8 +146,8 @@ class ExtendedModelReusingBaseModel(BaseModel):
     extra_field: str = Field(description="Extra field")
 
 
-class ToolkitTest(IsolatedAsyncioTestCase):
-    """Unittest for the toolkit module."""
+class ToolkitBasicTest(IsolatedAsyncioTestCase):
+    """Basic unittests for the toolkit module."""
 
     async def asyncSetUp(self) -> None:
         """Set up the test environment before each test."""
@@ -184,7 +183,7 @@ async def asyncSetUp(self) -> None:
                     "required": ["arg1"],
                     "type": "object",
                 },
-                "description": "A sync function for testing.\n\n"
+                "description": "A sync function for testing.\n"
                 "Long description.",
             },
         }
@@ -396,7 +395,7 @@ async def test_basic_functionalities(self) -> None:
                                 "arg3",
                             ],
                         },
-                        "description": "A sync function for testing.\n\n"
+                        "description": "A sync function for testing.\n"
                         "Long description.",
                     },
                 },
@@ -550,7 +549,7 @@ def func(
                             "properties": {},
                             "type": "object",
                         },
-                        "description": "A test function.\n\n"
+                        "description": "A test function.\n"
                         "Note this function is test.",
                     },
                 },
@@ -810,7 +809,7 @@ async def test_create_tool_group(self) -> None:
             [],
         )
 
-        # Active the tool group
+        # Activate the tool group
         self.toolkit.update_tool_groups(["my_group"], True)
         self.assertListEqual(
             self.toolkit.get_json_schemas(),
@@ -975,113 +974,6 @@ def example_func(
                 "Received: a=1, b=test, c=[1, 2, 3], d=xyz",
             )
 
-    async def test_meta_tool(self) -> None:
-        """Test the meta tool."""
-        self.toolkit.register_tool_function(
-            self.toolkit.reset_equipped_tools,
-        )
-        self.assertListEqual(
-            self.toolkit.get_json_schemas(),
-            [
-                {
-                    "type": "function",
-                    "function": {
-                        "name": "reset_equipped_tools",
-                        "parameters": {
-                            "properties": {},
-                            "type": "object",
-                        },
-                        "description": (
-                            "Choose appropriate tools to equip yourself "
-                            "with, so that you can\n\n"
-                            "finish your task. Each argument in this function "
-                            "represents a group\n"
-                            "of related tools, and the value indicates "
-                            "whether to activate the\n"
-                            "group or not. Besides, the tool response of "
-                            "this function will\n"
-                            "contain the precaution notes for using them, "
-                            "which you\n"
-                            "**MUST pay attention to and follow**. You can "
-                            "also reuse this function\n"
-                            "to check the notes of the tool groups.\n\n"
-                            "Note this function will `reset` the tools, so "
-                            "that the original tools\n"
-                            "will be removed first."
-                        ),
-                    },
-                },
-            ],
-        )
-        self.toolkit.create_tool_group(
-            "browser_use",
-            "The browser-use related tools.",
-            notes="""## About Browser-Use Tools
-1. You must xxx
-2. First click xxx
-""",
-        )
-        self.assertListEqual(
-            self.toolkit.get_json_schemas(),
-            [
-                {
-                    "type": "function",
-                    "function": {
-                        "name": "reset_equipped_tools",
-                        "parameters": {
-                            "properties": {
-                                "browser_use": {
-                                    "default": False,
-                                    "description": "The browser-use related "
-                                    "tools.",
-                                    "type": "boolean",
-                                },
-                            },
-                            "type": "object",
-                        },
-                        "description": (
-                            "Choose appropriate tools to equip yourself "
-                            "with, so that you can\n\n"
-                            "finish your task. Each argument in this function "
-                            "represents a group\n"
-                            "of related tools, and the value indicates "
-                            "whether to activate the\n"
-                            "group or not. Besides, the tool response of "
-                            "this function will\n"
-                            "contain the precaution notes for using them, "
-                            "which you\n"
-                            "**MUST pay attention to and follow**. You can "
-                            "also reuse this function\n"
-                            "to check the notes of the tool groups.\n\n"
-                            "Note this function will `reset` the tools, so "
-                            "that the original tools\n"
-                            "will be removed first."
-                        ),
-                    },
-                },
-            ],
-        )
-        res = await self.toolkit.call_tool_function(
-            ToolUseBlock(
-                type="tool_use",
-                id="123",
-                name="reset_equipped_tools",
-                input={"browser_use": True},
-            ),
-        )
-
-        async for chunk in res:
-            self.assertEqual(
-                chunk.content[0]["text"],
-                "Active tool groups successfully: ['browser_use']. "
-                "You MUST follow these notes to use the tools:\n"
-                "<notes>## About browser_use Tools\n"
-                "## About Browser-Use Tools\n"
-                "1. You must xxx\n"
-                "2. First click xxx\n"
-                "</notes>",
-            )
-
     async def asyncTearDown(self) -> None:
         """Clean up after each test."""
         self.toolkit = None
diff --git a/tests/toolkit_meta_tool_test.py b/tests/toolkit_meta_tool_test.py
new file mode 100644
--- /dev/null
+++ b/tests/toolkit_meta_tool_test.py
@@ -0,0 +1,276 @@
+# -*- coding: utf-8 -*-
+# mypy: disable-error-code="index"
+"""Test meta tool in toolkit module in agentscope."""
+from unittest import IsolatedAsyncioTestCase
+
+from agentscope.message import ToolUseBlock, TextBlock
+from agentscope.tool import ToolResponse, Toolkit
+
+
+def tool_function_1() -> ToolResponse:
+    """Test tool function 1."""
+    return ToolResponse(
+        content=[
+            TextBlock(
+                type="text",
+                text="1",
+            ),
+        ],
+    )
+
+
+def tool_function_2() -> ToolResponse:
+    """Test tool function 2."""
+    return ToolResponse(
+        content=[
+            TextBlock(
+                type="text",
+                text="2",
+            ),
+        ],
+    )
+
+
+class ToolkitMetaToolTest(IsolatedAsyncioTestCase):
+    """Unittest for the toolkit module."""
+
+    async def asyncSetUp(self) -> None:
+        """Set up the test environment before each test."""
+        self.toolkit = Toolkit()
+
+        self.function_1_schema = {
+            "type": "function",
+            "function": {
+                "name": "tool_function_1",
+                "parameters": {
+                    "type": "object",
+                    "properties": {},
+                },
+                "description": "Test tool function 1.",
+            },
+        }
+
+        self.function_2_schema = {
+            "type": "function",
+            "function": {
+                "name": "tool_function_2",
+                "parameters": {
+                    "type": "object",
+                    "properties": {},
+                },
+                "description": "Test tool function 2.",
+            },
+        }
+
+        self.meta_tool_schema = {
+            "type": "function",
+            "function": {
+                "name": "reset_equipped_tools",
+                "parameters": {
+                    "properties": {},
+                    "type": "object",
+                },
+                "description": """This function allows you to activate or \
+deactivate tool groups
+dynamically based on your current task requirements.
+**Important: Each call sets the absolute final state of ALL tool
+groups, not incremental changes**. Any group not explicitly set to True
+will be deactivated, regardless of its previous state.
+
+**Best practice**: Actively manage your tool groups——activate only
+what you need for the current task, and promptly deactivate groups as
+soon as they are no longer needed to conserve context space.
+
+The function will return the usage instructions for the activated tool
+groups, which you **MUST pay attention to and follow**. You can also
+reuse this function to check the notes of the tool groups.""",
+            },
+        }
+
+    async def test_meta_tool(self) -> None:
+        """Test the meta tool."""
+        self.toolkit.register_tool_function(
+            self.toolkit.reset_equipped_tools,
+        )
+
+        # Test if the meta tool is registered correctly
+        self.assertListEqual(
+            self.toolkit.get_json_schemas(),
+            [self.meta_tool_schema],
+        )
+
+        # Test creating a tool group and using the meta tool
+        self.toolkit.create_tool_group(
+            "browser_use",
+            "The browser-use related tools.",
+            notes="""1. You must xxx
+2. First click xxx
+""",
+        )
+        self.toolkit.register_tool_function(
+            tool_function_1,
+            group_name="browser_use",
+        )
+
+        self.meta_tool_schema["function"]["parameters"]["properties"] = {
+            "browser_use": {
+                "type": "boolean",
+                "description": "The browser-use related tools.",
+                "default": False,
+            },
+        }
+
+        # Test if the arguments are updated correctly
+        self.assertListEqual(
+            self.toolkit.get_json_schemas(),
+            [
+                self.meta_tool_schema,
+            ],
+        )
+
+        res = await self.toolkit.call_tool_function(
+            ToolUseBlock(
+                type="tool_use",
+                id="123",
+                name="reset_equipped_tools",
+                input={"browser_use": True},
+            ),
+        )
+
+        # Test if the tool response is correct
+        async for chunk in res:
+            self.assertEqual(
+                chunk.content[0]["text"],
+                "Now tool groups 'browser_use' are activated. "
+                "You MUST follow these notes to use these tools:\n"
+                "<notes>## About Tool Group 'browser_use'\n"
+                "1. You must xxx\n"
+                "2. First click xxx\n"
+                "</notes>",
+            )
+
+        # Test if the tool group is activated correctly, i.e. the tool
+        # function 1 is available
+        self.assertListEqual(
+            self.toolkit.get_json_schemas(),
+            [
+                self.meta_tool_schema,
+                {
+                    "type": "function",
+                    "function": {
+                        "name": "tool_function_1",
+                        "parameters": {
+                            "type": "object",
+                            "properties": {},
+                        },
+                        "description": "Test tool function 1.",
+                    },
+                },
+            ],
+        )
+
+        # Create another tool group and register tool function 2
+        self.toolkit.create_tool_group(
+            "file_use",
+            "The file-use related tools.",
+        )
+        self.toolkit.register_tool_function(
+            tool_function_2,
+            group_name="file_use",
+        )
+
+        # Test if the meta tool schema is updated correctly
+        self.meta_tool_schema["function"]["parameters"]["properties"] = {
+            "browser_use": {
+                "type": "boolean",
+                "description": "The browser-use related tools.",
+                "default": False,
+            },
+            "file_use": {
+                "type": "boolean",
+                "description": "The file-use related tools.",
+                "default": False,
+            },
+        }
+
+        self.assertListEqual(
+            self.toolkit.get_json_schemas(),
+            [
+                self.meta_tool_schema,
+                self.function_1_schema,
+            ],
+        )
+
+        # Activate the file-use tool group only
+        res = await self.toolkit.call_tool_function(
+            ToolUseBlock(
+                type="tool_use",
+                id="124",
+                name="reset_equipped_tools",
+                input={"file_use": True},
+            ),
+        )
+
+        # Test if the tool response is correct
+        async for chunk in res:
+            self.assertEqual(
+                chunk.content[0]["text"],
+                "Now tool groups 'file_use' are activated.",
+            )
+
+        # Test if only tool function 2 is available now
+        self.assertListEqual(
+            self.toolkit.get_json_schemas(),
+            [
+                self.meta_tool_schema,
+                self.function_2_schema,
+            ],
+        )
+
+        # Test if all tool groups are deactivated
+        res = await self.toolkit.call_tool_function(
+            ToolUseBlock(
+                type="tool_use",
+                id="125",
+                name="reset_equipped_tools",
+                input={},
+            ),
+        )
+
+        # Test if the tool response is correct
+        async for chunk in res:
+            self.assertEqual(
+                chunk.content[0]["text"],
+                "All tool groups are now deactivated currently.",
+            )
+
+        # Test if no tool function is available now
+        self.assertListEqual(
+            self.toolkit.get_json_schemas(),
+            [
+                self.meta_tool_schema,
+            ],
+        )
+
+        # Test calling the inactive tool function
+        res = await self.toolkit.call_tool_function(
+            ToolUseBlock(
+                type="tool_use",
+                id="126",
+                name="tool_function_1",
+                input={},
+            ),
+        )
+
+        async for chunk in res:
+            self.assertEqual(
+                chunk.content[0]["text"],
+                "FunctionInactiveError: The function 'tool_function_1' "
+                "is in the inactive group 'browser_use'. "
+                "Activate the tool group by calling 'reset_equipped_tools' "
+                "first to use this tool.",
+            )
+
+    async def asyncTearDown(self) -> None:
+        """Clean up after each test."""
+        self.toolkit = None
EOF_114329324912

# After patch application, check what test file exists now
echo "Files after patch application:"
ls -la tests/toolkit* 2>/dev/null || true

# Run the test file - first try the original name, then check for renamed version
# The patch may rename toolkit_test.py to toolkit_basic_test.py
if [ -f "tests/toolkit_test.py" ]; then
    TEST_FILE="tests/toolkit_test.py"
elif [ -f "tests/toolkit_basic_test.py" ]; then
    TEST_FILE="tests/toolkit_basic_test.py"
else
    echo "ERROR: No toolkit test file found after patch application"
    # List all test files for debugging
    find tests/ -name "*.py" | head -20
    exit 1
fi

echo "Running tests from: $TEST_FILE"

# Run the specific test file with pytest
# Use coverage run as per the CI configuration
coverage run -m pytest --no-header -rA --tb=no -p no:cacheprovider "$TEST_FILE"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Revert the test file to original commit state after execution
# Revert whatever file was modified by the patch
if [ -f "tests/toolkit_test.py" ]; then
    git checkout a2bf80ec96e29cb760ac6d4018680d6af68c9416 "tests/toolkit_test.py"
fi
if [ -f "tests/toolkit_basic_test.py" ]; then
    # If the patch created a new file, remove it
    rm -f "tests/toolkit_basic_test.py"
fi