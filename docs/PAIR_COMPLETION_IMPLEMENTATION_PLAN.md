# Pair Completion Implementation Plan

Status: implemented

Purpose: record the first shipped `Pair Completion` slice so later puzzle work extends the approved `Composition Line` model instead of drifting back toward picture-half completion.

## Shipped Scope

- puzzle type: `pair_completion`
- first form: `Composition Line`
- current content slice:
  - `small_apple`
  - `big_apple`
  - `small_ball`
  - `big_ball`
- real Bliss modifier symbols:
  - `small`
  - `big`

## Child-Facing Contract

- top area shows the result meaning as a picture example
- center formula row shows two symbol slots with one missing
- bottom tray offers `2` symbol choices
- child drags the missing symbol into the empty formula slot
- wrong answer returns the same card and removes one distractor
- supported-success keeps only the correct symbol and still requires final placement

## Current Runtime Shape

- result picture is rendered from the base noun picture with authored size scaling
- formula order stays adjective first, noun second
- missing slot alternates by round:
  - some rounds miss the modifier
  - some rounds miss the noun
- `SessionScreen` dispatches `pair_completion` directly as a real puzzle scene

## Current Content Contract

`res://data/curriculum/compositions.json` owns:

- `id`
- `release_phase`
- `enabled`
- `modifier_id`
- `modifier_symbol_asset`
- `base_concept_id`
- `result_picture_asset`
- `result_picture_scale`

The first implementation intentionally keeps composition content separate from `concepts.json` so modifiers like `small` and `big` do not need to become full noun-style curriculum concepts.

## Progression Entry

The first reachable node is:

- `phase_1_pair_01`

Placement:

- after `phase_1_reverse_01`
- before later phase-1 anchor review nodes

## Non-Goals

This slice does not yet implement:

- `Intersection Table`
- multi-step phrase building beyond two symbols
- color or feeling compositions
- parent-progress reporting specific to composition mastery

## Next Validation

- run a focused child-flow QA pass covering both `Reverse Anchor Match` and `Pair Completion`
- verify drag return, wrong-answer simplification, supported-success completion, and progression handoff through `phase_1_pair_01`
