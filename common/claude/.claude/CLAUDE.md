# Subagent models

Opus is the floor. Never pass `sonnet`, `haiku` or `fable` as the `model` of a subagent,
a workflow agent, or an agent hook — not for a "mechanical" task, not for a "cheap"
review, not to save a round trip. Either pass an opus model explicitly or omit `model` so
the agent inherits the session's.

This overrides the cost-saving advice in the superpowers skills, which tell you to pick
the least powerful model that can do each job. The user has weighed that and chosen
quality. `availableModels` in `~/.claude/settings.json` enforces the same rule at the
harness level; this instruction is what stops you asking for a cheaper one in the first
place.
