#!/root/.venv/bin/python
# @yaml
# signature: task_tracker --command <command> [--task_list <task_list>]
# docstring: Manage a lightweight task list for planning and tracking work.
# arguments:
#   command:
#     type: string
#     description: "The command to execute. Allowed values: view, plan."
#     required: true
#   task_list:
#     type: string
#     description: JSON array string for plan (list of task objects).
#     required: false

import argparse
import json


def _count_tasks(raw: str) -> int:
    try:
        data = json.loads(raw)
        if isinstance(data, list):
            return len(data)
    except Exception:
        pass
    return 0


def main() -> None:
    parser = argparse.ArgumentParser(description="Manage a lightweight task list.")
    parser.add_argument("--command", required=True, choices=["view", "plan"])
    parser.add_argument("--task_list", required=False)
    args = parser.parse_args()

    if args.command == "view":
        print('No task list found. Use the "plan" command to create one.')
        return

    count = _count_tasks(args.task_list or "")
    print(f"Task list has been updated with {count} items.")


if __name__ == "__main__":
    main()
