# Anchor Match Interaction Contract

Status: approved interaction contract, implementation not yet started

Owner: Lead

Purpose: define the child-facing drag-and-drop contract for `Anchor Match` before any further gameplay refactor happens.

This document exists because the current implementation was changed too quickly and does not yet satisfy the intended physical interaction model.

## Problem Statement

The current `Anchor Match` interaction is not coherent enough for the product goal.

The user feedback is:

- drag and drop must feel physical
- nothing should remain on the tray while a card is being dragged
- the Bliss symbol must remain visible on the dragged card
- the picture itself should be the drop target
- no extra drop zone is needed

That means the app must behave like moving one real card, not like dragging a copy while the original stays behind.

## Product Rules

These are the rules the BA would treat as the canonical requirement set.

1. `Anchor Match` uses one physical card model.
2. When drag starts, the original card must no longer appear to remain on the tray.
3. The dragged object must visibly carry the Bliss symbol during the whole drag.
4. The picture target is the only drop target in this puzzle.
5. No separate drop slot, green zone, or extra destination panel should appear.
6. On wrong drop, the same card returns to its origin.
7. On correct drop, the same card settles onto the picture target.
8. The interaction must stay calm: no harsh error feedback, no duplicate objects, no confusing preview behavior.

## UI/UX Behavior Spec

This section is the UI/UX contract.

### Resting State

- one large picture target is visible
- 2 to 3 symbol cards rest in the tray
- each tray card clearly shows the Bliss symbol
- no extra drop zone is visible anywhere on screen

### Drag Start

- the chosen card visually lifts from the tray
- the tray position where it came from becomes visually empty
- the tray should not show a full duplicate card left behind
- the dragged card remains fully visible and legible
- the picture target may gain a subtle ready state, but not a loud glow

### During Drag

- the dragged card should stay visually stable and readable
- the symbol must stay visible on the card
- no second ghost card should be visible in the tray
- no independent floating drag proxy should look different from the original card

### Wrong Drop

- the card returns to the tray
- the return motion should be short and smooth
- no shake, no red flash, no buzzer
- if the round logic removes a distractor, that happens after the wrong drop resolves

### Correct Drop

- the card settles onto the picture target
- the symbol remains visible after settling
- the tray origin remains empty after success
- success feedback stays brief and calm

## Gameplay Implementation Contract

This section is the engineering contract. It is intentionally prescriptive.

### Required Interaction Model

Do not use a “copy stays in tray while preview floats elsewhere” drag model.

The implementation should behave as one moved card:

- at drag start, either:
  - reparent the real card into a drag layer, or
  - hide the origin card and render a visually identical moved instance while the origin stays non-visible

If a proxy is used internally, it must still appear to the child as the same physical card.

### Required Scene Behavior

- `TargetCard` becomes the only accepted drop receiver
- `ChoiceCard` remains the visual source of the moved object
- the tray must not visibly retain the original card during drag
- on failed drop, the moved card returns to the original tray slot
- on successful drop, the moved card settles onto the target picture and becomes the placed symbol

### Explicit Anti-Patterns

Do not implement any of these:

- leaving the original card fully visible while dragging
- showing both the tray card and a second drag copy at the same time
- using a separate green drop panel
- replacing the moved card with a different-looking placed symbol on success
- allowing the symbol to disappear during drag

## QA Acceptance Criteria

The QA agent should use these checks.

1. Start dragging a symbol card.
Expected:
- the original tray card no longer appears to remain on the tray
- the dragged card still shows the symbol clearly

2. Drag a symbol around without dropping.
Expected:
- only one apparent card is being moved
- no visible duplicate stays behind

3. Release outside the picture target.
Expected:
- the same card returns to the tray
- no duplicate remains on the target

4. Drop the wrong symbol on the picture.
Expected:
- the same card returns to the tray
- wrong-answer recovery happens calmly afterward

5. Drop the correct symbol on the picture.
Expected:
- the same card settles onto the picture
- the symbol stays visible after settling
- no separate drop zone appears at any point

## Execution Rule

No further changes to `Anchor Match` drag behavior should be made until implementation follows a lead-approved plan and QA checklist derived from this contract.

Required sequence:

1. `UI/UX confirmation`
2. `gameplay implementation plan`
3. `QA verification checklist`
4. implementation
5. QA verification pass
