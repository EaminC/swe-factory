#!/bin/bash
set -uxo pipefail

source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed
git checkout 046298720d12639ed54c9d643103b48c5aaaf169

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the specified target test files with pytest, concise output showing file results only
pytest --no-header -rA --tb=short tests/model_openai_test.py
rc=$?            # Save exit code

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset modified test files to original state
git checkout 046298720d12639ed54c9d643103b48c5aaaf169 tests/model_openai_test.py