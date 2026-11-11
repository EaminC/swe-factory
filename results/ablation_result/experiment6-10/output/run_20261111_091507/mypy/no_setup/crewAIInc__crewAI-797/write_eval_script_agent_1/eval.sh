#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 377f919d42724744908fa0bcca5cf76826685e07

# Apply the provided test patch
git apply -v - <<'EOF_114329324912'
diff --git a/lib/crewai/tests/crew/test_manager_agent_verbose.py b/lib/crewai/tests/crew/test_manager_agent_verbose.py
new file mode 100644
index 00000000..e69de29bb
--- /dev/null
+++ b/lib/crewai/tests/crew/test_manager_agent_verbose.py
@@ -0,0 +1,34 @@
+import pytest
+from crewai.crew import Crew
+from crewai.agents.agent import Agent
+from crewai.agents.agent_tools import AgentTools
+
+class DummyI18n:
+    @staticmethod
+    def retrieve(key, field):
+        return f"{key}_{field}"
+
+class DummyLLM:
+    pass
+
+def test_manager_agent_verbose_flag():
+    # Setup crew with verbose=False
+    crew = Crew(
+        agents=[],
+        verbose=False,
+        manager_llm=DummyLLM(),
+    )
+    # Patch i18n to dummy
+    crew.i18n = DummyI18n
+    # Create manager agent as in hierarchical process
+    manager = Agent(
+        role=crew.i18n.retrieve("hierarchical_manager_agent", "role"),
+        goal=crew.i18n.retrieve("hierarchical_manager_agent", "goal"),
+        backstory=crew.i18n.retrieve("hierarchical_manager_agent", "backstory"),
+        tools=AgentTools(agents=crew.agents).tools(),
+        llm=crew.manager_llm,
+        verbose=crew.verbose,
+    )
+    # Assert verbose is False as crew.verbose
+    assert manager.verbose is False
+
EOF_114329324912

# Run only the specified test file using poetry run pytest, outputting concise results
poetry run pytest --tb=short -q --disable-warnings lib/crewai/tests/crew/test_manager_agent_verbose.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file(s) back to original state
git checkout 377f919d42724744908fa0bcca5cf76826685e07 lib/crewai/tests/crew/test_manager_agent_verbose.py