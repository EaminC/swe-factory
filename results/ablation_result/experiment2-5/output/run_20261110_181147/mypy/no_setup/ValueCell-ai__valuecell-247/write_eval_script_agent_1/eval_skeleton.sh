#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout 146faeb125cb123d94ee9393db4513d2e5d113aa 

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate Python venv environment
source /testbed/venv/bin/activate

# Run only the specified test file using the uv run pytest command template
uv run pytest ./python/valuecell/adapters/models/tests/test_openai_provider.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: revert changes made by patch to keep repo clean after tests
git checkout 146faeb125cb123d94ee9393db4513d2e5d113aa "python/valuecell/adapters/models/tests/test_openai_provider.py"