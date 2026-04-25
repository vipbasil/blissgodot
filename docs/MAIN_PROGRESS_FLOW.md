# Main Progress Flow

## Purpose

- `MainProgressFlowScreen` is the between-session progression view shown after `SessionSummaryScreen` and before the next `SessionScreen`.
- It selects the next session-sized content node, not individual rounds inside a session.
- The child-facing flow must still present one obvious forward action; progression visibility is secondary to starting the next playable session.

## Screen Role

- `HomeScreen` remains the first child entry surface for Milestone 1 and should not become a dense progress dashboard.
- Tapping the child play affordance can route into `MainProgressFlowScreen` once more than one authored session node exists.
- After a completed session, the app should return here with the just-finished node marked complete and the next playable node highlighted.

## Node Model

Each node represents one launchable session bundle:

- one authored `session_template_id`
- one primary puzzle type; Milestone 1 uses only `anchor_match`
- one content slice or review mix inside a release phase and progression band
- one position in a fixed linear path for V1

## Node States

- `hidden`: future node is not yet revealed because its `release_phase` is unavailable.
- `locked`: node is visible in the path but cannot be started yet because its prerequisite node is incomplete.
- `next`: single current playable node; this is the default focus and primary call to action.
- `completed`: node session has been finished at least once and can be replayed.
- `replay_ready`: optional presentation variant of `completed` when a node is recommended for review but is not required for forward progression.

For Milestone 1, only one node should ever be in `next` state at a time.

## Unlock Rules

- Completing a node session unlocks the next node in authored order.
- Unlocking depends on session completion only, never on star count.
- A node counts as completed as soon as the session reaches summary, including supported-success-heavy runs.
- Nodes from a later `release_phase` stay `hidden` until the current phase completion rule or content configuration enables that phase.
- Optional review nodes may unlock inside the current phase without replacing the single main `next` node.

## Next-Play Affordance

- Show one primary `Play` or `Continue` control bound to the single `next` node.
- Activating the primary control should launch the next node immediately without requiring a prior selection step.
- After completing a session, the primary control should advance to the newly unlocked node by default.
- Completed nodes may stay visible for replay, but they must not compete visually with the primary next-play action.

## Tap Behavior

- Tapping the `next` node launches its `SessionPlan`.
- Tapping a `completed` node replays that node's session bundle.
- Tapping a `locked` node should give a calm non-blocking response such as a brief lock pulse; do not open a heavy modal or fail screen.
- `hidden` nodes are not interactable because they are not rendered as active content.
- Swiping, free map panning, or branching route exploration are out of scope for V1; keep the path fixed and fully readable on one screen.

## Relation To Sessions And Content Phases

- Node choice happens between sessions, never between rounds inside `SessionScreen`.
- Each launched node still runs one normal session contract. In Milestone 1 that means `8` `Anchor Match` rounds.
- `release_phase` controls which authored node sets can appear at all.
- `progression_band_start` on concepts and content limits which concepts a node may draw from, but unlock state resolves at the node and session level.
- Milestone 1 should ship with only `release_phase: 1`, `band_a`, and `anchor_match` nodes using the first concept slice plus authored review repeats.

## Runtime Data Needed

### Static Content Data

- `progression_nodes`: ordered array of node defs with `id`, `sort_order`, `release_phase`, `session_template_id`, `puzzle_type`, `concept_pool` or `session_content_ids`, and optional `prerequisite_node_ids`
- optional phase metadata such as `phase_id`, `display_name`, and `enabled`

### Durable Save Data

- `completed_node_ids`
- `last_unlocked_node_id`
- `last_played_node_id`
- `completed_session_count`
- existing per-concept progression stats already stored in save data
- optional per-node best summary display data such as latest star result; never use this for unlocking

### Transient Runtime State

- `focused_node_id`
- `next_node_id`
- `just_completed_node_id`
- prepared `SessionPlan` for the node being launched

## Non-Goals

- branching map logic
- star-gated progression
- round-by-round node updates
- turning the child flow into a parent progress dashboard
