# Content Schema

## Scope

This document defines the first-pass curriculum data contract for Milestone 1.

It is intentionally small:
- one concept dataset at `res://data/curriculum/concepts.json`
- one category dataset at `res://data/curriculum/categories.json`
- one active progression band for the first playable: `band_a`
- one released concept slice for the first playable: `apple`, `water`, `ball`, `book`, `dog`, `cat`

## Canonical Concept ID Rules

- use lowercase `snake_case`
- IDs must be stable and unique across all releases
- ID should represent the canonical concept noun, not an asset filename variant
- do not encode category, phase, band, locale, or difficulty into the ID
- use one concept ID per teachable item: `apple`, not `food_apple` or `apple_v2`
- if a visual asset changes, keep the same concept ID unless the taught concept itself changes
- avoid synonyms and near-duplicates in IDs; pick one canonical noun and use aliases only in future metadata if needed

## Category Naming Rules

- category IDs use lowercase `snake_case`
- Milestone 1 category IDs are `food`, `objects`, and `animals`
- category IDs are stable content keys, not child-facing labels
- every concept belongs to exactly one category
- category names should stay broad and concrete enough to support later expansion without renaming

## File Boundaries

### `res://data/curriculum/concepts.json`

Owns immutable curriculum content:
- concept identity
- category assignment
- asset paths
- release phase
- starting progression band
- allowed puzzle types

Must not contain:
- exposure counts
- success counts
- learned flags
- unlocked state
- per-child difficulty history

### `res://data/curriculum/categories.json`

Owns stable category metadata and minimal release metadata.

### Save Data

Progression stays in `user://save_v1.json` and references content by IDs only.

## `concepts.json` Shape

```json
{
  "schema_version": 1,
  "concepts": [
    {
      "id": "apple",
      "category_id": "food",
      "release_phase": 1,
      "progression_band_start": "band_a",
      "default_puzzle_types": ["anchor_match"],
      "symbol_asset": "res://assets/bliss_symbols/apple.png",
      "picture_asset": "res://assets/pictures/apple.png",
      "enabled": true
    }
  ]
}
```

### Required Concept Fields

- `id`: canonical concept ID
- `category_id`: stable category ID from `categories.json`
- `release_phase`: integer release bucket from curriculum order
- `progression_band_start`: first progression band where the concept can appear
- `default_puzzle_types`: non-empty array of puzzle type IDs allowed for this concept by default
- `symbol_asset`: app-bundled Bliss symbol asset path
- `picture_asset`: app-bundled picture asset path
- `enabled`: runtime-safe content toggle

### Optional Concept Fields

These are allowed later but are not needed for the first playable:
- `display_name`: parent-facing label only
- `tags`: internal content filters
- `notes`: editorial note, never child-facing
- `alt_picture_assets`: optional future picture variants

Milestone 1 should ship without optional fields unless a concrete implementation need appears.

## `categories.json` Shape

```json
{
  "schema_version": 1,
  "categories": [
    {
      "id": "food",
      "display_name": "Food",
      "sort_order": 1,
      "release_phase": 1,
      "progression_band_start": "band_a",
      "enabled": true
    }
  ]
}
```

### Required Category Fields

- `id`: canonical category ID
- `display_name`: parent-facing display label
- `sort_order`: stable UI and reporting order
- `release_phase`: first phase where the category has released concepts
- `progression_band_start`: first band where the category can participate
- `enabled`: runtime-safe content toggle

### Optional Category Fields

- `description`: internal or parent-facing helper copy
- `icon_asset`: future parent-view icon path

## Milestone 1 Category Records

```json
{
  "schema_version": 1,
  "categories": [
    {
      "id": "food",
      "display_name": "Food",
      "sort_order": 1,
      "release_phase": 1,
      "progression_band_start": "band_a",
      "enabled": true
    },
    {
      "id": "objects",
      "display_name": "Objects",
      "sort_order": 2,
      "release_phase": 1,
      "progression_band_start": "band_a",
      "enabled": true
    },
    {
      "id": "animals",
      "display_name": "Animals",
      "sort_order": 3,
      "release_phase": 1,
      "progression_band_start": "band_a",
      "enabled": true
    }
  ]
}
```

## Milestone 1 Metadata Rules

- `release_phase` is an integer and follows `curriculum-v1.md`
- Milestone 1 first playable concepts all use `release_phase: 1`
- `progression_band_start` uses canonical IDs from `puzzle-taxonomy.md`
- Milestone 1 first playable concepts all start at `band_a`
- `default_puzzle_types` should contain only `anchor_match` for the first playable
- later puzzle availability can expand by data update without changing concept IDs

## First Six Concept Records

```json
{
  "schema_version": 1,
  "concepts": [
    {
      "id": "apple",
      "category_id": "food",
      "release_phase": 1,
      "progression_band_start": "band_a",
      "default_puzzle_types": ["anchor_match"],
      "symbol_asset": "res://assets/bliss_symbols/apple.png",
      "picture_asset": "res://assets/pictures/apple.png",
      "enabled": true
    },
    {
      "id": "water",
      "category_id": "food",
      "release_phase": 1,
      "progression_band_start": "band_a",
      "default_puzzle_types": ["anchor_match"],
      "symbol_asset": "res://assets/bliss_symbols/water.png",
      "picture_asset": "res://assets/pictures/water.png",
      "enabled": true
    },
    {
      "id": "ball",
      "category_id": "objects",
      "release_phase": 1,
      "progression_band_start": "band_a",
      "default_puzzle_types": ["anchor_match"],
      "symbol_asset": "res://assets/bliss_symbols/ball.png",
      "picture_asset": "res://assets/pictures/ball.png",
      "enabled": true
    },
    {
      "id": "book",
      "category_id": "objects",
      "release_phase": 1,
      "progression_band_start": "band_a",
      "default_puzzle_types": ["anchor_match"],
      "symbol_asset": "res://assets/bliss_symbols/book.png",
      "picture_asset": "res://assets/pictures/book.png",
      "enabled": true
    },
    {
      "id": "dog",
      "category_id": "animals",
      "release_phase": 1,
      "progression_band_start": "band_a",
      "default_puzzle_types": ["anchor_match"],
      "symbol_asset": "res://assets/bliss_symbols/dog.png",
      "picture_asset": "res://assets/pictures/dog.png",
      "enabled": true
    },
    {
      "id": "cat",
      "category_id": "animals",
      "release_phase": 1,
      "progression_band_start": "band_a",
      "default_puzzle_types": ["anchor_match"],
      "symbol_asset": "res://assets/bliss_symbols/cat.png",
      "picture_asset": "res://assets/pictures/cat.png",
      "enabled": true
    }
  ]
}
```

## Content Versus Progression Separation

Content data is shipped, read-only, and shared across all sessions.

Save data is child-specific and mutable. It should reference content rows by `id` and store only progression state such as:
- `exposure_count`
- `independent_success_count`
- `supported_success_count`
- `learned`
- unlocked release information if needed later

Do not mirror asset paths, category labels, or release metadata into save data.

## Gameplay And Asset Constraints

- every enabled concept must have exactly one `symbol_asset` and one `picture_asset`
- asset filenames should match concept IDs where possible to reduce mapping bugs
- concept records must remain concrete and imageable; avoid abstract starter concepts
- category assignment must be single-source and not inferred from asset folders at runtime
- `default_puzzle_types` must stay compatible with the current puzzle taxonomy
- first-playable concepts must all be safe for one-picture recognition in a calm drag-and-drop loop
- content records should be complete enough for runtime loading without hardcoded fallback mappings in scenes

## Anti-Patterns To Avoid

- storing per-child progress inside curriculum JSON
- embedding long text prompts or reading-dependent instructions in concept rows
- using asset filenames as the only concept identity without a stable content ID
- encoding version suffixes like `_v2` into canonical concept IDs
- assigning one concept to multiple categories in V1
- adding fields for unreleased systems before a real consumer exists
- splitting release logic across asset folders, scene scripts, and content JSON

## Milestone 1 Summary

Use a small, stable schema:
- concept rows are ID-first and asset-backed
- category rows are minimal and stable
- release phase and starting band are simple scalar metadata
- progression remains save-only

This is enough for the first playable and leaves room for later expansion without redesigning content IDs.
