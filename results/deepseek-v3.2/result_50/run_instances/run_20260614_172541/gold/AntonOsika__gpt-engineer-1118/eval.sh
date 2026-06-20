#!/bin/bash
set -uxo pipefail

# Activate the Poetry environment
source /activate_poetry_env.sh

# Navigate to the project directory
cd /testbed

# Reset the target test file to the original commit state
git checkout 96dae2cc72a93f98a93331b29c6869580b93cf0c "tests/core/default/test_steps.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/core/default/test_steps.py b/tests/core/default/test_steps.py
--- a/tests/core/default/test_steps.py
+++ b/tests/core/default/test_steps.py
@@ -14,6 +14,7 @@
     curr_fn,
     gen_code,
     gen_entrypoint,
+    handle_improve_mode,
     improve_fn,
     setup_sys_prompt,
     setup_sys_prompt_existing_code,
@@ -310,3 +311,26 @@ def test_improve_existing_code(self, tmp_path):
             }
         )
         assert improved_code == expected_code
+
+    def test_handle_improve_mode_multilayer_error_trace(self):
+        # Mock the AI class
+        class MockAI:
+            def improve(self, files_dict, prompt):
+                try:
+                    raise Exception("This is a nested test exception")
+                except Exception as e:
+                    raise Exception("This is a test exception") from e
+
+        agent = MockAI()
+        memory = DiskMemory(tempfile.mkdtemp())
+        files_dict = FilesDict({"main.py": "print('Hello, World!')"})
+        prompt = (
+            "Change the program to print 'Goodbye, World!' instead of 'Hello, World!'"
+        )
+
+        try:
+            handle_improve_mode(prompt, agent, memory, files_dict)
+        except Exception as e:
+            assert str(e) == "This is a test exception"
+            assert isinstance(e.__cause__, Exception)
+            assert str(e.__cause__) == "This is a nested test exception"
EOF_114329324912

# Run the specific test file using pytest with coverage (as per project configuration)
# Use the exact command from the context retrieval agent, but limit to the target file
poetry run pytest --cov=gpt_engineer --cov-report=xml tests/core/default/test_steps.py -v
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Revert the test file to its original state
git checkout 96dae2cc72a93f98a93331b29c6869580b93cf0c "tests/core/default/test_steps.py"