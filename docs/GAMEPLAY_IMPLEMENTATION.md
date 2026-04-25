# Gameplay Implementation Contract

## Scope

This document defines the first-pass implementation contract for Milestone 1 gameplay.

It is intentionally narrow:
- one puzzle type: `Anchor Match`
- one session container: `SessionScreen`
- one puzzle scene instance active per round
- one calm drag-and-drop loop with supportive recovery

## Scene And Component Contract

Recommended runtime split:

- `SessionScreen`
  - owns session flow, round progression, and session-level metrics
  - owns the fixed screen layout required by `UI_UX.md`
  - creates or hosts one `AnchorMatchScene` for the active round
- `AnchorMatchScene`
  - owns only the active round interaction
  - renders the target card, drop slot, and choice tray content for that round
  - emits round results upward instead of advancing the session itself

Recommended child components inside `AnchorMatchScene`:
- `TargetCard`
- `DropSlot`
- `OptionTray`
- `ChoiceCard` instances
- optional small `CalmFeedback` node for local success highlight only

Milestone 1 should avoid a deeper gameplay framework than this. One puzzle scene with a small reusable card/drop-slot composition is enough.

## Ownership Boundary

### `SessionScreen` Owns

- receiving the `SessionPlan`
- current round index and total rounds
- progress dots state
- creating, configuring, and replacing the active puzzle scene
- counting supported versus independent round outcomes
- step-down logic for the next round if support was needed repeatedly
- session completion, session summary handoff, and save-trigger input to higher-level flow

### `AnchorMatchScene` Owns

- displaying one `PuzzleRoundDef`
- drag start, drag preview, hover-over-slot state, drop evaluation, and return-to-tray motion
- local attempt count for the current round
- removing distractors after wrong answers
- switching the round into supported-success state when only the correct option remains
- short local correct-placement feedback before notifying `SessionScreen`

### `AnchorMatchScene` Must Not Own

- building the full 8-round session
- deciding what the next round is
- awarding stars
- mutating durable save data
- loading curriculum JSON directly
- global difficulty history beyond the current round

## Data Inputs

### `SessionScreen` Receives

- `SessionPlan`
  - ordered `rounds: Array[PuzzleRoundDef]`
  - `session_id` or equivalent transient identifier
  - `total_rounds`
- optional session context needed for Milestone 1 summary math
  - prior completed session count
  - whether intro difficulty should be used for the opening rounds

### `AnchorMatchScene` Receives

- one `PuzzleRoundDef`
  - `puzzle_type`: `anchor_match`
  - `concept_id`
  - `target_picture_asset`
  - `correct_symbol_asset`
  - `choice_concept_ids`
  - `choice_symbol_assets`
  - `correct_choice_id`
  - `choice_count`
- optional round config values
  - `max_wrong_attempts_before_support` for Milestone 1 this is effectively `2`
  - short timing constants for settle and advance

Milestone 1 should pass fully prepared round data into the puzzle scene. The puzzle scene should not query content services to assemble its own distractors.

## Drag-And-Drop Flow

Round interaction should follow this exact loop:

1. `AnchorMatchScene` renders the target picture already settled in the target card.
2. The drop slot is visible and empty before the child interacts.
3. The choice tray shows `2` or `3` draggable symbol cards.
4. Child drags one `ChoiceCard`.
5. While dragged, only the drop slot gets a hover-ready visual state.
6. On drop:
   - if released outside the slot, the card returns to its tray position
   - if released inside the slot and it is the correct card, the card snaps into the slot
   - if released inside the slot and it is incorrect, the card returns to the tray and the round enters wrong-answer handling
7. Correct placement triggers a brief calm success response, then the puzzle scene emits completion upward.
8. Wrong placement never blocks input for long and never changes the whole screen layout. It only simplifies the local choice set.

Milestone 1 should keep one drop target only. Do not add free dragging between multiple zones.

## Signals And Events

Use a small upward-only signal contract from puzzle scene to session flow.

Recommended `AnchorMatchScene` signals:

- `wrong_answer(attempt_count: int, removed_choice_id: StringName)`
  - emitted after an incorrect drop is processed
- `support_state_changed(is_supported: bool, remaining_choice_count: int)`
  - emitted when the round has stepped down to a simpler state
- `round_completed(result: Dictionary)`
  - emitted once, after local settle animation

Recommended `round_completed` payload:

```gdscript
{
    "concept_id": &"apple",
    "outcome": &"independent_success", # or &"supported_success"
    "wrong_attempt_count": 0,
    "shown_choice_count": 3,
    "ended_choice_count": 1
}
```

Milestone 1 does not need downward event complexity beyond simple setup calls:
- `SessionScreen -> AnchorMatchScene.configure_round(round_def)`
- `SessionScreen -> AnchorMatchScene.begin_round()`

Avoid bidirectional event webs. `SessionScreen` should listen; `AnchorMatchScene` should report.

## Round State Lifecycle

Use a small explicit per-round state model inside `AnchorMatchScene`:

1. `setup`
   - round data assigned
   - choice cards created and positioned
2. `awaiting_input`
   - drag interaction enabled
3. `evaluating_drop`
   - temporary input lock while a drop is being checked
4. `wrong_recovery`
   - incorrect card returns
   - optional distractor removed
   - state returns to `awaiting_input`
5. `correct_settle`
   - correct card snaps into slot
   - success feedback plays
6. `completed`
   - `round_completed` emitted
   - scene waits for `SessionScreen` to transition away

`SessionScreen` should track a parallel but separate session-level state:
- `preparing_round`
- `round_active`
- `round_transition`
- `session_complete`

## Wrong-Answer And Supported-Success Mechanics

Milestone 1 implementation rules:

- First wrong answer:
  - return the dropped card to the tray
  - if more than one distractor remains, remove exactly one distractor
  - keep the correct card visible
- Second wrong answer or equivalent repeated struggle:
  - return the wrong card
  - remove all remaining distractors
  - keep only the correct card available
  - the next successful placement counts as `supported_success`

Implementation notes:
- removed distractors should become non-interactive immediately
- removed distractors may fade or slide out quietly, but the motion should be short
- the target picture and slot should not jump or re-layout aggressively
- once the round is in supported state, do not reintroduce distractors
- auto-completing the round without a final correct placement should be avoided in Milestone 1; the child should still place the remaining correct card

Independent success means the correct card was placed before the round entered supported state.

Supported success means the round had to simplify to only the correct card before completion.

## Minimal Script Responsibilities

### `SessionScreen.gd`

- accept a prepared `SessionPlan`
- show progress dots from round count
- instantiate or reset `AnchorMatchScene` per round
- pass one `PuzzleRoundDef` at a time into the puzzle scene
- listen for `round_completed`
- record per-round session outcomes needed for session-end stars and save updates
- apply the simple step-down rule to the next round when recent support count requires it
- route to summary when all 8 rounds finish

### `AnchorMatchScene.gd`

- receive one `PuzzleRoundDef`
- spawn or bind the target card, drop slot, and choice cards
- manage drag/drop hit testing and snap/return animation
- count wrong attempts for the round
- remove distractors according to Milestone 1 support rules
- emit the three signals defined above
- lock further input after completion

### `ChoiceCard.gd`

- expose the concept or choice ID it represents
- render the symbol asset
- support drag start and reset-to-home behavior
- expose visual states such as default, dragging, disabled, and slotted

### `DropSlot.gd`

- expose hover-ready and filled states
- answer whether a drop position is accepted
- host the snapped correct card visually after success

Milestone 1 does not need a generic puzzle base class unless the implementation already benefits from one.

## Deferred Until Later Milestones

Do not add these in the first pass:

- multiple puzzle scenes active in one session
- reverse-direction or mixed puzzle switching
- generic event buses for gameplay flow
- per-concept adaptive scheduling beyond the simple next-round step-down rule
- drag gestures that depend on precise hover timing or multi-touch logic
- mid-round rewards, combo systems, streaks, or star updates
- auto-save during every round event
- reusable abstractions built for puzzle types that do not exist yet

## Anti-Patterns To Avoid

- letting `AnchorMatchScene` read save data, choose future rounds, or decide star awards
- putting round state into autoload singletons
- hardcoding concept-specific behavior in puzzle scripts
- coupling wrong-answer feedback to red flashes, shaking, or loud error sounds
- rebuilding the whole `SessionScreen` layout on every wrong answer
- using text instructions to explain drag behavior
- treating supported success as a fail state or dead end
- overgeneralizing Milestone 1 into a full puzzle framework before a second puzzle exists

## Recommended First Build Order

1. Implement `SessionScreen` with static placeholder progress dots and one hosted puzzle slot.
2. Implement `AnchorMatchScene` for one prepared round.
3. Add correct drop completion and round advance.
4. Add first wrong-answer simplification.
5. Add supported-success behavior and session-level result tracking.
6. Wire session-end summary input once the 8-round loop is stable.
