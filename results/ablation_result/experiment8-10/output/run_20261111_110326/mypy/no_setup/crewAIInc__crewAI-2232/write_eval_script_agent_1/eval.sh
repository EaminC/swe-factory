#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 34d299345677c7ce26b1368f240c559596526fa7

# Apply the test patch given via heredoc placeholder
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_knowledge_upsert.py b/tests/test_knowledge_upsert.py
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/tests/test_knowledge_upsert.py
@@ -0,0 +1,35 @@
+import pytest
+from crewai import Agent, Task, Crew, Process, LLM
+from crewai.knowledge.source.string_knowledge_source import StringKnowledgeSource
+
+def test_crew_knowledge_upsert():
+    content = "Users name is John. He is 30 years old and lives in San Francisco."
+    string_source = StringKnowledgeSource(content=content)
+
+    llm = LLM(model="gpt-4o-mini", temperature=0)
+
+    agent = Agent(
+        role="About User",
+        goal="You know everything about the user.",
+        backstory="You are a master at understanding people and their preferences.",
+        verbose=True,
+        allow_delegation=False,
+        llm=llm,
+    )
+
+    task = Task(
+        description="Answer the following questions about the user: {question}",
+        expected_output="An answer to the question.",
+        agent=agent,
+    )
+
+    crew = Crew(
+        agents=[agent],
+        tasks=[task],
+        verbose=True,
+        process=Process.sequential,
+        knowledge_sources=[string_source],
+    )
+
+    result = crew.kickoff(inputs={"question": "What city does John live in and how old is he?"})
+    assert "San Francisco" in result[0].lower() and "30" in result[0], "Output should mention San Francisco and 30"
EOF_114329324912

# Run only the specified test file using Poetry-managed venv with uv run pytest
# -rA shows summary of all tests with status
# --tb=short reduces traceback noise, but still informative
# --disable-warnings to reduce extraneous output
uv run pytest -rA --tb=short --disable-warnings -- tests/test_knowledge_upsert.py

rc=$?  # Capture pytest exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset repository state to discard patch and any test changes to files
git checkout 34d299345677c7ce26b1368f240c559596526fa7 "tests/test_knowledge_upsert.py"