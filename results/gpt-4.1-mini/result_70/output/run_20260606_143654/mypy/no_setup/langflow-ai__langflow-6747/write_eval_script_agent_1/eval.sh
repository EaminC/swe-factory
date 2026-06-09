#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout the target test file to ensure clean state
git checkout 4ef4c93baccf30fc18936941ec9110b5f2fc2a59 "src/backend/tests/unit/components/outputs/test_chat_output_component.py"

# Apply the test patch (content to be substituted at runtime)
git apply -v - <<'EOF_114329324912'
diff --git a/src/backend/tests/unit/components/outputs/test_chat_output_component.py b/src/backend/tests/unit/components/outputs/test_chat_output_component.py
--- a/src/backend/tests/unit/components/outputs/test_chat_output_component.py
+++ b/src/backend/tests/unit/components/outputs/test_chat_output_component.py
@@ -94,5 +94,5 @@ async def test_invalid_input(self, component_class, default_kwargs):
             await component.message_response()
 
         component.input_value = 123  # Invalid type
-        with pytest.raises(TypeError, match="Expected Data or DataFrame or Message or str"):
+        with pytest.raises(TypeError, match="Expected Data or DataFrame or Message or str, Generator or None"):
             await component.message_response()
EOF_114329324912

# Activate the virtual environment
source /testbed/testbed_venv/bin/activate

# Run the specified test file using uv run pytest as recommended
# Output test names and pass/fail/skip status with concise formatting
uv run pytest -v --tb=short "src/backend/tests/unit/components/outputs/test_chat_output_component.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to original state, discarding patch changes
git checkout 4ef4c93baccf30fc18936941ec9110b5f2fc2a59 "src/backend/tests/unit/components/outputs/test_chat_output_component.py"