# Tasks

This file is the global execution tracker for the Bliss project.

Agents should keep it current.

## Rules

- Move a task into `In Progress` when work actually starts.
- Move a task into `Done` in the same turn that the work is completed.
- Move a task into `Blocked` as soon as progress depends on a missing decision, missing asset, or external dependency.
- Keep tasks concrete and short.
- If a task is larger than one focused working session, split it.
- For implementation tasks, record and respect the specialist or worker that owns execution; the lead agent should not be the default implementer.

## Todo

- Import the legacy V1 progression into the live V2 SQLite store.
  Execution owner: `godot worker agent`
  Scope: seed the real `bliss_v2.sqlite` tables from `save_v1.json` without claiming fake puzzle-level history and keep the bridge additive.
- Route session and round writes into the live V2 SQLite tables.
  Execution owner: `gameplay/data worker agent`
  Scope: write `session_run`, `round_result`, and `node_progress` at the current summary-commit seam while preserving the existing child flow.
- Land the first runtime V2 store slice after the authored-content normalization review.
  Execution owner: `godot worker agent`
  Scope: add the learning-store service boundary, thin `save_v2` shell handling, and migration scaffolding without yet rewriting puzzle screens.
- Resolve the authored V2 category-gap before runtime readers depend on it.
  Execution owner: `content agent`
  Scope: align the new `qualities` references in V2-authored files with the canonical category model at the moment the runtime begins reading those files.
- Rerun the focused child-flow QA pass covering both `Reverse Anchor Match` and `Pair Completion` after the current data-model routing settles.
  Execution owner: `qa agent`
  Scope: validate drag return, wrong-answer simplification, supported-success completion, and progression handoff through `phase_1_reverse_01` and `phase_1_pair_01`.
- Route `Odd One Out` only after the V2 data-model rollout no longer risks immediate curriculum/schema rework.
- Run `MainProgressScreen` Phase 5 integration QA for post-summary reveal, restart persistence, replay stability, and release-phase visibility.
- Run the dedicated `Anchor Match` physical-drag QA checklist interactively and on target touch input.
- Align exact star thresholds and learned/mastered thresholds after first-playable validation.
- Expand the save and parent-progress view once category mastery rules are finalized.

## In Progress

- `Milestone 2: First Playable Puzzle`
  Current focus: turn the scaffold into a more polished, testable first playable session.
- `Lead routing refresh after MainProgress Phase 4`
  Execution owner: `lead agent`
  Scope: keep Android export treated as solved for project-code purposes, reflect the user pivot toward symbol-first puzzle expansion, and route the next implementation slice without reopening solved export work.
- `Second puzzle-family direction`
  Execution owner: `lead agent`
  Scope: keep `Reverse Anchor Match` and `Pair Completion` integrated and reviewed, but hold `Odd One Out` behind the V2 data-model rollout so the next puzzle slice does not harden the wrong curriculum/runtime shape.
- `Bliss Data Model V2 rollout`
  Execution owner: `lead agent`
  Scope: review the approved `docs/DATA_MODEL_V2_ARCHITECTURE.md` brief, route the first non-overlapping implementation slices, and keep the migration additive so current IDs, authored content, and shipped puzzle behavior do not get destructively rewritten.

## Done

- `Android export preset hardening`
  Execution owner: `godot worker agent`
  Scope: made `export_presets.cfg` project-side Android values sane without attempting machine-level SDK/JDK/template installation.
- `Android export and runtime stabilization`
  Execution owner: `godot worker agent`
  Scope: populated the active Godot Android SDK/JDK settings profile, exported successfully to `builds/android/bliss.apk`, set a real project icon, switched Android mobile rendering to `gl_compatibility` for emulator stability, and forced portrait orientation for the exported app.
- `Reverse Anchor Match` implementation brief
  Execution owner: `lead agent`
  Scope: published `docs/REVERSE_ANCHOR_MATCH_IMPLEMENTATION_PLAN.md` defining the first symbol-first expansion slice, including genericized round-asset guidance, `puzzle_type` scene dispatch, and early progression entry through `phase_1_reverse_01`.
- `Reverse Anchor Match` implementation
  Execution owner: `gameplay worker agent`
  Scope: shipped the first non-anchor puzzle with `SessionScreen` dispatch by `puzzle_type`, a real reverse puzzle scene, genericized round asset fields, an early reachable `phase_1_reverse_01` node, and released phase-1 concepts updated to advertise `reverse_anchor_match`.
- `Pair Completion` implementation brief
  Execution owner: `lead agent`
  Scope: published `docs/PAIR_COMPLETION_IMPLEMENTATION_PLAN.md` recording the shipped `Composition Line` contract, the dedicated `compositions.json` data source, and the first reachable `phase_1_pair_01` node.
- `Pair Completion` implementation
  Execution owner: `lead agent`
  Scope: shipped the first `Composition Line` puzzle with real `small/big` Bliss modifier symbols, a dedicated `pair_completion` scene, composition-driven session-plan building, and an 8-round `phase_1_pair_01` progression node built from `small/big` over `apple/ball`.
- `Godot Android editor-settings inspection`
  Execution owner: `godot explorer agent`
  Scope: verified that the failing Godot `4.6.1` app was reading `editor_settings-4.6.tres`, populated that file with the Android SDK and JDK 17 paths, removed Gradle-only Android preset overrides that are invalid when Gradle build is off, and reran headless export successfully.
- `Bliss Data Model V2 architecture`
  Execution owner: `architect agent`
  Scope: approved `hybrid JSON + SQLite` with authored curriculum staying in `res://data/`, runtime learning truth moving to `user://bliss_v2.sqlite`, a thin `save_v2.json` shell, explicit exemplar-based abstraction modeling, track-first progression, and additive migration from the current `concepts.json` plus `save_v1.json` shape.
- `Bliss Data Model V2 authored-content normalization`
  Execution owner: `content worker agent`
  Scope: added `symbols.json`, `tracks.json`, `exemplars.json`, and `puzzle_templates.json`, and enriched `compositions.json` additively while preserving current runtime-facing fields; this slice is valid on disk but not runtime-active yet because current code still reads the V1 content files only.
- `Bliss Data Model V2 runtime dependency and DB seam`
  Execution owner: `godot worker agent`
  Scope: installed the `godot-sqlite` addon under `addons/godot-sqlite`, introduced the `LearningStoreService` runtime seam, created and normalized `save_v2.json`, and now creates the live `user://bliss_v2.sqlite` database plus the initial V2 schema tables while leaving `save_v1.json` as the current gameplay compatibility truth.
- `Body Parts` starter track import
  Execution owner: `lead agent`
  Scope: imported the first real `body_parts` assets (`hand`, `eye`, `mouth`, `nose`) from the old reference repo, added the `body_parts` category plus V1/V2 authored rows, and inserted a reachable `phase_2_body_parts_01` anchor session ahead of the existing phase-2 mixed expansion.
- `Body Parts` reverse follow-up
  Execution owner: `lead agent`
  Scope: extended the new `body_parts` track with a real `phase_2_body_parts_02` reverse session so the category now follows the approved anchor-then-reverse depth pattern before broader phase-2 expansion resumes.
- `MainProgressScreen` visible-path compaction
  Execution owner: `lead agent`
  Scope: changed the visible node model to be puzzle-family-first instead of content-batch-first, kept completed nodes visible longer after completion, and updated numbering so the path no longer floods the child with near-duplicate puzzle nodes.
- `Body Parts` second batch rollout
  Execution owner: `lead agent`
  Scope: imported `ear`, `head`, and `arm`, then made them runtime-reachable by adding explicit `phase_2_body_parts_03` and `phase_2_body_parts_04` progression nodes after content-only staging proved insufficient.
- Produced a UI/UX design-only spec for `MainProgressScreen` in `docs/MAIN_PROGRESS_SCREEN_UI.md`, adapting the MITA path structure to Bliss while keeping the child flow calm and text-light.
- Created the project-local memory system, shared knowledge base, role files, worklogs, and dedicated role skills.
- Added BA agent support and explicit orchestration rules for BA, lead, and specialist routing.
- Added the milestone system with backlog and `Milestone 1: Foundation`.
- Produced the Milestone 1 planning pack:
  `ARCHITECTURE.md`, `GAME_DESIGN.md`, `CONTENT_SCHEMA.md`, `UI_UX.md`, `GAMEPLAY_IMPLEMENTATION.md`.
- Promoted durable cross-role decisions into shared project memory.
- Scaffolded the Godot 4 project in `/Users/vasilibraga/bliss`.
- Added autoloads for app state, content loading, save IO, and SFX placeholders.
- Added screen scaffolds for boot, home, session, summary, parent gate, and parent progress.
- Added `Anchor Match` puzzle and reusable component scene/script scaffolds.
- Added starter curriculum JSON for `apple`, `water`, `ball`, `book`, `dog`, and `cat`.
- Validated the scaffold with Godot `4.6.1` headlessly.
- Imported real Bliss symbol assets and generated picture assets for the first playable concept slice.
- Tightened the `Anchor Match` interaction flow with calmer wrong-answer handling and better settled-state feedback.
- Improved the session summary and parent progress presentation.
- Imported an additional batch of future-ready concept assets: `spoon`, `chair`, `banana`, `bread`, `cup`, `bottle`, `bed`, `toy`, `bird`, `duck`.
- Added a first visual-polish pass to cards, buttons, summary, and parent progress screens.
- Added the next playable content slice to the runtime with `release_phase: 2` concepts and unlock-aware session generation.
- Fixed parent-progress category calculations so they count only currently released content.
- Ran a QA pass on the first playable and recorded concrete issues in chat for follow-up.
- Fixed the first-playable card lifecycle crash caused by configuring `ChoiceCard` visuals before the card entered the scene tree.
- Hardened save loading by normalizing partial or older save dictionaries back into the expected runtime schema before gameplay reads and writes.
- Replaced the placeholder parent gate with a real long-press gate before opening the parent progress screen.
- Reworked unlocked-session generation so later phases keep earlier released concepts in review slots instead of dropping them entirely.
- Aligned parent-progress summary counting with the same released-content filter used by the category rows.
- Replaced the remaining label-heavy fallback presentation in gameplay cards and parent summary with more intentional visual fallback and stat-card treatment.
- Added real offline WAV sound effects and wired `SfxPlayer` to reusable audio players that respect the existing `sfx_enabled` setting.
- Changed `Anchor Match` so the symbol is dropped directly onto the picture target and removed the separate drop-zone from the child flow.
- Implemented the approved `Anchor Match` physical-drag refactor with a hidden source card, one visible drag proxy, picture-only drop target, and same-card return/settle behavior.
- Reviewed the specialist `MainProgressScreen` UI and flow docs and approved the direction in `docs/MAIN_PROGRESS_SCREEN_DECISION.md`.
- Approved the architect-owned `MainProgressScreen` execution plan in `docs/MAIN_PROGRESS_IMPLEMENTATION_PLAN.md`.
- Published `docs/MAIN_PROGRESS_FLOW.md` defining the functional contract for a child-facing progression screen between `HomeScreen` and sessions.
- Completed Phase 1 of the `MainProgressScreen` plan by adding authored progression node data and `ContentDB` loading/build helpers for node definitions and node-specific session plans.
- Completed Phase 2 of the `MainProgressScreen` plan by extending `AppState` and save normalization for node-completion progression state.
- Completed Phase 3 of the `MainProgressScreen` plan by adding the `main_progress` route, wiring `HomeScreen` into it, and creating a minimal shell `MainProgressScreen`.
- Completed Phase 4 of the `MainProgressScreen` plan by adding `MainProgressFlowProvider`, moving session-plan resolution and summary-time progression commits into `main.gd`, making `SessionScreen` consume `node_id` plus prepared `session_plan`, and replacing the shell `MainProgressScreen` with a real prepared node-path screen.
- Completed the `Anchor Match` read-only QA pass and captured concrete multi-touch/return-state findings in `docs/ANCHOR_MATCH_QA_FINDINGS.md`.
- Implemented the `Anchor Match` drag stability follow-up so return animations keep input locked, touch drags stay owned by the starting finger, and drag proxies inherit the source card's laid-out size.
- Completed the `MainProgressScreen` UI refinement pass and captured the full-screen `TopRail -> JourneyStage -> FooterAction` visual contract in `docs/MAIN_PROGRESS_SCREEN_UI_REFINEMENT.md`.
- Locked the workflow rule that the lead agent plans/routes/integrates while specialist or worker agents own normal feature implementation.
- Recorded the puzzle-system direction that Bliss should prioritize symbol-first puzzle families, treat `Pair Completion` as symbol composition, and build next toward `Reverse Anchor Match`, `Composition Line`, `Odd One Out`, `Category Sort`, and `Sequence Ordering`.

## Blocked

## Open Questions

- Exact adaptive difficulty thresholds after first-playable testing.
- Exact star thresholds and learned/mastered thresholds after first-playable testing.
- Exact long-term asset import pipeline for Bliss symbols and generated picture cards.
