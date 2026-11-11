#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 67d56f93a45e712e924f5334119779c93830e208

# Apply test patch (content replaced at runtime)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified test file with coverage reporting as per context info
uv run pytest python/valuecell/core/super_agent/tests/test_openai_compatible_provider.py --cov=valuecell.core --cov-report=xml --cov-report=term
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file to clean any changes from patch application
git checkout 67d56f93a45e712e924f5334119779c93830e208 python/valuecell/core/super_agent/tests/test_openai_compatible_provider.py