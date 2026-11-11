#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout f4d5eded95c65cfac06d78dea79dbe9459c4b9c0

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/python/valuecell/core/agent/tests/test_component_type_report.py b/python/valuecell/core/agent/tests/test_component_type_report.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/python/valuecell/core/agent/tests/test_component_type_report.py
@@ -0,0 +1,51 @@
+import pytest
+from datetime import datetime, timezone
+from python.third_party.TradingAgents.adapter.__main__ import (
+    ComponentType,
+    ReportComponentData
+)
+
+def test_report_component_data_fields():
+    now_str = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
+    data = ReportComponentData(
+        title="Test Report",
+        data="This is report content.",
+        url=None,
+        create_time=now_str
+    )
+    assert data.title == "Test Report"
+    assert data.data == "This is report content."
+    assert data.url is None
+    assert data.create_time == now_str
+
+def test_component_type_enum():
+    assert ComponentType.REPORT == "report"
+    assert ComponentType.PROFILE == "profile"
+
+@pytest.mark.asyncio
+async def test_streaming_component_generator_yields_report(monkeypatch):
+    # This test simulates the streaming.component_generator usage with ReportComponentData
+    from python.third_party.TradingAgents.adapter.__main__ import streaming
+
+    report_data = ReportComponentData(
+        title="Market Analysis Report",
+        data="Market is bullish.",
+        url=None,
+        create_time=datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
+    )
+
+    # We expect streaming.component_generator to be called with JSON and ComponentType.REPORT
+    # Patch streaming.component_generator to capture arguments
+    called = {}
+    def fake_component_generator(json_str, comp_type):
+        called['json_str'] = json_str
+        called['comp_type'] = comp_type
+        yield json_str
+
+    monkeypatch.setattr(streaming, "component_generator", fake_component_generator)
+
+    gen = streaming.component_generator(report_data.model_dump_json(), ComponentType.REPORT)
+    output = [chunk async for chunk in gen]
+    assert called['comp_type'] == ComponentType.REPORT
+    assert 'Market Analysis Report' in called['json_str']
+    assert output[0] == called['json_str']
EOF_114329324912

# Run only the specified test file using the given test command for specific test file
uv run pytest python/valuecell/core/agent/tests/test_component_type_report.py --tb=short -rA
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset any changes after test run
git checkout f4d5eded95c65cfac06d78dea79dbe9459c4b9c0 python/valuecell/core/agent/tests/test_component_type_report.py