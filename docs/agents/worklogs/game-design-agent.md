# Game Design Agent Worklog

## Current Focus

- Define the next symbol-first puzzle families for Bliss before more noun-only content expansion.

## Active Tasks

- Keep the next puzzle roadmap centered on symbol meaning, not just picture perception.
- Treat `Reverse Anchor Match` and `Pair Completion` as the strongest next puzzle families.
- Keep `Composition Line` ahead of `Intersection Table` in implementation order.

## Local Notes

- Use this file for temporary puzzle, balancing, and mastery-design notes.
- First playable should stay on one repeated interaction: picture target, drag symbol, calm confirmation, next round.
- Keep the first session to `8` rounds so all six starter concepts can appear once with two lightweight repeat rounds.
- Use shallow support logic only: first wrong answer removes a distractor, repeated struggle becomes supported success.
- Session-end stars should reflect support needed, but must never block completion or unlocks.
- Proposed Milestone 1 learned rule: `3` exposures plus `2` independent successes for a concept.
- Adjective+noun meanings such as `small apple` should be introduced as symbol combinations, not raw image-size comparison.
- `Pair Completion` should mean `result = symbol1 + symbol2` with one missing symbol, not a half-picture puzzle.

## Risks

- Star thresholds and learned thresholds may need adjustment after observing the first child playtests.
- Gameplay and parent-progress agents will need to align on whether `supported success` is stored explicitly or derived from attempt history.
- Picture-only puzzle families can accidentally drift away from symbol meaning if they are promoted too early.

## Next Update

- Promote the approved next puzzle-build order into implementation planning once the lead selects the next slice.
