# Milestones

This folder is the execution layer for the Bliss multi-agent workflow.

Use it after product ambiguity has been reduced by the BA agent and the lead agent is ready to coordinate real work.

## Purpose

Milestones turn the project brief into bounded delivery targets.

Each milestone should define:
- the goal
- the scope
- the required agents
- the expected outputs
- the exit criteria
- the handoff rules

## Workflow

1. BA agent clarifies the product problem if needed.
2. Lead agent selects or creates the active milestone.
3. Lead agent assigns work to specialist agents.
4. Specialists update their worklogs while working.
5. Lead agent integrates outputs.
6. QA agent reviews the integrated result.
7. Lead agent closes the milestone or splits the next one.

## Rules

- Only the lead agent should mark a milestone active or complete.
- A milestone should be small enough to review as one coherent unit.
- If a milestone becomes ambiguous, route back to the BA agent before more implementation work.
- If a milestone changes the product brief, update the knowledge base and shared project memory.

## Files

- `backlog.md`: candidate milestones and their status
- `milestone-1-foundation.md`: first concrete execution target for the project
