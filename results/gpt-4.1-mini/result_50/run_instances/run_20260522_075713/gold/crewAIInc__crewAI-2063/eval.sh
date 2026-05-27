#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to the committed version before applying patch
git checkout 6f4ad532e615a961ae7c5d57da48bb7209e3598b "tests/llm_test.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/llm_test.py b/tests/llm_test.py
--- a/tests/llm_test.py
+++ b/tests/llm_test.py
@@ -286,6 +286,79 @@ def test_o3_mini_reasoning_effort_medium():
 
 
 @pytest.mark.vcr(filter_headers=["authorization"])
+@pytest.fixture
+def anthropic_llm():
+    """Fixture providing an Anthropic LLM instance."""
+    return LLM(model="anthropic/claude-3-sonnet")
+
+@pytest.fixture
+def system_message():
+    """Fixture providing a system message."""
+    return {"role": "system", "content": "test"}
+
+@pytest.fixture
+def user_message():
+    """Fixture providing a user message."""
+    return {"role": "user", "content": "test"}
+
+def test_anthropic_message_formatting_edge_cases(anthropic_llm):
+    """Test edge cases for Anthropic message formatting."""
+    # Test None messages
+    with pytest.raises(TypeError, match="Messages cannot be None"):
+        anthropic_llm._format_messages_for_provider(None)
+        
+    # Test empty message list
+    formatted = anthropic_llm._format_messages_for_provider([])
+    assert len(formatted) == 1
+    assert formatted[0]["role"] == "user"
+    assert formatted[0]["content"] == "."
+    
+    # Test invalid message format
+    with pytest.raises(TypeError, match="Invalid message format"):
+        anthropic_llm._format_messages_for_provider([{"invalid": "message"}])
+
+def test_anthropic_model_detection():
+    """Test Anthropic model detection with various formats."""
+    models = [
+        ("anthropic/claude-3", True),
+        ("claude-instant", True),
+        ("claude/v1", True),
+        ("gpt-4", False),
+        ("", False),
+        ("anthropomorphic", False),  # Should not match partial words
+    ]
+    
+    for model, expected in models:
+        llm = LLM(model=model)
+        assert llm.is_anthropic == expected, f"Failed for model: {model}"
+
+def test_anthropic_message_formatting(anthropic_llm, system_message, user_message):
+    """Test Anthropic message formatting with fixtures."""
+    # Test when first message is system
+    formatted = anthropic_llm._format_messages_for_provider([system_message])
+    assert len(formatted) == 2
+    assert formatted[0]["role"] == "user"
+    assert formatted[0]["content"] == "."
+    assert formatted[1] == system_message
+
+    # Test when first message is already user
+    formatted = anthropic_llm._format_messages_for_provider([user_message])
+    assert len(formatted) == 1
+    assert formatted[0] == user_message
+
+    # Test with empty message list
+    formatted = anthropic_llm._format_messages_for_provider([])
+    assert len(formatted) == 1
+    assert formatted[0]["role"] == "user"
+    assert formatted[0]["content"] == "."
+
+    # Test with non-Anthropic model (should not modify messages)
+    non_anthropic_llm = LLM(model="gpt-4")
+    formatted = non_anthropic_llm._format_messages_for_provider([system_message])
+    assert len(formatted) == 1
+    assert formatted[0] == system_message
+
+
 def test_deepseek_r1_with_open_router():
     if not os.getenv("OPEN_ROUTER_API_KEY"):
         pytest.skip("OPEN_ROUTER_API_KEY not set; skipping test.")
EOF_114329324912

# Activate the virtual environment
source /opt/testbed/bin/activate

# Export required environment variables for authentication
export OPENAI_API_KEY="dummy_api_key_for_testing_purposes"
export SERPER_API_KEY="dummy_api_key_for_testing_purposes"

# Run only the specified test file with verbose output, no warnings
uv run pytest -v --tb=short --disable-warnings tests/llm_test.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to original state after test execution
git checkout 6f4ad532e615a961ae7c5d57da48bb7209e3598b "tests/llm_test.py"