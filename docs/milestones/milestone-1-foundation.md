# Milestone 1: Foundation

## Status

- `done`

## Goal

Create the project foundation needed to start implementation without product drift.

This milestone should make the new Godot project execution-ready by defining:
- the Godot app structure
- the core data contracts
- the first puzzle implementation target
- the initial parent-progress data requirements

## Why This Comes First

The project already has a stable brief, puzzle taxonomy, and curriculum direction.

What is missing is the implementation foundation that lets specialist agents work without inventing conflicting structures.

## In Scope

- Godot scene and module architecture
- progression and save-data shape
- first puzzle implementation target
- first curriculum data contract
- parent-progress data contract
- asset-pipeline constraints needed for implementation

## Out Of Scope

- full Android packaging
- full V1 curriculum implementation
- multiple puzzle types implemented in code
- polished final art pipeline
- advanced parent UI design

## Required Agents

- `lead agent`
- `godot architecture agent`
- `game design agent`
- `gameplay agent`
- `content agent`
- `parent progress agent`

Optional support:
- `asset agent`
- `qa agent`

## Agent Deliverables

### Lead Agent
- milestone plan
- task split with ownership boundaries
- integration summary

### Godot Architecture Agent
- proposed folder structure
- scene tree proposal
- autoload list
- save-data schema draft

### Game Design Agent
- first playable puzzle spec
- adaptive difficulty draft for the first loop
- session-flow definition for a minimal playable slice

### Gameplay Agent
- implementation contract for the first puzzle scene
- drag-and-drop interaction rules
- feedback behavior rules for correct and incorrect answers

### Content Agent
- first playable concept slice
- concept metadata contract
- category and release mapping for the first slice

### Parent Progress Agent
- minimal data requirements for tracking symbols learned and categories mastered
- parent-view dependency list for future milestone planning

### Asset Agent
- naming and import constraints needed by the first playable slice

### QA Agent
- risk review of the foundation plan
- missing-contract review

## Exit Criteria

Milestone 1 is complete when:
- the Godot project structure is defined
- the first puzzle type is specified clearly enough to implement
- the first content slice is defined
- the save/progression shape is defined at a practical level
- parent-progress tracking requirements are known
- cross-role contracts are documented well enough to prevent immediate drift

## Recommended Task Split

1. Architecture agent defines runtime structure.
2. Game design agent defines the first puzzle loop.
3. Content agent defines the first concept slice and metadata shape.
4. Parent progress agent defines minimal tracking fields.
5. Gameplay agent translates the puzzle loop into scene and interaction requirements.
6. Lead agent integrates and resolves conflicts.
7. QA agent reviews the integrated milestone output.

## Suggested First Concept Slice

Use a small concrete set for the first playable loop:
- apple
- water
- ball
- book
- dog
- cat

This slice is small enough for initial gameplay validation and broad enough to test category variety.

## Handoff Rules

- durable architecture decisions go to shared project memory and technical docs
- durable content decisions go to curriculum docs and shared project memory
- local drafting stays in the relevant agent worklog
- conflicts are resolved by the lead agent, not by parallel specialist edits

## Next Milestone

If this milestone completes successfully, the lead agent should open:
- `Milestone 2: First Playable Puzzle`
