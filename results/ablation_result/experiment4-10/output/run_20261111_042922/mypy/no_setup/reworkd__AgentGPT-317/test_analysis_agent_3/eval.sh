#!/bin/bash
set -uxo pipefail

cd /testbed
git checkout cff1554f488d75f02ae7acbe5a64f107103da389

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/platform/reworkd_platform/tests/test_settings.py b/platform/reworkd_platform/tests/test_settings.py
new file mode 100644
index 00000000..e1a2f9b4
--- /dev/null
+++ b/platform/reworkd_platform/tests/test_settings.py
@@ -0,0 +1,34 @@
+import { renderHook, act } from '@testing-library/react-hooks';
+import { useSettings } from '../../src/hooks/useSettings';
+
+describe('useSettings hook', () => {
+  beforeEach(() => {
+    localStorage.clear();
+  });
+
+  it('loads default settings when no localStorage data', () => {
+    const { result } = renderHook(() => useSettings());
+    expect(result.current.settings.customApiKey).toBeUndefined();
+    expect(result.current.settings.customModelName).toBeDefined();
+    expect(result.current.settings.customMaxLoops).toBeDefined();
+  });
+
+  it('saves and loads custom API key and max loops correctly', () => {
+    const { result } = renderHook(() => useSettings());
+    act(() => {
+      result.current.saveSettings({
+        customApiKey: 'test-key',
+        customModelName: 'gpt-3.5-turbo',
+        customTemperature: 0.5,
+        customMaxLoops: 10,
+        maxTokens: 400,
+      });
+    });
+    expect(result.current.settings.customApiKey).toBe('test-key');
+    expect(result.current.settings.customMaxLoops).toBe(10);
+    // Simulate reload
+    const { result: result2 } = renderHook(() => useSettings());
+    expect(result2.current.settings.customApiKey).toBe('test-key');
+    expect(result2.current.settings.customMaxLoops).toBe(10);
+  });
+});
EOF_114329324912

# Since the specified test file is Python (.py) but no Python environment exists,
# and repo is Node.js based, ensure the test file exists and is run only if it is JavaScript/TypeScript.
# Here, we will check if the test file exists and is recognized by Jest.
# The test file path given is a .py file which does not exist likely; skip running Jest on it as it won't run.

# Instead, list all .js/.ts tests in the platform/reworkd_platform/tests folder matching Jest patterns that might be affected by patch,
# but as no other tests were specified, we run Jest in dry-run mode on the exact path to confirm no tests found.
# To keep consistent with requirements, we just run Jest with --findRelatedTests if the file exists and is js/ts.

TEST_FILE="platform/reworkd_platform/tests/test_settings.py"

if [[ -f "$TEST_FILE" ]]; then
  # Check if the file has a js/ts extension recognized by Jest
  if [[ "$TEST_FILE" =~ \.jsx?$|\.tsx?$ ]]; then
    npx cross-env SKIP_ENV_VALIDATION=1 jest --findRelatedTests "$TEST_FILE" --reporters=default --testLocationInResults
    rc=$?
  else
    # Not recognized by Jest, no valid tests to run
    echo "OMNIGRIL_EXIT_CODE=1"
    rc=1
  fi
else
  # File does not exist; no tests to run
  echo "OMNIGRIL_EXIT_CODE=1"
  rc=1
fi

# Reset repo to undo patch or any changes
git reset --hard cff1554f488d75f02ae7acbe5a64f107103da389

exit $rc