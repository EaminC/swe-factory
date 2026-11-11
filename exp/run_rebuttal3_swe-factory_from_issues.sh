#!/usr/bin/env bash
# Rebuttal3 runner (from issue files): same pipeline as run_rebuttal3_swe-factory_ipt.sh,
# but steps 1-2b (fetch PRs, build_dataset, prepare_instances) are replaced by
# build_instances_from_issues.py, which reads issue_*.json files that already hold
# the issue, its linked PR, and the created in-patch test.
# Usage: ./run_rebuttal3_swe-factory_from_issues.sh <issues_dir>
#   e.g. ./baselines/run_rebuttal3_swe-factory_from_issues.sh baselines/data/issues/issues_woipt_ipt

set -euo pipefail

echo "=============================================="
echo "Initializing Environment..."
echo "=============================================="

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve the input dir before cd, so relative paths work from anywhere
ISSUES_DIR="${1:-}"
if [[ -z "$ISSUES_DIR" ]] || [[ ! -d "$ISSUES_DIR" ]]; then
  echo "Usage: $0 <issues_dir>   (folder containing issue_*.json)" >&2
  exit 1
fi
ISSUES_DIR="$(cd "$ISSUES_DIR" && pwd)"

cd "$REPO_ROOT"

if [[ -f ".env" ]]; then
    echo "Loading variables from .env..."
    export $(grep -v '^#' .env | tr -d '\r' | xargs)
else
    echo "ERROR: .env file not found! Please create one." >&2
    exit 1
fi

if [[ -z "${FORGE_API_KEY:-}" ]]; then
    echo "ERROR: FORGE_API_KEY is missing in .env" >&2
    exit 1
fi

if [[ -z "${MODEL:-}" ]]; then
    echo "ERROR: MODEL is missing in .env (e.g., MODEL=tensorblock/gpt-4.1-mini)" >&2
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
  echo "ERROR: Docker is not running or you don't have permissions." >&2
  exit 1
fi

export PYTHONPATH="$REPO_ROOT:${PYTHONPATH:-}"

count_jsonl() { if [[ -f "$1" ]]; then wc -l < "$1" | tr -d ' '; else echo "0"; fi }
count_json() { if [[ -f "$1" ]]; then python -c "import json; d=json.load(open('$1')); print(len(d) if isinstance(d, (list, dict)) else 0)" 2>/dev/null || echo "0"; else echo "0"; fi }

TS="$(date +%Y%m%d_%H%M%S)"
RUN_DIR="data/runs/${TS}"
OUTPUT_BASE="output/run_${TS}"
RUN_INSTANCES_DIR="run_instances"
RUN_ID="run_${TS}"
REPORTS_DIR="reports"
LOG_FILE="${RUN_DIR}/pipeline_log.txt"

mkdir -p "$RUN_DIR" "$REPORTS_DIR" "$OUTPUT_BASE"

INSTANCES="${RUN_DIR}/instances.jsonl"
INSTANCES_VERSIONS="${RUN_DIR}/instances_versions.jsonl"
RESULTS_JSON="${OUTPUT_BASE}/results/results.json"
GOLD_DIR="${RUN_INSTANCES_DIR}/${RUN_ID}/gold"
JUDGE_JSON="${REPORTS_DIR}/${RUN_ID}_gold.json"
COUNT_ISSUES=$(find "$ISSUES_DIR" -maxdepth 1 -name 'issue_*.json' | wc -l | tr -d ' ')

echo "=============================================="
echo "Input issues dir: $ISSUES_DIR ($COUNT_ISSUES files)"
echo "Timestamp: $TS"
echo "Run dir / output: $RUN_DIR, $OUTPUT_BASE, $RUN_INSTANCES_DIR"
echo "All output will be logged to: $LOG_FILE"
echo "=============================================="

{
  PIPELINE_START_TIME=$(date +%s)
    echo "Starting cost tracker..."
    python stats/entry.py start || echo "Warning: Failed to start stats tracker"

    echo -e "\n[1/5] Building instances from issue files (with created in-patch tests)..."
    python "$SCRIPT_DIR/build_instances_from_issues.py" "$ISSUES_DIR" "$INSTANCES"
    COUNT_INSTANCES=$(count_jsonl "$INSTANCES")
    echo " -> Remaining after Step 1: $COUNT_INSTANCES instances (skipped: ${INSTANCES}.skipped.json)"

    if [[ "$COUNT_INSTANCES" -eq 0 ]]; then
      echo "ERROR: no instances built; check ${INSTANCES}.skipped.json" >&2
      exit 1
    fi

    echo -e "\n[2/5] Fetching version tags..."
    python data_collection/collect/get_version.py --instance_path "$INSTANCES" --testbed "${RUN_DIR}/github_testbed" --max-workers 20
    COUNT_VERSIONS=$(count_jsonl "$INSTANCES_VERSIONS")
    echo " -> Remaining after Step 2: $COUNT_VERSIONS versioned instances"

    echo -e "\n[3/5] Running SWE-Builder (Agent Inference)..."
    if [[ "$COUNT_VERSIONS" -gt 0 ]]; then
      python -m app.main swe-bench \
        --model "$MODEL" \
        --tasks-map "$INSTANCES_VERSIONS" \
        --num-processes 10 \
        --model-temperature 0.2 \
        --conv-round-limit 10 \
        --output-dir "${OUTPUT_BASE}/mypy" \
        --setup-dir "testbed" \
        --results-path "${OUTPUT_BASE}/results"
      COUNT_RESULTS=$(count_json "$RESULTS_JSON")
      echo " -> Remaining after Step 3: $COUNT_RESULTS agent results"
    else
      echo " -> No versioned instances found; skipping SWE-Builder."
      COUNT_RESULTS=0
    fi

    if [[ "$COUNT_RESULTS" -gt 0 ]]; then
      echo -e "\n[4/5] Running Fail2Pass evaluation..."
      python evaluation/run_evaluation.py \
        --dataset_name "$RESULTS_JSON" \
        --predictions_path "gold" \
        --max_workers 5 \
        --run_id "$RUN_ID" \
        --output_path "$RUN_INSTANCES_DIR" \
        --timeout 3600 \
        --is_judge_fail2pass
    else
      echo -e "\n[4/5] Skipping Fail2Pass evaluation because no agent results were produced."
    fi

    echo -e "\n[5/5] Classifying Fail2Pass Status..."
    if [[ -d "$GOLD_DIR" ]]; then
      python scripts/judge_fail2pass.py "$GOLD_DIR" "$JUDGE_JSON"
      echo "Report generated: $JUDGE_JSON"
    else
      echo "Directory not found: $GOLD_DIR, skipping judge_fail2pass"
    fi

    echo "Waiting 5 seconds for API metrics to sync..."
    sleep 5

    echo -e "\nEnding cost tracker..."
    python stats/entry.py end || echo "Warning: Failed to end stats tracker"

    PIPELINE_END_TIME=$(date +%s)
    PIPELINE_DURATION=$((PIPELINE_END_TIME - PIPELINE_START_TIME))
    DURATION_HR=$((PIPELINE_DURATION / 3600))
    DURATION_MIN=$(((PIPELINE_DURATION % 3600) / 60))
    DURATION_SEC=$((PIPELINE_DURATION % 60))

    echo -e "\n=============================================="
    echo "          PIPELINE FUNNEL REPORT              "
    echo "=============================================="
    echo "1. Issue files             : $COUNT_ISSUES"
    echo "2. Built Instances         : $COUNT_INSTANCES"
    echo "3. Versioned Instances     : $COUNT_VERSIONS"
    echo "4. Agent Results Generated : $COUNT_RESULTS"
    echo "=============================================="
    echo "Master Log File   : $LOG_FILE"
    echo "Skipped issues    : ${INSTANCES}.skipped.json"
    echo "SWE-Builder output: $OUTPUT_BASE"
    echo "Fail2Pass logs    : ${RUN_INSTANCES_DIR}/${RUN_ID}"
    echo "=============================================="
    echo "Total pipeline duration: ${DURATION_HR}h ${DURATION_MIN}m ${DURATION_SEC}s"

} 2>&1 | tee -a "$LOG_FILE"