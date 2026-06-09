#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Reset target test file to clean state before patching
git checkout ab846f65e481a655b791959eb0f89fb4b1c84128 "tests/metagpt/roles/test_role.py"

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/metagpt/roles/test_role.py b/tests/metagpt/roles/test_role.py
--- a/tests/metagpt/roles/test_role.py
+++ b/tests/metagpt/roles/test_role.py
@@ -5,6 +5,7 @@
 
 from metagpt.provider.human_provider import HumanProvider
 from metagpt.roles.role import Role
+from metagpt.schema import Message, UserMessage
 
 
 def test_role_desc():
@@ -18,5 +19,15 @@ def test_role_human(context):
     assert isinstance(role.llm, HumanProvider)
 
 
+@pytest.mark.asyncio
+async def test_recovered():
+    role = Role(profile="Tester", desc="Tester", recovered=True)
+    role.put_message(UserMessage(content="2"))
+    role.latest_observed_msg = Message(content="1")
+    await role._observe()
+    await role._observe()
+    assert role.rc.msg_buffer.empty()
+
+
 if __name__ == "__main__":
     pytest.main([__file__, "-s"])
EOF_114329324912

# Run only the specified test file with pytest and required options, showing concise summary and test statuses
pytest --doctest-modules --tb=short -rA --disable-warnings tests/metagpt/roles/test_role.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the file after test run to revert patch
git checkout ab846f65e481a655b791959eb0f89fb4b1c84128 "tests/metagpt/roles/test_role.py"