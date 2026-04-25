# Main Progress Architecture

Status: implementation contract for `MainProgressScreen` V1

Inputs:
- [MAIN_PROGRESS_SCREEN_DECISION.md](./MAIN_PROGRESS_SCREEN_DECISION.md)
- [MAIN_PROGRESS_FLOW.md](./MAIN_PROGRESS_FLOW.md)
- [ARCHITECTURE.md](./ARCHITECTURE.md)
- [agents/shared-project-memory.md](./agents/shared-project-memory.md)

## Screen Ownership

- The root app scene and its controller own screen swapping, navigation decisions, and save-commit sequencing.
- `HomeScreen` stays a single-action child entry surface and never resolves node ordering, unlock rules, or session content.
- `MainProgressScreen` owns only between-session presentation of a prepared node path and emits selection/navigation signals.
- `SessionScreen` owns active session runtime, round progression, and summary handoff.
- `SessionSummaryScreen` owns end-of-session presentation, then asks the app controller to commit completion and return to `MainProgressScreen`.
- Parent-entry screens remain outside this child path except for the hidden `HomeScreen` access pattern.

## Node Data Source

- Source of truth for progression nodes is authored progression data, not direct reads from curriculum concept JSON.
- Add or load a dedicated read-only source such as `res://data/progression/progression_nodes.json` plus referenced session-template data.
- `ContentDB` loads ordered node definitions keyed by `node_id`.
- Each authored node definition should include at minimum:
  - `node_id`
  - `node_type`
  - `release_phase`
  - `session_template_id`
  - `primary_category_id`
  - `sort_order`
  - optional prerequisite or review metadata
- Curriculum concept rows remain inputs to session planning only; `MainProgressScreen` must not query concept JSON directly.

## Data Provider Responsibilities

- Introduce a narrow runtime helper, recommended as `MainProgressFlowProvider` under `scripts/progression/`.
- The provider combines read-only node defs from `ContentDB` with durable progression state from `AppState`.
- Inputs:
  - ordered node defs
  - completed node ids
  - last played or just completed node id
  - current unlocked release phase
- Output: a prepared `MainProgressScreenModel` containing:
  - visible `nodes`
  - `next_node_id`
  - `focused_node_id`
  - `current_release_phase`
  - optional `just_completed_node_id`
- Each node sent to the screen must already include `state` and use only visible screen states: `completed`, `next`, `available`, or `locked`.
- `hidden` remains provider-internal and should be filtered before the screen model is built.
- Exactly one node may be `next`.
- Completed nodes remain replayable.
- `available` is reserved for future visible unlocked nodes that are not the single main `next`; V1 may emit none.
- Non-responsibilities:
  - no scene instantiation
  - no save writes
  - no file IO
  - no per-round session logic

## Navigation Flow

1. `BootScreen` loads `ContentDB` and save data, then routes to `HomeScreen`.
2. Child taps play on `HomeScreen`.
3. The app controller asks `MainProgressFlowProvider` for a prepared screen model and opens `MainProgressScreen`.
4. `MainProgressScreen` renders that model and emits `node_selected(node_id)` only for `next` or replayable nodes.
5. The app controller resolves the selected node into a `SessionPlan` using `session_template_id`, then opens `SessionScreen`.
6. `SessionScreen` runs normally and passes a summary payload plus completed `node_id` to `SessionSummaryScreen`.
7. On summary continue, the app controller updates `AppState`, persists through `SaveService`, rebuilds the progress model, and returns to `MainProgressScreen`.

## Scene And Script Boundaries

- `scenes/app/main.tscn` with its controller script owns screen swaps, provider calls, and post-summary commit flow.
- `scenes/screens/main_progress_screen.tscn` with `scripts/screens/main_progress_screen.gd` is presentation-only.
- `MainProgressScreen` binds supplied node view-model data, manages focus/animation state, and forwards taps.
- A reusable node scene such as `scenes/components/main_progress_node.tscn` may handle visuals and tap feedback, but not unlock logic.
- `SessionSummaryScreen` reports completion upward; it does not derive unlocks or pick the next node itself.
- `SessionScreen` and puzzle scenes continue to consume prepared runtime data only and remain isolated from progression-node resolution.

## Required Autoloads And Runtime Helpers

- `ContentDB` must load progression node definitions and any referenced session-template records in addition to curriculum data.
- `AppState` must expose completed node ids, current unlocked release phase, and the last played or just completed node id from the loaded save snapshot.
- `SaveService` remains the single durable write path for node-completion updates.
- No new broad navigation singleton is required; navigation should stay in the root app controller.
- Recommended new helper: `MainProgressFlowProvider`.
- Optional separate helper: `SessionPlanBuilder`, only if session-plan assembly is not already covered elsewhere.

## Guardrails

- `MainProgressScreen` must not read JSON directly, mutate save data, or compute curriculum selection rules.
- Unlocking remains based on session completion, never stars.
- V1 keeps one fixed non-scroll path with one obvious `next` node.
- Parent-progress reporting remains a separate read model and does not leak onto this child-facing screen.
