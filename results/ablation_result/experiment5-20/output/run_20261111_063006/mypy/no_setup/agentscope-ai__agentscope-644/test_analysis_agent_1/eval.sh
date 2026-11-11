#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout f93b928219f5218a93f1651dc7ba486794061860 "tests/reactv2_agent_with_mcp/test_streamable_http_client.py"

git apply -v - <<'EOF_114329324912'
diff --git a/tests/reactv2_agent_with_mcp/test_streamable_http_client.py b/tests/reactv2_agent_with_mcp/test_streamable_http_client.py
new file mode 100644
index 0000000000..e1a2b3c4d5
--- /dev/null
+++ b/tests/reactv2_agent_with_mcp/test_streamable_http_client.py
@@ -0,0 +1,33 @@
+import asyncio
+import pytest
+import httpx
+from starlette.testclient import TestClient
+
+from examples.reactv2_agent_with_mcp.code.mcp_servers import main_app
+
+
+@pytest.fixture(scope="module")
+def client():
+    with TestClient(main_app) as c:
+        yield c
+
+@pytest.mark.asyncio
+async def test_streamable_http_app_add_and_multiply(client):
+    # Test the SSE app returns expected result for add tool
+    response_add = client.get("/sse_app/sse", stream=True)
+    # We expect the SSE app to be reachable
+    assert response_add.status_code == 200
+
+    # Test the streamable_http_app multiply tool
+    async with httpx.AsyncClient(base_url="http://testserver") as async_client:
+        # Send a request to multiply tool endpoint
+        resp = await async_client.post(
+            "/streamable_http_app/mcp/multiply",
+            json={"a": 3, "b": 4},
+            timeout=5.0,
+        )
+        # The multiply tool should return 12
+        assert resp.status_code == 200
+        data = resp.json()
+        assert data == 12
+
EOF_114329324912

# Activate the virtual environment provided by the Docker image
source /opt/testbed/bin/activate

# Run only the specified test file using pytest with coverage, concise output, no header, showing all outcomes and short tracebacks
pytest --no-header -rA --tb=short --cov=agentscope tests/reactv2_agent_with_mcp/test_streamable_http_client.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to clean state
git checkout f93b928219f5218a93f1651dc7ba486794061860 "tests/reactv2_agent_with_mcp/test_streamable_http_client.py"