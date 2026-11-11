#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 0e4b1ffbc3a9d2ac3a4d0d381766b9d929e42dad

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/python/valuecell/server/api/routers/tests/test_user_profile_api.py b/python/valuecell/server/api/routers/tests/test_user_profile_api.py
new file mode 100644
index 0000000..e1a2b3c
--- /dev/null
+++ b/python/valuecell/server/api/routers/tests/test_user_profile_api.py
@@ -0,0 +1,46 @@
+import pytest
+from fastapi.testclient import TestClient
+from python.valuecell.server.api.routers.user_profile import create_user_profile_router
+from fastapi import FastAPI
+
+app = FastAPI()
+app.include_router(create_user_profile_router())
+
+client = TestClient(app)
+
+def test_create_and_get_user_profile():
+    # Create a user profile with a valid category
+    response = client.post(
+        "/user_profiles/",
+        json={
+            "user_id": "testuser",
+            "category": "normal",
+            "content": "This is a test profile content."
+        },
+    )
+    assert response.status_code == 200
+    data = response.json()
+    assert data["success"] is True
+    assert "profile_id" in data
+
+    # Get profiles filtered by the same category
+    response = client.get("/user_profiles/?category=normal")
+    assert response.status_code == 200
+    data = response.json()
+    assert data["success"] is True
+    profiles = data["data"]
+    assert any(p["category"] == "normal" and p["content"] == "This is a test profile content." for p in profiles)
+
+def test_create_user_profile_invalid_category():
+    # Try to create a profile with an invalid category
+    response = client.post(
+        "/user_profiles/",
+        json={
+            "user_id": "testuser",
+            "category": "invalid_category",
+            "content": "Invalid category test"
+        },
+    )
+    assert response.status_code == 400
+    assert "category" in response.text
+
EOF_114329324912

# Activate the python virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file using uv run pytest from the python folder
# This ensures only target tests execute, printing concise status of the tests
uv run pytest server/api/routers/tests/test_user_profile_api.py --tb=short -q --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modification to keep repo clean
git checkout 0e4b1ffbc3a9d2ac3a4d0d381766b9d929e42dad server/api/routers/tests/test_user_profile_api.py