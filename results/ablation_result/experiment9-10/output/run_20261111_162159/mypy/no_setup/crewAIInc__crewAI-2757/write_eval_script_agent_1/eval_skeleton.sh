#!/bin/bash
set -uxo pipefail
cd /testbed
git checkout 2912c93d77053c1f5e46bfcc67d09fbecf3221c6 

git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

source /testbed/venv/bin/activate

# Run only the specified test file, showing concise test results with file names and outcomes
uv run pytest -r a --tb=short tests/test_litellm_llama_api.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

git checkout 2912c93d77053c1f5e46bfcc67d09fbecf3221c6