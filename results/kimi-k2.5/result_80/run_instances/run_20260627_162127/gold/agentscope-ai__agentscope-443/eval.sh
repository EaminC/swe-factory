#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Reset target test file to ensure clean state
git checkout 6c823a955c7be783a2a34c64d13b74aee8c552bf "tests/format_test.py"

# Apply test patch
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

# Run the specific target test file
python -m unittest tests.format_test -v
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the test file to original state
git checkout 6c823a955c7be783a2a34c64d13b74aee8c552bf "tests/format_test.py"