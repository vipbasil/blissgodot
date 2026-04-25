# Anchor Match Implementation Plan

Status: planning only

Depends on: [ANCHOR_MATCH_INTERACTION_CONTRACT.md](./ANCHOR_MATCH_INTERACTION_CONTRACT.md)

Purpose: define the concrete engineering approach for the approved physical drag model before any more gameplay edits happen.

## Goal

Implement `Anchor Match` so it behaves like moving one real symbol card:

- no visible duplicate stays behind in the tray
- the dragged card always shows the symbol
- the picture is the only drop target
- the same card returns on failure
- the same card settles on success

## Non-Goals

Do not change:

- session planning
- progression rules
- stars or mastery thresholds
- content schema
- parent flow

This plan only covers the drag interaction refactor for the first puzzle.

## Recommended Technical Model

Use a `single visible object` drag model with a hidden origin plus a controlled drag layer.

Recommended approach:

1. the real tray card becomes the logical source
2. on drag start, the source card becomes visually hidden in the tray
3. a visually identical drag card is spawned into a dedicated drag layer
4. only the drag card is visible while moving
5. on cancel or wrong drop, the drag card animates back to the source slot and then disappears while the source card becomes visible again
6. on correct drop, the drag card animates into the target picture settle position and remains there as the placed card

This still uses a proxy internally, but the child only perceives one moved card.

## Why This Model

This is the safest plan for Godot and the existing codebase because it avoids:

- trying to physically drag the real layout-managed tray child across containers mid-drag
- conflicting with `HBoxContainer` layout ownership during movement
- keeping the tray card visible while also using Godot’s standard drag preview

It preserves the product illusion while staying technically stable.

## Scene Changes

### `SessionScreen`

No structural change required.

### `AnchorMatchScene`

Responsibilities after refactor:

- own a top-level drag layer inside the puzzle scene
- create tray cards as before
- manage active drag session state
- route drop evaluation to `TargetCard`
- coordinate return animation and settle animation

New internal state to add:

- `active_drag_choice_id`
- `active_drag_source_card`
- `active_drag_proxy`
- `active_drag_home_global_position`
- `is_drag_in_progress`

### `TargetCard`

Responsibilities after refactor:

- expose target hover-ready state
- expose a method to provide the settle position for the placed symbol
- expose acceptance testing for a global drop point
- host the final placed card or an equivalent settled symbol card

### `ChoiceCard`

Responsibilities after refactor:

- support visual states:
  - default
  - dragging_source_hidden
  - drag_proxy
  - disabled
  - settled_on_target
- provide a way to clone or build a visually identical drag proxy
- keep the symbol visible in all drag-related states

## Implementation Steps

### Step 1: Remove Standard Preview-Based Drag

Replace the current `set_drag_preview` style flow.

Needed changes:

- stop relying on the current default drag-preview behavior
- move to an explicit drag-start / drag-update / drag-end flow owned by `AnchorMatchScene`

Reason:

The standard preview path encourages the exact copy-feel behavior the contract rejects.

### Step 2: Add Drag Layer

Add a dedicated `DragLayer` node inside `AnchorMatchScene`.

Requirements:

- it renders above the tray and target
- it holds only one active drag proxy at a time
- it uses global or canvas coordinates consistently

### Step 3: Hide Source Card During Drag

When drag starts:

- identify the source `ChoiceCard`
- capture its global rect/position
- set the source to a hidden-source state
- do not leave the full source card visible in the tray

The tray may keep layout space, but not the visible card.

### Step 4: Spawn Identical Drag Proxy

Create a drag proxy from the source card.

Requirements:

- same symbol art
- same size
- same rounded-card appearance
- slight lifted state is acceptable
- no detached “ghost preview” look

### Step 5: Evaluate Drop Against Picture Only

When release happens:

- test only the picture target bounds/acceptance
- do not use any separate drop zone
- if outside target bounds, treat as cancelled return
- if inside target and wrong, treat as wrong-drop return
- if inside target and correct, run settle flow

### Step 6: Wrong-Drop Return Flow

Order:

1. drag proxy returns to source position
2. drag proxy disappears
3. source card becomes visible again
4. wrong-answer handling runs
5. any distractor removal happens after the return is visually resolved

### Step 7: Correct-Drop Settle Flow

Order:

1. drag proxy moves to target settle position
2. source tray card stays hidden
3. target now owns the visible settled card state
4. success feedback runs
5. round completes

The settled object must still read as the same moved symbol card.

## File Ownership For Implementation

If executed, ownership should be:

- `scripts/puzzles/anchor_match_scene.gd`
  interaction state machine and drag orchestration
- `scenes/puzzles/anchor_match_scene.tscn`
  drag layer node and node hierarchy updates
- `scripts/components/choice_card.gd`
  source/proxy/settled visual-state behavior
- `scripts/components/target_card.gd`
  target acceptance and settled-card hosting

Avoid changing unrelated systems while doing this refactor.

## Explicit Do-Not-Do List

Do not:

- reintroduce a separate drop slot
- leave the tray card visible while dragging
- use a drag preview that differs visually from the real card
- replace the dragged card with a different badge-only object on success
- mix threshold tuning or content work into this refactor

## Exit Criteria

Implementation is complete only when all of these are true:

1. drag begins with no visible duplicate left in tray
2. the moving card visibly contains the symbol at all times
3. the picture is the only drop target
4. wrong drop returns the same visible card
5. correct drop settles the same visible card onto the picture
6. headless Godot load still passes
7. QA checklist passes
