# Main Progress Implementation Plan

Status: architecture-approved planning baseline

Owner: Architecture

Depends on:
- [MAIN_PROGRESS_SCREEN_DECISION.md](./MAIN_PROGRESS_SCREEN_DECISION.md)
- [MAIN_PROGRESS_SCREEN_UI.md](./MAIN_PROGRESS_SCREEN_UI.md)
- [MAIN_PROGRESS_FLOW.md](./MAIN_PROGRESS_FLOW.md)
- [MAIN_PROGRESS_ARCHITECTURE.md](./MAIN_PROGRESS_ARCHITECTURE.md)
- [ARCHITECTURE.md](./ARCHITECTURE.md)

Purpose: define the approved implementation order and ownership boundaries for replacing the current child flow with `MainProgressScreen` in Godot without mixing in gameplay redesign, parent-progress refactors, or generic framework work.

## Approved Outcome

Replace the current child flow:

`HomeScreen -> SessionScreen -> SessionSummaryScreen -> HomeScreen`

with:

`HomeScreen -> MainProgressScreen -> SessionScreen -> SessionSummaryScreen -> MainProgressScreen`

The architecture-approved V1 must preserve these product rules:

- one obvious `next` node
- completed nodes stay replayable
- locked nodes stay visible but quiet
- release-phase gating controls which future nodes can appear
- supported success still advances progression
- summary remains the commit gate before durable progression is updated

## Architecture Decisions Locked By This Plan

These points are no longer open design questions for implementation:

- Runtime route id is `main_progress`. Do not introduce `main_progress_flow` as a competing route or file prefix.
- `MainProgressScreen` is presentation-only. It renders a prepared model and emits navigation requests.
- Authored progression order comes from dedicated progression data, not from curriculum concept rows and not from screen scripts.
- `ContentDB` owns read-only progression-node and session-template loading.
- `AppState` owns normalized durable save state and progression writes, but it does not own visible-node resolution.
- A narrow provider layer, recommended as `scripts/progression/main_progress_flow_provider.gd`, owns visible-node resolution by combining `ContentDB` data with `AppState` save state.
- `scripts/app/main.gd` owns navigation, screen swapping, and post-summary commit sequencing.
- `SessionScreen` runs the supplied `session_plan` only. It must stop selecting the next session locally.
- `SessionSummaryScreen` displays results only. It must not write save data or decide the next node.

## Current Baseline The Plan Must Respect

Current repo facts:

- `scripts/app/main.gd` swaps screens through `navigate_to(screen_id, payload)`.
- `scripts/screens/home_screen.gd` currently routes `Play` directly to `session`.
- `scripts/screens/session_screen.gd` currently builds its own session through `ContentDB.build_first_playable_session_plan(...)`.
- `scripts/screens/session_screen.gd` currently writes progression immediately through `AppState.record_session_results(results)`.
- `scripts/screens/session_summary_screen.gd` currently routes `Continue` back to `home`.
- `autoload/content_db.gd` already owns release-phase lookup and session-plan assembly.
- `autoload/app_state.gd` currently owns save normalization and parent-progress derivation.
- `autoload/save_service.gd` is already the single durable write path and must remain that path.

The main architectural correction required by this plan is to remove next-node selection from `SessionScreen` and visible-node resolution from screen code, while also moving save-commit timing from session end to summary acceptance.

## File Ownership

Implementation ownership is approved as follows.

### Read-Only Authored Data

- `data/progression/progression_nodes.json`
  source of truth for authored node order, release-phase membership, and per-node session-template reference
- `data/progression/session_templates.json`
  optional only if node-to-session assembly cannot stay in existing config data cleanly; if added, keep it read-only and loaded by `ContentDB`

### Content Loading And Read Models

- `autoload/content_db.gd`
  load progression node defs, load any referenced session-template defs, filter by release phase, and build a `session_plan` for a selected node
- `scripts/progression/main_progress_flow_provider.gd`
  combine node defs plus save state into a prepared `MainProgressScreen` model with derived node states

### Durable State

- `autoload/app_state.gd`
  normalize save shape, expose progression snapshot inputs, record node completion after summary acceptance, and persist via `SaveService`
- `autoload/save_service.gd`
  carry the expanded save payload safely with backward-compatible normalization

### Navigation And Screen Integration

- `scripts/app/main.gd`
  register `main_progress`, own route transitions, own post-summary commit sequencing, and pass prepared payloads into screens
- `scripts/screens/home_screen.gd`
  send child play to `main_progress`
- `scripts/screens/session_screen.gd`
  consume `node_id` plus prepared `session_plan`; emit session results upward only
- `scripts/screens/session_summary_screen.gd`
  consume `node_id` plus results; emit continue upward only

### Presentation

- `scenes/screens/main_progress_screen.tscn`
  screen layout for the child-facing path
- `scripts/screens/main_progress_screen.gd`
  bind prepared model, manage local focus and animation state, and emit launch requests
- `scenes/components/main_progress_node.tscn`
  optional reusable node visual scene
- `scripts/components/main_progress_node.gd`
  optional node visual behavior and tap feedback only

V1 does not approve:

- a new global progression singleton
- a generic map framework
- branching-route infrastructure
- a second save subtree for the same progression facts

## Runtime Boundaries

### `ContentDB`

Owns:

- loading `progression_nodes.json`
- validating authored node defs
- resolving `release_phase` availability
- building `session_plan` for a specific `node_id`

Does not own:

- visible node state
- focused node choice
- save writes
- scene routing

### `MainProgressFlowProvider`

Owns:

- deriving visible node list for the current release phase
- mapping each visible node to `completed`, `next`, `available`, or `locked`
- selecting `next_node_id`
- selecting `focused_node_id`
- hiding provider-internal `hidden` nodes before the screen model is built

Does not own:

- file IO
- save writes
- screen instantiation
- puzzle-round logic

### `AppState`

Owns:

- normalized loaded save snapshot
- completed-node persistence
- completed-session counters
- concept progression stats
- parent-progress derivation

Does not own:

- authored node ordering
- visible path shaping
- UI focus selection rules beyond exposing raw save inputs

### `scripts/app/main.gd`

Owns:

- route registration
- screen swapping
- building the `MainProgressScreen` payload through the provider
- resolving `node_id` into `session_plan` through `ContentDB`
- commit sequencing after summary continue

Does not own:

- authored data storage
- per-node UI rendering
- gameplay scoring rules

### `MainProgressScreen`

Owns:

- rendering the supplied node path
- local tap routing for allowed nodes
- local reveal and settle animation state
- forwarding `parent_gate` access through the existing parent flow

Does not own:

- JSON reads
- save writes
- unlock rules
- session-plan assembly

### `SessionScreen`

Owns:

- running one prepared session
- round progression
- collecting results
- emitting summary payload

Does not own:

- choosing the next node
- persisting completion
- rebuilding session plans when payload is missing

### `SessionSummaryScreen`

Owns:

- rendering summary feedback
- emitting continue

Does not own:

- save writes
- node unlock logic
- route selection beyond asking the app controller to continue

## Scene And Data Dependencies

The implementation must preserve this dependency chain:

`progression_nodes.json -> ContentDB -> MainProgressFlowProvider -> MainProgressScreen`

`selected node_id -> ContentDB.build_session_plan_for_node(...) -> SessionScreen`

`SessionScreen results -> SessionSummaryScreen -> main.gd commit through AppState/SaveService -> MainProgressFlowProvider rebuild -> MainProgressScreen`

Required runtime dependencies by screen:

- `BootScreen`
  depends on `ContentDB.load_content()` and `AppState.load_from_disk()`
- `HomeScreen`
  depends only on route emission; no progression data lookup
- `MainProgressScreen`
  depends on a prepared payload with visible nodes, `next_node_id`, `focused_node_id`, current release phase, and optional `just_completed_node_id`
- `SessionScreen`
  depends on `node_id` plus prepared `session_plan`
- `SessionSummaryScreen`
  depends on `node_id` plus `results`

The screen layer must never depend directly on:

- curriculum concept JSON
- raw save-file structure
- release-phase config parsing

## Navigation Integration Contract

Approved route payloads for V1:

- `home -> main_progress`
  optional `focus_reason`; no session content payload
- `main_progress -> session`
  required `node_id`
  required `session_plan`
  optional `focused_node_id`
- `session -> session_summary`
  required `node_id`
  required `results`
- `session_summary -> main_progress`
  no direct save mutation in the screen payload; the app controller commits the pending completed node before reopening `main_progress`

Required commit sequence:

1. `SessionScreen` finishes and emits `node_id` plus `results`.
2. `main.gd` opens `SessionSummaryScreen` with that payload and retains the pending completion context.
3. `SessionSummaryScreen` emits continue.
4. `main.gd` calls the approved `AppState` completion write path for the pending node.
5. `AppState` persists through `SaveService`.
6. `main.gd` rebuilds the progress model through `MainProgressFlowProvider`.
7. `main.gd` opens `MainProgressScreen` with `just_completed_node_id` set.

This sequencing is architecture-critical. Do not persist node completion from inside `SessionScreen`.

## Approved Save And Data Contracts

### Authored Node Definition Contract

Each authored node row must include at minimum:

- `node_id`
- `node_type`
- `sort_order`
- `release_phase`
- `session_template_id`
- `primary_category_id`

Optional authored fields:

- `prerequisite_node_ids`
- `review_tag`
- `art_id`

Runtime-only fields such as `state`, `is_focused`, `is_replay`, or `is_visible` must not be stored in authored JSON.

### Durable Save Additions

Extend `save_data.progression` with:

- `completed_node_ids`
- `last_played_node_id`
- `last_completed_node_id`
- existing `completed_session_count`
- existing concept progression fields

`last_unlocked_node_id` is optional. Add it only if implementation proves it is required for stable UX. Do not add speculative save fields.

### Prepared Screen Model Contract

The model given to `MainProgressScreen` must include:

- ordered visible `nodes`
- `next_node_id`
- `focused_node_id`
- `current_release_phase`
- optional `just_completed_node_id`

Each visible node must include:

- `node_id`
- `session_template_id`
- `release_phase`
- `primary_category_id`
- `sort_order`
- `state`

Approved visible states:

- `completed`
- `next`
- `available`
- `locked`

Provider-internal `hidden` state may exist during filtering, but it must not leak into the screen payload.

## Build Phases

### Phase 0: Lock Contracts Before UI Work

Primary files:

- `docs/MAIN_PROGRESS_IMPLEMENTATION_PLAN.md`
- `docs/MAIN_PROGRESS_ARCHITECTURE.md`

Outputs:

- route naming frozen to `main_progress`
- provider boundary frozen
- commit sequencing frozen
- save shape frozen enough for implementation start

Exit criteria:

- no unresolved ownership conflict between `ContentDB`, `AppState`, and `MainProgressScreen`
- no remaining assumption that `SessionScreen` selects the next session

### Phase 1: Author Progression Data

Primary files:

- `data/progression/progression_nodes.json`
- optional `data/progression/session_templates.json`
- `autoload/content_db.gd`

Work:

- add authored V1 node rows for the first short path
- keep the visible default at `5` nodes
- keep authored order deterministic through `sort_order`
- add `ContentDB` accessors for ordered node defs
- add `ContentDB.build_session_plan_for_node(node_id, prior_completed_sessions)` or equivalent

Exit criteria:

- node definitions load without any screen reading JSON
- phase gating remains driven by `release_phase`
- a selected `node_id` resolves to one prepared `session_plan`

### Phase 2: Add Durable Progression Inputs And Provider

Primary files:

- `autoload/app_state.gd`
- `autoload/save_service.gd`
- `scripts/progression/main_progress_flow_provider.gd`

Work:

- normalize new node-progression fields into existing save data
- add `AppState` read accessors for raw progression inputs
- add one approved `AppState` write path for node completion after summary acceptance
- implement provider logic that resolves visible nodes and the single `next` node

Exit criteria:

- older saves still normalize safely
- exactly one visible node resolves to `next`
- completed nodes remain replayable
- the first incomplete visible authored node becomes `next`
- supported-success-heavy runs still advance progression after summary acceptance

### Phase 3: Integrate Navigation And Commit Sequencing

Primary files:

- `scripts/app/main.gd`
- `scripts/screens/home_screen.gd`
- `scripts/screens/session_screen.gd`
- `scripts/screens/session_summary_screen.gd`

Work:

- register `main_progress` in `SCREEN_SCENES`
- route `HomeScreen` play into `main_progress`
- remove session selection from `SessionScreen`
- make `SessionScreen` require `node_id` plus `session_plan`
- route summary continue through `main.gd` commit sequencing before reopening `main_progress`

Exit criteria:

- child flow becomes `home -> main_progress -> session -> session_summary -> main_progress`
- `SessionScreen` runs entirely from the supplied payload
- no save write occurs inside `SessionScreen`
- summary continue returns to rebuilt progress state, not raw `home`

### Phase 4: Build The Screen Shell And Components

Primary files:

- `scenes/screens/main_progress_screen.tscn`
- `scripts/screens/main_progress_screen.gd`
- optional `scenes/components/main_progress_node.tscn`
- optional `scripts/components/main_progress_node.gd`

Work:

- create a presentation-only screen shell
- render prepared nodes and the single primary CTA
- make CTA tap and focused-node tap launch the same node
- support replay on completed nodes
- provide calm locked-node feedback only

Exit criteria:

- screen renders from prepared payload only
- one node is visually dominant
- path fits on one screen with no pan or scroll
- parent access remains secondary and routes to `parent_gate`

### Phase 5: Final V1 UI State Handling And QA

Primary files:

- `scripts/screens/main_progress_screen.gd`
- `scripts/app/main.gd`
- `autoload/app_state.gd`

Work:

- use `just_completed_node_id` for post-summary reveal
- settle focus onto the new `next` node
- verify restart persistence
- run manual integration checks for first run, replay, supported success, release-phase unlock, and parent-gate access

Exit criteria:

- completion returns to a visibly updated progress path
- restart preserves node completion and `next` resolution
- later-phase nodes appear only when the configured phase unlocks
- replay never regresses forward progression

## Anti-Drift Guardrails

Do not:

- move visible-node resolution into `MainProgressScreen`
- move authored node ordering into `AppState`
- let `SessionScreen` build fallback content when `session_plan` is missing
- write node completion before summary continue
- gate progression on stars, mastery labels, or parent-progress metrics
- add scrolling, panning, zooming, or branching routes in V1
- expose parent dashboard data on the child-facing progress screen
- store runtime node state inside authored JSON
- create both `main_progress` and `main_progress_flow` naming variants
- add a generic progression manager, event bus, or puzzle-agnostic framework for future puzzle types
- mix this work with threshold tuning, parent-progress redesign, or new puzzle mechanics

## Architecture Signoff Checklist

Implementation is architecture-complete only when all of these are true:

1. `HomeScreen` launches `MainProgressScreen`, not `SessionScreen`.
2. `MainProgressScreen` renders from a prepared provider model and does not read JSON or save data directly.
3. `SessionScreen` consumes `node_id` plus prepared `session_plan` and does not select the next session.
4. `SessionSummaryScreen` does not write progression and returns control to `main.gd`.
5. `main.gd` commits pending node completion only after summary continue.
6. `ContentDB`, `AppState`, and `MainProgressFlowProvider` each keep their approved boundary.
7. Exactly one visible node is `next`, completed nodes are replayable, and release-phase gating still controls future visibility.
