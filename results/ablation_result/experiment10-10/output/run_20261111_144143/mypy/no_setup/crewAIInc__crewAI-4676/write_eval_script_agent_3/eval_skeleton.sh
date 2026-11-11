#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout e7f17d228429e7c9dc997d1ff0fd19a7c9078d9b

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment
source /testbed/testbed/bin/activate

# Ensure required test dependencies are installed in the virtual environment
pip install pytest==8.4.2 vcrpy==7.0.0

# Run only the specified target test file with pytest using concise output and failfast options
pytest -vv --tb=short --maxfail=3 --disable-warnings tests/test_gemini_thinking_output.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# If the test file exists after patch application, reset it to original commit state to cleanup
if git ls-files --error-unmatch tests/test_gemini_thinking_output.py > /dev/null 2>&1; then
    git checkout e7f17d228429e7c9dc997d1ff0fd19a7c9078d9b -- tests/test_gemini_thinking_output.py || true
fi