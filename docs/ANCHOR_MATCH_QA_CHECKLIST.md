# Anchor Match QA Checklist

Status: planning only

Depends on: [ANCHOR_MATCH_INTERACTION_CONTRACT.md](./ANCHOR_MATCH_INTERACTION_CONTRACT.md)

Purpose: provide the exact verification list for the physical drag refactor before and after implementation.

## Visual Identity Checks

1. Start dragging a symbol card.
Expected:
- the tray no longer shows a full duplicate card in the origin slot
- the moved card still clearly shows the Bliss symbol

2. Move the card across the screen.
Expected:
- only one apparent card is moving
- no second card remains visibly resting in the tray
- the moving object does not change into a different-looking preview

3. Drag over the picture target.
Expected:
- only the picture target shows a subtle ready state
- no separate drop zone appears

## Failure Path Checks

4. Release outside the picture.
Expected:
- the same card returns to the tray
- the card becomes fully visible again in the tray
- no card remains on the target

5. Drop the wrong symbol on the picture.
Expected:
- the same card returns to the tray first
- only after return does wrong-answer simplification happen
- no harsh feedback appears

6. After wrong-answer simplification, drag again.
Expected:
- the remaining cards still follow the same one-card physical model

## Success Path Checks

7. Drop the correct symbol on the picture.
Expected:
- the same card settles onto the picture
- the symbol stays visible after settling
- the tray origin remains visually empty after success

8. Complete a supported-success round.
Expected:
- even after distractors are removed, the final card still behaves as one physical card
- no duplicate appears during the final drag

## Regression Checks

9. Confirm the puzzle still records round completion.
Expected:
- success still advances the round
- supported success still reports correctly

10. Confirm wrong-answer behavior still removes distractors as intended.
Expected:
- first wrong answer removes one distractor
- repeated struggle simplifies to the final correct choice only

11. Confirm no separate drop slot exists in the child flow.
Expected:
- only picture target plus tray cards are visible as task elements

12. Confirm project stability.
Expected:
- Godot headless load passes
- no script errors on scene load
