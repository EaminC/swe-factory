#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Reset target test file to the committed state before patching
git checkout 8b209d4e17ad7dfc1ad7a80505eac42f71228734 "tests/metagpt/provider/test_ollama_api.py"

# Apply test patch (content will be replaced programmatically)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/metagpt/provider/test_ollama_api.py b/tests/metagpt/provider/test_ollama_api.py
--- a/tests/metagpt/provider/test_ollama_api.py
+++ b/tests/metagpt/provider/test_ollama_api.py
@@ -3,11 +3,11 @@
 # @Desc   : the unittest of ollama api
 
 import json
-from typing import Any, Tuple
+from typing import Any, AsyncGenerator, Tuple
 
 import pytest
 
-from metagpt.provider.ollama_api import OllamaLLM
+from metagpt.provider.ollama_api import OllamaLLM, OpenAIResponse
 from tests.metagpt.provider.mock_llm_config import mock_llm_config
 from tests.metagpt.provider.req_resp_const import (
     llm_general_chat_funcs_test,
@@ -23,21 +23,19 @@
 async def mock_ollama_arequest(self, stream: bool = False, **kwargs) -> Tuple[Any, Any, bool]:
     if stream:
 
-        class Iterator(object):
+        async def async_event_generator() -> AsyncGenerator[Any, None]:
             events = [
                 b'{"message": {"role": "assistant", "content": "I\'m ollama"}, "done": false}',
                 b'{"prompt_eval_count": 20, "eval_count": 20, "done": true}',
             ]
+            for event in events:
+                yield OpenAIResponse(event, {})
 
-            async def __aiter__(self):
-                for event in self.events:
-                    yield event
-
-        return Iterator(), None, None
+        return async_event_generator(), None, None
     else:
         raw_default_resp = default_resp.copy()
         raw_default_resp.update({"prompt_eval_count": 20, "eval_count": 20})
-        return json.dumps(raw_default_resp).encode(), None, None
+        return OpenAIResponse(json.dumps(raw_default_resp).encode(), {}), None, None
 
 
 @pytest.mark.asyncio
EOF_114329324912

# Run only the specified test file with verbose output of test file statuses,
# using pytest as recommended but limited to our target test path.
# We add --maxfail=1 --disable-warnings to keep output concise but informative.
pytest --continue-on-collection-errors --doctest-modules --cov=./metagpt/ --cov-report=xml:cov.xml --cov-report=html:htmlcov --durations=20 "tests/metagpt/provider/test_ollama_api.py" | tee unittest.txt
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to original state after tests
git checkout 8b209d4e17ad7dfc1ad7a80505eac42f71228734 "tests/metagpt/provider/test_ollama_api.py"