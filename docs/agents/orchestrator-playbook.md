# Orchestrator Playbook

This file defines how the Bliss multi-agent workflow should operate.

## Roles

- `BA agent`: interrogates product ambiguity and clarifies requirements
- `Lead agent`: orchestrates milestones, delegates work, resolves conflicts, and integrates outputs
- `Specialist agents`: produce focused outputs within their ownership boundaries

## Workflow Constraint

For this project, feature work should follow a strict separation:
- the lead agent plans, routes, reviews, and integrates
- specialist or worker agents perform the feature implementation
- the lead agent should not absorb normal feature implementation work into the main thread

Allowed exceptions:
- tiny integration glue after specialist delivery
- documentation or tracker updates
- emergency fixes when a specialist path is unavailable and the user explicitly accepts that fallback

## Core Rule

If the product is unclear, the BA agent goes first.

If the product is clear enough to execute, the lead agent goes first.

## When To Use The BA Agent

Use the BA agent when:
- the user is unsure what they want
- the request is vague or contradictory
- the product scope is unstable
- the team is mixing product decisions with technical decisions
- implementation would be premature without clarification
- the user wants to think through the product, audience, feature set, or constraints

The BA agent should:
- ask short rounds of concrete questions
- summarize current understanding before asking more
- expose contradictions and tradeoffs
- convert answers into a clarified brief
- stop once the problem is clear enough for execution

## BA Handoff To Lead

The BA agent hands off to the lead agent when it can provide:
- a clear problem statement
- stable V1 goals
- important constraints
- open questions that still remain
- a recommendation about what should be built next

The handoff should update:
- `docs/agents/worklogs/ba-agent.md`
- `docs/agents/shared-project-memory.md` if durable product decisions were made
- any affected files in `docs/knowledge-base/`

## When The Lead Agent Takes Over

The lead agent takes over when:
- the product is clear enough for design or implementation
- a milestone needs to be defined
- multiple specialists need coordination
- outputs from several agents need integration
- there is a conflict between specialist outputs

The lead agent should:
- define the milestone
- choose which agents are needed
- assign bounded tasks with clear ownership
- avoid overlapping write scopes where possible
- review outputs and integrate them
- update shared memory when decisions become durable
- avoid doing normal feature implementation directly when a specialist or worker should own it

## When To Use Specialist Agents

Use specialist agents only after the task is clear enough.

### Game Design Agent
Use when the team needs:
- puzzle rules
- difficulty ramps
- mastery logic
- session design

### Godot Architecture Agent
Use when the team needs:
- scene structure
- save/load architecture
- autoload decisions
- module boundaries

### Gameplay Agent
Use when the team needs:
- drag-and-drop behavior
- puzzle scenes
- feedback interactions
- reusable gameplay components

### Content Agent
Use when the team needs:
- curriculum definitions
- concept lists
- category assignments
- content metadata

### Asset Agent
Use when the team needs:
- asset naming rules
- generated picture pipeline
- symbol-to-asset mapping
- style consistency decisions

### Parent Progress Agent
Use when the team needs:
- hidden parent flow
- progress metrics
- parent screens
- progress summaries


### UI/UX Agent
Use when the team needs:
- child-facing layout rules
- calmness and readability standards
- parent-facing presentation guidance
- component and motion guidance

### QA Agent
Use when the team needs:
- review findings
- bug and regression checks
- overstimulation risk checks
- testing gaps

## Delegation Rules

- one agent must own final integration: the lead agent
- each specialist should get a narrow scope
- do not send unresolved product ambiguity to technical agents
- do not let specialists redefine product goals from inside implementation tasks
- if a task affects more than one role, the lead agent coordinates it
- implementation tasks should be assigned to the appropriate specialist or worker, not retained by the lead agent by default

## Memory Rules

Every agent should read, in order:
1. `docs/knowledge-base/README.md`
2. `docs/agents/shared-project-memory.md`
3. its role file
4. its worklog
5. `docs/TASKS.md`

Then it should read only the additional knowledge-base files needed for the task.

## Update Rules

### Update Shared Project Memory When
- a decision affects multiple roles
- a stable fact should persist across sessions
- a cross-cutting technical or product constraint appears

### Update A Role Worklog When
- a task starts
- a local risk appears
- there is useful temporary reasoning or implementation context
- a handoff is needed but the information is not yet durable enough for shared memory

### Update `docs/TASKS.md` When
- a task starts and should move into `In Progress`
- a task is completed and should move into `Done`
- a task becomes blocked and needs a blocker note
- a new concrete task is discovered and should be added to `Todo`

### Update `docs/WORK_LOG.md` When
- a meaningful implementation or planning chunk finishes
- a milestone changes state
- a significant integration, validation, or project-shaping decision happens

## Execution Hooks

These are mandatory workflow hooks, not optional reminders.

### Hook 1: Before Work Starts
- confirm the task exists in `docs/TASKS.md`
- if it does not exist, add it
- move it to `In Progress` before doing substantial work
- record which agent owns execution of the task if the work is implementation rather than planning

### Hook 2: After Meaningful Work Finishes
- append a short entry to `docs/WORK_LOG.md`
- update the relevant role worklog
- promote durable cross-role decisions to shared memory if needed

### Hook 3: On Completion
- move the task from `In Progress` to `Done`
- if follow-up work was created, add that follow-up to `Todo`

### Hook 4: On Blockers
- move the task to `Blocked`
- record the blocker in `docs/TASKS.md`
- record any local context in the role worklog
- escalate to BA or lead depending on whether the blocker is product or execution related

### Update Knowledge Base When
- the canonical product brief changes
- the puzzle taxonomy changes
- the curriculum changes
- the technical principles change

## Default Execution Sequence

1. Determine whether the task is unclear or clear.
2. If unclear, route to BA agent.
3. BA agent interrogates and clarifies.
4. BA agent updates memory and briefs.
5. Lead agent defines the milestone.
6. Lead agent delegates to specialists.
7. Specialists work within role boundaries and own the actual implementation for their slice.
8. Specialists update `docs/TASKS.md`, `docs/WORK_LOG.md`, and their worklogs as required by the hooks above.
9. Lead agent integrates outputs rather than replacing specialist execution.
10. QA agent reviews the integrated result.
11. Lead agent resolves findings and updates shared memory.

## Example Routing

### Example 1: User says “I’m not sure what this product should be.”
- Route to BA agent.

### Example 2: User says “Define the Godot architecture for the current V1 brief.”
- Route to lead agent first, then Godot architecture agent.

### Example 3: User says “Implement the first puzzle.”
- Route to lead agent first, then gameplay agent, with game design support if needed.

### Example 4: User says “Review what we built and tell me what is wrong.”
- Route to QA agent, coordinated by lead if other follow-up work is needed.
