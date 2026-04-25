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

- Run the dedicated `Anchor Match` physical-drag QA checklist interactively and on target touch input.
- Run `MainProgressScreen` Phase 5 integration QA for post-summary reveal, restart persistence, replay stability, and release-phase visibility.
- Run an Android export verification pass on a machine with Godot plus valid Java SDK and Android SDK paths configured in Editor Settings.
- Align exact star thresholds and learned/mastered thresholds after first-playable validation.
- Expand the save and parent-progress view once category mastery rules are finalized.

## In Progress

- `Milestone 2: First Playable Puzzle`
  Current focus: turn the scaffold into a more polished, testable first playable session.

## Done

- `Android export preset hardening`
  Execution owner: `godot worker agent`
  Scope: made `export_presets.cfg` project-side Android values sane without attempting machine-level SDK/JDK/template installation.
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

## Blocked

- None currently.

## Open Questions

- Exact adaptive difficulty thresholds after first-playable testing.
- Exact star thresholds and learned/mastered thresholds after first-playable testing.
- Exact long-term asset import pipeline for Bliss symbols and generated picture cards.
