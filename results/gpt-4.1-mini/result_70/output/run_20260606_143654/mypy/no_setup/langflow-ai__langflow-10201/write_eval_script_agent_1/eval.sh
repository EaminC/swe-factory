#!/bin/bash
set -uxo pipefail

cd /testbed

# Reset the target test file to original state before patching
git checkout 676299dc0aa02a088b5be43723023ad8fae6464b "src/backend/tests/unit/components/languagemodels/test_chatollama_component.py"

# Apply the test patch
git apply -v - <<'EOF_114329324912'
diff --git a/src/backend/tests/unit/components/languagemodels/test_chatollama_component.py b/src/backend/tests/unit/components/languagemodels/test_chatollama_component.py
--- a/src/backend/tests/unit/components/languagemodels/test_chatollama_component.py
+++ b/src/backend/tests/unit/components/languagemodels/test_chatollama_component.py
@@ -56,7 +56,7 @@ async def test_build_model(self, mock_chat_ollama, component_class, default_kwar
         mock_chat_ollama.assert_called_once_with(
             base_url="http://localhost:11434",
             model="ollama-model",
-            mirostat=0,
+            # mirostat is not included when disabled (set to None and filtered out)
             format="json",
             metadata={"keywords": ["model", "llm", "language model", "large language model"]},
             num_ctx=2048,
@@ -84,6 +84,51 @@ async def test_build_model_missing_base_url(self, mock_chat_ollama, component_cl
         with pytest.raises(ValueError, match=re.escape("Unable to connect to the Ollama API.")):
             component.build_model()
 
+    @patch("lfx.components.ollama.ollama.ChatOllama")
+    async def test_build_model_with_mirostat_enabled(self, mock_chat_ollama, component_class):
+        """Test that mirostat parameters are included when Mirostat is enabled."""
+        mock_instance = MagicMock()
+        mock_chat_ollama.return_value = mock_instance
+
+        component = component_class(
+            base_url="http://localhost:11434",
+            model_name="ollama-model",
+            mirostat="Mirostat",  # Setting to Mirostat (value 1)
+            mirostat_eta=0.1,
+            mirostat_tau=5.0,
+            temperature=0.1,
+        )
+        model = component.build_model()
+
+        # Verify that mirostat and its related params ARE passed
+        call_kwargs = mock_chat_ollama.call_args[1]
+        assert call_kwargs["mirostat"] == 1
+        assert call_kwargs["mirostat_eta"] == 0.1
+        assert call_kwargs["mirostat_tau"] == 5.0
+        assert model == mock_instance
+
+    @patch("lfx.components.ollama.ollama.ChatOllama")
+    async def test_build_model_with_mirostat_2_enabled(self, mock_chat_ollama, component_class):
+        """Test that mirostat parameters are included when Mirostat 2.0 is enabled."""
+        mock_instance = MagicMock()
+        mock_chat_ollama.return_value = mock_instance
+
+        component = component_class(
+            base_url="http://localhost:11434",
+            model_name="ollama-model",
+            mirostat="Mirostat 2.0",  # Setting to Mirostat 2.0 (value 2)
+            mirostat_eta=0.2,
+            mirostat_tau=10.0,
+            temperature=0.1,
+        )
+        model = component.build_model()
+        # Verify that mirostat and its related params ARE passed
+        call_kwargs = mock_chat_ollama.call_args[1]
+        assert call_kwargs["mirostat"] == 2
+        assert call_kwargs["mirostat_eta"] == 0.2
+        assert call_kwargs["mirostat_tau"] == 10.0
+        assert model == mock_instance
+
     @pytest.mark.asyncio
     @patch("lfx.components.ollama.ollama.httpx.AsyncClient.post")
     @patch("lfx.components.ollama.ollama.httpx.AsyncClient.get")
EOF_114329324912

# Activate the virtual environment and run pytest on the specified test file only,
# output concise info with test file name and status, suppress unnecessary info
source /opt/testbed/bin/activate

uv run pytest "src/backend/tests/unit/components/languagemodels/test_chatollama_component.py" -rA --tb=short --disable-warnings
rc=$?

echo "OMNIGRIL_EXIT_CODE=$rc"

# Reset the test file after running tests
git checkout 676299dc0aa02a088b5be43723023ad8fae6464b "src/backend/tests/unit/components/languagemodels/test_chatollama_component.py"