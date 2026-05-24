#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset target test files to exact commit version to ensure clean state
git checkout b992ee9d6b604993b3cc09ae366e314f68f78705 "tests/project_test.py"

# Apply test patch to update target test files
git apply -v - <<'EOF_114329324912'
diff --git a/tests/config/agents.yaml b/tests/config/agents.yaml
--- a/tests/config/agents.yaml
+++ b/tests/config/agents.yaml
@@ -8,6 +8,7 @@ researcher:
     developments in {topic}. Known for your ability to find the most relevant
     information and present it in a clear and concise manner.
   verbose: true
+  function_calling_llm: "local_llm"
 
 reporting_analyst:
   role: >
@@ -18,4 +19,5 @@ reporting_analyst:
     You're a meticulous analyst with a keen eye for detail. You're known for
     your ability to turn complex data into clear and concise reports, making
     it easy for others to understand and act on the information you provide.
-  verbose: true
\ No newline at end of file
+  verbose: true
+  function_calling_llm: "online_llm"
\ No newline at end of file
diff --git a/tests/project_test.py b/tests/project_test.py
--- a/tests/project_test.py
+++ b/tests/project_test.py
@@ -2,7 +2,16 @@
 
 from crewai.agent import Agent
 from crewai.crew import Crew
-from crewai.project import CrewBase, after_kickoff, agent, before_kickoff, crew, task
+from crewai.llm import LLM
+from crewai.project import (
+    CrewBase,
+    after_kickoff,
+    agent,
+    before_kickoff,
+    crew,
+    llm,
+    task,
+)
 from crewai.task import Task
 
 
@@ -31,6 +40,13 @@ class InternalCrew:
     agents_config = "config/agents.yaml"
     tasks_config = "config/tasks.yaml"
 
+    @llm
+    def local_llm(self):
+        return LLM(
+            model='openai/model_name',
+            api_key="None",
+            base_url="http://xxx.xxx.xxx.xxx:8000/v1")
+
     @agent
     def researcher(self):
         return Agent(config=self.agents_config["researcher"])
@@ -105,6 +121,20 @@ def test_task_name():
     ), "Custom task name is not being set as expected"
 
 
+def test_agent_function_calling_llm():
+    crew = InternalCrew()
+    llm = crew.local_llm()
+    obj_llm_agent = crew.researcher()
+    assert (
+        obj_llm_agent.function_calling_llm is llm
+    ), "agent's function_calling_llm is incorrect"
+
+    str_llm_agent = crew.reporting_analyst()
+    assert (
+        str_llm_agent.function_calling_llm.model == "online_llm"
+    ), "agent's function_calling_llm is incorrect"
+
+
 @pytest.mark.vcr(filter_headers=["authorization"])
 def test_before_kickoff_modification():
     crew = InternalCrew()
EOF_114329324912

# Activate the Python virtual environment for running tests
source /opt/testbed/bin/activate

# Run only the specified Python test file with pytest via "uv run" as recommended
uv run pytest tests/project_test.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test files after running tests to keep repo clean
git checkout b992ee9d6b604993b3cc09ae366e314f68f78705 "tests/project_test.py"