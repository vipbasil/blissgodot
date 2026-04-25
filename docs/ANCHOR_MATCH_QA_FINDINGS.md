# Anchor Match QA Findings

Date: 2026-04-25
Scope: read-only QA review of the current physical-drag implementation against `docs/ANCHOR_MATCH_QA_CHECKLIST.md`

## Summary

The implementation appears aligned with the main visual contract in code: picture-only target, hidden source card during drag, return-before-simplify on wrong drops, and no separate drop slot. Headless project load also still passes. The remaining issues are interaction-state gaps that can break the intended one-card physical model on touch devices.

## Findings

### High: A new drag can start before the previous card finishes returning

- Files:
  - `scripts/puzzles/anchor_match_scene.gd:73-91`
  - `scripts/puzzles/anchor_match_scene.gd:204-226`
- Why it matters:
  - `_return_active_drag_to_source()` clears `active_drag_proxy` and `active_drag_source_card` before the return tween finishes.
  - `_on_choice_drag_pressed()` only blocks input when `input_locked` is true or `active_drag_proxy` is still set.
  - That means the child can start dragging another visible card while the previous wrong/outside-drop card is still animating home.
  - This breaks the checklist's one-card physical model and can let wrong-answer simplification fire while a second drag is already in progress.
- Checklist impact:
  - Fails or weakens checks 4, 5, and 6 under fast repeat input.

### High: Touch drag state is not tied to the finger that started the drag

- Files:
  - `scripts/components/choice_card.gd:83-85`
  - `scripts/puzzles/anchor_match_scene.gd:62-69`
- Why it matters:
  - Touch start emits only a position, not the touch index.
  - The active drag then responds to any `InputEventScreenDrag` and any `InputEventScreenTouch` release while a proxy exists.
  - On Android, a second finger can therefore move or release the active card even if it did not start the drag.
  - For the target audience, accidental second touches are realistic and this can make the card feel unstable or unpredictable.
- Checklist impact:
  - Risks checks 2 through 8 on real touch hardware, especially multi-touch or hand-over-hand use.

### Medium: The drag proxy is a fresh scene instance, not the source card's actual on-screen size

- Files:
  - `scripts/components/choice_card.gd:38-44`
  - `scenes/components/choice_card.tscn:20-24`
  - `scripts/puzzles/anchor_match_scene.gd:85-88`
  - `scripts/puzzles/anchor_match_scene.gd:235`
- Why it matters:
  - `build_drag_proxy()` creates a new `ChoiceCard` with the scene defaults.
  - No code copies the source card's current size or final laid-out rect to the proxy.
  - If the tray card is resized by device width or future layout changes, the moving card can appear to change size or settle with slightly different placement.
  - That is a direct risk against the checklist requirement that the moving object not change into a different-looking preview.
- Checklist impact:
  - Risks checks 1, 2, 7, and 8 on smaller phones or any layout that compresses the tray cards.

## Residual Testing Gaps

- Interactive checklist execution was not run in this pass; only static review and headless load were completed.
- Real Android touch verification is still needed for:
  - single-touch drag/release outside target
  - wrong-drop return followed by simplification
  - supported-success final drag with one remaining card
  - multi-touch interference during an active drag
- Narrow handset verification is still needed to confirm the drag proxy matches the tray card size and settles cleanly on the target.
- Interrupted-drag behavior still needs device testing, especially home gesture, app backgrounding, or notification-shade interruption during an active drag.

## Stability Check

- Headless load passed with:
  - `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path /Users/vasilibraga/bliss --quit`
