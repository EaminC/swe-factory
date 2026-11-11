#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout ba00896c5673990923abd0e99dba147938871512

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_benchmark_feedback.py b/tests/test_benchmark_feedback.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_benchmark_feedback.py
@@ -0,0 +1,41 @@
+import json
+import os
+import tempfile
+from pathlib import Path
+
+import pytest
+
+from scripts import benchmark
+
+def test_generate_report_creates_markdown_section(tmp_path):
+    # Setup a fake benchmark folder with memory/review file
+    bench_folder = tmp_path / "bench1"
+    memory_folder = bench_folder / "memory"
+    memory_folder.mkdir(parents=True)
+    review_data = {
+        "ran": True,
+        "works": False,
+        "perfect": True,
+        "comments": "Test comment"
+    }
+    review_file = memory_folder / "review"
+    review_file.write_text(json.dumps(review_data))
+
+    # Create a RESULTS.md file with a header
+    results_md = tmp_path / "RESULTS.md"
+    results_md.write_text("# Results\n\n")
+
+    # Patch ask_yes_no to always return False to avoid interactive input
+    benchmark.ask_yes_no = lambda question: False
+
+    # Run generate_report
+    benchmark.generate_report([(bench_folder, None, None)], tmp_path)
+
+    # Check that RESULTS.md content is unchanged (no append)
+    content = results_md.read_text()
+    assert content == "# Results\n\n"
+
+    # Check that to_emoji returns correct symbols
+    assert benchmark.to_emoji(True) == "\u2705"
+    assert benchmark.to_emoji(False) == "\u274C"
+
EOF_114329324912

# Activate python virtual environment and run only the specified test file with pytest
source /opt/testbed/bin/activate

pytest --no-header -rA --tb=short tests/test_benchmark_feedback.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout ba00896c5673990923abd0e99dba147938871512 tests/test_benchmark_feedback.py