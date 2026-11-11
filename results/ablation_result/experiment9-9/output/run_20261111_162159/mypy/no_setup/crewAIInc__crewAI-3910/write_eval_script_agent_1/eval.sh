#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout c59173a762c7fa7fb1ccad8bee2596131db8f07b

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_azure_structured_output.py b/tests/test_azure_structured_output.py
new file mode 100644
index 0000000..b1c2d3f
--- /dev/null
+++ b/tests/test_azure_structured_output.py
@@ -0,0 +1,39 @@
+import os
+import pytest
+from pydantic import BaseModel
+from crewai import LLM, Agent
+
+class Greeting(BaseModel):
+    name: str
+    message: str
+
+@pytest.mark.skipif(
+    not (os.getenv("AZURE_API_KEY") and os.getenv("MYDEPLOYMENTURL")),
+    reason="Azure credentials not set",
+)
+def test_azure_llm_structured_response():
+    llm = LLM(
+        temperature=0,
+        model="azure/gpt-4.1-nano",
+        api_key=os.getenv("AZURE_API_KEY"),
+        endpoint=os.getenv("MYDEPLOYMENTURL"),
+        max_retries=1,
+    )
+
+    # Test direct call with response_model
+    response = llm.call("My name is Alice.", response_model=Greeting)
+    assert isinstance(response, Greeting)
+    assert response.name == "Alice"
+    assert isinstance(response.message, str) and len(response.message) > 0
+
+    # Test Agent kickoff with response_format
+    agent = Agent(
+        role="Greeter",
+        goal="Greet the user with a friendly message.",
+        backstory="An AI assistant that loves to greet people.",
+        llm=llm,
+    )
+    agent_response = agent.kickoff("My name is Alice.", response_format=Greeting)
+    assert isinstance(agent_response, Greeting)
+    assert agent_response.name == "Alice"
+    assert isinstance(agent_response.message, str) and len(agent_response.message) > 0
EOF_114329324912

# Activate the virtual environment
source /testbed/testbed/bin/activate

# Run only the specified target test file with pytest through the uv runner as per collected info
uv run pytest -v tests/test_azure_structured_output.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset changes to test file after test execution
git checkout c59173a762c7fa7fb1ccad8bee2596131db8f07b tests/test_azure_structured_output.py