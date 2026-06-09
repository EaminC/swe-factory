#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the specified test file to the commit state before patching
git checkout 96dae2cc72a93f98a93331b29c6869580b93cf0c "tests/core/default/test_steps.py"

# Apply the given test patch
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

# Run the specified test file using poetry's pytest integration
# Activate poetry virtualenv by sourcing the in-project .venv activate script
# This ensures exact environment for tests including dependencies and python version
source .venv/bin/activate

poetry run pytest --tb=short -rA tests/core/default/test_steps.py

rc=$?  # Capture the exit code of the tests

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file back to original commit state, cleaning up patch
git checkout 96dae2cc72a93f98a93331b29c6869580b93cf0c "tests/core/default/test_steps.py"