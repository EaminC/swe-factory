#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 9b589c65fed699a48d1c93fe74c9e57bc361b70d 

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_sql_correction_instructions.py b/tests/test_sql_correction_instructions.py
new file mode 100644
index 00000000..e69de29bb
--- /dev/null
+++ b/tests/test_sql_correction_instructions.py
@@ -0,0 +1,37 @@
+import pytest
+from wren-ai-service.src.pipelines.generation.sql_correction import SQLCorrection, prompt
+from src.pipelines.generation.utils.sql import construct_instructions
+
+class DummyPromptBuilder:
+    def run(self, **kwargs):
+        # Return the prompt string including instructions if present
+        instructions = kwargs.get('instructions', [])
+        prompt_parts = []
+        if instructions:
+            prompt_parts.append('### USER INSTRUCTIONS ###')
+            for i, instr in enumerate(instructions, 1):
+                prompt_parts.append(f"{i}. {instr.get('text', '')}")
+        prompt_parts.append('### QUESTION ###')
+        return {"prompt": "\n".join(prompt_parts)}
+
+def test_instructions_in_prompt():
+    instructions = [{'text': 'Use only uppercase keywords.'}, {'text': 'Avoid subqueries.'}]
+    invalid_generation_result = {"sql": "SELECT * FROM table", "error": "syntax error"}
+    documents = []
+    prompt_builder = DummyPromptBuilder()
+    # Construct instructions list as done in patch
+    constructed = construct_instructions(instructions)
+    result = prompt(
+        documents=documents,
+        invalid_generation_result=invalid_generation_result,
+        prompt_builder=prompt_builder,
+        instructions=instructions
+    )
+    prompt_text = result["prompt"]
+    # Check that instructions appear in prompt
+    assert "### USER INSTRUCTIONS ###" in prompt_text
+    assert "1. Use only uppercase keywords." in prompt_text
+    assert "2. Avoid subqueries." in prompt_text
+    # Also check that question section is present
+    assert "### QUESTION ###" in prompt_text
+
EOF_114329324912

# Activate Poetry virtual environment and run the requested test file only.
# The working directory is /testbed, and test file relative to root is provided.
# Use poetry run just test with path limitation by passing pytest args.
source /testbed/.venv/bin/activate

# Run only the specified test file explicitly through pytest via just test command
# just test command internally runs pytest, we add the test file argument after --
# to ensure only the target test file executes.
poetry run just test -- tests/test_sql_correction_instructions.py

rc=$?            #Required, save exit code

echo "OMNIGRIL_EXIT_CODE=$rc" #Required, echo test status

# Reset the patch to clean changes to test files
git checkout 9b589c65fed699a48d1c93fe74c9e57bc361b70d "tests/test_sql_correction_instructions.py"