#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to original state before patching
git checkout 676299dc0aa02a088b5be43723023ad8fae6464b "src/backend/tests/unit/components/languagemodels/test_chatollama_component.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate the virtual environment and run pytest on the specified test file only,
# output concise info with test file name and status, suppress unnecessary info
source /opt/testbed/bin/activate

uv run pytest "src/backend/tests/unit/components/languagemodels/test_chatollama_component.py" -rA --tb=short --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file after running tests
git checkout 676299dc0aa02a088b5be43723023ad8fae6464b "src/backend/tests/unit/components/languagemodels/test_chatollama_component.py"