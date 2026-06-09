#!/bin/bash
set -uxo pipefail

cd /testbed

# Ensure target test files are reset to original state before patching
git checkout a4dc5381b2cf31c507cc32f9027f76bf00d61ccc \
    "src/backend/tests/unit/test_custom_component.py" \
    "src/backend/tests/unit/test_database.py"

# Apply patch for the target tests
git apply -v - <<'EOF_114329324912'
diff --git a/src/backend/tests/unit/test_custom_component.py b/src/backend/tests/unit/test_custom_component.py
--- a/src/backend/tests/unit/test_custom_component.py
+++ b/src/backend/tests/unit/test_custom_component.py
@@ -400,6 +400,7 @@ def test_custom_component_get_function_entrypoint_args_no_args():
     the CustomComponent class with a build method with no arguments.
     """
     my_code = """
+from langflow.custom import CustomComponent
 class MyMainClass(CustomComponent):
     def build():
         pass"""
diff --git a/src/backend/tests/unit/test_database.py b/src/backend/tests/unit/test_database.py
--- a/src/backend/tests/unit/test_database.py
+++ b/src/backend/tests/unit/test_database.py
@@ -73,10 +73,11 @@ def test_read_flows(client: TestClient, json_flow: str, active_user, logged_in_h
     assert len(response.json()) > 0
 
 
-def test_read_flow(client: TestClient, json_flow: str, active_user, logged_in_headers):
+def test_read_flow(client: TestClient, json_flow: str, logged_in_headers):
     flow = orjson.loads(json_flow)
     data = flow["data"]
-    flow = FlowCreate(name="Test Flow", description="description", data=data)
+    unique_name = str(uuid4())
+    flow = FlowCreate(name=unique_name, description="description", data=data)
     response = client.post("api/v1/flows/", json=flow.model_dump(), headers=logged_in_headers)
     flow_id = response.json()["id"]  # flow_id should be a UUID but is a string
     # turn it into a UUID
EOF_114329324912

# Activate Poetry virtual environment
source /testbed/.venv/bin/activate

# Run only the specified target test files using poetry and pytest with recommended flags
poetry run pytest \
    src/backend/tests/unit/test_custom_component.py \
    src/backend/tests/unit/test_database.py \
    --instafail -ra -m "not api_key_required"

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified files after test run
git checkout a4dc5381b2cf31c507cc32f9027f76bf00d61ccc \
    "src/backend/tests/unit/test_custom_component.py" \
    "src/backend/tests/unit/test_database.py"