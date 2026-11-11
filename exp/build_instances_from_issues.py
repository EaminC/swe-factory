#!/usr/bin/env python3
"""Build SWE-Factory instances.jsonl directly from issue_*.json files.

Replaces steps 1-2b of the rebuttal3 runner (fetch_prs_from_issue_map,
build_dataset, prepare_instances). No GitHub API calls: everything comes
from the issue files.

Expected issue file format (one issue per file):
  number, title, body, url, created_at,
  linked_prs: [{number, url, merged, base_sha, patch, test_paths_in_patch}, ...]
where `patch` holds the PR fix plus the created in-patch test, and
`test_paths_in_patch` lists the test files inside that patch.

The PR patch is split into:
  patch      = every file NOT in test_paths_in_patch (the gold fix)
  test_patch = the files in test_paths_in_patch     (your in-patch test)

Usage:
  python build_instances_from_issues.py baselines/data/issues/issues_woipt_ipt data/runs/X/instances.jsonl
"""
import argparse
import glob
import json
import os
import re
import sys


class Skip(Exception):
    pass


def repo_from_url(url):
    m = re.search(r"github\.com/([^/]+/[^/]+)/(?:issues|pull)/\d+", url or "")
    return m.group(1) if m else None


TEST_LIKE_RE = re.compile(
    r"(^|/)(tests?|testing)/|(^|/)test_[^/]*\.py$|_test\.py$|(^|/)conftest\.py$"
)


def split_patch(patch, test_paths):
    """Split a unified diff into (source part, test part) by file path."""
    test_paths = set(test_paths)
    src, tests, seen_tests = [], [], set()
    for chunk in re.split(r"(?m)^(?=diff --git )", patch):
        if not chunk.strip():
            continue
        m = re.match(r"diff --git a/(\S+) b/(\S+)", chunk)
        if not m:
            raise Skip("patch has a chunk without a 'diff --git' header")
        path = m.group(2)
        if path in test_paths:
            tests.append(chunk)
            seen_tests.add(path)
        else:
            if TEST_LIKE_RE.search(path):
                print(f"   warning: {path} looks like a test but is not in "
                      f"test_paths_in_patch; it stays in the gold patch")
            src.append(chunk)
    missing = test_paths - seen_tests
    if missing:
        raise Skip(f"test paths not found in patch: {sorted(missing)}")
    return "".join(src), "".join(tests)


HUNK_RE = re.compile(r"^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@(.*)$")


def fix_hunk_counts(diff):
    """Recompute the line counts in every '@@ -a,b +c,d @@' header.

    Some generated patches have wrong counts (e.g. '+1,24' for a 41-line new
    file). git apply then silently writes only the counted lines, truncating
    the file. Returns (fixed_diff, number_of_headers_changed).
    """
    lines = diff.split("\n")
    out, changed, i = [], 0, 0
    while i < len(lines):
        m = HUNK_RE.match(lines[i])
        if not m:
            out.append(lines[i]); i += 1
            continue
        j, old_n, new_n = i + 1, 0, 0
        while j < len(lines) and not lines[j].startswith(("@@ ", "diff --git ")):
            line = lines[j]
            if line.startswith("+"):
                new_n += 1
            elif line.startswith("-"):
                old_n += 1
            elif line.startswith(" "):
                old_n += 1; new_n += 1
            elif line == "":
                if j == len(lines) - 1:
                    pass  # trailing artefact of the final newline
                else:
                    old_n += 1; new_n += 1  # blank context line; git apply accepts it
            elif line.startswith("\\"):
                pass  # "\ No newline at end of file"
            else:
                break
            j += 1
        old_start, new_start, rest = m.group(1), m.group(2), m.group(3)
        header = f"@@ -{old_start},{old_n} +{new_start},{new_n} @@{rest}"
        if header != lines[i]:
            changed += 1
        out.append(header)
        out.extend(lines[i + 1:j])
        i = j
    return "\n".join(out), changed


def choose_pr(prs):
    """Pick the linked PR that carries an in-patch test, preferring merged ones."""
    usable = [p for p in prs if p.get("patch") and p.get("test_paths_in_patch")]
    if not usable:
        raise Skip("no linked PR with an in-patch test")
    usable.sort(key=lambda p: not p.get("merged", False))
    return usable[0], len(usable)


def build_instance(issue):
    prs = issue.get("linked_prs") or []
    if not prs:
        raise Skip("no linked PR")
    pr, n_usable = choose_pr(prs)
    if n_usable > 1:
        print(f"   note: {n_usable} linked PRs with tests, using PR #{pr['number']}")

    repo = repo_from_url(pr.get("url")) or repo_from_url(issue.get("url"))
    if not repo:
        raise Skip("cannot work out owner/repo from the URLs")
    if not pr.get("base_sha"):
        raise Skip(f"PR #{pr.get('number')} has no base_sha")

    patch, test_patch = split_patch(pr["patch"], pr["test_paths_in_patch"])
    patch, n1 = fix_hunk_counts(patch)
    test_patch, n2 = fix_hunk_counts(test_patch)
    if n1 or n2:
        print(f"   fixed {n1 + n2} wrong hunk header(s) (patch: {n1}, test_patch: {n2})")
    if not patch.strip():
        raise Skip("PR patch has no non-test changes")

    title = (issue.get("title") or "").strip()
    body = (issue.get("body") or "").replace("\r\n", "\n").strip()
    problem = f"{title}\n{body}".strip()
    if not problem:
        raise Skip("no issue title or body")

    return {
        "repo": repo,
        "pull_number": pr["number"],
        "instance_id": f"{repo.replace('/', '__')}-{pr['number']}",
        "issue_numbers": [str(issue.get("number"))],
        "base_commit": pr["base_sha"],
        "patch": patch,
        "test_patch": test_patch,
        "problem_statement": problem,
        "hints_text": "",
        "created_at": pr.get("created_at") or issue.get("created_at"),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("issues_dir")
    ap.add_argument("output_jsonl")
    ap.add_argument("--pattern", default="issue_*.json")
    args = ap.parse_args()

    files = sorted(glob.glob(os.path.join(args.issues_dir, args.pattern)))
    if not files:
        sys.exit(f"No files matching {args.pattern} in {args.issues_dir}")

    instances, skipped, seen = [], [], set()
    for path in files:
        name = os.path.basename(path)
        try:
            with open(path, encoding="utf-8") as f:
                issue = json.load(f)
            inst = build_instance(issue)
            if inst["instance_id"] in seen:
                raise Skip(f"duplicate PR {inst['instance_id']} (already used by another issue)")
            seen.add(inst["instance_id"])
            instances.append(inst)
            print(f"ok   {name} -> {inst['instance_id']}")
        except Skip as e:
            skipped.append({"file": name, "reason": str(e)})
            print(f"skip {name}: {e}")
        except Exception as e:
            skipped.append({"file": name, "reason": f"error: {e!r}"})
            print(f"skip {name}: error: {e!r}")

    os.makedirs(os.path.dirname(os.path.abspath(args.output_jsonl)), exist_ok=True)
    with open(args.output_jsonl, "w", encoding="utf-8") as f:
        for inst in instances:
            f.write(json.dumps(inst) + "\n")
    with open(args.output_jsonl + ".skipped.json", "w", encoding="utf-8") as f:
        json.dump(skipped, f, indent=2)

    print(f"\n{len(files)} issue files -> {len(instances)} instances, {len(skipped)} skipped")
    print(f"Skipped list: {args.output_jsonl}.skipped.json")


if __name__ == "__main__":
    main()