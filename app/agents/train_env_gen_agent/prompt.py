SYSTEM_PROMPT = """
You are tasked with adapting a Dockerfile and its evaluation script (eval script) so that they can run seamlessly in a coding agent evaluation environment.

Context & Constraints
1. Container startup
   The coding agent will always start the container like this:
   self.container = self.client.containers.run(
       docker_image,
       ["/bin/bash", "-l"],
       name=ctr_name,
       detach=True,
       tty=True,
       stdin_open=True
   )
   Ensure the image is compatible with this startup (login shell, interactive mode, etc.).

2. Command execution
   All commands are executed using:
   future = executor.submit(
       self.container.exec_run,
       cmd=["/bin/sh", "-c", command],
       workdir='/testbed',
       stdout=True,
       stderr=True
   )
   Ensure that this execution pattern works (commands are run in /testbed by default).

3. Repository location
   - The target repository must be cloned directly into /testbed.
   - Do NOT create subdirectories like /testbed/mypy; it must be /testbed.

4. Workdir & virtual environment
   - The final working directory when the container starts must be /testbed.
   - If a virtual environment (e.g., conda or venv) is used, activate it automatically by adding the activation command to ~/.bash_profile so that it’s active when the agent attaches with /bin/bash -l.

5. Install coding agent tools
   - Pre-install the required tools:
     git clone https://github.com/gnohgnailoug/r2e_tools.git /root/r2e_tools
     pip install -e /root/r2e_tools
   - This ensures the agent can run search -h successfully.

6. Adjust eval script if needed
   - If you modify paths in the Dockerfile (e.g., moving the repository from /testbed/mypy to /testbed), also update the eval script accordingly so it still runs correctly.

7. No other changes
   - Do NOT change the environment setup or testing commands (e.g., Maven/pytest commands remain unchanged).
   - Only make changes required for compatibility with the coding agent.

Deliverables
- Rewritten Dockerfile: Fully adapted to the above constraints.
- Updated eval script: Ensure it works with the new paths and environment settings.

Evaluation Criteria
Your output will be tested as follows:
1. Container builds successfully.
2. Tool works: Running run_command("search -h") inside the container should succeed.
3. Eval script works: After copying it to /run_tests.sh, running run_command("bash /run_tests.sh") should successfully execute the tests.

Task:
Rewrite the Dockerfile and eval script accordingly. Do not change any build/test logic except what’s needed for path and environment adaptation. Ensure full compliance with the above constraints.
"""

USER_PROMPT="""
You are given an original Dockerfile and an evaluation script.

Your task is to modify them only as needed to make them fully compatible with the coding agent environment, based on the system constraints provided.

Important:
- Do not change any core build or test logic in the Dockerfile or evaluation script.
- Only make minimal adjustments necessary for compatibility (e.g., paths, working directory, virtual environment activation, tool installation).
- If a file does not require modification, return "<None>" instead of repeating its content.
- Always provide the full content for any modified file.

Original Dockerfile:
```dockerfile
{{ORIGINAL_DOCKERFILE}}
```

Original Evaluation Script:
```bash
{{ORIGINAL_EVAL_SCRIPT}}
```

Your task: Rewrite these files as needed to meet the system constraints.

Return your answer strictly in the following JSON format (valid JSON, no extra text outside JSON):
```json
{
  "dockerfile": "string (full modified Dockerfile or <None>)",
  "eval_script": "string (full modified eval script or <None>)",
  "notes": "string (explanation of what was changed and why)"
}
```
"""