#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test file to the committed state before applying patch
git checkout 37979a0ca1ab7c657ed005fdfeabacaa1a7a3568 ".github/workflows/tests.yml"

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/.github/workflows/tests.yml b/.github/workflows/tests.yml
--- a/.github/workflows/tests.yml
+++ b/.github/workflows/tests.yml
@@ -12,6 +12,9 @@ jobs:
   tests:
     runs-on: ubuntu-latest
     timeout-minutes: 15
+    strategy:
+      matrix:
+        python-version: ['3.10', '3.11', '3.12']
     steps:
       - name: Checkout code
         uses: actions/checkout@v4
@@ -21,9 +24,8 @@ jobs:
         with:
           enable-cache: true
 
-
-      - name: Set up Python
-        run: uv python install 3.12.8
+      - name: Set up Python ${{ matrix.python-version }}
+        run: uv python install ${{ matrix.python-version }}
 
       - name: Install the project
         run: uv sync --dev --all-extras
diff --git a/tests/memory/external/test_external_memory.py b/tests/memory/external/external_memory_test.py
similarity index 100%
rename from tests/memory/external/test_external_memory.py
rename to tests/memory/external/external_memory_test.py
EOF_114329324912

# Activate the correct virtual environment and run the specified test file using uv run pytest
source /testbed/.venv/bin/activate
uv run pytest -rA --tb=short --disable-warnings ".github/workflows/tests.yml"
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset target test file to committed state after test run
git checkout 37979a0ca1ab7c657ed005fdfeabacaa1a7a3568 ".github/workflows/tests.yml"