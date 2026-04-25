# Bliss Architecture

## Scope

This is the first-pass runtime architecture for Milestone 1. It defines a simple Godot 4 foundation for an offline-first Android learning game and avoids systems that are not needed for the first playable slice.

## Engine And Language

- Recommended engine: Godot `4.6` stable
- Recommended scripting language: `GDScript` with static typing where practical

Why:
- `GDScript` has the tightest Godot editor integration and is the lowest-friction choice for a small scene-driven app.
- The project does not need the extra packaging and tooling complexity of `.NET` for Milestone 1.
- Godot `4.6` is on the supported stable line, which is safer than starting a new Android project on an end-of-life 4.x release.

## Architecture Principles

- One Godot app, one child profile in V1
- Offline-first: all content required for V1 ships with the app
- Data-driven runtime: puzzle scenes consume content records and round definitions, not hardcoded per-concept logic
- Child flow stays calm: no timers, no fail screens, no text-heavy UI, no noisy reward loops
- Keep global state small: content and persistence can be global, active session state should stay scene-local

## Project Folder Structure

Use a small domain-based layout:

```text
res://
  autoload/
    app_state.gd
    content_db.gd
    save_service.gd
    sfx_player.gd
  scenes/
    app/
      main.tscn
    screens/
      boot_screen.tscn
      home_screen.tscn
      session_screen.tscn
      session_summary_screen.tscn
      parent_gate_screen.tscn
      parent_progress_screen.tscn
    puzzles/
      anchor_match_scene.tscn
      reverse_anchor_match_scene.tscn
      pair_completion_scene.tscn
    components/
      target_card.tscn
      choice_card.tscn
      option_tray.tscn
      drop_slot.tscn
      progress_dots.tscn
      calm_feedback.tscn
  scripts/
    models/
      concept_record.gd
      puzzle_round_def.gd
      session_plan.gd
    screens/
    puzzles/
    components/
  data/
    curriculum/
      concepts.json
      categories.json
      progression_bands.json
    config/
      app_config.json
  assets/
    bliss_symbols/
    pictures/
    audio/sfx/
    ui/
```

Notes:
- Keep scenes and scripts separate by role, not by feature explosion.
- Start with JSON content files unless a clear Godot `Resource` workflow becomes necessary later.
- Do not create per-symbol scenes or per-concept scripts.

## Scene Tree And Screen Flow

Use one root app scene and swap one active screen at a time.

```text
Main
  BackgroundLayer
  ScreenRoot
  OverlayRoot
```

Recommended flow:

1. `BootScreen`
2. `HomeScreen`
3. `SessionScreen`
4. `SessionSummaryScreen`
5. Back to `HomeScreen`

Hidden parent flow:

1. `HomeScreen`
2. `ParentGateScreen`
3. `ParentProgressScreen`
4. Back to `HomeScreen`

Guidelines:
- `BootScreen` only loads content and save data, then routes forward. It should not become a feature-heavy startup framework.
- `HomeScreen` is the child-facing launch point for the next session. Keep it minimal.
- `SessionScreen` owns the active 3 to 5 minute session and advances through puzzle rounds.
- `SessionSummaryScreen` handles stars, gentle praise, and unlock feedback at the end of the session, not after every move.
- `ParentGateScreen` is a hidden access barrier, not a full auth system in Milestone 1.

## Recommended Autoloads

Keep autoloads few and narrow.

### `AppState`

Responsibilities:
- hold the loaded save snapshot in memory
- expose the current unlocked concept set and session-completion state
- provide small app-level flags such as first launch or current screen request

Non-responsibilities:
- no scene-specific drag logic
- no content loading rules
- no direct file IO

### `ContentDB`

Responsibilities:
- load read-only curriculum and puzzle configuration data from `res://data/`
- expose concept records by ID
- expose release-order slices and puzzle availability by band

Non-responsibilities:
- no mutable progression data
- no save writes

### `SaveService`

Responsibilities:
- load and save the app state from `user://`
- manage schema versioning
- write atomically and keep a backup copy

Non-responsibilities:
- no gameplay decisions
- no parent UI logic

### `SfxPlayer`

Responsibilities:
- central place for low-noise one-shot sound effects
- enforce a small approved SFX set and volume defaults

Non-responsibilities:
- no music system
- no reward-state logic

## Data Model Boundaries

### Curriculum Data

Location:
- `res://data/curriculum/*.json`

Contains:
- concept ID
- category
- Bliss symbol asset path
- picture asset path
- release phase
- allowed puzzle types

Rules:
- read-only at runtime
- no progress or mastery fields

### Progression Data

Location:
- save file only

Contains:
- unlocked concept IDs
- per-concept exposure count
- per-concept success count
- per-concept learned flag
- current band or difficulty step if needed
- completed session count

Rules:
- tracks durable learning progress
- should stay numeric and ID-based
- should not duplicate curriculum metadata

### Session State

Location:
- owned by `SessionScreen`, optionally mirrored in `AppState` only while active

Contains:
- current session plan
- current round index
- current round attempts
- stars earned this session
- temporary per-round feedback state

Rules:
- transient
- can be discarded safely after summary is committed
- do not treat it as long-term progression

### Parent Progress Read Model

Location:
- derived from progression data, with optional cached summary fields in save

Contains:
- symbols learned
- categories mastered
- recent session count

Rules:
- parent metrics are a reporting view over progression, not a separate source of truth
- keep mastery thresholds configurable, not hardcoded into the UI

## Save And Load Strategy

Use a single JSON save file for V1:

- path: `user://save_v1.json`
- backup: `user://save_v1.bak`
- top-level fields: `schema_version`, `profile`, `progression`, `parent_progress`, `settings`

Write behavior:
- load once during `BootScreen`
- save after session summary is accepted
- save after any parent-side setting change
- avoid saving on every drag event or hover event

Implementation notes:
- write to a temp file first, then replace the main file
- if the main save fails to load, attempt the backup file
- keep one child profile only in V1
- do not store image binaries, imported resources, or duplicated curriculum rows in save data

## Reusable Puzzle Composition

Puzzle scenes should share a small common contract:

- input: `PuzzleRoundDef`
- output signals: `answered_correct`, `answered_incorrect`, `round_completed`

Common reusable pieces:
- target presenter
- draggable choice cards
- drop slot
- option tray
- calm feedback overlay
- progress dots

Composition rule:
- build puzzle variants by assembling shared components around a thin scene script
- keep puzzle-specific scripts focused on layout and answer evaluation

Do not start with a deep inheritance tree such as `BasePuzzle -> BaseMatchPuzzle -> BaseAnchorPuzzle -> AnchorMatch`. Composition is a better fit for this scope.

## First-Playable Implementation Path

Milestone 1 should bias toward one complete loop, not breadth.

Recommended order:

1. Create `Main`, `BootScreen`, `HomeScreen`, `SessionScreen`, and `SessionSummaryScreen`.
2. Implement `ContentDB`, `SaveService`, and `AppState`.
3. Define the first concept slice using the suggested Milestone 1 set: `apple`, `water`, `ball`, `book`, `dog`, `cat`.
4. Implement `Anchor Match` first as the only fully playable puzzle type.
5. Support low-pressure incorrect handling: first wrong answer removes one distractor, repeated struggle can auto-step down to an easier round.
6. Save session completion and basic learned-progress metrics.
7. Add a minimal hidden parent progress screen that reads from saved metrics.

What not to do in the first playable:
- do not implement all puzzle taxonomy types
- do not build adaptive mastery logic beyond simple thresholds
- do not add a content editor inside the app
- do not build account, cloud, or analytics systems

## Anti-Patterns To Avoid

- too many autoload singletons with overlapping state
- hardcoded concept data inside scenes or scripts
- per-concept scenes for content that belongs in data files
- mixing child-flow UI and hidden parent-flow UI in the same screen scene
- saving transient drag state as durable progress
- building a complicated event bus before the first puzzle exists
- choosing `.NET` or native extensions before a real performance need appears
- rewarding every action with large animations or noisy feedback
- adding timers, fail states, or text-heavy instructions that conflict with the brief

## Recommended Milestone 1 Contract

If another agent needs a concrete implementation target, treat this as the baseline:

- first playable puzzle type: `Anchor Match`
- first runtime content slice: `apple`, `water`, `ball`, `book`, `dog`, `cat`
- one active screen scene at a time
- one save file in `user://`
- one child profile
- end-of-session reward emphasis instead of per-action reward emphasis
