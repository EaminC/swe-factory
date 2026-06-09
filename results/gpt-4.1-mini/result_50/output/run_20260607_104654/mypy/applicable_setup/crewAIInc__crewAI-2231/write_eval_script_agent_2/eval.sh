#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout the specific commit version of the test file to ensure a clean state before applying patch
git checkout fbf87327841dd7b92bb04a23fd1575881a3ad3fa tests/flow_test.py

# Apply test patch (placeholder content will be replaced during evaluation)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/flow_test.py b/tests/flow_test.py
--- a/tests/flow_test.py
+++ b/tests/flow_test.py
@@ -654,3 +654,104 @@ def handle_flow_plot(source, event):
     assert isinstance(received_events[0], FlowPlotEvent)
     assert received_events[0].flow_name == "StatelessFlow"
     assert isinstance(received_events[0].timestamp, datetime)
+
+
+def test_multiple_routers_from_same_trigger():
+    """Test that multiple routers triggered by the same method all activate their listeners."""
+    execution_order = []
+
+    class MultiRouterFlow(Flow):
+        def __init__(self):
+            super().__init__()
+            # Set diagnosed conditions to trigger all routers
+            self.state["diagnosed_conditions"] = "DHA"  # Contains D, H, and A
+
+        @start()
+        def scan_medical(self):
+            execution_order.append("scan_medical")
+            return "scan_complete"
+
+        @router(scan_medical)
+        def diagnose_conditions(self):
+            execution_order.append("diagnose_conditions")
+            return "diagnosis_complete"
+
+        @router(diagnose_conditions)
+        def diabetes_router(self):
+            execution_order.append("diabetes_router")
+            if "D" in self.state["diagnosed_conditions"]:
+                return "diabetes"
+            return None
+
+        @listen("diabetes")
+        def diabetes_analysis(self):
+            execution_order.append("diabetes_analysis")
+            return "diabetes_analysis_complete"
+
+        @router(diagnose_conditions)
+        def hypertension_router(self):
+            execution_order.append("hypertension_router")
+            if "H" in self.state["diagnosed_conditions"]:
+                return "hypertension"
+            return None
+
+        @listen("hypertension")
+        def hypertension_analysis(self):
+            execution_order.append("hypertension_analysis")
+            return "hypertension_analysis_complete"
+
+        @router(diagnose_conditions)
+        def anemia_router(self):
+            execution_order.append("anemia_router")
+            if "A" in self.state["diagnosed_conditions"]:
+                return "anemia"
+            return None
+
+        @listen("anemia")
+        def anemia_analysis(self):
+            execution_order.append("anemia_analysis")
+            return "anemia_analysis_complete"
+
+    flow = MultiRouterFlow()
+    flow.kickoff()
+
+    # Verify all methods were called
+    assert "scan_medical" in execution_order
+    assert "diagnose_conditions" in execution_order
+
+    # Verify all routers were called
+    assert "diabetes_router" in execution_order
+    assert "hypertension_router" in execution_order
+    assert "anemia_router" in execution_order
+
+    # Verify all listeners were called - this is the key test for the fix
+    assert "diabetes_analysis" in execution_order
+    assert "hypertension_analysis" in execution_order
+    assert "anemia_analysis" in execution_order
+
+    # Verify execution order constraints
+    assert execution_order.index("diagnose_conditions") > execution_order.index(
+        "scan_medical"
+    )
+
+    # All routers should execute after diagnose_conditions
+    assert execution_order.index("diabetes_router") > execution_order.index(
+        "diagnose_conditions"
+    )
+    assert execution_order.index("hypertension_router") > execution_order.index(
+        "diagnose_conditions"
+    )
+    assert execution_order.index("anemia_router") > execution_order.index(
+        "diagnose_conditions"
+    )
+
+    # All analyses should execute after their respective routers
+    assert execution_order.index("diabetes_analysis") > execution_order.index(
+        "diabetes_router"
+    )
+    assert execution_order.index("hypertension_analysis") > execution_order.index(
+        "hypertension_router"
+    )
+    assert execution_order.index("anemia_analysis") > execution_order.index(
+        "anemia_router"
+    )
EOF_114329324912

# Activate the Python virtual environment from the correct path
source /testbed/.venv/bin/activate

# Confirm pytest is available and run pytest only on the specified test file with concise output,
# reporting file names and test result status without excessive debug info
pytest --version
pytest tests/flow_test.py -rA --tb=short
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to discard patch changes and any test side effects
git checkout fbf87327841dd7b92bb04a23fd1575881a3ad3fa tests/flow_test.py