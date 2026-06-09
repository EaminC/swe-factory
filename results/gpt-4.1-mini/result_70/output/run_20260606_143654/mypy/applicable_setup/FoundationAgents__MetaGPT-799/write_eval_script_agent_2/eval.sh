#!/bin/bash
set -uxo pipefail

source /opt/conda/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Reset the target test file to the committed state before patch
git checkout 59afc5301f55037e7b379497767f4af62fd65b31 "tests/metagpt/utils/test_repair_llm_raw_output.py"

# Apply the test patch to update target tests
git apply -v - <<'EOF_114329324912'
diff --git a/tests/metagpt/utils/test_repair_llm_raw_output.py b/tests/metagpt/utils/test_repair_llm_raw_output.py
--- a/tests/metagpt/utils/test_repair_llm_raw_output.py
+++ b/tests/metagpt/utils/test_repair_llm_raw_output.py
@@ -141,6 +141,32 @@ def test_repair_json_format():
     output = repair_llm_raw_output(output=raw_output, req_keys=[None], repair_type=RepairType.JSON)
     assert output == target_output
 
+    raw_output = """
+{
+    "Language": "en_us",  // define language
+    "Programming Language": "Python" # define code language
+}
+"""
+    target_output = """{
+    "Language": "en_us",  
+    "Programming Language": "Python"
+}"""
+    output = repair_llm_raw_output(output=raw_output, req_keys=[None], repair_type=RepairType.JSON)
+    assert output == target_output
+
+    raw_output = """
+    {
+        "Language": "#en_us#",  // define language
+        "Programming Language": "//Python # Code // Language//" # define code language
+    }
+    """
+    target_output = """{
+        "Language": "#en_us#",  
+        "Programming Language": "//Python # Code // Language//"
+    }"""
+    output = repair_llm_raw_output(output=raw_output, req_keys=[None], repair_type=RepairType.JSON)
+    assert output == target_output
+
 
 def test_repair_invalid_json():
     from metagpt.utils.repair_llm_raw_output import repair_invalid_json
EOF_114329324912

# Run only the specified test file with concise output showing pass/fail/skip of each test in that file
pytest -q --tb=short --disable-warnings --maxfail=1 tests/metagpt/utils/test_repair_llm_raw_output.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the test file to the committed state after tests to clean up
git checkout 59afc5301f55037e7b379497767f4af62fd65b31 "tests/metagpt/utils/test_repair_llm_raw_output.py"