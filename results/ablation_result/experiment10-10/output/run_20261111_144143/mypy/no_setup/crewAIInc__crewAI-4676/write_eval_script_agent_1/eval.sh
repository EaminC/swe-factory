#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout e7f17d228429e7c9dc997d1ff0fd19a7c9078d9b

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_gemini_thinking_output.py b/tests/test_gemini_thinking_output.py
new file mode 100644
index 0000000000..e69de29bb2
--- /dev/null
+++ b/tests/test_gemini_thinking_output.py
@@ -0,0 +1,30 @@
+import pytest
+from crewai.llms.providers.gemini.completion import GeminiCompletion
+from crewai.events.types.llm_events import LLMThinkingChunkEvent
+
+
+class DummyEventBus:
+    def __init__(self):
+        self.emitted_events = []
+    def emit(self, sender, event):
+        self.emitted_events.append(event)
+
+
+def test_gemini_thinking_chunk_event_emitted(monkeypatch):
+    # Patch the global event bus to capture emitted events
+    dummy_bus = DummyEventBus()
+    monkeypatch.setattr('crewai.llms.base_llm.crewai_event_bus', dummy_bus)
+
+    # Create GeminiCompletion with thinking config enabled
+    gemini = GeminiCompletion(thinking_config=None)  # None triggers include_thoughts=True internally
+
+    # Emit a thinking chunk event
+    test_chunk = "This is a thought chunk"
+    gemini._emit_thinking_chunk_event(chunk=test_chunk, response_id="resp123")
+
+    # Verify that an LLMThinkingChunkEvent was emitted with correct chunk
+    events = dummy_bus.emitted_events
+    assert any(
+        isinstance(e, LLMThinkingChunkEvent) and e.chunk == test_chunk and e.response_id == "resp123"
+        for e in events
+    ), "LLMThinkingChunkEvent with correct chunk and response_id was not emitted"
EOF_114329324912

# Activate virtual environment
source /testbed/testbed/bin/activate

# Run only the specified target test file with pytest and configured verbosity and options summarized for concise output
pytest -vv --tb=short --maxfail=3 --disable-warnings tests/test_gemini_thinking_output.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified test file(s) back to commit state
git checkout e7f17d228429e7c9dc997d1ff0fd19a7c9078d9b tests/test_gemini_thinking_output.py