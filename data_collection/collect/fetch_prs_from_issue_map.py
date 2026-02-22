#!/usr/bin/env python3
"""
根据 issue_pr_map 只拉取指定的 PR，输出与 print_pulls.py 相同的 prs.jsonl。

输入格式（每项仅需 3 个字段，其余忽略）：
  - repo: "owner/repo"
  - issue_number: int
  - pr_number: int
支持 name 作为 repo 的别名。
"""

import argparse
import json
import logging
import os
import sys
from typing import Optional

# 与 print_pulls 同目录，便于复用 utils
from utils import Repo

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def fetch_single_pr(owner: str, repo_name: str, pr_number: int, token: str) -> Optional[dict]:
    """用 GitHub API 拉取单个 PR，返回与 list pulls 中单条相同的结构。"""
    import requests
    url = f"https://api.github.com/repos/{owner}/{repo_name}/pulls/{pr_number}"
    headers = {"Accept": "application/vnd.github+json", "Authorization": f"token {token}"}
    r = requests.get(url, headers=headers)
    if r.status_code != 200:
        logger.warning(f"[{owner}/{repo_name}] PR #{pr_number} -> {r.status_code} {r.text[:200]}")
        return None
    return r.json()


# 输入 map 只读这 3 个字段，其余忽略
REQUIRED_KEYS = ("repo", "issue_number", "pr_number")
REPO_ALIAS = "name"


def main(issue_pr_map_path: str, output: str, token: Optional[str] = None, language: str = "python"):
    """
    - issue_pr_map_path: JSON 数组，每项只需 repo, issue_number, pr_number
    - output: 输出 prs.jsonl，供 build_dataset 使用
    """
    if token is None:
        token = os.environ.get("GITHUB_TOKEN")
    if not token:
        logger.error("请设置环境变量 GITHUB_TOKEN 或传入 --token")
        sys.exit(1)

    with open(issue_pr_map_path, "r", encoding="utf-8") as f:
        raw = f.read().strip()
    if raw.startswith("["):
        entries = json.loads(raw)
    else:
        entries = [json.loads(line) for line in raw.splitlines() if line.strip()]

    out_dir = os.path.dirname(output)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)

    repo_cache = {}
    written = 0
    failed = 0

    with open(output, "w", encoding="utf-8") as f:
        for i, entry in enumerate(entries):
            repo_full = entry.get(REQUIRED_KEYS[0]) or entry.get(REPO_ALIAS)
            pr_number = entry.get(REQUIRED_KEYS[2])
            issue_number = entry.get(REQUIRED_KEYS[1])
            if not repo_full or pr_number is None:
                logger.warning(f"跳过第 {i+1} 条（缺少 repo 或 pr_number）: {entry}")
                failed += 1
                continue
            try:
                owner, repo_name = repo_full.split("/", 1)
            except Exception:
                logger.warning(f"跳过无效 repo 名: {repo_full}")
                failed += 1
                continue

            key = (owner, repo_name)
            if key not in repo_cache:
                try:
                    repo_cache[key] = Repo(owner, repo_name, token=token, language=language)
                except Exception as e:
                    logger.warning(f"无法创建 Repo {repo_full}: {e}")
                    failed += 1
                    continue

            pull = fetch_single_pr(owner, repo_name, int(pr_number), token)
            if pull is None:
                failed += 1
                continue

            # 与 print_pulls 一致：必须有 resolved_issues（build_dataset 会校验）
            if issue_number is not None:
                pull["resolved_issues"] = [str(issue_number)]
            else:
                repo = repo_cache[key]
                pull["resolved_issues"] = repo.extract_resolved_issues_with_official_github_api(pull)
            if not pull.get("resolved_issues"):
                pull["resolved_issues"] = [str(pull["number"])]

            f.write(json.dumps(pull, ensure_ascii=False) + "\n")
            written += 1
            if (written + failed) % 50 == 0:
                logger.info(f"已处理 {written + failed} 条，写入 {written} 条 PR")

    logger.info(f"完成：写入 {written} 条 PR 到 {output}，失败/跳过 {failed} 条")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("issue_pr_map", help="JSON 路径，每项仅需 repo, issue_number, pr_number")
    parser.add_argument("output", help="输出 prs.jsonl 路径")
    parser.add_argument("--token", default=None, help="GitHub token（默认用 GITHUB_TOKEN）")
    parser.add_argument("--language", default="python", help="Repo 语言，用于 Repo 初始化（python/java/js）")
    args = parser.parse_args()
    main(args.issue_pr_map, args.output, token=args.token, language=args.language)
