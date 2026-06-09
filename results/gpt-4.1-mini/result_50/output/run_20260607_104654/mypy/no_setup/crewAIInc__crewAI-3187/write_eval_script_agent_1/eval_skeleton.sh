#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout 2ab79a7dd5623fe3adde03469afb61caefed528b "tests/storage/test_mem0_storage.py"

# Apply test patch (replace [CONTENT OF TEST PATCH] with actual patch content at runtime)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

git checkout 2ab79a7dd5623fe3adde03469afb61caefed528b "tests/storage/test_mem0_storage.py"

# Export required environment variables
export OPENAI_API_KEY=""
export SERPER_API_KEY=""
export OPTIONAL_OTEL_SDK_DISABLED=true
export OPTIONAL_share_crew=true

# Run only the specified test file with uv run pytest, show concise output with test statuses
uv run pytest tests/storage/test_mem0_storage.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"