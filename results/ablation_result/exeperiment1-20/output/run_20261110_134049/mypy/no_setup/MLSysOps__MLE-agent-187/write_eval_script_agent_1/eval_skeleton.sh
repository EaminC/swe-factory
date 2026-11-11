#!/bin/bash
set -uxo pipefail

cd /testbed

git checkout b95f56b446a2fe55247eee717ab85fe45f857d27

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate virtual environment
source /opt/testbed/bin/activate

# Run only the specified test file using unittest module allowing test discovery filtering by pattern
python -m unittest discover -s tests -p test_clarify_dataset.py -v
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset patched files to original state
git checkout b95f56b446a2fe55247eee717ab85fe45f857d27 "tests/test_clarify_dataset.py"