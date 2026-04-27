# Bliss Data Model V2 Architecture

## Decision

Bliss should move to a `hybrid JSON + SQLite` data model.

- Keep authored curriculum in `res://data/` as JSON.
- Move runtime learning truth to `user://bliss_v2.sqlite`.
- Keep a thin `user://save_v2.json` shell for profile, settings, migration state, and DB pointer metadata.

This is the best fit for the repo because:
- authored curriculum still needs to live in Git and be easy to review
- runtime learning now needs per-round history, KPI by puzzle, reinforcement, and track-level progression
- offline Android is a hard requirement, so all storage must stay local
- the current `save_v1.json` model cannot answer puzzle-specific mastery or abstraction coverage without becoming brittle

## Why V1 Breaks

The current model is too flat in two places:

- authored content treats nouns as the main unit and only lightly adds composition data
- runtime progress stores only per-concept totals in `save_v1.json`

That is enough for:
- `exposure_count`
- `independent_success_count`
- `supported_success_count`

It is not enough for:
- KPI by puzzle type
- category tracks with their own gates
- standalone adjectives versus adjective+noun composition
- picture-action verbs
- reinforcement scheduling
- abstraction coverage across multiple real exemplars of one symbol

## V2 Boundary

### Authored Truth

Authored truth stays in JSON under `res://data/`.

It defines:
- what symbols exist
- what they mean
- what role they play: noun, adjective, verb
- which exemplars map to each symbol
- which compositions are valid
- which pedagogic tracks exist
- which puzzle templates exist
- which progression nodes consume which tracks and templates

### Runtime Truth

Runtime truth moves to SQLite.

It stores:
- session history
- round history
- puzzle-specific KPI
- symbol mastery
- track mastery
- composition mastery
- reinforcement queue
- node progress

### Thin JSON Save Shell

`user://save_v2.json` should contain only:
- `schema_version`
- `profile`
- `settings`
- `learning_store.path`
- `learning_store.schema_version`
- `migration`

It should not be the source of truth for learning analytics.

## Authored Content Model

### Design Rule

Do not split nouns, adjectives, and verbs into separate canonical tables.

Use one canonical symbol table and give each row a `lexical_role`.

Reason:
- mastery logic should work across all symbol roles
- compositions need one stable symbol ID namespace
- parent reporting and reinforcement should not branch on file type

### Target JSON Files

```text
res://data/curriculum/
  categories.json
  tracks.json
  symbols.json
  exemplars.json
  compositions.json
  puzzle_templates.json
  progression_bands.json
res://data/progression/
  progression_nodes.json
```

### `categories.json`

Purpose:
- semantic families used for parent reporting and high-level curriculum organization

Required fields:
- `id`
- `display_name`
- `sort_order`
- `enabled`
- `reporting_group`

Example categories:
- `body_parts`
- `animals`
- `food`
- `toys`
- `plants`
- later `actions`
- later `qualities`

### `tracks.json`

Purpose:
- pedagogic progression lanes
- categories and tracks are related, but not the same thing

Examples:
- `body_parts_nouns_intro`
- `animals_nouns_intro`
- `food_nouns_intro`
- `size_qualities_intro`
- `daily_actions_intro`

Required fields:
- `id`
- `display_name`
- `category_id`
- `role_focus`
- `sort_order`
- `release_phase`
- `prerequisite_track_ids`
- `enabled`

Recommended fields:
- `starter_symbol_ids`
- `expansion_batches`
- `default_puzzle_template_ids`
- `mastery_gate_profile`

`role_focus` values:
- `noun`
- `adjective`
- `verb`
- `composition`
- `mixed_review`

### `symbols.json`

Purpose:
- canonical meaning-bearing units
- replaces the current narrow `concepts.json` model

Required fields:
- `id`
- `display_name`
- `lexical_role`
- `category_id`
- `release_phase`
- `enabled`
- `bliss_symbol_asset`
- `default_track_ids`
- `teaching_modes`

Recommended fields:
- `description`
- `tags`
- `composition_roles`
- `default_puzzle_types`
- `abstraction_group_id`

`lexical_role` values:
- `noun`
- `adjective`
- `verb`

`teaching_modes` examples:
- `picture_symbol_match`
- `symbol_picture_match`
- `standalone_quality_bucket`
- `picture_action_match`
- `composition_modifier`
- `composition_head`

Example noun:

```json
{
  "id": "apple",
  "display_name": "Apple",
  "lexical_role": "noun",
  "category_id": "food",
  "release_phase": 1,
  "enabled": true,
  "bliss_symbol_asset": "res://assets/bliss_symbols/apple.png",
  "default_track_ids": ["food_nouns_intro"],
  "teaching_modes": ["picture_symbol_match", "symbol_picture_match", "composition_head"],
  "default_puzzle_types": ["anchor_match", "reverse_anchor_match", "pair_completion"]
}
```

Example adjective:

```json
{
  "id": "small",
  "display_name": "Small",
  "lexical_role": "adjective",
  "category_id": "qualities",
  "release_phase": 1,
  "enabled": true,
  "bliss_symbol_asset": "res://assets/bliss_symbols/small.png",
  "default_track_ids": ["size_qualities_intro"],
  "teaching_modes": ["standalone_quality_bucket", "composition_modifier"],
  "default_puzzle_types": ["anchor_match", "pair_completion"]
}
```

Example verb:

```json
{
  "id": "eat",
  "display_name": "Eat",
  "lexical_role": "verb",
  "category_id": "actions",
  "release_phase": 2,
  "enabled": true,
  "bliss_symbol_asset": "res://assets/bliss_symbols/eat.png",
  "default_track_ids": ["daily_actions_intro"],
  "teaching_modes": ["picture_action_match", "symbol_picture_match"],
  "default_puzzle_types": ["anchor_match", "reverse_anchor_match"]
}
```

### `exemplars.json`

Purpose:
- explicitly model abstraction
- one stable symbol can map to many real pictures or action depictions

This is the critical new file for representing:
- different apples map to one `apple` symbol
- different dogs map to one `dog` symbol
- different body images map to one `hand` symbol

Required fields:
- `id`
- `symbol_id`
- `asset_path`
- `content_kind`
- `variant_group_id`
- `enabled`

Recommended fields:
- `style`
- `tags`
- `supports_puzzle_types`
- `salience_level`
- `crop_profile`

`content_kind` values:
- `object_picture`
- `body_part_picture`
- `action_picture`
- `composed_scene`

Example:

```json
{
  "id": "apple_red_whole_01",
  "symbol_id": "apple",
  "asset_path": "res://assets/pictures/apple.png",
  "content_kind": "object_picture",
  "variant_group_id": "apple_default",
  "style": "illustration",
  "tags": ["single", "whole", "red"],
  "supports_puzzle_types": ["anchor_match", "reverse_anchor_match"],
  "enabled": true
}
```

### `compositions.json`

Purpose:
- model combined meanings as first-class authored items

Do not hardcode compositions as adjective-only.

Use a generic composition model that supports:
- adjective + noun
- later verb + noun
- later noun + noun if Bliss content needs it

Required fields:
- `id`
- `composition_type`
- `member_symbol_ids`
- `head_symbol_id`
- `result_exemplar_id`
- `default_track_ids`
- `release_phase`
- `enabled`

Recommended fields:
- `slot_roles`
- `teaching_modes`
- `default_puzzle_types`

Example:

```json
{
  "id": "small_apple",
  "composition_type": "adjective_noun",
  "member_symbol_ids": ["small", "apple"],
  "head_symbol_id": "apple",
  "result_exemplar_id": "apple_small_01",
  "default_track_ids": ["size_qualities_on_food"],
  "release_phase": 1,
  "enabled": true,
  "slot_roles": ["modifier", "head"],
  "default_puzzle_types": ["pair_completion"]
}
```

### `puzzle_templates.json`

Purpose:
- move puzzle contract data out of code and out of overloaded node fields

Required fields:
- `id`
- `puzzle_type`
- `prompt_kind`
- `target_kind`
- `choice_kind`
- `default_choice_count`
- `max_wrong_attempts_before_support`
- `support_policy`
- `enabled`

Recommended fields:
- `candidate_pool_policy`
- `variant_policy`
- `response_mode`
- `stage_purpose`

Example templates:
- `anchor_intro_2_choice`
- `anchor_standard_3_choice`
- `reverse_standard_3_choice`
- `quality_bucket_intro`
- `composition_line_intro`
- `composition_line_standard`

### `progression_nodes.json`

Purpose:
- sequence concrete playable nodes
- nodes should consume tracks and templates, not duplicate puzzle logic ad hoc

Required fields:
- `node_id`
- `track_id`
- `puzzle_template_id`
- `sort_order`
- `release_phase`
- `focus_symbol_ids`
- `review_symbol_ids`
- `repeat_symbol_ids`
- `prerequisite_node_ids`
- `gate_profile`
- `enabled`

Recommended fields:
- `focus_composition_ids`
- `allowed_exemplar_group_ids`
- `session_round_target`
- `stage_label`
- `breadth_unlock_target`

Design rule:
- nodes are the playable schedule
- templates are the puzzle contract
- tracks are the pedagogic lane

## Runtime Learning Model

## Storage

- `user://save_v2.json`: shell only
- `user://bliss_v2.sqlite`: runtime truth

## Runtime Tables

### `learner_profile`

One row in V2, but keep the table so multi-child does not require a redesign later.

Columns:
- `learner_id TEXT PRIMARY KEY`
- `created_at TEXT`
- `display_name TEXT`
- `active INTEGER`

### `node_progress`

Tracks playable node completion and current position.

Columns:
- `learner_id TEXT`
- `node_id TEXT`
- `status TEXT`
- `first_started_at TEXT`
- `last_started_at TEXT`
- `completed_at TEXT`
- `play_count INTEGER`
- `best_support_band TEXT`
- `PRIMARY KEY (learner_id, node_id)`

`status` values:
- `locked`
- `available`
- `in_progress`
- `completed`

### `session_run`

One row per launched session.

Columns:
- `session_run_id TEXT PRIMARY KEY`
- `learner_id TEXT`
- `node_id TEXT`
- `track_id TEXT`
- `puzzle_type TEXT`
- `puzzle_template_id TEXT`
- `started_at TEXT`
- `completed_at TEXT`
- `round_count INTEGER`
- `independent_round_count INTEGER`
- `supported_round_count INTEGER`
- `star_count INTEGER`

### `round_result`

This is the core fact table.

One row per completed round.

Columns:
- `round_result_id TEXT PRIMARY KEY`
- `session_run_id TEXT`
- `learner_id TEXT`
- `node_id TEXT`
- `track_id TEXT`
- `puzzle_type TEXT`
- `puzzle_template_id TEXT`
- `target_symbol_id TEXT`
- `target_exemplar_id TEXT`
- `composition_id TEXT`
- `prompt_role TEXT`
- `correct_choice_symbol_id TEXT`
- `wrong_attempt_count INTEGER`
- `support_step_count INTEGER`
- `outcome TEXT`
- `response_time_ms INTEGER`
- `occurred_at TEXT`

`outcome` values:
- `independent_success`
- `supported_success`

`prompt_role` examples:
- `noun_picture_target`
- `symbol_target`
- `adjective_bucket_target`
- `composition_missing_modifier`
- `composition_missing_head`
- `action_picture_target`

### `symbol_puzzle_mastery`

KPI by symbol and puzzle type.

Columns:
- `learner_id TEXT`
- `symbol_id TEXT`
- `puzzle_type TEXT`
- `exposure_count INTEGER`
- `independent_success_count INTEGER`
- `supported_success_count INTEGER`
- `distinct_exemplar_count INTEGER`
- `last_seen_at TEXT`
- `mastery_state TEXT`
- `next_due_at TEXT`
- `PRIMARY KEY (learner_id, symbol_id, puzzle_type)`

`mastery_state` values:
- `new`
- `practicing`
- `stable`
- `reinforce`

### `symbol_mastery`

Overall per-symbol read model across puzzle types.

Columns:
- `learner_id TEXT`
- `symbol_id TEXT`
- `lexical_role TEXT`
- `exposure_count INTEGER`
- `independent_success_count INTEGER`
- `supported_success_count INTEGER`
- `stable_puzzle_count INTEGER`
- `distinct_exemplar_count INTEGER`
- `last_seen_at TEXT`
- `mastery_state TEXT`
- `PRIMARY KEY (learner_id, symbol_id)`

### `composition_mastery`

Needed because `small` and `apple` being known does not mean `small_apple` is known.

Columns:
- `learner_id TEXT`
- `composition_id TEXT`
- `puzzle_type TEXT`
- `exposure_count INTEGER`
- `independent_success_count INTEGER`
- `supported_success_count INTEGER`
- `last_seen_at TEXT`
- `mastery_state TEXT`
- `next_due_at TEXT`
- `PRIMARY KEY (learner_id, composition_id, puzzle_type)`

### `track_mastery`

Tracks progress inside one pedagogic lane before breadth expansion.

Columns:
- `learner_id TEXT`
- `track_id TEXT`
- `current_stage_label TEXT`
- `introduced_symbol_count INTEGER`
- `stable_symbol_count INTEGER`
- `stable_composition_count INTEGER`
- `last_played_at TEXT`
- `gate_state TEXT`
- `PRIMARY KEY (learner_id, track_id)`

`gate_state` values:
- `locked`
- `teaching`
- `review`
- `ready_to_expand`
- `reinforcement_due`

### `reinforcement_queue`

Explicit queue so reinforcement is planned, not improvised.

Columns:
- `learner_id TEXT`
- `item_type TEXT`
- `item_id TEXT`
- `preferred_puzzle_type TEXT`
- `reason TEXT`
- `priority_score REAL`
- `due_at TEXT`
- `last_served_at TEXT`
- `resolved_at TEXT`
- `PRIMARY KEY (learner_id, item_type, item_id, preferred_puzzle_type)`

`item_type` values:
- `symbol`
- `composition`
- `track`

### `migration_log`

Tracks one-time imports from V1.

Columns:
- `migration_id TEXT PRIMARY KEY`
- `source_schema_version INTEGER`
- `target_schema_version INTEGER`
- `migrated_at TEXT`
- `status TEXT`
- `notes TEXT`

## KPI Model

The raw truth is `round_result`.

Everything else is a cached or derived learning view.

This is the key architectural shift.

Recommended initial KPI gates:

- `symbol_puzzle_mastery.stable`
  - at least `3` exposures in that puzzle type
  - at least `2` independent successes
  - at least `2` distinct exemplars for noun and verb picture-based puzzles

- `symbol_mastery.stable`
  - stable in `anchor_match`
  - stable in `reverse_anchor_match`
  - no overdue reinforcement item

- `composition_mastery.stable`
  - at least `4` exposures
  - at least `3` independent successes
  - success in both missing-slot variants when relevant

- `track_mastery.ready_to_expand`
  - all focus symbols in the current micro-set are `stable`
  - current review node success is above target support threshold

These thresholds should live in authored gate profiles, not in hardcoded UI logic.

## Explicit Abstraction Model

Bliss must model abstraction directly:

- one `symbol` represents one stable notion
- many `exemplars` can point to that symbol

This allows the app to teach:
- different apples are still `apple`
- different hands are still `hand`
- different action pictures are still `eat`

Implementation rule:
- every picture shown in a round should resolve to an `exemplar_id`
- every exemplar must resolve to exactly one `symbol_id`
- every noun or verb mastery rule that claims true understanding should require at least some distinct exemplar coverage

Without this layer, the app will only teach picture memorization.

## Track Progression Before Breadth Expansion

Bliss should progress deeply inside one track before widening content.

Recommended order for a noun track such as `body_parts_nouns_intro`:

1. `Anchor Match` first contact
   - small focus set: `3` to `4` symbols
   - low choice count
   - one calm exemplar each

2. `Anchor Match` abstraction pass
   - same symbols
   - additional exemplars for each symbol

3. `Reverse Anchor Match`
   - same symbols
   - verify symbol to picture understanding

4. `Mixed review` inside the same track
   - same symbols
   - no new breadth yet

5. only after gate success:
   - add the next symbol batch in that track
   - or unlock the next track

Recommended order for adjectives:

1. standalone quality notion
   - `big`
   - `small`
   - later `green`

2. quality sorting or target-to-field selection
   - symbol `big` receives big things

3. composition teaching
   - `small + apple`
   - `big + ball`

Recommended order for verbs:

1. picture-action teaching
   - `eat`
   - `drink`
   - `sleep`

2. reverse verification
   - symbol to action picture

3. only later:
   - verb + noun compositions if the product decides to teach them

## Migration Path

The migration should be additive, not destructive.

### Content Migration

Phase 1:
- keep current IDs exactly as they are
- create `symbols.json` using current `concepts.json` rows as the initial noun seed
- create `exemplars.json` with one exemplar per current concept using the current `picture_asset`
- keep `compositions.json` and enrich it rather than replacing it
- add `tracks.json` and map current categories into initial noun tracks

Compatibility rule:
- `concepts.json` can stay temporarily as an input source or compatibility alias
- runtime code should migrate toward `symbols.json`, but the IDs must not change

### Save Migration

Boot-time migration from `save_v1.json` should:

1. create `save_v2.json`
2. create `bliss_v2.sqlite`
3. import learner/profile/settings
4. import completed session count and node completion into `session_run` summary seed and `node_progress`
5. import per-concept totals into `symbol_mastery`
6. mark imported records with `migration_log`

Important limit:
- `save_v1.json` does not contain per-puzzle round history
- therefore puzzle-level KPI cannot be reconstructed faithfully

So:
- seed `symbol_mastery` from V1 totals
- initialize `symbol_puzzle_mastery` as `unknown` or empty
- start true puzzle-level KPI from the first V2 session onward

This avoids fake precision.

## Risks And Tradeoffs

### Why Not Pure JSON

Pure JSON remains attractive for simplicity, but it is the wrong runtime store now.

Problems:
- append-only round history becomes awkward
- puzzle-specific KPI becomes slow and messy
- reinforcement scheduling becomes custom query code over nested dictionaries
- migration gets harder, not easier

### SQLite Tradeoffs

Real costs:
- requires a SQLite integration path for Godot on Android
- adds schema migration work
- needs query ownership discipline

Why it is still the right choice:
- one child profile means the DB stays small
- per-round history and reinforcement become straightforward
- parent reporting stays local and queryable
- authored content remains simple JSON under version control

### Why This Fits Bliss

- offline Android: yes
- calm game loop: yes
- data-driven growth across many puzzle types: yes
- abstraction teaching through exemplar coverage: yes
- minimal destructive rework: yes, because IDs and authored JSON remain central

## Recommended Implementation Phases

### Phase 1: Canonical Content Normalization

- add `tracks.json`
- add `symbols.json`
- add `exemplars.json`
- add `puzzle_templates.json`
- keep current IDs and current `progression_nodes.json` node IDs

### Phase 2: Runtime Store Introduction

- add SQLite service
- add `save_v2.json`
- add migration from `save_v1.json`
- keep parent settings and app settings in the JSON shell

### Phase 3: Session Fact Recording

- write `session_run`
- write `round_result`
- update `node_progress`
- keep existing puzzle scenes, but route result reporting through V2 records

### Phase 4: Mastery And Reinforcement

- build `symbol_puzzle_mastery`
- build `symbol_mastery`
- build `composition_mastery`
- build `track_mastery`
- build `reinforcement_queue`

### Phase 5: Planner Migration

- move session planning away from flat phase lists
- plan from `track_id`, `puzzle_template_id`, node gates, and reinforcement

### Phase 6: Parent Read Model

- switch parent progress from shallow counts to DB-derived summaries
- report:
  - symbols stable
  - tracks ready to expand
  - compositions learned
  - reinforcement due

## Architect Recommendation

Use `hybrid JSON + SQLite`.

Keep authored curriculum in JSON because this repo is already data-driven and Git-based.
Move runtime learning truth into SQLite because KPI by puzzle, abstraction coverage, reinforcement, and track gating now require queryable fact storage.

Do not continue growing `save_v1.json` into a nested analytics database. That path will create more rework than the SQLite integration it tries to avoid.
