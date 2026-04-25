# Gameplay Agent Worklog

## Current Focus

- Post-fix QA support for `Anchor Match` drag stability on touch devices, plus Phase 5 follow-up for `MainProgressScreen` integration QA

## Active Tasks

- Run the dedicated `Anchor Match` physical-drag QA checklist interactively on touch hardware after the stability fix lands
- Run the `MainProgressScreen` Phase 5 QA checklist once the lead schedules validation coverage

## Completed This Update

- Tightened `AnchorMatchScene` drag state so return/settle transitions keep input locked until cleanup finishes and a second drag cannot start mid-return
- Tied touch drag ownership to the finger that started the drag so other fingers cannot move or release the active card
- Updated `ChoiceCard` drag proxy creation to copy the source card's laid-out size instead of using scene defaults
- Added `scripts/progression/main_progress_flow_provider.gd` so visible node state resolves outside screen code
- Moved `MainProgressScreen` session launch and summary commit sequencing into `scripts/app/main.gd`
- Changed `SessionScreen` to consume supplied `node_id` plus prepared `session_plan` and emit results upward only
- Changed `SessionSummaryScreen` to emit continue upward without deciding progression
- Replaced the shell `MainProgressScreen` with a real node-path presentation that renders prepared node payload data only

## Local Notes

- Use this file for puzzle interaction notes, drag-and-drop behavior details, and feedback ideas.
- Chosen implementation split: `SessionScreen` owns the 8-round loop and session metrics; `AnchorMatchScene` owns exactly one round of drag-and-drop interaction.
- Puzzle scenes should receive prepared `PuzzleRoundDef` data instead of reading curriculum JSON or assembling distractors directly.
- Supported success should still end with the child placing the final correct symbol; do not auto-complete the round as soon as distractors are removed.
- Wrong-answer handling should simplify only the local choice tray and should not disturb the fixed `SessionScreen` vertical layout.
- Milestone 1 does not need a puzzle base class or a generalized gameplay event bus.
- Approved direction for physical drag:
  hidden source card + visually identical drag proxy + picture-only drop target + same-card return/settle behavior.
- Drag ownership contract now includes pointer identity: only the initiating mouse button or touch index may drive the active proxy until release/cleanup completes.
- Added `docs/MAIN_PROGRESS_FLOW.md` to define the between-session node path, unlock contract, and next-play behavior.
- `SessionScreen` no longer selects sessions or persists progression; it only runs the provided plan and hands `node_id` plus results to summary.
- `main.gd` is now the commit gate for both session results and node completion after summary continue.

## Risks

- If architecture or screen implementations expect `SessionScreen` to own the target card and tray nodes directly, the gameplay contract will need a small integration adjustment. Current recommendation is that the puzzle scene owns round-interactive content inside the fixed screen slot.
- `PuzzleRoundDef` is referenced as an input contract but may still need alignment with the architecture agent's final model naming and field shape.
- Signal payload shape is intentionally minimal; if analytics or QA instrumentation expands later, the contract should extend without changing the calm interaction loop.
- The current node-path screen keeps the first pass intentionally simple; Phase 5 still needs replay/restart/release-phase QA and any post-summary reveal polish that follows from that testing.

## Next Update

- Support Phase 5 QA on node unlock/replay persistence and make only minimal fixes if the checks uncover contract gaps.
- Support QA follow-up on the interactive drag behavior if the checklist finds edge cases on touch devices.
