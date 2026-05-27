#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test file to the committed version before patching
git checkout 6c823a955c7be783a2a34c64d13b74aee8c552bf "tests/format_test.py"

# Apply the test patch (placeholder content to be replaced at runtime)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/format_test.py b/tests/format_test.py
--- a/tests/format_test.py
+++ b/tests/format_test.py
@@ -283,7 +283,7 @@ def test_ollama_chat(self) -> None:
         # correct format
         ground_truth = [
             {
-                "role": "system",
+                "role": "user",
                 "content": (
                     "You are a helpful assistant\n"
                     "\n"
EOF_114329324912

# Run the specified target test file only
# Use coverage as per environment info but simplified to run single test file with output of test names and statuses
# The tests are run via coverage run tests/run.py usually, but this runs all tests;
# Since no individual test run command is given, run pytest directly targeting the specified test file to run only that file
# -q quiet output, -rA to show all test outcomes, --tb=short to avoid long tracebacks

pytest -q -rA --tb=short tests/format_test.py
rc=$?  # capture exit code after tests run

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file after running tests to discard patch changes
git checkout 6c823a955c7be783a2a34c64d13b74aee8c552bf "tests/format_test.py"