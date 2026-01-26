from __future__ import annotations

import os
import re
from typing import Any, Dict, Optional, Tuple

from inference.agenthub.runtime.base import ExecutionEnvironment


class RemoteRuntime(ExecutionEnvironment):
    """
    Template runtime that mirrors DockerRuntime's interface but delegates to a remote service.
    Implement _request() and the TODOs to wire up your API.
    """

    def __init__(
        self,
        ds: Dict[str, Any],
        docker_image: Optional[str] = None,
        repo_name: Optional[str] = None,
        swefactory: bool = True,
    ) -> None:
        assert ds, "ds is required"
        self.ds = ds
        self.api_base = (os.getenv("REMOTE_RUNTIME_API_BASE") or "").rstrip("/")
        if not self.api_base:
            raise ValueError("REMOTE_RUNTIME_API_BASE must be set for RemoteRuntime.")
        self.docker_image = docker_image or ds.get("docker_image") or ds.get("image_name") or "unknown"
        self.repo_name = repo_name or ds.get("repo") or ds.get("repo_name") or "unknown"
        self.swefactory = swefactory

    def _request(self, method: str, path: str, payload: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        raise NotImplementedError("RemoteRuntime._request is a template placeholder.")

    def reset(self) -> None:
        # Optional: implement if your remote service supports a reset endpoint.
        return

    def close(self) -> None:
        # Optional: implement if your remote service needs cleanup.
        return

    def run(self, cmd: str, timeout: int = 120, use_timeout_wrapper: bool = False) -> Tuple[str, str]:
        # TODO: call remote exec endpoint and return (stdout, error_code)
        raise NotImplementedError("RemoteRuntime.run is a template placeholder.")

    def copy_to_container(self, src: str, dest: str) -> None:
        # TODO: no-op for swefactory; otherwise upload to remote runtime.
        if self.swefactory:
            return
        raise NotImplementedError("RemoteRuntime.copy_to_container is a template placeholder.")

    def get_task_instruction(self) -> str:
        # Same behavior as DockerRuntime: read from ds.
        try:
            content = self.ds["problem_statement"]
            return re.search(r"\\[ISSUE\\](.*)\\[/ISSUE\\]", content, re.DOTALL).group(1)
        except Exception:
            return self.ds.get("problem_statement", "")

    def get_patch(self) -> str:
        # TODO: call remote endpoint that returns current git diff.
        raise NotImplementedError("RemoteRuntime.get_patch is a template placeholder.")

    def _calculate_reward(self, get_test_output: bool = False, timeout: int = 300):
        # TODO: call remote reward endpoint. Return (reward, output) if get_test_output.
        raise NotImplementedError("RemoteRuntime._calculate_reward is a template placeholder.")
