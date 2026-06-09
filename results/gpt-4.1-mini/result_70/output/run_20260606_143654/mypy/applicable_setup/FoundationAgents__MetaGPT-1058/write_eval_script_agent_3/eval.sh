#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

# Ensure pytest is installed
pip install pytest

cd /testbed

# Reset target test file before patching
git checkout adb42f44d65a3fd9468c2919a1557e1c3751759d "tests/mock/mock_llm.py"

# Prepare valid mock configuration for API key to avoid validation error
mkdir -p ~/.metagpt/
cat > ~/.metagpt/config2.yaml << EOF
llm:
  api_key: "mocked_api_key_for_testing"
  api_type: "openai"
  model: "gpt-3.5-turbo"
  base_url: "https://api.openai.com/v1"
EOF

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/mock/mock_llm.py b/tests/mock/mock_llm.py
--- a/tests/mock/mock_llm.py
+++ b/tests/mock/mock_llm.py
@@ -8,7 +8,6 @@
 from metagpt.provider.constant import GENERAL_FUNCTION_SCHEMA
 from metagpt.provider.openai_api import OpenAILLM
 from metagpt.schema import Message
-from metagpt.utils.common import process_message
 
 OriginalLLM = OpenAILLM if config.llm.api_type == LLMType.OPENAI else AzureOpenAILLM
 
@@ -105,7 +104,7 @@ async def aask_batch(self, msgs: list, timeout=3) -> str:
         return rsp
 
     async def aask_code(self, messages: Union[str, Message, list[dict]], **kwargs) -> dict:
-        msg_key = json.dumps(process_message(messages), ensure_ascii=False)
+        msg_key = json.dumps(self.format_msg(messages), ensure_ascii=False)
         rsp = await self._mock_rsp(msg_key, self.original_aask_code, messages, **kwargs)
         return rsp
 
EOF_114329324912

# Run only the specified test file with concise output
python -m pytest --maxfail=1 --disable-warnings --no-header -rA --tb=no -p no:cacheprovider tests/mock/mock_llm.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to original state after tests
git checkout adb42f44d65a3fd9468c2919a1557e1c3751759d "tests/mock/mock_llm.py"