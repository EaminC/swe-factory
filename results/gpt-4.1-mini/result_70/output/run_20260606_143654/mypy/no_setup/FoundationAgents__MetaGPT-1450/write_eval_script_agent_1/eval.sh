#!/bin/bash
set -uxo pipefail

cd /testbed
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

# Activate virtual environment
source /opt/venv/bin/activate

# Ensure metagpt config directory and config file copied before test run
export ALLOW_OPENAI_API_CALL=0
mkdir -p ~/.metagpt
cp tests/config2.yaml ~/.metagpt/config2.yaml

# Run only the target test file with pytest showing concise results on file level
pytest -rA --tb=short --disable-warnings tests/metagpt/provider/test_bedrock_api.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Clean up by resetting the patched test file
git checkout ab846f65e481a655b791959eb0f89fb4b1c84128 "tests/metagpt/provider/test_bedrock_api.py"