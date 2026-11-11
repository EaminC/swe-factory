#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout e7f17d228429e7c9dc997d1ff0fd19a7c9078d9b

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment
source /testbed/testbed/bin/activate

# Install pytest and vcrpy explicitly to ensure required versions and avoid plugin conflicts
pip install pytest==8.4.2 vcrpy==7.0.0

# Run the specified test file with minimal pytest arguments to avoid unknown argument errors from plugins
pytest tests/test_gemini_thinking_output.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the test file if it exists
if git ls-files --error-unmatch tests/test_gemini_thinking_output.py > /dev/null 2>&1; then
    git checkout e7f17d228429e7c9dc997d1ff0fd19a7c9078d9b -- tests/test_gemini_thinking_output.py || true
fi