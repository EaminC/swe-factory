#!/bin/bash
set -uxo pipefail
cd /testbed

# Verify we're in the correct position
echo "Current directory: $(pwd)"
echo "Python version: $(python --version)"
echo "Pytest version: $(pytest --version)"

# Apply test patch if needed
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

# Run the target test file
pytest tests/format_test.py -v --tb=short --no-header -rA
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"