#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 4e496d7a202802917ad4f47eb9efdd6a41f06e18

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_concurrency.py b/tests/test_concurrency.py
new file mode 100644
index 00000000..e1a2b3c4
--- /dev/null
+++ b/tests/test_concurrency.py
@@ -0,0 +1,58 @@
+import pytest
+import threading
+import asyncio
+from concurrent.futures import ThreadPoolExecutor, as_completed
+from src.crewai.llm import FilteredStream
+
+
+class DummyAgent:
+    def crew(self):
+        return self
+    def kickoff(self, inputs):
+        # Simulate normal response
+        return f"response to {inputs}"
+    async def kickoff_async(self, inputs):
+        # Simulate async normal response
+        return f"async response to {inputs}"
+
+
+def test_filtered_stream_thread_safety():
+    stream = FilteredStream(original_stream=None)
+    results = []
+    def write_data():
+        for _ in range(100):
+            stream.write("test\n")
+            results.append(True)
+
+    threads = [threading.Thread(target=write_data) for _ in range(5)]
+    for t in threads:
+        t.start()
+    for t in threads:
+        t.join()
+    assert len(results) == 500
+
+
+@pytest.mark.asyncio
+async def test_async_concurrent_calls():
+    agent = DummyAgent()
+    sem = asyncio.Semaphore(5)
+
+    async def generate_response(payload):
+        async with sem:
+            return await agent.kickoff_async(inputs=payload)
+
+    payloads = [f"input{i}" for i in range(10)]
+    results = await asyncio.gather(*(generate_response(p) for p in payloads))
+    assert all(r.startswith("async response to input") for r in results)
+
+
+def test_threadpool_concurrent_calls():
+    agent = DummyAgent()
+    def generate_response(payload):
+        return agent.kickoff(inputs=payload)
+
+    payloads = [f"input{i}" for i in range(10)]
+    with ThreadPoolExecutor(max_workers=5) as executor:
+        futures = [executor.submit(generate_response, p) for p in payloads]
+        results = [f.result() for f in futures]
+    assert all(r.startswith("response to input") for r in results)
EOF_114329324912

# Activate python virtual environment
source /testbed/venv/bin/activate

# Run only the target test file with uv command and pytest
# Use -rA to show all test summary info and --tb=short to keep tracebacks concise
uv run pytest -rA --tb=short tests/test_concurrency.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout 4e496d7a202802917ad4f47eb9efdd6a41f06e18 tests/test_concurrency.py