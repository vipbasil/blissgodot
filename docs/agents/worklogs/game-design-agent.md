# Game Design Agent Worklog

## Current Focus

- First-pass Milestone 1 game design for the `Anchor Match` first playable is drafted in `docs/GAME_DESIGN.md`.

## Active Tasks

- None currently.

## Local Notes

- Use this file for temporary puzzle, balancing, and mastery-design notes.
- First playable should stay on one repeated interaction: picture target, drag symbol, calm confirmation, next round.
- Keep the first session to `8` rounds so all six starter concepts can appear once with two lightweight repeat rounds.
- Use shallow support logic only: first wrong answer removes a distractor, repeated struggle becomes supported success.
- Session-end stars should reflect support needed, but must never block completion or unlocks.
- Proposed Milestone 1 learned rule: `3` exposures plus `2` independent successes for a concept.
- No shared-memory update yet; thresholds should be treated as first-pass until validated against implementation and playtest behavior.

## Risks

- Star thresholds and learned thresholds may need adjustment after observing the first child playtests.
- Gameplay and parent-progress agents will need to align on whether `supported success` is stored explicitly or derived from attempt history.
- Content and gameplay implementation must avoid introducing extra prompts or reverse-match mixing into the first playable.

## Next Update

- Promote stable puzzle or progression decisions to shared memory and the knowledge base.
