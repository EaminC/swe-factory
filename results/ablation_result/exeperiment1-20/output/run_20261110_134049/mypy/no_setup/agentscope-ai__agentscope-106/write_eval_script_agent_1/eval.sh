#!/bin/bash
set -uxo pipefail

# Activate conda environment and run everything within it
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate testbed

cd /testbed

# Reset repo to target commit to ensure clean state
git checkout 371d1680ab7f41c7d695559221956250ba048475

# Apply test patch (content replaced during actual run)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_logging_utils.py b/tests/test_logging_utils.py
new file mode 100644
index 0000000000..f1a2b3c4d5
--- /dev/null
+++ b/tests/test_logging_utils.py
@@ -0,0 +1,26 @@
+import pytest
+from src.agentscope.utils import logging_utils
+
+def test_log_studio_handles_single_and_list_urls(monkeypatch):
+    messages = [
+        {"content": "test", "url": "http://example.com/image.png"},
+        {"content": "test", "url": ["http://example.com/image1.png", "http://example.com/image2.png"]},
+        {"content": "test", "audio_path": "audio.mp3"},
+        {"content": "test", "audio_path": ["audio1.mp3", "audio2.mp3"]},
+        {"content": "test", "video_path": "video.mp4"},
+        {"content": "test", "video_path": ["video1.mp4", "video2.mp4"]},
+        {"content": "test"},
+    ]
+
+    for message in messages:
+        # Should not raise exceptions
+        logging_utils.log_studio(message, uid="testuid")
+
+@pytest.mark.parametrize("message", [
+    {"content": "test", "url": None},
+    {"content": "test", "audio_path": None},
+    {"content": "test", "video_path": None},
+])
+def test_log_studio_handles_none_values(message):
+    # Should not raise exceptions when url/audio_path/video_path is None
+    logging_utils.log_studio(message, uid="testuid")
EOF_114329324912

# Run only the specified test file with coverage
# Using coverage run with tests/run.py to select single test file via environment variable PYTHONPATH override,
# but as per collected info, tests/run.py runs entire suite, so instead run python -m unittest on specific test file.
# However, the info only gives coverage run tests/run.py, no direct test command for individual tests.
# So we run coverage on unittest specifying the test file explicitly, which unittest supports:
# Run coverage on the specific test file
coverage run -m unittest discover -s tests -p test_logging_utils.py

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset files after test run
git checkout 371d1680ab7f41c7d695559221956250ba048475 tests/test_logging_utils.py