#!/bin/bash
set -uxo pipefail

# Activate the python virtual environment
source /testbed/testbed/bin/activate

cd /testbed

# Checkout exact commit for the target test file to ensure clean state
git checkout 6c823a955c7be783a2a34c64d13b74aee8c552bf "tests/format_test.py"

# Apply test patch if required (placeholder for actual patch content)
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

# Run only specified test file with pytest as per context information
pytest --disable-warnings -rA --tb=short tests/format_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file after testing to clean state
git checkout 6c823a955c7be783a2a34c64d13b74aee8c552bf "tests/format_test.py"