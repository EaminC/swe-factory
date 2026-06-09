#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset target test files to the specified commit state
git checkout 4c43b4cc82e02dd0dd2d58992618195521bdc865 "tests/conftest.py" "tests/unit/test_messages.py"

# Apply the test patch (content replaced programmatically)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/conftest.py b/tests/conftest.py
--- a/tests/conftest.py
+++ b/tests/conftest.py
@@ -73,13 +73,6 @@ def get_text():
         assert path.exists(), f"File {path} does not exist. Available files: {list(data_path.iterdir())}"
 
 
-@pytest.fixture(autouse=True)
-def check_openai_api_key_in_environment_variables():
-    import os
-
-    assert os.environ.get("OPENAI_API_KEY") is not None, "OPENAI_API_KEY is not set in environment variables"
-
-
 @pytest.fixture()
 async def async_client() -> AsyncGenerator:
     from langflow.main import create_app
diff --git a/tests/unit/test_messages.py b/tests/unit/test_messages.py
--- a/tests/unit/test_messages.py
+++ b/tests/unit/test_messages.py
@@ -7,6 +7,7 @@
 from langflow.services.database.models.message import MessageCreate, MessageRead
 from langflow.services.database.models.message.model import MessageTable
 from langflow.services.deps import session_scope
+from langflow.services.tracing.utils import convert_to_langchain_type
 
 
 @pytest.fixture()
@@ -74,3 +75,28 @@ def test_store_message():
     stored_messages = store_message(message)
     assert len(stored_messages) == 1
     assert stored_messages[0].text == "Stored message"
+
+
+@pytest.mark.parametrize("method_name", ["message", "convert_to_langchain_type"])
+def test_convert_to_langchain(method_name):
+    def convert(value):
+        if method_name == "message":
+            return value.to_lc_message()
+        elif method_name == "convert_to_langchain_type":
+            return convert_to_langchain_type(value)
+        else:
+            raise ValueError(f"Invalid method: {method_name}")
+
+    lc_message = convert(Message(text="Test message 1", sender="User", sender_name="User", session_id="session_id2"))
+    assert lc_message.content == "Test message 1"
+    assert lc_message.type == "human"
+
+    lc_message = convert(Message(text="Test message 2", sender="AI", session_id="session_id2"))
+    assert lc_message.content == "Test message 2"
+    assert lc_message.type == "ai"
+
+    iterator = iter(["stream", "message"])
+    lc_message = convert(Message(text=iterator, sender="AI", session_id="session_id2"))
+    assert lc_message.content == ""
+    assert lc_message.type == "ai"
+    assert len(list(iterator)) == 2
EOF_114329324912

# Run only the specified test files using pytest
# Using pytest with no header, show all summary info and no traceback to keep output concise
# poetry is configured to not create venv; poetry run uses system environment
poetry run pytest --no-header -rA --tb=no "tests/conftest.py" "tests/unit/test_messages.py"
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset target test files to original commit state to clean up changes
git checkout 4c43b4cc82e02dd0dd2d58992618195521bdc865 "tests/conftest.py" "tests/unit/test_messages.py"