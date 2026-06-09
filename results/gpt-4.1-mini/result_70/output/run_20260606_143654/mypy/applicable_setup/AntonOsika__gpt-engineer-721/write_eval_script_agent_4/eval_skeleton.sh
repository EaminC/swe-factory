#!/bin/bash
set -uxo pipefail

# Activate conda environment
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Print installed langchain version for debugging
echo "Installed langchain version:"
python -c "import langchain; print(langchain.__version__)"

# Reset the specified test file to the target commit state
git checkout 7dac88a3f8e8c0610e9e3189c867b19d055dab2d "tests/test_chat_to_files.py"

# Apply test patch (content replaced during execution)
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Run only the target test file with pytest
pytest --no-header -rA --tb=short -p no:cacheprovider tests/test_chat_to_files.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the modified test file to clean state after tests
git checkout 7dac88a3f8e8c0610e9e3189c867b19d055dab2d "tests/test_chat_to_files.py"