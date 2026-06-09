#!/bin/bash
set -uxo pipefail

# Activate the conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate metagpt

cd /testbed

# Ensure the target test file is at the expected commit state
git checkout ab846f65e481a655b791959eb0f89fb4b1c84128 "tests/metagpt/provider/test_bedrock_api.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/metagpt/provider/test_bedrock_api.py b/tests/metagpt/provider/test_bedrock_api.py
--- a/tests/metagpt/provider/test_bedrock_api.py
+++ b/tests/metagpt/provider/test_bedrock_api.py
@@ -3,7 +3,7 @@
 import pytest
 
 from metagpt.provider.bedrock.utils import (
-    NOT_SUUPORT_STREAM_MODELS,
+    NOT_SUPPORT_STREAM_MODELS,
     SUPPORT_STREAM_MODELS,
 )
 from metagpt.provider.bedrock_api import BedrockLLM
@@ -14,7 +14,7 @@
 )
 
 # all available model from bedrock
-models = SUPPORT_STREAM_MODELS | NOT_SUUPORT_STREAM_MODELS
+models = SUPPORT_STREAM_MODELS | NOT_SUPPORT_STREAM_MODELS
 messages = [{"role": "user", "content": "Hi!"}]
 usage = {
     "prompt_tokens": 1000000,
EOF_114329324912

# Run pytest only on the requested test file with concise output but showing test file and summary
# Include parameters for coverage as originally indicated but limited to the single test file
pytest "tests/metagpt/provider/test_bedrock_api.py" --continue-on-collection-errors --doctest-modules --cov=./metagpt/ --cov-report=xml:cov.xml --cov-report=html:htmlcov --durations=20 | tee unittest.txt
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to original committed state to clean up any patch
git checkout ab846f65e481a655b791959eb0f89fb4b1c84128 "tests/metagpt/provider/test_bedrock_api.py"