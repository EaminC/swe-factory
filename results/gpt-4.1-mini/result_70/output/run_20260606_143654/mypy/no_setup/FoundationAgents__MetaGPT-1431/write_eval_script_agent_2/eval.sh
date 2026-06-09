#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout the specified commit and reset the target test files before patching
git checkout 22e100912839965231144ae25790d643180ddc57 \
    "tests/metagpt/actions/test_action_node.py" \
    "tests/metagpt/test_config.py" \
    "tests/metagpt/test_context.py"

# Apply the test patch if required
git apply -v - <<'EOF_114329324912'
diff --git a/tests/metagpt/actions/test_action_node.py b/tests/metagpt/actions/test_action_node.py
--- a/tests/metagpt/actions/test_action_node.py
+++ b/tests/metagpt/actions/test_action_node.py
@@ -6,7 +6,7 @@
 @File    : test_action_node.py
 """
 from pathlib import Path
-from typing import List, Tuple
+from typing import List, Optional, Tuple
 
 import pytest
 from pydantic import BaseModel, Field, ValidationError
@@ -302,6 +302,19 @@ def test_action_node_from_pydantic_and_print_everything():
     assert "tasks" in code, "tasks should be in code"
 
 
+def test_optional():
+    mapping = {
+        "Logic Analysis": (Optional[List[Tuple[str, str]]], Field(default=None)),
+        "Task list": (Optional[List[str]], None),
+        "Plan": (Optional[str], ""),
+        "Anything UNCLEAR": (Optional[str], None),
+    }
+    m = {"Anything UNCLEAR": "a"}
+    t = ActionNode.create_model_class("test_class_1", mapping)
+
+    t1 = t(**m)
+    assert t1
+
+
 if __name__ == "__main__":
-    test_create_model_class()
-    test_create_model_class_with_mapping()
+    pytest.main([__file__, "-s"])
diff --git a/tests/metagpt/test_config.py b/tests/metagpt/test_config.py
--- a/tests/metagpt/test_config.py
+++ b/tests/metagpt/test_config.py
@@ -14,8 +14,8 @@
 def test_config_1():
     cfg = Config.default()
     llm = cfg.get_openai_llm()
-    assert llm is not None
-    assert llm.api_type == LLMType.OPENAI
+    if cfg.llm.api_type == LLMType.OPENAI:
+        assert llm is not None
 
 
 def test_config_from_dict():
diff --git a/tests/metagpt/test_context.py b/tests/metagpt/test_context.py
--- a/tests/metagpt/test_context.py
+++ b/tests/metagpt/test_context.py
@@ -53,8 +53,8 @@ def test_context_1():
 def test_context_2():
     ctx = Context()
     llm = ctx.config.get_openai_llm()
-    assert llm is not None
-    assert llm.api_type == LLMType.OPENAI
+    if ctx.config.llm.api_type == LLMType.OPENAI:
+        assert llm is not None
 
     kwargs = ctx.kwargs
     assert kwargs is not None
EOF_114329324912

# Activate the python virtual environment
source /opt/testbed/bin/activate

# Ensure pytest is installed before running tests (in case it's missing)
pip install pytest

# Run only the specified test files in one pytest command with concise output
pytest -v --maxfail=1 --disable-warnings \
    tests/metagpt/actions/test_action_node.py \
    tests/metagpt/test_config.py \
    tests/metagpt/test_context.py

rc=$?  # capture exit code of pytest

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test files to original committed state after tests
git checkout 22e100912839965231144ae25790d643180ddc57 \
    "tests/metagpt/actions/test_action_node.py" \
    "tests/metagpt/test_config.py" \
    "tests/metagpt/test_context.py"