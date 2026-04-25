# QA Agent Worklog

## Current Focus

- Review the first playable for concrete logic bugs, regressions, and parent-facing risks.

## Active Tasks

- Validate the session loop, progression writes, release-phase behavior, and parent-progress reporting.
- Run the dedicated `Anchor Match` physical-drag checklist against the implemented interaction.

## Local Notes

- Use this file for findings-in-progress, test ideas, and unresolved risk notes.
- Confirmed risk: save loading trusts any non-empty dictionary and later session completion code indexes `save_data["progression"]` directly.
- Confirmed risk: once phase 2 unlocks, session generation stops reviewing phase 1 concepts entirely.
- Confirmed risk: parent summary counts all learned concepts in save data, while category rows count only released concepts.
- Fixed since last QA pass: `ParentGateScreen` now requires a deliberate long press before parent progress opens.
- Approved future check path: use `docs/ANCHOR_MATCH_QA_CHECKLIST.md` for the physical-drag refactor instead of ad hoc drag judgments.
- Current note: the physical-drag refactor compiles and loads, but still needs interactive touch/device verification.

## Risks

- Save-shape drift can break progression persistence on older or partial save files.
- Content unlock behavior currently favors new content over retention of earlier symbols.

## Next Update

- Promote confirmed cross-cutting issues to shared memory.
- 2026-04-25: Reviewed the current `Anchor Match` physical-drag implementation against `docs/ANCHOR_MATCH_QA_CHECKLIST.md` and wrote findings to `docs/ANCHOR_MATCH_QA_FINDINGS.md`.
- Confirmed this pass is read-mostly only: no gameplay code changes.
- Confirmed headless load still passes.
- New concrete risks from the drag pass:
  - a second drag can start before the previous return animation finishes
  - active touch drag is not bound to the originating finger, so another finger can move or release the card
  - the drag proxy does not inherit the source card's actual laid-out size, so smaller-device layouts may show a different-looking moving card
- Remaining gap: checklist still needs interactive Android verification, especially multi-touch and interrupted-drag cases.
