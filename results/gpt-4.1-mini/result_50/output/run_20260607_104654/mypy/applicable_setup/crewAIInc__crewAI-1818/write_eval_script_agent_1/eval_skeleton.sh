#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout target test files to reset any changes
git checkout a548463faebd22aa3167a13ad417b4ab89776478 "tests/utilities/test_planning_handler.py" "tests/utilities/test_knowledge_planning.py"

# Apply test patch (replace [CONTENT OF TEST PATCH] with actual patch content at runtime)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the UV environment (virtual env is on PATH according to Dockerfile, just ensure)
# We are already in the correct environment with PATH set in Dockerfile,
# so no explicit activation required here.

# Run only the specified test files in one pytest invocation via uv run
uv run pytest tests/utilities/test_planning_handler.py tests/utilities/test_knowledge_planning.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test files to original state after testing
git checkout a548463faebd22aa3167a13ad417b4ab89776478 "tests/utilities/test_planning_handler.py" "tests/utilities/test_knowledge_planning.py"