#!/bin/bash
set -uxo pipefail
cd /testbed

# Activate the virtual environment
source /testbed/venv/bin/activate

# Verify the environment is properly activated
python --version
pip --version

# Ensure we're on the correct commit
git checkout c29bdded396eff9a47aa36643ce1169b2ebf5318 "tests/formatter_dashscope_test.py"

# Apply test patch (if any content is provided)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/formatter_dashscope_test.py b/tests/formatter_dashscope_test.py
--- a/tests/formatter_dashscope_test.py
+++ b/tests/formatter_dashscope_test.py
@@ -257,7 +257,7 @@ async def asyncSetUp(self) -> None:
             },
             {
                 "role": "assistant",
-                "content": [{"text": None}],
+                "content": [],
                 "tool_calls": [
                     {
                         "id": "1",
@@ -319,11 +319,7 @@ async def asyncSetUp(self) -> None:
             },
             {
                 "role": "assistant",
-                "content": [
-                    {
-                        "text": None,
-                    },
-                ],
+                "content": [],
                 "tool_calls": [
                     {
                         "id": "1",
@@ -360,11 +356,7 @@ async def asyncSetUp(self) -> None:
             },
             {
                 "role": "assistant",
-                "content": [
-                    {
-                        "text": None,
-                    },
-                ],
+                "content": [],
                 "tool_calls": [
                     {
                         "id": "1",
@@ -429,11 +421,7 @@ async def asyncSetUp(self) -> None:
             },
             {
                 "role": "assistant",
-                "content": [
-                    {
-                        "text": None,
-                    },
-                ],
+                "content": [],
                 "tool_calls": [
                     {
                         "id": "1",
@@ -463,11 +451,7 @@ async def asyncSetUp(self) -> None:
             },
             {
                 "role": "assistant",
-                "content": [
-                    {
-                        "text": None,
-                    },
-                ],
+                "content": [],
                 "tool_calls": [
                     {
                         "id": "1",
@@ -628,7 +612,7 @@ async def test_chat_formatter_with_extract_media_blocks(
             },
             {
                 "role": "assistant",
-                "content": [{"text": None}],
+                "content": [],
                 "tool_calls": [
                     {
                         "id": "1",
@@ -852,11 +836,7 @@ async def test_multiagent_formatter_with_promote_media_tool_result(
             },
             {
                 "role": "assistant",
-                "content": [
-                    {
-                        "text": None,
-                    },
-                ],
+                "content": [],
                 "tool_calls": [
                     {
                         "id": "1",
EOF_114329324912

# Verify required dependencies are installed
python -c "import agentscope; print('agentscope: OK')"
python -c "import dashscope; print('dashscope: OK')"
python -c "import pytest; print('pytest: OK')"

# Run the target test file with verbose output
pytest tests/formatter_dashscope_test.py -v
rc=$?

# Required: capture and echo the exit code
echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the test file to the original state
git checkout c29bdded396eff9a47aa36643ce1169b2ebf5318 "tests/formatter_dashscope_test.py"

exit $rc