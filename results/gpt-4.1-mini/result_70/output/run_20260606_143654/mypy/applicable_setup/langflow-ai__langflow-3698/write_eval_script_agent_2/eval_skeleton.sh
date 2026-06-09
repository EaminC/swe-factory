#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset target test files to original state before patch
git checkout a4dc5381b2cf31c507cc32f9027f76bf00d61ccc \
    "src/backend/tests/unit/test_custom_component.py" \
    "src/backend/tests/unit/test_database.py"

# Apply test patch
git apply -v - <<'EOF_114329324912'
[CONTENT OF TEST PATCH]
EOF_114329324912

# Activate Poetry virtual environment
source /testbed/.venv/bin/activate

# Initialize the database schema before running tests
# The schema is created using SQLModel metadata as in test setup, so we run a small Python one-liner
python3 -c "from sqlmodel import SQLModel; from src.backend.db.database import engine; SQLModel.metadata.create_all(engine)"

# Run only the specified target test files using poetry pytest with appropriate flags
poetry run pytest \
    src/backend/tests/unit/test_custom_component.py \
    src/backend/tests/unit/test_database.py \
    --instafail -ra -m "not api_key_required"

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Cleanup: reset the patched test files
git checkout a4dc5381b2cf31c507cc32f9027f76bf00d61ccc \
    "src/backend/tests/unit/test_custom_component.py" \
    "src/backend/tests/unit/test_database.py"