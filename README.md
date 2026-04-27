# Bliss

Offline-first Godot game for helping nonverbal autistic children learn Blissymbolics through calm, short visual-matching sessions.

## Status

This repository is the Godot implementation of Bliss.

Current engine target:
- Godot `4.6`

Current milestone focus:
- first playable mobile loop
- one primary puzzle: `Anchor Match`
- short `3` to `5` minute sessions
- offline-first child experience

## Product Direction

Bliss is being built as a learning game first, not a full communication tool.

Core experience goals:
- calm presentation
- drag-and-drop only interaction
- no timers
- no failure screens
- minimal text in the child-facing flow
- gentle end-of-session rewards

Initial target platform:
- Android

## Current First-Playable Loop

The current design center is `Anchor Match`:
- one target picture is shown
- the child drags the matching Bliss symbol into a drop slot
- incorrect answers quietly simplify the round
- repeated struggle resolves as supported success rather than failure

The current starter concept slice is:
- `apple`
- `water`
- `ball`
- `book`
- `dog`
- `cat`

## Open The Project

1. Install Godot `4.6`.
2. Open `/Users/vasilibraga/bliss/project.godot` in the Godot editor.
3. Run the main scene from the editor, or use:

```bash
godot --path /Users/vasilibraga/bliss
```

Main scene:
- `res://scenes/app/main.tscn`

## Repository Layout

- [project.godot](/Users/vasilibraga/bliss/project.godot): Godot project configuration
- [scenes](/Users/vasilibraga/bliss/scenes): app, screen, puzzle, and component scenes
- [scripts](/Users/vasilibraga/bliss/scripts): gameplay, screen, progression, and model logic
- [autoload](/Users/vasilibraga/bliss/autoload): shared app state, content loading, save service, and audio helpers
- [data](/Users/vasilibraga/bliss/data): curriculum, config, and progression data
- [assets](/Users/vasilibraga/bliss/assets): pictures, Bliss symbols, audio, and UI assets
- [docs](/Users/vasilibraga/bliss/docs): design, architecture, implementation plans, and work logs

## Key Docs

- [docs/GAME_DESIGN.md](/Users/vasilibraga/bliss/docs/GAME_DESIGN.md): milestone gameplay scope and child-session rules
- [docs/ARCHITECTURE.md](/Users/vasilibraga/bliss/docs/ARCHITECTURE.md): codebase structure and runtime ownership
- [docs/GAMEPLAY_IMPLEMENTATION.md](/Users/vasilibraga/bliss/docs/GAMEPLAY_IMPLEMENTATION.md): gameplay implementation contract
- [docs/MAIN_PROGRESS_IMPLEMENTATION_PLAN.md](/Users/vasilibraga/bliss/docs/MAIN_PROGRESS_IMPLEMENTATION_PLAN.md): progression-screen execution plan
- [docs/TASKS.md](/Users/vasilibraga/bliss/docs/TASKS.md): active work queue
- [docs/WORK_LOG.md](/Users/vasilibraga/bliss/docs/WORK_LOG.md): running project notes

## Git Notes

Tracked on purpose:
- `.import` files
- `.uid` files
- project scenes, scripts, assets, docs, and data

Ignored on purpose:
- `.godot/`
- `.vscode/`
- `.DS_Store`

## Near-Term Goals

- finish the first stable `Anchor Match` session loop
- wire `MainProgressScreen` cleanly into the child flow
- keep progression and save-state contracts simple and durable
- preserve a calm UX over test-like difficulty
