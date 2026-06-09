#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout b6d668fc664c5f376626f06acdf48f9f462884e2 "tests/crew_test.py"

git apply -v - <<'EOF_114329324912'
diff --git a/tests/crew_test.py b/tests/crew_test.py
--- a/tests/crew_test.py
+++ b/tests/crew_test.py
@@ -15,6 +15,7 @@
 from crewai.crew import Crew
 from crewai.crews.crew_output import CrewOutput
 from crewai.knowledge.source.string_knowledge_source import StringKnowledgeSource
+from crewai.llm import LLM
 from crewai.memory.contextual.contextual_memory import ContextualMemory
 from crewai.process import Process
 from crewai.project import crew
@@ -3341,7 +3342,8 @@ def test_crew_testing_function(kickoff_mock, copy_mock, crew_evaluator):
     copy_mock.return_value = crew
 
     n_iterations = 2
-    crew.test(n_iterations, openai_model_name="gpt-4o-mini", inputs={"topic": "AI"})
+    llm_instance = LLM('gpt-4o-mini')
+    crew.test(n_iterations, llm_instance, inputs={"topic": "AI"})
 
     # Ensure kickoff is called on the copied crew
     kickoff_mock.assert_has_calls(
@@ -3350,7 +3352,7 @@ def test_crew_testing_function(kickoff_mock, copy_mock, crew_evaluator):
 
     crew_evaluator.assert_has_calls(
         [
-            mock.call(crew, "gpt-4o-mini"),
+            mock.call(crew,llm_instance),
             mock.call().set_iteration(1),
             mock.call().set_iteration(2),
             mock.call().print_crew_evaluation_result(),
EOF_114329324912

# Activate UV venv 'testbed' and run only the specified test file with pytest via uv
# Output test names and pass/fail/skip with concise but informative pytest options
source ~/.bashrc
uv activate testbed
uv run pytest -r a --tb=short --capture=no tests/crew_test.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout b6d668fc664c5f376626f06acdf48f9f462884e2 "tests/crew_test.py"