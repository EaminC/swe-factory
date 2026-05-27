#!/bin/bash
set -uxo pipefail
cd /testbed
# Checkout only existing tracked test files, remove untracked or non-existent entries like file1.txt and missing directories
git checkout c1f4a9da5dd0abed15b91f6d1c60464cad84ce6c \
  "tests/core/test_chat_to_files.py" \
  "tests/core/test_salvage_correct_hunks.py"

# Apply test patch
git apply -v - <<'EOF_114329324912'
diff --git a/tests/core/improve_function_test_cases/zbf_yml_missing_chat b/tests/core/improve_function_test_cases/zbf_yml_missing_chat
new file mode 100644
--- /dev/null
+++ b/tests/core/improve_function_test_cases/zbf_yml_missing_chat
@@ -0,0 +1,109 @@
+To achieve the separation of environments (stage and local) and to use H2 DB for the local environment, we need to make the following changes:
+
+1. Create a new `application-local.yml` configuration file for the local environment.
+2. Modify the existing `application.yml` to be used for the stage environment.
+3. Update the `run.sh` script to handle both environments.
+
+Let's start with the changes:
+
+### 1. Create `application-local.yml` for the local environment
+
+```diff
+--- /dev/null
++++ src/main/resources/application-local.yml
+@@ -0,0 +1,13 @@
++spring:
++  datasource:
++    url: jdbc:h2:mem:testdb
++    driver-class-name: org.h2.Driver
++    username: sa
++    password: password
++  h2:
++    console:
++      enabled: true
++  jpa:
++    hibernate:
++      ddl-auto: update
++    show-sql: true
+```
+
+### 2. Modify `application.yml` to be used for the stage environment
+
+```diff
+--- src/main/resources/application.yml
++++ src/main/resources/application.yml
+@@ -1,13 +1,13 @@
+ spring:
+   datasource:
+-    url: jdbc:postgresql://<RDS_ENDPOINT>:5432/<DB_NAME>
+-    username: <DB_USERNAME>
+-    password: <DB_PASSWORD>
++    url: jdbc:postgresql://stage-rds-endpoint:5432/stage_db
++    username: stage_user
++    password: stage_password
+     driver-class-name: org.postgresql.Driver
+   jpa:
+     hibernate:
+       ddl-auto: update
+     show-sql: true
+     properties:
+       hibernate:
+         format_sql: true
+```
+
+
+
+### 6. Update `application.yml` to include profile-specific configurations
+
+```diff
+--- src/main/resources/application.yml
++++ src/main/resources/application.yml
+@@ -1,13 +1,15 @@
+ spring:
+   profiles:
+-    active: stage
++    active: stage
+   datasource:
+-    url: jdbc:postgresql://<RDS_ENDPOINT>:5432/<DB_NAME>
+-    username: <DB_USERNAME>
+-    password: <DB_PASSWORD>
++    url: jdbc:postgresql://stage-rds-endpoint:5432/stage_db
++    username: stage_user
++    password: stage_password
+     driver-class-name: org.postgresql.Driver
+   jpa:
+     hibernate:
+       ddl-auto: update
+     show-sql: true
+     properties:
+       hibernate:
+         format_sql: true
+```
+
+### 7. Update `application-local.yml` to include profile-specific configurations
+
+```diff
+--- src/main/resources/application-local.yml
++++ src/main/resources/application-local.yml
+@@ -1,13 +1,15 @@
+ spring:
+   profiles:
+-    active: local
++    active: local
+   datasource:
+-    url: jdbc:h2:mem:testdb
+-    driver-class-name: org.h2.Driver
+-    username: sa
+-    password: password
++    url: jdbc:h2:mem:testdb
++    driver-class-name: org.h2.Driver
++    username: sa
++    password: password
+   h2:
+     console:
+       enabled: true
+   jpa:
+     hibernate:
+       ddl-auto: update
+     show-sql: true
+```
diff --git a/tests/core/improve_function_test_cases/zbf_yml_missing_code b/tests/core/improve_function_test_cases/zbf_yml_missing_code
new file mode 100644
--- /dev/null
+++ b/tests/core/improve_function_test_cases/zbf_yml_missing_code
@@ -0,0 +1,13 @@
+spring:
+  datasource:
+    url: jdbc:postgresql://<RDS_ENDPOINT>:5432/<DB_NAME>
+    username: <DB_USERNAME>
+    password: <DB_PASSWORD>
+    driver-class-name: org.postgresql.Driver
+  jpa:
+    hibernate:
+      ddl-auto: update
+    show-sql: true
+    properties:
+      hibernate:
+        format_sql: true
diff --git a/tests/core/test_chat_to_files.py b/tests/core/test_chat_to_files.py
--- a/tests/core/test_chat_to_files.py
+++ b/tests/core/test_chat_to_files.py
@@ -147,6 +147,32 @@ class Calculator:
 Conclusion: ***
 """
 
+single_diff = """
+```
+--- a/file1.txt
++++ a/file1.txt
+@@ -1,3 +1,3 @@
+-old line
++new line
+```
+"""
+multi_diff = """
+```
+--- a/file1.txt
++++ a/file1.txt
+@@ -1,3 +1,3 @@
+-old line
++new line
+```
+```
+--- a/file1.txt
++++ a/file1.txt
+@@ -2,3 +2,3 @@
+-another old line
++another new line
+```
+"""
+
 
 # Single function tests
 def test_basic_similarity():
@@ -289,6 +315,36 @@ def parse_chats_with_regex(
     return diff_content, code_content, diffs
 
 
+def capture_print_output(func):
+    import io
+    import sys
+
+    captured_output = io.StringIO()
+    sys.stdout = captured_output
+    func()
+    sys.stdout = sys.__stdout__
+    return captured_output
+
+
+def test_single_diff():
+    diffs = parse_diffs(single_diff)
+    correct_diff = "\n".join(single_diff.strip().split("\n")[1:-1])
+    assert diffs["a/file1.txt"].diff_to_string() == correct_diff
+
+
+def test_multi_diff_discard():
+    captured_output = capture_print_output(lambda: parse_diffs(multi_diff))
+    diffs = parse_diffs(multi_diff)
+    correct_diff = "\n".join(multi_diff.strip().split("\n")[1:8]).replace(
+        "```\n```", ""
+    )
+    assert (
+        "Multiple diffs found for a/file1.txt. Only the first one is kept."
+        in captured_output.getvalue()
+    )
+    assert diffs["a/file1.txt"].diff_to_string().strip() == correct_diff.strip()
+
+
 # test parse diff
 def test_controller_diff():
     parse_chats_with_regex("controller_chat", "controller_code")
diff --git a/tests/core/test_salvage_correct_hunks.py b/tests/core/test_salvage_correct_hunks.py
--- a/tests/core/test_salvage_correct_hunks.py
+++ b/tests/core/test_salvage_correct_hunks.py
@@ -89,6 +89,17 @@ def test_theo_case():
     print(updated_files["run.py"])
 
 
+def test_zbf_yml_missing():
+    files = FilesDict(
+        {"src/main/resources/application.yml": get_file_content("zbf_yml_missing_code")}
+    )
+    updated_files, _ = salvage_correct_hunks(
+        message_builder("zbf_yml_missing_chat"), files, memory
+    )
+    print(updated_files["src/main/resources/application.yml"])
+    print(updated_files["src/main/resources/application-local.yml"])
+
+
 def test_clean_up_folder(clean_up_folder):
     # The folder should be deleted after the test is run
     assert True
EOF_114329324912

# Run only the specified existing test files with pytest
pytest -v --tb=short --disable-warnings \
  tests/core/test_chat_to_files.py \
  tests/core/test_salvage_correct_hunks.py
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test files to original commit state after testing
git checkout c1f4a9da5dd0abed15b91f6d1c60464cad84ce6c \
  "tests/core/test_chat_to_files.py" \
  "tests/core/test_salvage_correct_hunks.py"