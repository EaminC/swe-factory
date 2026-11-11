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

# Run only the specified test file with Jest using npx cross-env to ensure command availability
npx cross-env SKIP_ENV_VALIDATION=1 jest platform/reworkd_platform/tests/test_settings.py --reporters=default --testLocationInResults

rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the whole repo to the specified commit to undo patch and changes safely
git reset --hard cff1554f488d75f02ae7acbe5a64f107103da389