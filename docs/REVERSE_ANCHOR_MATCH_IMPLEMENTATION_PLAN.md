# Reverse Anchor Match Implementation Plan

Status: planning only

Depends on:
- [knowledge-base/puzzle-taxonomy.md](./knowledge-base/puzzle-taxonomy.md)
- [GAMEPLAY_IMPLEMENTATION.md](./GAMEPLAY_IMPLEMENTATION.md)

Purpose: define the concrete engineering approach for the first non-`Anchor Match` puzzle so a specialist can implement it without reopening puzzle-direction or schema debates.

## Goal

Implement `Reverse Anchor Match` as the first symbol-first expansion:

- the target is a Bliss symbol
- the child drags the correct picture card from a small tray
- the same calm wrong-answer and support loop from `Anchor Match` is preserved
- the puzzle is reachable through normal progression, not only through ad hoc debug routing

## Why This Slice Is First

`Reverse Anchor Match` is the lowest-risk second puzzle because it:

- keeps the same one-target, one-tray, one-card drag model
- verifies symbol meaning in the reverse direction instead of adding a new visual game grammar
- reuses the current concept assets without waiting for adjective or composition content
- adds real puzzle variety without forcing a full gameplay framework rewrite

## Non-Goals

Do not mix this slice with:

- `Pair Completion` or symbol-formula composition
- mastery-threshold tuning
- parent-progress redesign
- `MainProgressScreen` QA
- new Android-specific work
- a generic puzzle framework built for future puzzle families that do not exist yet

## Child-Facing Contract

The visible interaction should feel like `Anchor Match` turned around, not like a different genre.

Round flow:

1. a large Bliss symbol target is already visible and settled
2. `2` or `3` picture cards appear in the tray
3. the child drags one picture card
4. only the symbol target shows drag-ready emphasis
5. if dropped outside the symbol target, the same picture card returns
6. if dropped on the symbol target and wrong, the same picture card returns and one distractor is removed
7. if dropped on the symbol target and correct, the same picture card settles on the target and success feedback plays

The product rule stays the same:

- no fail screens
- no timers
- no noisy punishment
- no visual clutter increase

## Recommended Technical Model

Use the current `Anchor Match` drag model as the base interaction contract.

Recommended approach:

- keep `Reverse Anchor Match` as its own puzzle scene
- reuse the existing target-card and choice-card components where they can be made asset-agnostic with small edits
- do not build a shared puzzle base class yet
- do add narrow `puzzle_type` dispatch in `SessionScreen` so the runtime can host more than one puzzle scene

This keeps the implementation concrete without overfitting the codebase to hypothetical later puzzles.

## Runtime Contract Changes

### `SessionScreen`

`SessionScreen` is currently hardwired to `anchor_match_scene.tscn`.

This slice should change it to:

- resolve the puzzle scene from `round_def.puzzle_type`
- support only:
  - `anchor_match`
  - `reverse_anchor_match`
- keep the rest of session ownership unchanged

Do not move session progression, save writes, or summary logic out of the existing flow.

### `PuzzleRoundDef`

The current round schema is still anchor-specific.

For this slice, make the round asset contract minimally generic:

- `target_asset_path`
- `target_content_kind`
- `correct_choice_asset_path`
- `choice_content_kind`
- `choices: [{ "id", "asset_path" }]`

Keep these existing fields:

- `puzzle_type`
- `concept_id`
- `correct_choice_id`
- `choice_count`
- `max_wrong_attempts_before_support`

Migration rule:

- update `Anchor Match` to read the generic fields too
- do not keep growing parallel anchor-only and reverse-only asset fields

This is the right moment to normalize the round contract because only one real puzzle is live today.

### `TargetCard`

`TargetCard` already renders one asset plus a settle anchor.

Required changes:

- allow `set_content(...)` to accept a `content_kind` such as `picture` or `symbol`
- use that kind only for fallback labeling and any future styling split
- keep the settle anchor and drag-target behavior unchanged

Do not split this into separate target-card scene types unless implementation proves the visuals truly diverge.

### `ChoiceCard`

`ChoiceCard` is currently symbol-oriented.

Required changes:

- allow choice cards to render either a symbol asset or a picture asset
- keep the same drag proxy, hidden-source, disabled, and settled states
- make fallback labeling depend on `content_kind`

Do not create duplicate `SymbolChoiceCard` and `PictureChoiceCard` variants in this slice.

## Reverse Round Builder

Add a dedicated reverse round builder in `ContentDB`.

Recommended split:

- `_build_anchor_round_def(...)`
- `_build_reverse_anchor_round_def(...)`

`build_session_plan_for_node(...)` should:

- inspect the node's `puzzle_type`
- choose the correct round builder
- continue to apply the same intro-rule and choice-count logic

`_build_reverse_anchor_round_def(...)` should produce:

- `puzzle_type: "reverse_anchor_match"`
- `target_asset_path`: the concept's `symbol_asset`
- `target_content_kind: "symbol"`
- `correct_choice_asset_path`: the concept's `picture_asset`
- `choice_content_kind: "picture"`
- `choices`: picture-choice entries using the same `id` ordering rules as anchor rounds

Candidate selection, release filtering, and distractor ordering should stay aligned with the existing anchor-session rules.

## Progression Entry

The first implementation must be reachable in normal flow.

Add one early progression node:

- `node_id`: `phase_1_reverse_01`
- `puzzle_type`: `reverse_anchor_match`
- `node_type`: `reverse_anchor_match_session`

Recommended placement:

- after `phase_1_anchor_01`
- before the later anchor review nodes

Why:

- the user asked for puzzle variety, so the second puzzle should appear early
- `phase_1_anchor_01` already introduces the first concept slice
- reverse-direction review is reasonable immediately after that first contact

Recommended content for the first reverse node:

- use the same first-playable concept slice as `phase_1_anchor_01`
- keep `session_round_target = 8`
- keep `default_choice_count = 3`
- allow `use_intro_rules = false`

This slice does not need new concept assets.

## Curriculum Metadata

Update the first-playable concepts so their `default_puzzle_types` reflect reality once reverse play is shipped.

For the currently released concepts, include:

- `anchor_match`
- `reverse_anchor_match`

Do not add `pair_completion` yet.

## File Ownership For Implementation

If executed, ownership should be:

- `autoload/content_db.gd`
  round-builder split and node puzzle-type routing
- `scripts/models/puzzle_round_def.gd`
  genericized round asset contract
- `scripts/screens/session_screen.gd`
  puzzle-scene dispatch by `puzzle_type`
- `scenes/puzzles/reverse_anchor_match_scene.tscn`
  new reverse puzzle scene
- `scripts/puzzles/reverse_anchor_match_scene.gd`
  reverse drag/drop interaction
- `scripts/components/choice_card.gd`
  asset-agnostic choice rendering and existing drag states
- `scripts/components/target_card.gd`
  asset-kind-aware target rendering
- `data/progression/progression_nodes.json`
  new reverse node insertion
- `data/curriculum/concepts.json`
  honest puzzle-type availability metadata

Avoid changing save schema, summary math, parent screens, or unrelated docs during this slice.

## Recommended Build Order

1. genericize the round asset fields in `PuzzleRoundDef`, `TargetCard`, and `ChoiceCard`
2. split `ContentDB` round building into anchor and reverse builders
3. add `puzzle_type` scene dispatch in `SessionScreen`
4. implement `reverse_anchor_match_scene.tscn/.gd`
5. add `phase_1_reverse_01` to progression
6. run headless boot validation
7. run one manual child-flow pass through the new node

## Exit Criteria

Implementation is complete only when all of these are true:

1. `SessionScreen` launches the correct puzzle scene from `round_def.puzzle_type`
2. `Reverse Anchor Match` runs with a symbol target and picture choices
3. wrong-answer handling matches the current calm `Anchor Match` support loop
4. the reverse puzzle is reachable through the normal progression path
5. existing `Anchor Match` sessions still run without regression
6. headless Godot load still passes
7. the implementation does not introduce a generic puzzle framework beyond narrow scene dispatch and asset-contract cleanup
