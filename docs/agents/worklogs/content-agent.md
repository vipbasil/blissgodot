# Content Agent Worklog

## Current Focus

- first-pass Milestone 1 content schema for curriculum data contracts

## Active Tasks

- define concept and category JSON shapes for `res://data/curriculum/`
- lock the first playable concept records for `apple`, `water`, `ball`, `book`, `dog`, and `cat`
- document schema boundaries between shipped content and save progression

## Local Notes

- Use this file for curriculum drafts, naming checks, and concept-list adjustments.
- Canonical concept IDs should stay lowercase `snake_case` and avoid category or version prefixes.
- Milestone 1 content rows should stay minimal: identity, category, release phase, starting band, allowed puzzle types, and asset paths.
- `water` remains in `food` because that is the current approved curriculum grouping.
- First playable concepts all start in `release_phase: 1`, `progression_band_start: band_a`, and `default_puzzle_types: ["anchor_match"]`.

## Risks

- asset file extensions and final import pipeline are still open, so schema examples use stable path conventions rather than a locked importer format
- if category taxonomy changes later, concept IDs must stay stable and only `category_id` should move

## Next Update

- Promote finalized concept or category changes to curriculum docs and shared memory.
