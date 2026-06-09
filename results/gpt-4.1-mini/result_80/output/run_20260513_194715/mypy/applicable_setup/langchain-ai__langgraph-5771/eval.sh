#!/bin/bash
set -uxo pipefail

cd /testbed/libs/langgraph

# Reset the test file to clean state before patching
git checkout 18887e9f86a6d8675a2b4aed03a1c190ef6e1581 "tests/test_deprecation.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/libs/langgraph/tests/test_deprecation.py b/libs/langgraph/tests/test_deprecation.py
--- a/libs/langgraph/tests/test_deprecation.py
+++ b/libs/langgraph/tests/test_deprecation.py
@@ -1,6 +1,7 @@
 import pytest
+from langchain_core.runnables import RunnableConfig
 from pytest_mock import MockerFixture
-from typing_extensions import TypedDict
+from typing_extensions import NotRequired, TypedDict
 
 from langgraph.channels.last_value import LastValue
 from langgraph.errors import NodeInterrupt
@@ -136,6 +137,7 @@ def my_entrypoint(state: PlainState) -> PlainState:
         assert my_entrypoint.config_schema() is not None
 
 
+@pytest.mark.filterwarnings("ignore:`config_type` is deprecated")
 def test_config_type_deprecation_pregel(mocker: MockerFixture) -> None:
     add_one = mocker.Mock(side_effect=lambda x: x + 1)
     chain = NodeBuilder().subscribe_only("input").do(add_one).write_to("output")
@@ -185,3 +187,45 @@ def test_deprecated_import() -> None:
         match="Importing PREVIOUS from langgraph.constants is deprecated. This constant is now private and should not be used directly.",
     ):
         from langgraph.constants import PREVIOUS  # noqa: F401
+
+
+@pytest.mark.filterwarnings("ignore:`checkpoint_during` is deprecated")
+def test_checkpoint_during_deprecation_state_graph() -> None:
+    class CheckDurability(TypedDict):
+        durability: NotRequired[str]
+
+    def plain_node(state: CheckDurability, config: RunnableConfig) -> CheckDurability:
+        return {"durability": config["configurable"]["__pregel_durability"]}
+
+    builder = StateGraph(CheckDurability)
+    builder.add_node("plain_node", plain_node)
+    builder.set_entry_point("plain_node")
+    graph = builder.compile()
+
+    with pytest.warns(
+        LangGraphDeprecatedSinceV10,
+        match="`checkpoint_during` is deprecated and will be removed. Please use `durability` instead.",
+    ):
+        result = graph.invoke({}, checkpoint_during=True)
+        assert result["durability"] == "async"
+
+    with pytest.warns(
+        LangGraphDeprecatedSinceV10,
+        match="`checkpoint_during` is deprecated and will be removed. Please use `durability` instead.",
+    ):
+        result = graph.invoke({}, checkpoint_during=False)
+        assert result["durability"] == "exit"
+
+    with pytest.warns(
+        LangGraphDeprecatedSinceV10,
+        match="`checkpoint_during` is deprecated and will be removed. Please use `durability` instead.",
+    ):
+        for chunk in graph.stream({}, checkpoint_during=True):  # type: ignore[arg-type]
+            assert chunk["plain_node"]["durability"] == "async"
+
+    with pytest.warns(
+        LangGraphDeprecatedSinceV10,
+        match="`checkpoint_during` is deprecated and will be removed. Please use `durability` instead.",
+    ):
+        for chunk in graph.stream({}, checkpoint_during=False):  # type: ignore[arg-type]
+            assert chunk["plain_node"]["durability"] == "exit"
EOF_114329324912

# Run pytest inside the hatch environment with all required pytest options
hatch run pytest --full-trace --strict-markers --strict-config --durations=5 --snapshot-warn-unused tests/test_deprecation.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to clean state after tests
git checkout 18887e9f86a6d8675a2b4aed03a1c190ef6e1581 "tests/test_deprecation.py"