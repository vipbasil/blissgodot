# Main Progress Screen Decision

Status: approved for implementation planning

Inputs:
- [MAIN_PROGRESS_SCREEN_UI.md](./MAIN_PROGRESS_SCREEN_UI.md)
- [MAIN_PROGRESS_FLOW.md](./MAIN_PROGRESS_FLOW.md)

Owner: Lead

## Decision

The project should replace the current plain `HomeScreen -> SessionScreen` child flow with:

1. `HomeScreen`
2. `MainProgressScreen`
3. `SessionScreen`
4. `SessionSummaryScreen`
5. back to `MainProgressScreen`

`HomeScreen` remains a single-action launch surface.

`MainProgressScreen` becomes the child-facing between-puzzles screen.

## Approved Direction

### What The Screen Is

- a calm short-journey progression surface
- spatial rather than menu-like
- one obvious next playable node
- replayable earlier nodes kept available but visually secondary
- hidden parent entry kept small and off the main path

### What The Screen Is Not

- not a replacement parent progress report
- not a dense level-select map
- not a content dashboard
- not a grid of equal puzzle choices

## Approved Structural Rules

- show a short visible path, not a long scrolling world
- target `5` visible nodes as the first implementation default
- exactly one node should be `next`
- completed nodes remain replayable
- locked nodes remain visible but quiet
- unlocking is based on session completion, not stars
- supported-success completion still advances unlock progression

## Approved Visual Rules

- use a curved or gently stepped path as the organizing shape
- keep the current/next node as the strongest focal point
- keep the path itself visually subordinate to the nodes
- avoid busy scrapbook texture or highly saturated path colors from the MITA reference
- use minimal text on the child-facing surface
- keep the parent access small, neutral, and top-right

## Approved Node States

- `completed`
- `next`
- `available`
- `locked`

No `failed` state should exist.

## Approved Runtime Contract

Implementation should expect prepared runtime data rather than reading curriculum JSON directly from the screen.

Minimum conceptual inputs:

- ordered `nodes`
- one `next_node_id`
- current unlocked release phase
- completed node ids

Each node should resolve at minimum:

- `node_id`
- `node_type`
- `release_phase`
- `session_template_id`
- `primary_category_id`
- `sort_order`
- `state`

## First-Pass Product Mapping

For the first implementation:

- each node maps to one short session entry point
- early nodes should emphasize `Anchor Match`
- phase 2 nodes should appear when phase 2 unlocks
- earlier nodes must remain replayable after later nodes appear

## MITA Reference Decision

Approved to borrow:

- short spatial journey feeling
- large node-based progression
- visually obvious next destination

Explicitly rejected:

- busy textured background
- tiny corner controls
- saturated dominant path color
- multiple equal focal points
- bright parent-entry buttoning

## Implementation Guardrails

When implementation starts:

- do not mix this work with threshold tuning
- do not mix this work with parent-progress refactors
- do not expose stats or mastery labels to the child flow
- do not make the screen scrollable in the first pass

## Next Step

Before code:

1. create a `MAIN_PROGRESS_IMPLEMENTATION_PLAN.md`
2. define the runtime node-data source and navigation contract
3. then implement the screen replacement for the current simple home-to-session transition
