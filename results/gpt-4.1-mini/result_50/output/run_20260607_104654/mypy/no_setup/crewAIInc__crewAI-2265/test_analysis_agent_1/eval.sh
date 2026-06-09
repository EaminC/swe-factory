#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test file to the commit version to ensure clean state
git checkout e1a73e0c44fd85b2ad34ca0a3eda57964c0dee4b "tests/crew_test.py"

# Apply the test patch to update target tests (placeholder for actual patch content)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/crew_test.py b/tests/crew_test.py
--- a/tests/crew_test.py
+++ b/tests/crew_test.py
@@ -11,7 +11,9 @@
 import pytest
 
 from crewai.agent import Agent
+from crewai.agents import CacheHandler
 from crewai.agents.cache import CacheHandler
+from crewai.agents.crew_agent_executor import CrewAgentExecutor
 from crewai.crew import Crew
 from crewai.crews.crew_output import CrewOutput
 from crewai.knowledge.source.string_knowledge_source import StringKnowledgeSource
@@ -4063,3 +4065,52 @@ def test_crew_with_knowledge_sources_works_with_copy():
     assert len(crew_copy.tasks) == len(crew.tasks)
 
     assert len(crew_copy.tasks) == len(crew.tasks)
+
+
+def test_crew_kickoff_for_each_works_with_manager_agent_copy():
+    researcher = Agent(
+        role="Researcher",
+        goal="Conduct thorough research and analysis on AI and AI agents",
+        backstory="You're an expert researcher, specialized in technology, software engineering, AI, and startups. You work as a freelancer and are currently researching for a new client.",
+        allow_delegation=False
+    )
+
+    writer = Agent(
+        role="Senior Writer",
+        goal="Create compelling content about AI and AI agents",
+        backstory="You're a senior writer, specialized in technology, software engineering, AI, and startups. You work as a freelancer and are currently writing content for a new client.",
+        allow_delegation=False
+    )
+
+    # Define task
+    task = Task(
+        description="Generate a list of 5 interesting ideas for an article, then write one captivating paragraph for each idea that showcases the potential of a full article on this topic. Return the list of ideas with their paragraphs and your notes.",
+        expected_output="5 bullet points, each with a paragraph and accompanying notes.",
+    )
+
+    # Define manager agent
+    manager = Agent(
+        role="Project Manager",
+        goal="Efficiently manage the crew and ensure high-quality task completion",
+        backstory="You're an experienced project manager, skilled in overseeing complex projects and guiding teams to success. Your role is to coordinate the efforts of the crew members, ensuring that each task is completed on time and to the highest standard.",
+        allow_delegation=True
+    )
+
+    # Instantiate crew with a custom manager
+    crew = Crew(
+        agents=[researcher, writer],
+        tasks=[task],
+        manager_agent=manager,
+        process=Process.hierarchical,
+        verbose=True
+    )
+
+    crew_copy = crew.copy()
+    assert crew_copy.manager_agent is not None
+    assert crew_copy.manager_agent.id != crew.manager_agent.id
+    assert crew_copy.manager_agent.role == crew.manager_agent.role
+    assert crew_copy.manager_agent.goal == crew.manager_agent.goal
+    assert crew_copy.manager_agent.backstory == crew.manager_agent.backstory
+    assert isinstance(crew_copy.manager_agent.agent_executor, CrewAgentExecutor)
+    assert isinstance(crew_copy.manager_agent.cache_handler, CacheHandler)
+
EOF_114329324912

# Activate the uv managed virtual environment and run only the specified test file with verbose output
source .venv/bin/activate
uv run pytest -vv tests/crew_test.py
rc=$?            # Save exit code of test run

echo "OMNIGRIL_EXIT_CODE=$rc" # Output test execution result

# Reset the target test file again after test run to clean up any changes
git checkout e1a73e0c44fd85b2ad34ca0a3eda57964c0dee4b "tests/crew_test.py"