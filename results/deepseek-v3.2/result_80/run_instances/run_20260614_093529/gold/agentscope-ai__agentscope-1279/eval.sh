#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Ensure the target test file is at the correct commit state
git checkout 28cfb99a21902d330dab6cb3762a739198cf972f -- "tests/plan_test.py"

# Check if patch is non-empty before applying
# The patch content will be provided during execution, but we need to handle empty/malformed patches
if [ -n "$(cat <<'EOF_114329329312'
[CONTENT OF TEST PATCH]
EOF_114329329312
)" ]; then
    echo "Applying test patch..."
    git apply -v - <<'EOF_114329329312'
[CONTENT OF TEST PATCH]
EOF_114329329312
    patch_rc=$?
    
    if [ $patch_rc -eq 0 ]; then
        echo "Patch applied successfully"
        # Verify the patch was applied
        git status --porcelain "tests/plan_test.py" | grep -q "M" && echo "File modified by patch" || echo "File not modified by patch"
    else
        echo "Warning: Patch application failed with code $patch_rc"
        echo "Proceeding with original test file..."
    fi
else
    echo "No patch content provided, proceeding with original test file"
fi

# Set environment variable required for DashScopeChatModel tests
export DASHSCOPE_API_KEY="test_key"  # Use a dummy key since tests likely mock the API calls

# Run the specified test file using pytest with concise output
# Use --no-header to remove pytest header, -v for verbose test names, --tb=short for concise tracebacks
# -p no:cacheprovider to avoid caching issues in Docker environment
pytest "tests/plan_test.py" --no-header -v --tb=short -p no:cacheprovider
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Restore the test file to its original state
git checkout 28cfb99a21902d330dab6cb3762a739198cf972f -- "tests/plan_test.py"