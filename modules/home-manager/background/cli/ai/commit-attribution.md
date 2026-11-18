# Commit attribution

When creating a commit with AI assistance, include this trailer in its footer:

```text
Assisted-by: Agent Name (Model Name)
```

Use the tool's display name, such as `Claude Code` or `Codex`, and the actual
model used for the work. For example, a Claude Code session using Claude Opus
5.5 would write `Assisted-by: Claude Code (Claude Opus 5.5)`.
Use the model identity supplied by the session; do not infer it from a default
configuration or copy the example's model. If the exact model is unavailable,
use `Assisted-by: Agent Name` rather than inventing one.

Use `Assisted-by` for AI attribution instead of an AI `Co-Authored-By` trailer.
Preserve human co-author trailers. If multiple AI systems contributed, include
one `Assisted-by` trailer per contributing system.
