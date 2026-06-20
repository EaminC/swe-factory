#!/bin/bash
set -uxo pipefail

# Activate the conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Ensure we are on the correct commit and checkout the target test file
git checkout 6c823a955c7be783a2a34c64d13b74aee8c552bf "tests/format_test.py"

# Apply the test patch
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

# Run the specific test file using the project's test runner with the pattern flag
# This ensures only format_test.py is executed, not all tests.
python tests/run.py --pattern "format_test.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Revert changes to the test file to cleanup
git checkout 6c823a955c7be783a2a34c64d13b74aee8c552bf "tests/format_test.py"