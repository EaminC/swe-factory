#!/bin/bash
set -uxo pipefail
cd /testbed

# Restore target test files to exact commit state before patching
git checkout 04c71d7d297447479d897b6803206210ed589d53 "tests/applications/cli/test_learning.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/applications/cli/test_learning.py b/tests/applications/cli/test_learning.py
--- a/tests/applications/cli/test_learning.py
+++ b/tests/applications/cli/test_learning.py
@@ -3,6 +3,7 @@
 from gpt_engineer.applications.cli import learning
 from gpt_engineer.applications.cli.learning import Learning
 from gpt_engineer.core.default.disk_memory import DiskMemory
+from gpt_engineer.core.prompt import Prompt
 
 
 def test_human_review_input_no_concent_returns_none():
@@ -86,7 +87,7 @@ def test_extract_learning():
     memory.to_json.return_value = {"prompt": "prompt"}
 
     result = learning.extract_learning(
-        "prompt",
+        Prompt("prompt"),
         "model_name",
         0.01,
         ("prompt_tokens", "completion_tokens"),
EOF_114329324912

# Run only the specified test file with pytest inside poetry virtual environment
# Use poetry run to ensure correct environment activation
poetry run pytest -q --tb=short --disable-warnings --color=yes "tests/applications/cli/test_learning.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Revert test files to clean state after test run
git checkout 04c71d7d297447479d897b6803206210ed589d53 "tests/applications/cli/test_learning.py"