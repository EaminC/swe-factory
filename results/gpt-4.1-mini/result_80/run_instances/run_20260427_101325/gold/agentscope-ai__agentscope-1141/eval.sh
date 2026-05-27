#!/bin/bash
set -uxo pipefail

cd /testbed

# Restore the test file to the target commit state before applying patch
git checkout c29bdded396eff9a47aa36643ce1169b2ebf5318 "tests/formatter_dashscope_test.py"

# Apply the test patch
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

# Activate the python virtual environment
source /testbed/testbed/bin/activate

# Run pytest on the specified test file only, 
# showing concise pass/fail/skip status with test file names
pytest --tb=short -q -rA tests/formatter_dashscope_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore possible changes to the test file after test run
git checkout c29bdded396eff9a47aa36643ce1169b2ebf5318 "tests/formatter_dashscope_test.py"