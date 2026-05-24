#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset target test file to exact commit version to ensure clean state
git checkout c96d4a6823fb5a3ef196427612b784efe504fdce "tests/cli/test_utils.py"

# Apply test patch to update target test file(s)
git apply -v - <<'EOF_114329324912'
diff --git a/tests/cli/test_utils.py b/tests/cli/test_utils.py
--- a/tests/cli/test_utils.py
+++ b/tests/cli/test_utils.py
@@ -261,3 +261,104 @@ def __init__(self, name:
     captured = capsys.readouterr()
 
     assert "was never closed" in captured.out
+
+
+@pytest.fixture
+def mock_crew():
+    from crewai.crew import Crew
+
+    class MockCrew(Crew):
+        def __init__(self):
+            pass
+
+    return MockCrew()
+
+
+@pytest.fixture
+def temp_crew_project():
+    with tempfile.TemporaryDirectory() as temp_dir:
+        old_cwd = os.getcwd()
+        os.chdir(temp_dir)
+
+        crew_content = """
+        from crewai.crew import Crew
+        from crewai.agent import Agent
+
+        def create_crew() -> Crew:
+            agent = Agent(role="test", goal="test", backstory="test")
+            return Crew(agents=[agent], tasks=[])
+
+        # Direct crew instance
+        direct_crew = Crew(agents=[], tasks=[])
+        """
+
+        with open("crew.py", "w") as f:
+            f.write(crew_content)
+
+        os.makedirs("src", exist_ok=True)
+        with open(os.path.join("src", "crew.py"), "w") as f:
+            f.write(crew_content)
+
+        # Create a src/templates directory that should be ignored
+        os.makedirs(os.path.join("src", "templates"), exist_ok=True)
+        with open(os.path.join("src", "templates", "crew.py"), "w") as f:
+            f.write("# This should be ignored")
+
+        yield temp_dir
+
+        os.chdir(old_cwd)
+
+
+def test_get_crews_finds_valid_crews(temp_crew_project, monkeypatch, mock_crew):
+    def mock_fetch_crews(module_attr):
+        return [mock_crew]
+
+    monkeypatch.setattr(utils, "fetch_crews", mock_fetch_crews)
+
+    crews = utils.get_crews()
+
+    assert len(crews) > 0
+    assert mock_crew in crews
+
+
+def test_get_crews_with_nonexistent_file(temp_crew_project):
+    crews = utils.get_crews(crew_path="nonexistent.py", require=False)
+    assert len(crews) == 0
+
+
+def test_get_crews_with_required_nonexistent_file(temp_crew_project, capsys):
+    with pytest.raises(SystemExit):
+        utils.get_crews(crew_path="nonexistent.py", require=True)
+
+    captured = capsys.readouterr()
+    assert "No valid Crew instance found" in captured.out
+
+
+def test_get_crews_with_invalid_module(temp_crew_project, capsys):
+    with open("crew.py", "w") as f:
+        f.write("import nonexistent_module\n")
+
+    crews = utils.get_crews(crew_path="crew.py", require=False)
+    assert len(crews) == 0
+
+    with pytest.raises(SystemExit):
+        utils.get_crews(crew_path="crew.py", require=True)
+
+    captured = capsys.readouterr()
+    assert "Error" in captured.out
+
+
+def test_get_crews_ignores_template_directories(temp_crew_project, monkeypatch, mock_crew):
+    template_crew_detected = False
+
+    def mock_fetch_crews(module_attr):
+        nonlocal template_crew_detected
+        if hasattr(module_attr, "__file__") and "templates" in module_attr.__file__:
+            template_crew_detected = True
+        return [mock_crew]
+
+    monkeypatch.setattr(utils, "fetch_crews", mock_fetch_crews)
+
+    utils.get_crews()
+
+    assert not template_crew_detected
EOF_114329324912

# Activate the Python virtual environment for running tests
source /opt/testbed/bin/activate

# Run only the specified test file with pytest under "uv run" as recommended
uv run pytest tests/cli/test_utils.py --tb=short -rA --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset test file after running tests to keep repo clean
git checkout c96d4a6823fb5a3ef196427612b784efe504fdce "tests/cli/test_utils.py"