#!/bin/bash
set -uxo pipefail

# Activate the UV virtual environment
source /testbed/.venv/bin/activate

# Debug: Verify Python version and environment
echo "=== Environment Verification ==="
python --version
echo "Python executable: $(which python)"
echo "UV version: $(uv --version)"
echo "Installed packages:"
pip list | grep -E "^(crewai|pytest|uv|pydantic|openai|litellm|instructor)" || true
echo "=== End Environment Verification ==="

# Navigate to the repository root
cd /testbed

# Ensure the target test file is at the correct commit state
git checkout b4e2db03069fcedbf80eb2130aa91d0cb68b3a43 "tests/llm_test.py"

# Apply the test patch (placeholder will be replaced during execution)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/llm_test.py b/tests/llm_test.py
--- a/tests/llm_test.py
+++ b/tests/llm_test.py
@@ -6,7 +6,7 @@
 from pydantic import BaseModel
 
 from crewai.agents.agent_builder.utilities.base_token_process import TokenProcess
-from crewai.llm import LLM
+from crewai.llm import CONTEXT_WINDOW_USAGE_RATIO, LLM
 from crewai.utilities.events import crewai_event_bus
 from crewai.utilities.events.tool_usage_events import ToolExecutionErrorEvent
 from crewai.utilities.token_counter_callback import TokenCalcHandler
@@ -285,6 +285,23 @@ def test_o3_mini_reasoning_effort_medium():
     assert isinstance(result, str)
     assert "Paris" in result
 
+def test_context_window_validation():
+    """Test that context window validation works correctly."""
+    # Test valid window size
+    llm = LLM(model="o3-mini")
+    assert llm.get_context_window_size() == int(200000 * CONTEXT_WINDOW_USAGE_RATIO)
+
+    # Test invalid window size
+    with pytest.raises(ValueError) as excinfo:
+        with patch.dict(
+            "crewai.llm.LLM_CONTEXT_WINDOW_SIZES",
+            {"test-model": 500},  # Below minimum
+            clear=True,
+        ):
+            llm = LLM(model="test-model")
+            llm.get_context_window_size()
+    assert "must be between 1024 and 2097152" in str(excinfo.value)
+
 
 @pytest.mark.vcr(filter_headers=["authorization"])
 @pytest.fixture
EOF_114329324912

# Run the specified test file using pytest with UV
# Use uv run to ensure proper environment isolation and dependency resolution
echo "=== Running Tests ==="
uv run pytest tests/llm_test.py -v --tb=short --no-header -rA
rc=$?

# Output the exit code for the judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the test file to its original state
git checkout b4e2db03069fcedbf80eb2130aa91d0cb68b3a43 "tests/llm_test.py"