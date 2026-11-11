#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 2b8e056d5d4d14665b88a01c41356253c94b9259

git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_token_usage_log.py b/tests/test_token_usage_log.py
new file mode 100644
index 0000000..f3a7b1c
--- /dev/null
+++ b/tests/test_token_usage_log.py
@@ -0,0 +1,50 @@
+import pytest
+from gpt_engineer.ai import AI
+
+def test_token_usage_log_accumulates_and_records():
+    ai = AI(model="gpt-4", temperature=0.1)
+    # Start with first step
+    messages1 = [
+        {"role": "system", "content": "You are a helpful assistant."},
+        {"role": "user", "content": "Hello, how are you?"},
+    ]
+    # Simulate first call
+    result1 = ai.next(messages1, step_name="step1")
+    # There should be one log entry
+    assert len(ai.token_usage_log) == 1
+    log1 = ai.token_usage_log[0]
+    assert log1.step_name == "step1"
+    # Tokens used in step should be positive
+    assert log1.in_step_prompt_tokens > 0
+    assert log1.in_step_completion_tokens >= 0
+    assert log1.in_step_total_tokens == log1.in_step_prompt_tokens + log1.in_step_completion_tokens
+    # Cumulative tokens should match
+    assert log1.total_prompt_tokens == log1.in_step_prompt_tokens
+    assert log1.total_completion_tokens == log1.in_step_completion_tokens
+    assert log1.total_tokens == log1.in_step_total_tokens
+
+    # Simulate second call with additional prompt
+    messages2 = [
+        {"role": "system", "content": "You are a helpful assistant."},
+        {"role": "user", "content": "What is the weather today?"},
+    ]
+    result2 = ai.next(messages2, step_name="step2")
+    assert len(ai.token_usage_log) == 2
+    log2 = ai.token_usage_log[1]
+    assert log2.step_name == "step2"
+    # Tokens in step positive
+    assert log2.in_step_prompt_tokens > 0
+    assert log2.in_step_completion_tokens >= 0
+    assert log2.in_step_total_tokens == log2.in_step_prompt_tokens + log2.in_step_completion_tokens
+    # Cumulative tokens should increase
+    assert log2.total_prompt_tokens >= log1.total_prompt_tokens
+    assert log2.total_completion_tokens >= log1.total_completion_tokens
+    assert log2.total_tokens >= log1.total_tokens
+
+    # The formatted log string contains both steps
+    formatted = ai.format_token_usage_log()
+    assert "step1" in formatted
+    assert "step2" in formatted
+    # The formatted string has lines equal to number of logs + header
+    assert formatted.count('\n') == len(ai.token_usage_log) + 1
+
EOF_114329324912

# Run only the specified test file using globally installed packages
pytest --tb=short -rA tests/test_token_usage_log.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"