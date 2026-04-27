# Shared Project Memory

## Facts

- New project root: `/Users/vasilibraga/bliss`
- Old Bliss repo is reference-only knowledge base
- V1 target platform is Android in Godot
- V1 is a learning game first, not yet a communication tool
- Sessions should be short: 3 to 5 minutes

## Decisions

- Child flow uses drag-and-drop
- V1 teaches symbol recognition, picture to symbol, and symbol to picture
- Symbols should always be paired with generated pictures at first
- No timers, no failure screens, no distracting sounds, no music in V1
- Unlocking is based on session completion
- Parent view is hidden and tracks symbols learned and categories mastered
- `ParentGateScreen` uses a deliberate long-press interaction instead of a one-tap pass-through
- Initial content categories are food, objects, and animals
- Project baseline is Godot `4.6` stable with typed `GDScript`
- Runtime should use one root app scene and one active screen scene at a time
- Curriculum ships as read-only data in `res://data/`
- Durable progression saves to a single `user://save_v1.json` file with backup handling
- Active session state stays scene-local instead of becoming a global singleton
- First playable implementation target is `Anchor Match` using `apple`, `water`, `ball`, `book`, `dog`, and `cat`
- Milestone 1 session contract is `8` Anchor Match rounds using the first playable concept slice
- Wrong-answer contract is supportive: first wrong answer removes one distractor, repeated struggle resolves as supported success, never a fail state
- Reward contract is session-end only; unlocks depend on session completion rather than star count
- Per-concept progression should track `exposure_count`, `independent_success_count`, and `supported_success_count`
- Curriculum content contract uses stable lowercase `snake_case` concept IDs, one category per concept, and keeps release metadata in read-only curriculum JSON while progression remains save-only
- `HomeScreen` should remain a single-action child launch surface, not a menu or progress dashboard
- `SessionScreen` should keep a fixed vertical structure: progress dots, target card, choice tray, calm feedback
- `Anchor Match` should use the picture target itself as the drop target; do not show a separate green drop zone in the child flow
- Interaction changes that affect child motor/comprehension behavior should go through a lead-approved cross-agent contract before implementation
- The approved `Anchor Match` physical-drag contract must be executed through the dedicated implementation plan and QA checklist, not ad hoc refactors
- Child progression should move through `HomeScreen -> MainProgressScreen -> SessionScreen`, with `MainProgressScreen` acting as a calm short-journey node path rather than a dense menu
- `docs/MAIN_PROGRESS_IMPLEMENTATION_PLAN.md` is the approved execution contract for implementing `MainProgressScreen`; implementation should follow its phased order and guardrails
- Authored progression-node data now lives in `data/progression/progression_nodes.json`, and `ContentDB` owns loading progression nodes plus building node-specific session plans
- Durable node progression now lives under `save_data.progression` with `completed_node_ids`, `last_played_node_id`, and `last_completed_node_id`, normalized safely for older saves
- Multi-agent workflow must stay strict: the lead agent plans, routes, reviews, and integrates; specialist or worker agents own normal feature implementation
- Wrong-answer presentation should reduce complexity quietly and never use red, shake, buzzer, or error-heavy feedback
- `SessionScreen` owns session flow, round progression, and summary handoff; puzzle scenes own only per-round interaction
- Puzzle scenes should receive prepared `PuzzleRoundDef` data and must not read curriculum JSON or assemble distractors themselves
- Supported success should still end with the child placing the final correct card after distractors are removed; it should not auto-complete
- Later content phases should reserve review slots for already released concepts instead of replacing earlier targets completely
- Bliss puzzle planning should treat symbols as meaning-bearing language units, not only visual shapes
- Puzzle families should be classified as `symbol-first`, `picture-first side content`, or `avoid for core Bliss`
- `Pair Completion` is approved as a symbol-composition puzzle rather than an incomplete picture pair; its first implementation should be `Composition Line`, with `Intersection Table` reserved for later
- Adjective+noun meanings such as `small apple` and `big tree` should be taught as combinable symbol phrases rather than picture-size comparisons
- The approved next puzzle-build order is `Reverse Anchor Match -> Pair Completion (Composition Line) -> Odd One Out -> Category Sort -> Sequence Ordering`
- `Reverse Anchor Match` is now implemented in the runtime with `SessionScreen` dispatch by `puzzle_type`, generic round asset fields, and an early progression node `phase_1_reverse_01` immediately after `phase_1_anchor_01`
- `Pair Completion` is now implemented in the runtime as a real `Composition Line` puzzle using imported Bliss `small` and `big` modifier symbols plus the first composition records `small_apple`, `big_apple`, `small_ball`, and `big_ball`
- The next runtime validation for puzzle expansion is a focused QA pass covering both `phase_1_reverse_01` and `phase_1_pair_01`, not another taxonomy or architecture debate
- BA clarification tightened the curriculum direction: Bliss should teach meaning and abstraction before communication performance, prioritize daily-life noun tracks first, teach standalone qualities before composition, introduce verbs through picture-action teaching, and prefer deep track repetition before breadth expansion
- The approved data direction is now `hybrid JSON + SQLite`: authored curriculum remains in `res://data/`, runtime learning truth moves to `user://bliss_v2.sqlite`, `save_v2.json` becomes a thin shell, and explicit `exemplar -> symbol` mapping is required to teach abstraction rather than picture memorization
- New puzzle or curriculum expansion should not harden the old V1 save/content model if it would conflict with the V2 rollout for per-puzzle KPI, track mastery, composition mastery, and reinforcement scheduling
- The first authored V2 normalization slice now exists on disk in `symbols.json`, `tracks.json`, `exemplars.json`, and `puzzle_templates.json`, with additive enrichment in `compositions.json`; current runtime remains stable because `ContentDB` still reads only the V1 curriculum files
- Known follow-up: the V2-authored adjective rows reference `category_id: qualities`, but the current `categories.json` has not been expanded yet, so that mismatch must be resolved before runtime readers switch to the V2 authored model
- The real SQLite runtime dependency is now installed in-repo under `addons/godot-sqlite`, and Bliss successfully creates the live `user://bliss_v2.sqlite` file plus the initial V2 schema tables
- Current behavior remains additive: `save_v2.json` and `bliss_v2.sqlite` now exist, but gameplay truth still bridges through `save_v1.json` until legacy import and session/round DB writes are migrated
- The old reference repo at `/Users/vasilibraga/Downloads/Bliss` contains both canonical body-part Bliss symbol files and paired toddler `dist/picto` PNGs; `hand`, `eye`, `mouth`, and `nose` are now imported into the live Godot project as the first real `body_parts` asset batch
- `body_parts` is now a real authored category and phase-2 noun track in Bliss, with `phase_2_body_parts_01` inserted before the broader phase-2 noun expansion so body-part learning can enter progression without reopening the V2 schema again later
- The first live `body_parts` track now includes both `phase_2_body_parts_01` (`anchor_match`) and `phase_2_body_parts_02` (`reverse_anchor_match`) before the broader phase-2 noun expansion continues
- `MainProgressScreen` visible nodes should now be puzzle-family-first rather than content-batch-first; repeated anchor/reverse content passes should collapse into one visible node per puzzle family so the child sees variety, not a long strip of nearly identical nodes
- Completed path nodes should remain visible briefly after completion; the visible journey window should anchor around the just-completed node before shifting to the next node so progress does not appear to vanish instantly
- The second `body_parts` batch (`ear`, `head`, `arm`) is now imported into the live project, but it only became runtime-live after explicit progression nodes `phase_2_body_parts_03` and `phase_2_body_parts_04` were added; authored `expansion_batches` alone are not yet sufficient because the current planner does not consume them

## Open Questions

- exact adaptive difficulty thresholds
- exact asset import pipeline for Bliss symbols and generated images
- exact parent-progress mastery thresholds and reporting rules
- exact star thresholds and exact learned/mastered thresholds after first playable validation

## Next Handoff

- UI/UX now has a dedicated role for child-facing calmness, layout rules, parent-facing presentation, and reusable interface guidance
- BA agent handles product interrogation and requirement clarification before implementation when the product is unclear
- Keep README and knowledge-base docs aligned
- Do not treat the old repo as the new codebase
- Respect role boundaries when splitting work across agents
