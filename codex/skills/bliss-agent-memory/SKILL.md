---
name: bliss-agent-memory
description: Use when working on the Bliss project with multiple Codex agents and you need stable project memory, role-specific briefings, shared knowledge-base guidance, or per-agent worklog discipline.
---

# Bliss Agent Memory

Use this skill when Codex is doing parallel or role-based work on the `Bliss` project.

## Purpose

Keep all agents aligned on:
- the shared product brief
- the child experience constraints
- the V1 curriculum and puzzle taxonomy
- ownership boundaries between agents
- the distinction between shared durable decisions and local working notes

## Memory Model

Use this structure:
- `docs/knowledge-base/`: shared canonical knowledge base
- `docs/agents/shared-project-memory.md`: shared durable project memory
- `docs/agents/<role>-agent.md`: role scope and ownership
- `docs/agents/worklogs/<role>-agent.md`: role-local working memory
- `docs/TASKS.md`: global `todo / in progress / done / blocked` tracker
- `docs/WORK_LOG.md`: chronological execution log

Shared knowledge stays shared.

Agent-local worklogs are for temporary notes, in-progress reasoning, local risks, and handoff-ready task context.

## Read Order

Before substantial work, read these files in order:
1. `docs/knowledge-base/README.md`
2. `docs/agents/shared-project-memory.md`
3. the role file that matches your assigned agent
4. the matching worklog in `docs/agents/worklogs/`
5. `docs/TASKS.md`

Then read only the specific knowledge-base files relevant to the task.

## Project Rules

- Treat `/Users/vasilibraga/Downloads/Bliss` as a reference knowledge source, not the new codebase.
- Treat `/Users/vasilibraga/bliss` as the new project root.
- Preserve the V1 constraints: offline-first, Android-first, Godot, calm UX, no timers, no failure screens, minimal text, sound effects only.
- The child flow is a learning game first, not yet a full communication tool.
- Symbols should be paired with generated pictures in V1.
- For this project, the lead agent should not perform normal feature implementation by default; specialist or worker agents should own execution, with the lead coordinating and integrating.

## Update Rules

Update `docs/agents/shared-project-memory.md` when:
- a product decision changes
- a new cross-cutting technical constraint appears
- a content or asset rule affects multiple teams
- a fact becomes important for more than one role

Update a role file when:
- the role's ownership changes
- its contracts change
- its required inputs or outputs change

Update a worklog when:
- the role starts or changes a task
- new local risks appear
- a temporary implementation note matters for the next handoff
- work is in progress but not yet durable enough for shared memory

Update `docs/TASKS.md` when:
- a task starts
- a task completes
- a task becomes blocked
- a new concrete follow-up task appears

Update `docs/WORK_LOG.md` when:
- a meaningful implementation or planning chunk finishes
- a milestone changes state
- a validation step materially changes confidence in the project state

## Trigger Hooks

These hooks are mandatory.

### Before Starting A Meaningful Task
- make sure the task exists in `docs/TASKS.md`
- move it to `In Progress`
- if the task is implementation, record which agent owns execution

### After Completing A Meaningful Task
- append a concise entry to `docs/WORK_LOG.md`
- update the role worklog
- move the task to `Done` or `Blocked`

### When Durable Information Emerges
- update shared project memory
- update the knowledge base if canonical docs changed

Update knowledge-base files when:
- the canonical product brief evolves
- puzzle taxonomy changes
- curriculum scope changes
- technical principles change

## Ownership Discipline

- Do not redefine product scope from inside a technical task.
- Do not change curriculum decisions from inside a rendering task.
- Do not change architecture contracts from inside content authoring unless the architecture owner agrees.
- Promote only stable cross-role information into shared memory.
- Keep local speculation in the worklog until it is validated.

## Role Files

Available agent briefings:
- `docs/agents/lead-agent.md`
- `docs/agents/game-design-agent.md`
- `docs/agents/godot-architecture-agent.md`
- `docs/agents/gameplay-agent.md`
- `docs/agents/content-agent.md`
- `docs/agents/asset-agent.md`
- `docs/agents/parent-progress-agent.md`
- `docs/agents/qa-agent.md`
- `docs/agents/ba-agent.md`
- `docs/agents/ui-ux-agent.md`

Matching worklogs:
- `docs/agents/worklogs/lead-agent.md`
- `docs/agents/worklogs/game-design-agent.md`
- `docs/agents/worklogs/godot-architecture-agent.md`
- `docs/agents/worklogs/gameplay-agent.md`
- `docs/agents/worklogs/content-agent.md`
- `docs/agents/worklogs/asset-agent.md`
- `docs/agents/worklogs/parent-progress-agent.md`
- `docs/agents/worklogs/qa-agent.md`
- `docs/agents/worklogs/ba-agent.md`
- `docs/agents/worklogs/ui-ux-agent.md`

## Knowledge Base Files

Core references:
- `docs/knowledge-base/product-brief.md`
- `docs/knowledge-base/puzzle-taxonomy.md`
- `docs/knowledge-base/curriculum-v1.md`
- `docs/knowledge-base/technical-principles.md`

Load only what the task needs.
