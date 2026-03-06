# AI Task Orchestration & State Rules

To maintain consistency and prevent context loss during complex operations, you MUST follow this protocol.

## Task Management (Internal Memory)

- **CRITICAL:** At the start of any multi-step task, use the `todowrite` tool to initialize a checklist.
- **SYNC:** Update the checklist using `todowrite` as each sub-task is completed.
- **RECOVERY:** Always use `todoread` at the beginning of a session to resume progress.

## Plan Persistence (External Memory)

- For operations involving more than 3 steps, document the architecture in `.opencode/plans/current_plan.md`.
- You are authorized to create the `.opencode/plans/` directory if it does not exist.
- Use this file to store technical decisions and dependency graphs, replacing the need for external tools like beads.
