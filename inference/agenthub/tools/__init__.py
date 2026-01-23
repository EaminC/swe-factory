##############################################################################
# tool definitions
##############################################################################

# Import allowed commands from the editor module
from .str_replace_editor import ALLOWED_STR_REPLACE_EDITOR_COMMANDS

# V1 File Editor
_FILE_EDITOR_DESCRIPTION = """Custom editing tool for viewing, creating and editing files
* State is persistent across command calls and discussions with the user
* If `path` is a file, `view` displays the result of applying `cat -n`. If `path` is a directory, `view` lists non-hidden files and directories up to 2 levels deep
* The `create` command cannot be used if the specified `path` already exists as a file
* If a `command` generates a long output, it will be truncated and marked with `<response clipped>`
* The `undo_edit` command will revert the last edit made to the file at `path`

Notes for using the `str_replace` command:
* The `old_str` parameter should match EXACTLY one or more consecutive lines from the original file. Be mindful of whitespaces!
* If the `old_str` parameter is not unique in the file, the replacement will not be performed. Make sure to include enough context in `old_str` to make it unique
* The `new_str` parameter should contain the edited lines that should replace the `old_str`
"""

file_editor = {
    "type": "function",
    "function": {
        "name": "file_editor",
        "description": _FILE_EDITOR_DESCRIPTION,
        "parameters": {
            "type": "object",
            "properties": {
                "command": {
                    "description": "The command to run. Allowed options are: `view`, `create`, `str_replace`, `insert`, `undo_edit`.",
                    "enum": ["view", "create", "str_replace", "insert", "undo_edit"],
                    "type": "string",
                },
                "path": {
                    "description": "Absolute path to file or directory, e.g. `/testbed/file.py` or `/testbed`.",
                    "type": "string",
                },
                "file_text": {
                    "description": "Required for the `create` command, contains the content of the file to be created.",
                    "type": "string",
                },
                "old_str": {
                    "description": "Required for the `str_replace` command, specifies the string in `path` to replace.",
                    "type": "string",
                },
                "new_str": {
                    "description": "Optional for the `str_replace` command to specify the replacement string. Required for the `insert` command to specify the string to insert.",
                    "type": "string",
                },
                "insert_line": {
                    "description": "Required for the `insert` command. The `new_str` will be inserted AFTER the line specified.",
                    "type": "integer",
                },
                "view_range": {
                    "description": "Optional for the `view` command when `path` points to a file. Specifies the line range to view. E.g., [11, 12] shows lines 11 and 12. Indexing starts at 1. Use [start_line, -1] to show all lines from `start_line` to the end.",
                    "type": "array",
                    "items": {"type": "integer"},
                },
                "concise": {
                    "description": "Optional for the `view` command. If `True`, displays a concise skeletal view of the file. Very useful for localization tasks. Highly recommended for large files.",
                    "type": "boolean",
                },
            },
            "required": ["command", "path"],
        },
    },
}


_STR_REPLACE_EDITOR_DESCRIPTION = """Custom editing tool for viewing, creating and editing files
* State is persistent across command calls and discussions with the user
* If `path` is a file, `view` displays the result of applying `cat -n`. If `path` is a directory, `view` lists non-hidden files and directories up to 2 levels deep
* The `create` command cannot be used if the specified `path` already exists as a file
* If a `command` generates a long output, it will be truncated and marked with `<response clipped>`

Notes for using the `str_replace` command:
* The `old_str` parameter should match EXACTLY one or more consecutive lines from the original file. Be mindful of whitespaces!
* If the `old_str` parameter is not unique in the file, the replacement will not be performed. Make sure to include enough context in `old_str` to make it unique
* The `new_str` parameter should contain the edited lines that should replace the `old_str`
"""

str_replace_editor_tool = {
    "type": "function",
    "function": {
        "name": "str_replace_editor",
        "description": _STR_REPLACE_EDITOR_DESCRIPTION,
        "parameters": {
            "type": "object",
            "properties": {
                "command": {
                    "description": f"The command to run. Allowed options are: {', '.join(f'`{cmd}`' for cmd in ALLOWED_STR_REPLACE_EDITOR_COMMANDS)}.",
                    "enum": ALLOWED_STR_REPLACE_EDITOR_COMMANDS,
                    "type": "string",
                },
                "path": {
                    "description": "Absolute path to file or directory, e.g. `/testbed/file.py` or `/testbed`.",
                    "type": "string",
                },
                "file_text": {
                    "description": "Required for the `create` command, contains the content of the file to be created.",
                    "type": "string",
                },
                "old_str": {
                    "description": "Required for the `str_replace` command, specifies the string in `path` to replace.",
                    "type": "string",
                },
                "new_str": {
                    "description": "Optional for the `str_replace` command to specify the replacement string. Required for the `insert` command to specify the string to insert.",
                    "type": "string",
                },
                "insert_line": {
                    "description": "Required for the `insert` command. The `new_str` will be inserted AFTER the line specified.",
                    "type": "integer",
                },
                "view_range": {
                    "description": "Optional for the `view` command when `path` points to a file. Specifies the line range to view. E.g., [11, 12] shows lines 11 and 12. Indexing starts at 1. Use [start_line, -1] to show all lines from `start_line` to the end.",
                    "type": "array",
                    "items": {"type": "integer"},
                },
            },
            "required": ["command", "path"],
        },
    },
}


_R2EGYM_BASH_EXECUTE_DESCRIPTION = """
Description: Execute a bash command in the terminal.

Parameters:
  (1) command (string, required): The bash command to execute. For example: `python my_script.py`
"""

r2egym_bash_execute_tool = {
    "type": "function",
    "function": {
        "name": "execute_bash",
        "description": _R2EGYM_BASH_EXECUTE_DESCRIPTION,
        "parameters": {
            "type": "object",
            "properties": {
                "cmd": {
                    "type": "string",
                    "description": "The command (and optional arguments) to execute. For example: 'python my_script.py'",
                }
            },
            "required": ["cmd"],
        },
    },
}



_BASH_DESCRIPTION = """
Description: Execute a bash command in the terminal.

Parameters:
  (1) command (string, optional): The bash command to execute. For example: `python my_script.py`. If not provided, will show help.
"""

execute_bash_tool = {
    "type": "function",
    "function": {
        "name": "execute_bash",
        "description": _BASH_DESCRIPTION,
        "parameters": {
            "type": "object",
            "properties": {
                "command": {
                    "type": "string",
                    "description": "The command (and optional arguments) to execute. For example: 'python my_script.py'",
                }
            },
            "required": [],
        },
    },
}


_SEARCH_DESCRIPTION = """
Description: Search for a term in either a directory or a single file.

Behavior:
* If `--path` points to a directory (default is `.`), we recursively search all non-hidden files and directories.
* If `--path` points to a file, we run `grep -n` on that file to find line numbers containing the search term.
* If more than 100 files match (directory search scenario), the tool will stop listing and inform you to narrow your search.
* If no files are found that match your search term, the tool will inform you of that as well.

**Parameters:**
  1. **search_term** (`string`, required): The term to search for in files.
  2. **path** (`string`, optional): The file or directory in which to search. If not provided, defaults to the current directory (i.e., `.`).
"""

search_tool = {
    "type": "function",
    "function": {
        "name": "search",
        "description": _SEARCH_DESCRIPTION,
        "parameters": {
            "type": "object",
            "properties": {
                "search_term": {
                    "description": "The term to search for in files.",
                    "type": "string",
                },
                "path": {
                    "description": "The file or directory to search in. Defaults to `.` if not specified.",
                    "type": "string",
                },
            },
            "required": ["search_term"],
        },
    },
}

# V1 Finish
_FINISH_DESCRIPTION = """
"A simple finish tool with a 'submit' command.\n\n"
"Notes about the `submit` command:\n"
"* When invoked with `--result`, the provided string is used for submitting required task results.\n"
"* If no `--result` is provided, it defaults to an empty string.\n\n"
"**Parameters:**\n"
"  1. **command** (`string`, required): The command to run. Currently allowed option is: `submit`.\n"
"     - Allowed value: [`submit`]\n"
"  2. **result** (`string`, optional): The result text to submit. Defaults to an empty string.\n"
"""
finish_tool = {
    "type": "function",
    "function": {
        "name": "finish",
        "description": _FINISH_DESCRIPTION,
        "parameters": {
            "type": "object",
            "properties": {
                "command": {
                    "description": "The command to run. Currently only `submit` is supported.",
                    "type": "string",
                    "enum": ["submit"],
                },
                "result": {
                    "description": "Optional. The result text to submit. Defaults to an empty string if not provided.",
                    "type": "string",
                },
            },
            "required": ["command"],
        },
        # "cache_control": {"type": "ephemeral"},
    },
}

# V2 Submit
_SUBMIT_DESCRIPTION = """
A simple submit tool to finish tasks.

This tool signals completion of a task or submission of results.
No parameters required - simply call to indicate task completion.
"""

submit_tool = {
    "type": "function",
    "function": {
        "name": "submit",
        "description": _SUBMIT_DESCRIPTION,
        "parameters": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
}

think_tool =  {
                "type": "function",
                "function": {
                    "name": "think",
                    "description": "Use the tool to think about something. It will not obtain new information or make any changes to the repository, but just log the thought. Use it when complex reasoning or brainstorming is needed.\n\nCommon use cases:\n1. When exploring a repository and discovering the source of a bug, call this tool to brainstorm several unique ways of fixing the bug, and assess which change(s) are likely to be simplest and most effective.\n2. After receiving test results, use this tool to brainstorm ways to fix failing tests.\n3. When planning a complex refactoring, use this tool to outline different approaches and their tradeoffs.\n4. When designing a new feature, use this tool to think through architecture decisions and implementation details.\n5. When debugging a complex issue, use this tool to organize your thoughts and hypotheses.\n\nThe tool simply logs your thought process for better transparency and does not execute any code or make changes.",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "thought": {
                                "type": "string",
                                "description": "The thought to log."
                            }
                        },
                        "required": [
                            "thought"
                        ]
                    }
                }
            }

task_tracker_tool = {
    "type": "function",
    "function": {
        "name": "task_tracker",
        "description": "This tool provides structured task management capabilities for development workflows.\nIt enables systematic tracking of work items, progress monitoring, and efficient\norganization of complex development activities.\n\nThe tool maintains visibility into project status and helps communicate\nprogress effectively to users.\n\n## Application Guidelines\n\nUtilize this tool in the following situations:\n\n1. Multi-phase development work - When projects involve multiple sequential or\n   parallel activities\n2. Complex implementation tasks - Work requiring systematic planning and\n   coordination across multiple components\n3. Explicit user request for task organization - When users specifically ask\n   for structured task management\n4. Multiple concurrent requirements - When users present several work items\n   that need coordination\n5. Project initiation - Capture and organize user requirements at project start\n6. Work commencement - Update task status to in_progress before beginning\n   implementation. Maintain focus by limiting active work to one task\n7. Task completion - Update status to done and identify any additional work\n   that emerged during implementation\n\n## Situations Where Tool Usage Is Unnecessary\n\nAvoid using this tool when:\n\n1. Single atomic tasks that require no decomposition\n2. Trivial operations where tracking adds no organizational value\n3. Simple activities completable in minimal steps\n4. Pure information exchange or discussion\n\nNote: For single straightforward tasks, proceed with direct implementation\nrather than creating tracking overhead.\n\n## Usage Scenarios\n\n**Scenario A: Feature Development with Validation**\nUser request: \"Build a user authentication system with login/logout functionality.\nDon't forget to include input validation and error handling!\"\n\nResponse approach: I'll implement a user authentication system with comprehensive\nvalidation. Let me organize this work systematically.\n\n*Task breakdown includes:*\n1. Design authentication API endpoints and data models\n2. Implement user login/logout controllers with session management\n3. Add client-side form validation and error display\n4. Create backend input sanitization and security checks\n5. Implement comprehensive error handling for edge cases\n6. Perform integration testing and fix any issues\n\n**Scenario B: Codebase Refactoring**\nUser request: \"I need to update all instances of the method 'fetchData' to\n'retrieveInformation' throughout the entire project\"\n\nResponse approach: Let me first analyze your codebase to identify all locations\nwhere 'fetchData' appears.\n\n*After code analysis*\n\nI've located 12 occurrences of 'fetchData' across 6 files in your project.\nI'll create a systematic plan to update these references.\n\n*Organized task list includes specific file-by-file updates*\n\n**Scenario C: Multi-feature Development**\nUser request: \"Set up a blog platform with these components: admin dashboard,\narticle management, comment system, and user profiles.\"\n\nResponse approach: I'll help build your blog platform. Let me break down these\ncomponents into manageable implementation phases.\n\n*Creates structured plan with each feature decomposed into specific development tasks*\n\n## Counter-examples - Direct Implementation Preferred\n\n**Counter-example A: Simple inquiry**\nUser request: \"What's the syntax for a for loop in JavaScript?\"\n\nResponse approach: Here's how to write a for loop in JavaScript:\n\n```javascript\nfor (let i = 0; i < array.length; i++) {\n    console.log(array[i]);\n}\n```\n\n*No task tracking needed - single informational response*\n\n**Counter-example B: Minor modification**\nUser request: \"Please add a docstring to the processPayment function explaining\nits parameters.\"\n\nResponse approach: I'll add a docstring to explain the processPayment function.\n\n*Direct edit without task tracking for simple modification*\n\n## Status Management and Workflow\n\n1. **Status Values**: Track work using these states:\n   - todo: Not yet initiated\n   - in_progress: Currently active (maintain single focus)\n   - done: Successfully completed\n\n2. **Workflow Practices**:\n   - Update status dynamically as work progresses\n   - Mark completion immediately upon task finish\n   - Limit active work to ONE task at any given time\n   - Complete current activities before initiating new ones\n   - Remove obsolete tasks from tracking entirely\n\n3. **Completion Criteria**:\n   - Mark tasks as done only when fully achieved\n   - Keep status as in_progress if errors, blocks, or partial completion exist\n   - Create new tasks for discovered issues or dependencies\n   - Never mark done when:\n       - Test suites are failing\n       - Implementation remains incomplete\n       - Unresolved errors persist\n       - Required resources are unavailable\n\n4. **Task Organization**:\n   - Write precise, actionable descriptions\n   - Decompose complex work into manageable units\n   - Use descriptive, clear naming conventions\n\nWhen uncertain, favor using this tool. Proactive task management demonstrates\nsystematic approach and ensures comprehensive requirement fulfillment.\n",
        "parameters": {
            "type": "object",
            "properties": {
                "command": {
                    "type": "string",
                    "enum": [
                        "view",
                        "plan"
                    ],
                    "description": "The command to execute. `view` shows the current task list. `plan` creates or updates the task list based on provided requirements and progress. Always `view` the current list before making changes."
                },
                "task_list": {
                    "type": "array",
                    "description": "The full task list. Required parameter of `plan` command.",
                    "items": {
                        "type": "object",
                        "properties": {
                            "id": {
                                "type": "string",
                                "description": "Unique task identifier"
                            },
                            "title": {
                                "type": "string",
                                "description": "Brief task description"
                            },
                            "status": {
                                "type": "string",
                                "description": "Current task status",
                                "enum": [
                                    "todo",
                                    "in_progress",
                                    "done"
                                ]
                            },
                            "notes": {
                                "type": "string",
                                "description": "Optional additional context or details"
                            }
                        },
                        "required": [
                            "title",
                            "status",
                            "id"
                        ],
                        "additionalProperties": False
                    }
                }
            },
            "required": [
                "command"
            ],
            "additionalProperties": False
        }
    }
}

           
           
            
