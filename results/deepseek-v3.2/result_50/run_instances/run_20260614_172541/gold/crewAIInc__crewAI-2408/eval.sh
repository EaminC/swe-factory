#!/bin/bash
set -uxo pipefail

# Activate the virtual environment
source /testbed/.venv/bin/activate

# Navigate to the testbed directory
cd /testbed

# First, verify the test file exists at the expected location
echo "Checking test file location..."
if [ -f "tests/agent_test.py" ]; then
    echo "Test file found at: tests/agent_test.py"
    TEST_PATH="tests/agent_test.py"
else
    echo "Searching for agent_test.py in the repository..."
    TEST_PATH=$(find /testbed -name "agent_test.py" -type f | head -1)
    if [ -z "$TEST_PATH" ]; then
        echo "ERROR: agent_test.py not found in the repository!"
        exit 1
    fi
    echo "Test file found at: $TEST_PATH"
    # Get relative path from testbed
    TEST_PATH=$(realpath --relative-to=/testbed "$TEST_PATH")
fi

# Reset the specific test file to the original commit state
git checkout 4f6054d439c602f93283eda351fe6b67133b9a84 "$TEST_PATH"

# Apply the test patch (placeholder will be replaced during execution)
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

# Set VCR mode to "none" to prevent recording attempts
export VCR_MODE="none"

# Run the entire test file without specifying a class (since tests are standalone functions)
# The test patch should handle skipping network-dependent tests
echo "Running tests from: $TEST_PATH"
uv run pytest "$TEST_PATH" -vv \
    --tb=short \
    --disable-warnings \
    -p no:vcr
rc=$?

# Output the exit code for the judge
echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the test file to its original state
git checkout 4f6054d439c602f93283eda351fe6b67133b9a84 "$TEST_PATH"