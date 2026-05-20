#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 220314b53a960964a82657451b846f3a7cb2f348 "libs/langgraph/tests/test_deprecation.py"

# Apply test patch to update target tests
git apply -v - <<'EOF_114329324912'
diff --git a/libs/langgraph/tests/test_deprecation.py b/libs/langgraph/tests/test_deprecation.py
--- a/libs/langgraph/tests/test_deprecation.py
+++ b/libs/langgraph/tests/test_deprecation.py
@@ -1,3 +1,8 @@
+from __future__ import annotations
+
+import warnings
+from typing import Any, Optional
+
 import pytest
 from langchain_core.runnables import RunnableConfig
 from pytest_mock import MockerFixture
@@ -188,7 +193,9 @@ def test_deprecated_import() -> None:
         from langgraph.constants import PREVIOUS  # noqa: F401
 
 
-@pytest.mark.filterwarnings("ignore:`checkpoint_during` is deprecated")
+@pytest.mark.filterwarnings(
+    "ignore:`durability` has no effect when no checkpointer is present"
+)
 def test_checkpoint_during_deprecation_state_graph() -> None:
     class CheckDurability(TypedDict):
         durability: NotRequired[str]
@@ -228,3 +235,100 @@ def plain_node(state: CheckDurability, config: RunnableConfig) -> CheckDurabilit
     ):
         for chunk in graph.stream({}, checkpoint_during=False):  # type: ignore[arg-type]
             assert chunk["plain_node"]["durability"] == "exit"
+
+
+def test_config_parameter_incorrect_typing() -> None:
+    """Test that a warning is raised when config parameter is typed incorrectly."""
+    builder = StateGraph(PlainState)
+
+    # Test sync function with config: dict
+    with pytest.warns(
+        UserWarning,
+        match="The 'config' parameter should be typed as 'RunnableConfig' or 'RunnableConfig | None', not '.*dict.*'. ",
+    ):
+
+        def sync_node_with_dict_config(state: PlainState, config: dict) -> PlainState:
+            return state
+
+        builder.add_node(sync_node_with_dict_config)
+
+    # Test async function with config: dict
+    with pytest.warns(
+        UserWarning,
+        match="The 'config' parameter should be typed as 'RunnableConfig' or 'RunnableConfig | None', not '.*dict.*'. ",
+    ):
+
+        async def async_node_with_dict_config(
+            state: PlainState, config: dict
+        ) -> PlainState:
+            return state
+
+        builder.add_node(async_node_with_dict_config)
+
+    # Test with other incorrect types
+    with pytest.warns(
+        UserWarning,
+        match="The 'config' parameter should be typed as 'RunnableConfig' or 'RunnableConfig | None', not '.*Any.*'. ",
+    ):
+
+        def sync_node_with_any_config(state: PlainState, config: Any) -> PlainState:
+            return state
+
+        builder.add_node(sync_node_with_any_config)
+
+    with pytest.warns(
+        UserWarning,
+        match="The 'config' parameter should be typed as 'RunnableConfig' or 'RunnableConfig | None', not '.*Any.*'. ",
+    ):
+
+        async def async_node_with_any_config(
+            state: PlainState, config: Any
+        ) -> PlainState:
+            return state
+
+        builder.add_node(async_node_with_any_config)
+
+    with warnings.catch_warnings(record=True) as w:
+
+        def node_with_correct_config(
+            state: PlainState, config: RunnableConfig
+        ) -> PlainState:
+            return state
+
+        builder.add_node(node_with_correct_config)
+
+        def node_with_optional_config(
+            state: PlainState,
+            config: Optional[RunnableConfig],  # noqa: UP045
+        ) -> PlainState:
+            return state
+
+        builder.add_node(node_with_optional_config)
+
+        def node_with_untyped_config(state: PlainState, config) -> PlainState:
+            return state
+
+        builder.add_node(node_with_untyped_config)
+
+        async def async_node_with_correct_config(
+            state: PlainState, config: RunnableConfig
+        ) -> PlainState:
+            return state
+
+        builder.add_node(async_node_with_correct_config)
+
+        async def async_node_with_optional_config(
+            state: PlainState,
+            config: Optional[RunnableConfig],  # noqa: UP045
+        ) -> PlainState:
+            return state
+
+        builder.add_node(async_node_with_optional_config)
+
+        async def async_node_with_untyped_config(
+            state: PlainState, config
+        ) -> PlainState:
+            return state
+
+        builder.add_node(async_node_with_untyped_config)
+        assert len(w) == 0
EOF_114329324912

# Activate uv environment
source /usr/local/bin/uv activate dev

# Run only specified test file with pytest, outputting concise results
pytest -rA --tb=short libs/langgraph/tests/test_deprecation.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to discard patch changes
git checkout 220314b53a960964a82657451b846f3a7cb2f348 "libs/langgraph/tests/test_deprecation.py"