# UI/UX Agent Worklog

## Current Focus

- First-pass Milestone 1 UI/UX principles for the new Bliss project
- Screen and component guidance for the calm first playable

## Active Tasks

- `docs/UI_UX.md` drafted for Milestone 1 child-facing and parent-facing presentation rules
- Await implementation handoff and cross-role confirmation on screen/component contracts
- `docs/MAIN_PROGRESS_SCREEN_UI.md` drafted as a design-only replacement direction for the plain home/start surface, using a calm short-journey model inspired by the MITA reference without copying its busier patterns
- `docs/MAIN_PROGRESS_SCREEN_UI_REFINEMENT.md` drafted to turn the approved MainProgress direction into concrete layout, spacing, state-clarity, parent-entry, and minimal-text rules for the real node-path screen

## Local Notes

- Use this file for temporary layout ideas, interaction presentation notes, visual hierarchy drafts, and motion/feedback reasoning.
- Milestone 1 should treat `HomeScreen` as a single-action launch surface, not a menu.
- Main progression screen should use a calm curved node path with one obvious next session and a hidden top-right parent entry.
- `SessionScreen` should keep a stable top-to-bottom structure: progress dots, target card, drop slot, choice tray.
- Wrong-answer handling should read as simplification of the layout, not as correction or failure.
- Child summary should stay lightweight: stars, one praise moment, one clear continue action.
- Parent UI should be clearly adult-facing through denser text and more utilitarian layout, but still visually calm.
- `ParentGateScreen` is now implemented as a compact long-press gate with a short progress indicator and a plain back path.
- The new main progress screen should reinterpret the single-action home rule as one obvious next node on a short journey path, not as a dashboard or large map.
- The MITA reference is useful for path structure and large nodes, but Bliss should stay calmer, lighter, and less visually crowded.
- The real screen should move from the current centered shell card to a full-screen three-region composition: quiet top rail, dominant journey stage, and single bottom CTA.
- Node spacing should prioritize one centered `next` node, readable completed-vs-locked contrast, and a clear empty zone around the top-right parent entry.
- Child-facing copy should stay near-zero on this screen: no node ids, counters, or mastery language.

## Risks

- Asset style inconsistency between generated pictures and Bliss symbols could make the calm layout feel uneven even if the screen structure is correct.
- If engineering compresses card sizes too far for smaller Android devices, drag comfort and scanability will drop quickly.

## Next Update

- Promote stable UI/UX rules into shared memory or dedicated design docs when they become cross-role constraints.
- Recommend promoting any cross-role screen contract only if implementation teams need it as a hard constraint.
- Await lead review before promoting `MainProgressScreen` rules into shared memory, since this is still a specialist design proposal rather than an approved cross-role contract.
