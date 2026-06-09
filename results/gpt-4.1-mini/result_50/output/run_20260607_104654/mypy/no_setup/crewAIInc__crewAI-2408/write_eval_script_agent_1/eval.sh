#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file(s) to the exact commit state before patching
git checkout 4f6054d439c602f93283eda351fe6b67133b9a84 "tests/agent_test.py"

# Apply the provided test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/agent_test.py b/tests/agent_test.py
--- a/tests/agent_test.py
+++ b/tests/agent_test.py
@@ -72,9 +72,54 @@ def test_agent_creation():
     assert agent.role == "test role"
     assert agent.goal == "test goal"
     assert agent.backstory == "test backstory"
-    assert agent.tools == []
 
+def test_agent_with_only_system_template():
+    """Test that an agent with only system_template works without errors."""
+    agent = Agent(
+        role="Test Role",
+        goal="Test Goal",
+        backstory="Test Backstory",
+        allow_delegation=False,
+        system_template="You are a test agent...",
+        # prompt_template is intentionally missing
+    )
+
+    assert agent.role == "Test Role"
+    assert agent.goal == "Test Goal"
+    assert agent.backstory == "Test Backstory"
+
+def test_agent_with_only_prompt_template():
+    """Test that an agent with only system_template works without errors."""
+    agent = Agent(
+        role="Test Role",
+        goal="Test Goal",
+        backstory="Test Backstory",
+        allow_delegation=False,
+        prompt_template="You are a test agent...",
+        # prompt_template is intentionally missing
+    )
+
+    assert agent.role == "Test Role"
+    assert agent.goal == "Test Goal"
+    assert agent.backstory == "Test Backstory"
+
+
+def test_agent_with_missing_response_template():
+    """Test that an agent with system_template and prompt_template but no response_template works without errors."""
+    agent = Agent(
+        role="Test Role",
+        goal="Test Goal",
+        backstory="Test Backstory",
+        allow_delegation=False,
+        system_template="You are a test agent...",
+        prompt_template="This is a test prompt...",
+        # response_template is intentionally missing
+    )
 
+    assert agent.role == "Test Role"
+    assert agent.goal == "Test Goal"
+    assert agent.backstory == "Test Backstory"
+    
 def test_agent_default_values():
     agent = Agent(role="test role", goal="test goal", backstory="test backstory")
     assert agent.llm.model == "gpt-4o-mini"
EOF_114329324912

# Run only the specified test file(s) with pytest; concise output showing test names and results
# We use --tb=short for cleaner tracebacks and -rA to show summary of all tests (passed, failed, skipped)
pytest --tb=short -rA tests/agent_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the patched test files to original committed state
git checkout 4f6054d439c602f93283eda351fe6b67133b9a84 "tests/agent_test.py"