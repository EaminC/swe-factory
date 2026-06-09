#!/bin/bash
set -uxo pipefail

cd /testbed

# Ensure the target test file is at the correct commit version before patch
git checkout 4c55a976c677202cdca6a51da8dbd326de650f9c "tests/metagpt/roles/test_researcher.py"

# Apply the test patch from stdin (placeholder for actual patch content)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/metagpt/roles/test_researcher.py b/tests/metagpt/roles/test_researcher.py
--- a/tests/metagpt/roles/test_researcher.py
+++ b/tests/metagpt/roles/test_researcher.py
@@ -1,3 +1,4 @@
+import tempfile
 from pathlib import Path
 from random import random
 from tempfile import TemporaryDirectory
@@ -6,6 +7,7 @@
 
 from metagpt.actions.research import CollectLinks
 from metagpt.roles import researcher
+from metagpt.team import Team
 from metagpt.tools import SearchEngineType
 from metagpt.tools.search_engine import SearchEngine
 
@@ -57,5 +59,13 @@ def test_write_report(mocker, context):
             assert (researcher.RESEARCH_PATH / f"{i+1}. metagpt.md").read_text().startswith("# Research Report")
 
 
+@pytest.mark.asyncio
+async def test_serialize():
+    team = Team()
+    team.hire([researcher.Researcher()])
+    with tempfile.TemporaryDirectory() as dirname:
+        team.serialize(Path(dirname) / "team.json")
+
+
 if __name__ == "__main__":
     pytest.main([__file__, "-s"])
EOF_114329324912

# Activate the python virtual environment
source /opt/testbed/bin/activate

# Execute only the target test file with pytest and required options for concise output
pytest -v --tb=short tests/metagpt/roles/test_researcher.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to original state
git checkout 4c55a976c677202cdca6a51da8dbd326de650f9c "tests/metagpt/roles/test_researcher.py"