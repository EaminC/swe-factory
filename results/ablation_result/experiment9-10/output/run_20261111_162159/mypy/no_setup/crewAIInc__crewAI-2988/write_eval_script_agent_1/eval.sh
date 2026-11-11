#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 99133104dd1a3f77a8558aa882243d702893a1ca 

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_mem0_storage.py b/tests/test_mem0_storage.py
new file mode 100644
index 00000000..e3f1a2b7
--- /dev/null
+++ b/tests/test_mem0_storage.py
@@ -0,0 +1,41 @@
+import pytest
+from unittest.mock import MagicMock
+from src.crewai.memory.storage.mem0_storage import Mem0Storage
+
+class DummyCrew:
+    def __init__(self, agents):
+        self.agents = agents
+
+class DummyAgent:
+    def __init__(self, role):
+        self.role = role
+
+def test_agent_name_sanitization_and_add_memory(monkeypatch):
+    # Setup dummy crew with long agent role to test sanitization
+    long_role = 'a' * 300
+    crew = DummyCrew(agents=[DummyAgent(role=long_role)])
+
+    storage = Mem0Storage()
+    storage.crew = crew
+
+    # Patch _sanitize_role to return the role unchanged
+    storage._sanitize_role = lambda x: x
+
+    # The sanitized agent name should be truncated to 255 chars
+    agent_name = storage._get_agent_name()
+    assert len(agent_name) <= 255
+
+    # Patch MemoryClient.add to verify it is called with a list, not a string
+    called_args = {}
+    def fake_add(items):
+        called_args['items'] = items
+        return True
+
+    monkeypatch.setattr('mem0.MemoryClient.add', fake_add)
+
+    # Simulate adding memory with a list
+    storage.client = MagicMock()
+    storage.client.add = fake_add
+    storage.client.add(['memory1'])
+    assert isinstance(called_args['items'], list)
+
EOF_114329324912

# Activate virtual environment
source /testbed/testbed/bin/activate

# Run only the specified target test files with pytest using uv run as recommended
uv run pytest -q --tb=short tests/test_mem0_storage.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes made by the test patch
git checkout 99133104dd1a3f77a8558aa882243d702893a1ca