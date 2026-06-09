#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Reset the specified test file to the target commit state
git checkout 7dac88a3f8e8c0610e9e3189c867b19d055dab2d "tests/test_chat_to_files.py"

# Apply test patch (content replaced during execution)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_chat_to_files.py b/tests/test_chat_to_files.py
--- a/tests/test_chat_to_files.py
+++ b/tests/test_chat_to_files.py
@@ -13,7 +13,7 @@ class DummyDBs:
     project_metadata = {}
 
 
-def test_to_files():
+def test_to_files_and_memory():
     chat = textwrap.dedent(
         """
     This is a sample program.
EOF_114329324912

# Run only the target test file with pytest
pytest --no-header -rA --tb=short -p no:cacheprovider tests/test_chat_to_files.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the modified test file to clean state after tests
git checkout 7dac88a3f8e8c0610e9e3189c867b19d055dab2d "tests/test_chat_to_files.py"