#!/usr/bin/env python3
"""Pre-check generated in-patch tests (IPTs) before spending SWE-Factory time on them.

For every issue_*.json (same input as the runner) it:
  1. builds the instance with build_instances_from_issues.py (same split + hunk fix),
  2. in a clean python:<ver> Docker container, checks out base_commit and installs the repo,
  3. applies ONLY the test_patch and runs the test files      -> "before"
  4. applies the gold patch as well and runs them again        -> "after"
  5. classifies the result:

     F2P    fail before, pass after   -> valid Fail2Pass test (keep)
     P2P    pass before, pass after   -> test does not detect the bug
     F2F    fail before, fail after   -> test is broken (cannot pass with the fix)
     P2F    pass before, fail after   -> test contradicts the fix
     ERROR  setup / install / patch-apply problem (see the log)

Outputs (in --out):
  <instance_id>.log    full container output
  summary.json / summary.csv
  f2p_issues/          copies of the issue files classified F2P, ready for
                       ./baselines/run_rebuttal3_swe-factory_from_issues.sh <out>/f2p_issues

Usage:
  python baselines/precheck_f2p.py baselines/data/issues/issues_woipt_ipt --out precheck/run1
  python baselines/precheck_f2p.py <issues_dir> --out <dir> --pip-index https://pypi.tuna.tsinghua.edu.cn/simple
"""
import argparse
import concurrent.futures as cf
import csv
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_instances_from_issues import Skip, build_instance  # noqa: E402

# Runs inside the container (or on the host with --no-docker).
# Paths come from env: SRC (repo cache, may be empty), IO (patches), WORK (scratch).
INNER = r'''
set -u
git config --global --add safe.directory '*' >/dev/null 2>&1
git config --global advice.detachedHead false
if [ -n "${SRC:-}" ] && [ -d "$SRC/.git" ]; then
  cp -a "$SRC" "$WORK"
else
  git clone -q "https://github.com/$REPO.git" "$WORK" || { echo "STATUS=ERROR clone_failed"; exit 0; }
fi
cd "$WORK"
git checkout -q -f "$BASE" 2>/dev/null || { git fetch -q origin "$BASE" && git checkout -q -f "$BASE"; } \
  || { echo "STATUS=ERROR checkout_failed"; exit 0; }
git clean -fdxq

echo "== install (python $(python --version 2>&1))"
python -m pip install -q -U pip pytest pytest-asyncio 2>&1 | tail -3
INSTALL_DIR=.
if [ ! -f setup.py ] && [ ! -f pyproject.toml ] && [ -d python ]; then INSTALL_DIR=python; fi
[ -f "$INSTALL_DIR/requirements.txt" ] && python -m pip install -q -r "$INSTALL_DIR/requirements.txt" 2>&1 | tail -5
[ "$INSTALL_DIR" != "." ] && [ -f requirements.txt ] && python -m pip install -q -r requirements.txt 2>&1 | tail -5
if [ -f "$INSTALL_DIR/setup.py" ] || [ -f "$INSTALL_DIR/pyproject.toml" ]; then
  python -m pip install -q -e "$INSTALL_DIR" 2>&1 | tail -5 || echo "WARN install_failed"
fi

git apply --whitespace=nowarn "$IO/test.patch" || { echo "STATUS=ERROR test_patch_apply_failed"; exit 0; }
echo "== BEFORE (test_patch only)"
timeout "$TEST_TIMEOUT" python -m pytest -q -p no:cacheprovider $TESTS 2>&1 | tail -40
echo "RESULT_BEFORE=${PIPESTATUS[0]}"

git apply --whitespace=nowarn "$IO/gold.patch" || { echo "STATUS=ERROR gold_patch_apply_failed"; exit 0; }
if [ -f "$INSTALL_DIR/setup.py" ] || [ -f "$INSTALL_DIR/pyproject.toml" ]; then
  python -m pip install -q -e "$INSTALL_DIR" >/dev/null 2>&1
fi
echo "== AFTER (test_patch + gold patch)"
timeout "$TEST_TIMEOUT" python -m pytest -q -p no:cacheprovider $TESTS 2>&1 | tail -40
echo "RESULT_AFTER=${PIPESTATUS[0]}"
'''


def test_files(test_patch):
    return sorted(set(re.findall(r"(?m)^\+\+\+ b/(\S+)", test_patch)))


def detect_python(cache_dir, base, default):
    """Use requires-python from pyproject.toml (root or python/) when it asks for >= 3.12."""
    if not cache_dir:
        return default
    for path in ("pyproject.toml", "python/pyproject.toml"):
        try:
            txt = subprocess.run(["git", "-C", cache_dir, "show", f"{base}:{path}"],
                                 capture_output=True, text=True, timeout=30).stdout
        except Exception:
            continue
        m = re.search(r'requires-python\s*=\s*["\'][^"\']*>=\s*3\.(\d+)', txt)
        if m and int(m.group(1)) > int(default.split(".")[1]):
            return f"3.{m.group(1)}"
    return default


def classify(before, after):
    if before is None or after is None:
        return "ERROR"
    b, a = before == 0, after == 0
    return {(False, True): "F2P", (True, True): "P2P",
            (False, False): "F2F", (True, False): "P2F"}[(b, a)]


def run_one(item, args):
    inst, src_file = item
    iid = inst["instance_id"]
    log_path = os.path.join(args.out, f"{iid}.log")
    owner, name = inst["repo"].split("/")
    cache = os.path.abspath(os.path.join(args.cache_root, owner, f"{name}_cache"))
    cache = cache if os.path.isdir(os.path.join(cache, ".git")) else ""
    py = args.python_map.get(inst["repo"]) or detect_python(cache, inst["base_commit"], args.python)
    tests = test_files(inst["test_patch"])

    io_dir = tempfile.mkdtemp(prefix=f"pre_{iid}_")
    with open(os.path.join(io_dir, "test.patch"), "w") as f:
        f.write(inst["test_patch"])
    with open(os.path.join(io_dir, "gold.patch"), "w") as f:
        f.write(inst["patch"])
    with open(os.path.join(io_dir, "inner.sh"), "w") as f:
        f.write(INNER)

    env = {"REPO": inst["repo"], "BASE": inst["base_commit"], "TESTS": " ".join(tests),
           "TEST_TIMEOUT": str(args.test_timeout)}
    if args.pip_index:
        env["PIP_INDEX_URL"] = args.pip_index

    if args.no_docker:
        work = tempfile.mkdtemp(prefix=f"work_{iid}_")
        shutil.rmtree(work)
        env.update({"SRC": cache, "IO": io_dir, "WORK": work})
        cmd = ["bash", os.path.join(io_dir, "inner.sh")]
        run_env = {**os.environ, **env}
    else:
        env.update({"SRC": "/src" if cache else "", "IO": "/io", "WORK": "/work"})
        cmd = ["docker", "run", "--rm", "-v", f"{io_dir}:/io"]
        if cache:
            cmd += ["-v", f"{cache}:/src:ro"]
        for k, v in env.items():
            cmd += ["-e", f"{k}={v}"]
        cmd += [f"python:{py}", "bash", "/io/inner.sh"]
        run_env = None

    try:
        out = subprocess.run(cmd, capture_output=True, text=True, env=run_env,
                             timeout=args.instance_timeout).stdout
    except subprocess.TimeoutExpired as e:
        out = (e.stdout or "") if isinstance(e.stdout, str) else ""
        out += "\nSTATUS=ERROR instance_timeout"
    finally:
        shutil.rmtree(io_dir, ignore_errors=True)
        if args.no_docker:
            shutil.rmtree(env.get("WORK", ""), ignore_errors=True)

    with open(log_path, "w") as f:
        f.write(out)
    rb = re.search(r"RESULT_BEFORE=(\d+)", out)
    ra = re.search(r"RESULT_AFTER=(\d+)", out)
    err = re.search(r"STATUS=ERROR (\S+)", out)
    before, after = (int(rb.group(1)) if rb else None), (int(ra.group(1)) if ra else None)
    label = classify(before, after)
    return {"instance_id": iid, "issue_file": src_file, "python": py, "tests": tests,
            "before_exit": before, "after_exit": after, "label": label,
            "error": err.group(1) if err else "", "log": log_path}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("issues_dir")
    ap.add_argument("--out", required=True)
    ap.add_argument("--pattern", default="issue_*.json")
    ap.add_argument("--cache-root", default="testbed", help="SWE-Factory repo caches: <root>/<owner>/<repo>_cache")
    ap.add_argument("--python", default="3.11", help="default Python version (auto-raised from requires-python)")
    ap.add_argument("--python-map", default="", help='per-repo override, e.g. "ValueCell-ai/valuecell=3.12,a/b=3.10"')
    ap.add_argument("--pip-index", default="", help="pip mirror URL")
    ap.add_argument("--workers", type=int, default=2)
    ap.add_argument("--test-timeout", type=int, default=600, help="seconds per pytest run")
    ap.add_argument("--instance-timeout", type=int, default=3600, help="seconds per instance incl. install")
    ap.add_argument("--no-docker", action="store_true", help="run on the host in a temp dir (uses current python)")
    args = ap.parse_args()
    args.python_map = dict(p.split("=", 1) for p in args.python_map.split(",") if "=" in p)
    os.makedirs(args.out, exist_ok=True)

    items, skipped = [], []
    for path in sorted(glob.glob(os.path.join(args.issues_dir, args.pattern))):
        try:
            with open(path, encoding="utf-8") as f:
                items.append((build_instance(json.load(f)), path))
        except Skip as e:
            skipped.append({"issue_file": path, "label": "SKIPPED", "error": str(e)})
        except Exception as e:
            skipped.append({"issue_file": path, "label": "SKIPPED", "error": repr(e)})
    print(f"{len(items)} instances to check, {len(skipped)} skipped by the converter\n")

    results = []
    with cf.ThreadPoolExecutor(max_workers=args.workers) as pool:
        futs = {pool.submit(run_one, it, args): it for it in items}
        for fut in cf.as_completed(futs):
            r = fut.result()
            results.append(r)
            extra = f"  ({r['error']})" if r["error"] else ""
            print(f"{r['label']:5}  {r['instance_id']}  before={r['before_exit']} after={r['after_exit']}{extra}")

    results.sort(key=lambda r: r["instance_id"])
    all_rows = results + skipped
    with open(os.path.join(args.out, "summary.json"), "w") as f:
        json.dump(all_rows, f, indent=2)
    with open(os.path.join(args.out, "summary.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["instance_id", "issue_file", "label", "before_exit", "after_exit", "python", "error"])
        for r in all_rows:
            w.writerow([r.get("instance_id", ""), os.path.basename(r["issue_file"]), r["label"],
                        r.get("before_exit", ""), r.get("after_exit", ""), r.get("python", ""), r.get("error", "")])

    keep_dir = os.path.join(args.out, "f2p_issues")
    os.makedirs(keep_dir, exist_ok=True)
    for r in results:
        if r["label"] == "F2P":
            shutil.copy2(r["issue_file"], keep_dir)

    counts = {}
    for r in all_rows:
        counts[r["label"]] = counts.get(r["label"], 0) + 1
    print("\n=== Summary ===")
    for k in ("F2P", "P2P", "F2F", "P2F", "ERROR", "SKIPPED"):
        if k in counts:
            print(f"  {k:7} {counts[k]}")
    print(f"\nDetails: {args.out}/summary.csv   logs: {args.out}/<instance_id>.log")
    print(f"F2P issue files for the runner: {keep_dir}")


if __name__ == "__main__":
    main()