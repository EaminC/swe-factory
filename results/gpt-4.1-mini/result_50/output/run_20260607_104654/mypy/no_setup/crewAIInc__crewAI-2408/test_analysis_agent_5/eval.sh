#!/bin/bash
set -uxo pipefail
cd /testbed

# Reset the target test file to the committed state before applying patch
git checkout 4f6054d439c602f93283eda351fe6b67133b9a84 "tests/agent_test.py"

# Apply test patch
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

# Activate the correct Python 3.11 virtual environment and run the specified test file without creating new environments
source /testbed/testbed_venv/bin/activate

# Export required environment variables to avoid auth errors and telemetry interference
export OPENAI_API_KEY="test_api_key_placeholder"
export SERPER_API_KEY="test_api_key_placeholder"
export OTEL_SDK_DISABLED=true

# Run tests using python interpreter and pytest from the activated venv to avoid uv creating new envs
pytest -rA --tb=short --disable-warnings tests/agent_test.py
rc=$?

# Echo exit code for evaluation
echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file to committed state after test run
git checkout 4f6054d439c602f93283eda351fe6b67133b9a84 "tests/agent_test.py"