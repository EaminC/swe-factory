#!/bin/bash
set -uxo pipefail

cd /testbed

# Checkout only the target test files to ensure a clean state before patching
git checkout 667713f6c04fbc208fb7eefba70f101562070c9e \
  "src/frontend/tests/core/features/chatInputOutputUser-shard-0.spec.ts" \
  "src/backend/tests/unit/utils/test_rewrite_file_path.py" \
  "src/frontend/tests/extended/regression/general-bugs-shard-3836.spec.ts"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/src/backend/tests/unit/utils/test_rewrite_file_path.py b/src/backend/tests/unit/utils/test_rewrite_file_path.py
new file mode 100644
--- /dev/null
+++ b/src/backend/tests/unit/utils/test_rewrite_file_path.py
@@ -0,0 +1,43 @@
+from langflow.graph.utils import rewrite_file_path
+import pytest
+
+
+@pytest.mark.parametrize(
+    "file_path, expected",
+    [
+        # Test case 1: Standard path with multiple directories
+        ("/home/user/documents/file.txt", ["documents/file.txt"]),
+        # Test case 2: Path with only one directory
+        ("/documents/file.txt", ["documents/file.txt"]),
+        # Test case 3: Path with no directories (just filename)
+        ("file.txt", ["file.txt"]),
+        # Test case 4: Path with multiple levels and special characters
+        ("/home/user/my-docs/special_file!.pdf", ["my-docs/special_file!.pdf"]),
+        # Test case 5: Path with trailing slash
+        ("/home/user/documents/", ["user/documents"]),
+        # Test case 6: Empty path
+        ("", [""]),
+        # Test case 7: Path with only slashes
+        ("///", [""]),
+        # Test case 8: Path with dots
+        ("/home/user/../documents/./file.txt", ["./file.txt"]),
+        # Test case 9: Windows-style path
+        ("C:\\Users\\Documents\\file.txt", ["Documents/file.txt"]),
+        # Test case 10: Windows path with trailing backslash
+        ("C:\\Users\\Documents\\", ["Users/Documents"]),
+        # Test case 11: Mixed separators
+        ("C:/Users\\Documents/file.txt", ["Documents/file.txt"]),
+        # Test case 12: Network path (UNC)
+        ("\\\\server\\share\\file.txt", ["share/file.txt"]),
+    ],
+)
+def test_rewrite_file_path(file_path, expected):
+    result = rewrite_file_path(file_path)
+    assert result == expected
+
+
+# Additional test for type checking
+def test_rewrite_file_path_type():
+    result = rewrite_file_path("/home/user/file.txt")
+    assert isinstance(result, list)
+    assert all(isinstance(item, str) for item in result)
diff --git a/src/frontend/tests/core/features/chatInputOutputUser-shard-0.spec.ts b/src/frontend/tests/core/features/chatInputOutputUser-shard-0.spec.ts
--- a/src/frontend/tests/core/features/chatInputOutputUser-shard-0.spec.ts
+++ b/src/frontend/tests/core/features/chatInputOutputUser-shard-0.spec.ts
@@ -1,4 +1,4 @@
-import { expect, test } from "@playwright/test";
+import { test } from "@playwright/test";
 import * as dotenv from "dotenv";
 import { readFileSync } from "fs";
 import path from "path";
diff --git a/src/frontend/tests/extended/regression/general-bugs-shard-3836.spec.ts b/src/frontend/tests/extended/regression/general-bugs-shard-3836.spec.ts
new file mode 100644
--- /dev/null
+++ b/src/frontend/tests/extended/regression/general-bugs-shard-3836.spec.ts
@@ -0,0 +1,114 @@
+import { expect, test } from "@playwright/test";
+import * as dotenv from "dotenv";
+import path from "path";
+
+test("user must be able to send an image on chat using advanced tool on ChatInputComponent", async ({
+  page,
+}) => {
+  test.skip(
+    !process?.env?.OPENAI_API_KEY,
+    "OPENAI_API_KEY required to run this test",
+  );
+
+  if (!process.env.CI) {
+    dotenv.config({ path: path.resolve(__dirname, "../../.env") });
+  }
+
+  await page.goto("/");
+
+  await page.waitForTimeout(1000);
+
+  let modalCount = 0;
+  try {
+    const modalTitleElement = await page?.getByTestId("modal-title");
+    if (modalTitleElement) {
+      modalCount = await modalTitleElement.count();
+    }
+  } catch (error) {
+    modalCount = 0;
+  }
+
+  while (modalCount === 0) {
+    await page.getByText("New Project", { exact: true }).click();
+    await page.waitForTimeout(3000);
+    modalCount = await page.getByTestId("modal-title")?.count();
+  }
+
+  await page.getByRole("heading", { name: "Basic Prompting" }).click();
+  await page.waitForSelector('[title="fit view"]', {
+    timeout: 100000,
+  });
+
+  await page.getByTitle("fit view").click();
+  await page.getByTitle("zoom out").click();
+  await page.getByTitle("zoom out").click();
+  await page.getByTitle("zoom out").click();
+
+  let outdatedComponents = await page.getByTestId("icon-AlertTriangle").count();
+
+  while (outdatedComponents > 0) {
+    await page.getByTestId("icon-AlertTriangle").first().click();
+    await page.waitForTimeout(1000);
+    outdatedComponents = await page.getByTestId("icon-AlertTriangle").count();
+  }
+
+  await page
+    .getByTestId("popover-anchor-input-api_key")
+    .fill(process.env.OPENAI_API_KEY ?? "");
+
+  await page.getByTestId("dropdown_str_model_name").click();
+  await page.getByTestId("gpt-4o-1-option").click();
+
+  await page.waitForSelector("text=Chat Input", { timeout: 30000 });
+
+  await page.getByText("Chat Input", { exact: true }).click();
+  await page.getByTestId("more-options-modal").click();
+  await page.getByTestId("edit-button-modal").click();
+  await page.getByTestId("showfiles").click();
+  await page.getByText("Close").last().click();
+
+  await page.waitForTimeout(500);
+
+  const userQuestion = "What is this image?";
+  await page.getByTestId("textarea_str_input_value").fill(userQuestion);
+
+  const filePath = "tests/assets/chain.png";
+
+  await page.click('[data-testid="inputfile_file_files"]');
+
+  const [fileChooser] = await Promise.all([
+    page.waitForEvent("filechooser"),
+    page.click('[data-testid="inputfile_file_files"]'),
+  ]);
+
+  await fileChooser.setFiles(filePath);
+
+  await page.keyboard.press("Escape");
+
+  await page.getByTestId("button_run_chat output").click();
+  await page.getByText("built successfully").last().click({
+    timeout: 15000,
+  });
+
+  await page.getByText("Playground", { exact: true }).click();
+
+  await page.waitForTimeout(500);
+
+  await page.waitForSelector('[data-testid="icon-LucideSend"]', {
+    timeout: 100000,
+  });
+
+  await page.waitForSelector("text=chain.png", { timeout: 30000 });
+
+  expect(await page.getByAltText("generated image").isVisible()).toBeTruthy();
+
+  expect(
+    await page.getByTestId(`chat-message-User-${userQuestion}`).isVisible(),
+  ).toBeTruthy();
+
+  const textContents = await page
+    .getByTestId("div-chat-message")
+    .allTextContents();
+
+  expect(textContents[0]).toContain("chain");
+});
EOF_114329324912

# Activate the python virtual environment (venv)
source /opt/testbed-venv/bin/activate

# Run backend python test file with pytest (unit test)
# Run frontend playwright tests with correct sharding + file inputs
# We combine the Playwright commands for frontend TS test files, grouping them by directory

# Backend python test command
backend_test="pytest --no-header -rA --tb=short src/backend/tests/unit/utils/test_rewrite_file_path.py"

# Frontend playwright command base
frontend_base_cmd="cd src/frontend && npx playwright test --trace on --workers 2"

# Frontend test files grouped by shard though here we have 2 separate shards
# We'll run each shard command separately because shard indices differ (0 and 3836)
# and it's safer to run them independently, but combine tests in one shard if multiple

frontend_test_shard_0="tests/core/features/chatInputOutputUser-shard-0.spec.ts --shard 0/128"
frontend_test_shard_3836="tests/extended/regression/general-bugs-shard-3836.spec.ts --shard 3836/3840"

# Execute all tests with output of test file names and status
# Run backend python tests first, then each frontend shard test
set +x
echo "=== RUNNING BACKEND PYTHON TESTS ==="
$backend_test
rc_backend=$?
echo "=== RUNNING FRONTEND PLAYWRIGHT TESTS SHARD 0 ==="
cd src/frontend && npx playwright test $frontend_test_shard_0 --trace on --workers 2
rc_frontend_0=$?
echo "=== RUNNING FRONTEND PLAYWRIGHT TESTS SHARD 3836 ==="
npx playwright test $frontend_test_shard_3836 --trace on --workers 2
rc_frontend_3836=$?
set -x

# Determine aggregate exit code (fail if any failure)
rc=0
if [[ $rc_backend -ne 0 || $rc_frontend_0 -ne 0 || $rc_frontend_3836 -ne 0 ]]; then
  rc=1
fi

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the patched test files after the run
git checkout 667713f6c04fbc208fb7eefba70f101562070c9e \
  "src/frontend/tests/core/features/chatInputOutputUser-shard-0.spec.ts" \
  "src/backend/tests/unit/utils/test_rewrite_file_path.py" \
  "src/frontend/tests/extended/regression/general-bugs-shard-3836.spec.ts"