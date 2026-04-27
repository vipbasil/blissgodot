# Work Log

Chronological record of significant Bliss project work.

## 2026-04-24

- Created the new project root at `/Users/vasilibraga/bliss` and treated the old repo as reference-only knowledge.
- Wrote the initial project README and V1 product brief for the new app.
- Built the multi-agent coordination system:
  shared knowledge base, shared project memory, role files, worklogs, dedicated role skills, BA agent, UI/UX agent, and orchestrator playbook.
- Added the milestone system and defined `Milestone 1: Foundation`.
- Ran architecture planning and created `docs/ARCHITECTURE.md`.
- Ran game-design planning and created `docs/GAME_DESIGN.md`.
- Ran content-schema planning and created `docs/CONTENT_SCHEMA.md`.
- Ran UI/UX planning and created `docs/UI_UX.md`.
- Ran gameplay-contract planning and created `docs/GAMEPLAY_IMPLEMENTATION.md`.
- Promoted approved cross-role decisions into `docs/agents/shared-project-memory.md`.
- Scaffolded the actual Godot project:
  `project.godot`, autoloads, scenes, scripts, curriculum JSON, and asset folder structure.
- Validated the new project headlessly with Godot `4.6.1`.
- Imported real starter assets for the first six concepts from the old reference repo.
- Replaced placeholder card text with actual picture and Bliss symbol rendering, keeping text as fallback only.
- Tightened the first playable interaction:
  quieter distractor removal, slot hover state, real settled card state, and calmer success feedback.
- Improved end-of-session presentation with a clearer summary card and star display.
- Improved the parent progress screen with summary counts and per-category progress rows.
- Imported an additional batch of future-ready assets for upcoming concepts.
- Added a first visual-polish pass across key cards and screens.
- Expanded runtime curriculum content with a second released slice:
  `banana`, `bread`, `cup`, `bottle`, `bed`, `toy`, `bird`, `duck`.
- Updated session generation so the second content slice unlocks after enough completed sessions while keeping distractors limited to the active session pool.
- Fixed parent-progress and category-mastery calculations so they consider only currently released content.
- Ran the first QA pass on the playable and identified follow-up issues in save-schema hardening, parent-gate behavior, review coverage after phase unlocks, and parent-progress summary consistency.
- Fixed a scene-lifecycle crash in the first playable by making card and slot components tolerate pre-ready data assignment and by moving `ChoiceCard` data binding after `add_child`.
- Hardened save loading in `AppState` by rebuilding loaded save data into the current schema shape and recomputing parent progress instead of trusting disk payloads directly.
- Replaced the placeholder parent gate with a deliberate long-press interaction and progress indicator so parent progress is no longer reachable through a single tap.
- Reworked phase-based session generation so unlocked content expands the session mix while reserving review slots for older released concepts; phase 2 now cycles new targets while keeping phase-1 review alive.
- Aligned the parent summary counts with released-content filtering so the top-level “symbols learned” summary matches the category rows.
- Replaced the remaining text-heavy fallback states in target cards, choice cards, drop slots, and parent summary stats with more deliberate visual fallback treatment.
- Generated two offline WAV assets for success and summary feedback and wired `SfxPlayer` to reusable `AudioStreamPlayer` nodes, with playback gated by the saved `sfx_enabled` setting.
- Changed the first puzzle to use direct picture drops instead of a separate drop zone; the picture now accepts the symbol and shows the settled symbol badge on success.
- Paused further `Anchor Match` interaction refactors and wrote a lead-owned decision pack in `docs/ANCHOR_MATCH_INTERACTION_CONTRACT.md` so physical drag behavior can be approved before more implementation work.
- Marked the interaction contract as approved and added `docs/ANCHOR_MATCH_IMPLEMENTATION_PLAN.md` plus `docs/ANCHOR_MATCH_QA_CHECKLIST.md` so the physical-drag refactor can be executed against a fixed plan.
- Implemented the approved physical-drag model in code: tray source card hides during drag, one visible drag proxy carries the symbol, the picture is the only drop target, wrong drops return the same card, and correct drops settle the same card onto the picture.

## 2026-04-25

- Ran a gameplay/design specialist planning pass for a new child-facing progression screen inspired by the old MITA-style path reference while keeping Bliss child-flow constraints intact.
- Added `docs/MAIN_PROGRESS_FLOW.md` defining node states, unlock rules, tap behavior, relation to session/content phases, and the runtime data contract for a `MainProgressScreen` that sits between `HomeScreen` and `SessionScreen`.
- Updated the gameplay-agent worklog and project task tracker to record the new progression-screen contract and flag it for lead/UI-UX review before implementation.

## Current State

- The project opens cleanly in Godot `4.6.1`.
- The app has a real first-playable scaffold with real starter assets.
- The execution tracker was added after the planning and scaffolding work and backfilled here.

## 2026-04-25

- Ran a UI/UX specialist pass on the next child-facing navigation screen using the MITA reference image only as structural inspiration.
- Wrote `docs/MAIN_PROGRESS_SCREEN_UI.md` as a design-only spec for a calm short-journey progress screen that sits between puzzle sessions, defining layout, node states, parent-entry placement, text minimization, and explicit “copy/do not copy” rules.
- Updated the UI/UX agent worklog and execution tracker to record the new main-screen design handoff.
- Reviewed the specialist UI and gameplay specs together and approved the combined `MainProgressScreen` direction in `docs/MAIN_PROGRESS_SCREEN_DECISION.md`, making it the lead-owned screen contract for implementation planning.
- Reviewed the architect-owned `MainProgressScreen` implementation plan and accepted it as the execution contract for the upcoming Godot screen replacement work.
- Completed MainProgress Phase 1 by adding `data/progression/progression_nodes.json` and extending `ContentDB` to load ordered node definitions, filter them by release phase, and build prepared session plans for specific node ids without changing screen flow yet.
- Completed MainProgress Phase 2 by extending `AppState` and `SaveService` with normalized node-completion fields (`completed_node_ids`, `last_played_node_id`, `last_completed_node_id`) and helper methods for recording node progression without touching screen routing yet.
- Completed MainProgress Phase 3 by registering the `main_progress` route, rewiring `HomeScreen` play into it, routing summary continue back into it, and adding a minimal shell `MainProgressScreen` that can launch node-specific session plans.
- Completed MainProgress Phase 4 by adding a narrow `MainProgressFlowProvider`, moving session-plan resolution and summary-time progression commits into `scripts/app/main.gd`, changing `SessionScreen` to run only supplied `node_id` plus `session_plan`, and replacing the shell `MainProgressScreen` with a real node-path presentation that renders only prepared payload data.
- Ran a parallel QA review of the current `Anchor Match` physical-drag implementation and captured two high-severity touch-state issues plus one medium drag-proxy sizing risk in `docs/ANCHOR_MATCH_QA_FINDINGS.md`.
- Implemented the `Anchor Match` drag stability follow-up: return animations now keep drag input locked until cleanup finishes, touch drags stay owned by the starting finger, and drag proxies copy the source card's laid-out size instead of scene defaults.
- Ran a parallel UI/UX refinement pass for `MainProgressScreen` and captured the approved full-screen `TopRail -> JourneyStage -> FooterAction` composition, calm 5-node path guidance, and low-weight parent-entry placement in `docs/MAIN_PROGRESS_SCREEN_UI_REFINEMENT.md`.
- Formalized the workflow constraint that the lead agent must stay in planning/routing/integration mode while specialist or worker agents own normal feature implementation, and recorded that rule in the playbook, shared memory, lead briefing, and task/memory discipline files.
- Hardened the project-side Android export preset by replacing placeholder package metadata, setting `version/name` to `0.1.0`, choosing `min_sdk 24` and `target_sdk 35`, pointing the preset export path at `builds/android/bliss.apk`, and disabling Gradle-project build mode because this repo does not carry a custom Android source template; launcher icon fields remain unset because no Android icon assets were found in the project tree.
- Started machine-side validation by routing the export attempt through the locally installed Godot app so any remaining Android export failure can be identified as environment-level rather than preset-level.
- Re-ran Android export after removing the unnecessary Gradle-project build requirement; the remaining blockers are now only the missing Java SDK path and Android SDK path in Godot Editor Settings.
- Installed Homebrew `openjdk@17` and verified the supported JDK at `/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home` with the JDK 17 binary reporting `openjdk version "17.0.19" 2026-04-21`.
- Confirmed the Android SDK includes `platforms/android-35` and `build-tools/35.0.1`, and confirmed `/Users/vasilibraga/Library/Application Support/Godot/editor_settings-4.tres` contains `export/android/java_sdk_path=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home` and `export/android/android_sdk_path=/Users/vasilibraga/Library/Android/sdk`.
- Re-ran `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path /Users/vasilibraga/bliss --export-debug Android /tmp/bliss-test-debug.apk`; export still fails because Godot reports `A valid Java SDK path is required in Editor Settings.` and `A valid Android SDK path is required in Editor Settings.` even with those exact configured values.
- Resumed lead coordination from project memory, confirmed `MainProgressScreen` Phases 1 to 4 and the `Anchor Match` drag-stability follow-up are already complete, and set the next unblocked path to `MainProgressScreen` Phase 5 QA plus dedicated touch QA while Android export stays isolated behind the editor-settings investigation.
- Found the actual active Godot settings file at `/Users/vasilibraga/Library/Application Support/Godot/editor_settings-4.6.tres`, where both `export/android/android_sdk_path` and `export/android/java_sdk_path` were blank even though `editor_settings-4.tres` had been populated.
- Backed up `editor_settings-4.6.tres`, wrote the Android SDK path `/Users/vasilibraga/Library/Android/sdk` and the explicit JDK 17 path `/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home`, then reran the export to confirm the SDK-path errors were gone.
- Fixed the remaining project-side Android preset validation error by removing `compress_native_libraries`, `min_sdk`, and `target_sdk` overrides that Godot `4.6.1` rejects when `gradle_build/use_gradle_build=false`.
- Successfully exported a debug APK with `'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path /Users/vasilibraga/bliss --export-debug Android /tmp/bliss-test-debug.apk`; the only remaining export warning is that no project icon is specified in Project Settings, and the trailing `adb` daemon connection refusal does not block APK generation.
- Ran a game-design research pass on preschool puzzle families and reclassified them for Bliss as `symbol-first`, `picture-first side content`, and `avoid for core`, then promoted the next puzzle-build order into durable project memory.
- Redefined `Pair Completion` for Bliss as a symbol-composition puzzle built around `Composition Line` first and `Intersection Table` later, with adjective+noun phrases such as `small apple` treated as combinable symbol meanings rather than picture-size comparisons.
- Published `docs/REVERSE_ANCHOR_MATCH_IMPLEMENTATION_PLAN.md` as the first specialist-ready puzzle-expansion brief, specifying narrow round-data genericization, `SessionScreen` dispatch by `puzzle_type`, and a reachable `phase_1_reverse_01` progression node instead of a debug-only integration.
- Implemented `Reverse Anchor Match` through a gameplay worker slice: `ContentDB` now builds reverse round defs, `SessionScreen` dispatches `anchor_match` versus `reverse_anchor_match`, the new reverse puzzle scene uses a symbol target with picture choices, and progression now inserts `phase_1_reverse_01` immediately after `phase_1_anchor_01`.
- Verified the reverse slice at runtime with a headless Godot script: the initial next node stays `phase_1_anchor_01`, the next node after completing that anchor node becomes `phase_1_reverse_01`, the reverse session plan resolves to `reverse_anchor_match` with `symbol` target and `picture` choices, and the reverse scene initializes cleanly.
- Implemented `Pair Completion` as the first `Composition Line` slice: imported real Bliss `small` and `big` modifier symbols, added `data/curriculum/compositions.json`, shipped `scenes/puzzles/pair_completion_scene.tscn` plus `scripts/puzzles/pair_completion_scene.gd`, and taught the runtime to build `pair_completion` rounds from composition records instead of noun-only concept records.
- Added the first reachable pair-composition progression node `phase_1_pair_01` after `phase_1_reverse_01`, using the four composition meanings `small_apple`, `big_apple`, `small_ball`, and `big_ball`, with an 8-round session contract.
- Verified the pair slice at runtime with a headless Godot script: after `phase_1_reverse_01`, the next node becomes `phase_1_pair_01`, the pair session resolves to `pair_completion` with two formula slots and symbol choices, and the pair puzzle scene initializes cleanly.
- Started the combined Android child-flow QA pass for `Reverse Anchor Match` and `Pair Completion`: the current APK rebuilt and installed, Bliss rendered on the emulator after dismissing an unrelated `System UI` ANR dialog, but direct child-flow validation is blocked because after relaunch with a loaded save the home `Play` button no longer advances despite Bliss staying focused.
- Recorded the Android blocker in `docs/PUZZLE_EXPANSION_QA_FINDINGS.md`; reverse/pair interaction QA remains blocked until the relaunch/home-input issue is fixed.
- Stabilized the Android home relaunch/input path by adding a direct touch fallback on `HomeScreen` that routes visible button taps even when the normal button press path does not fire after relaunch with a loaded save.
- Confirmed the direct-touch `HomeScreen` fix in a clean headless validation pass after removing temporary debug logging; the combined reverse/pair Android QA still needs to be rerun now that the blocker is cleared.
- Ran a BA clarification pass on curriculum ordering and learned that Bliss should prioritize meaning and abstraction before communication performance: daily-life noun categories first, standalone qualities before composition, picture-action verbs before verb combinations, and deep track repetition before breadth expansion.
- Accepted the architect brief in `docs/DATA_MODEL_V2_ARCHITECTURE.md` and shifted the project priority from immediate `Odd One Out` expansion to a `Bliss Data Model V2` rollout built around hybrid authored JSON plus runtime SQLite, explicit exemplar coverage, per-puzzle KPI, track mastery, and additive migration from `save_v1.json`.
- Landed the first V2 authored-content normalization slice by adding `data/curriculum/symbols.json`, `tracks.json`, `exemplars.json`, and `puzzle_templates.json`, and by enriching `compositions.json` additively; current runtime remains stable because `ContentDB` does not read these files yet.
- Lead review confirmed the new authored V2 slice is staged rather than live and identified one follow-up data gap: the new adjective rows use `category_id: qualities` even though the current `categories.json` still only defines `food`, `objects`, and `animals`.
- Installed the real `godot-sqlite` addon under `addons/godot-sqlite` using the packaged `v4.7` release binaries, not the source-only repository checkout.
- Upgraded `LearningStoreService` from a pure stub to a live SQLite seam: after an editor verification pass, Bliss now creates `user://bliss_v2.sqlite`, opens it successfully, and materializes the initial V2 schema tables while preserving `save_v1.json` as the current gameplay compatibility source.
- Confirmed the old reference repo at `/Users/vasilibraga/Downloads/Bliss` contains both the canonical Blissymbolic body-part symbols and the paired toddler `dist/picto` picture set, with explicit ID mappings for `hand`, `eye`, `mouth`, and `nose`.
- Imported the first `body_parts` starter assets into the live project, added `body_parts` as a real authored category, created the `body_parts_nouns_intro` V2 track, and inserted a new reachable `phase_2_body_parts_01` node so the body-parts slice exists in product progression rather than only in planning.
- Extended the new body-parts slice with `phase_2_body_parts_02` as a real `reverse_anchor_match` session over `hand`, `eye`, `mouth`, and `nose`, so the track now follows the same anchor-then-reverse progression depth as earlier noun tracks.
- Changed `MainProgressScreen` path presentation so the child-visible node strip is puzzle-family-first instead of content-batch-first, collapsing repeated anchor/reverse runs into one visible node per puzzle family rather than flooding the path with near-duplicate nodes.
- Fixed the path-window behavior so a just-completed node does not immediately disappear from the visible journey; the window now anchors around the recently completed node before shifting focus to the next one.
- Imported the second `body_parts` asset batch from the old reference repo (`ear`, `head`, `arm`) into the live project, first staging them in authored content and then promoting them to real runtime progression after confirming that `expansion_batches` alone were not yet consumed by the planner.
- Added explicit `phase_2_body_parts_03` (`anchor_match`) and `phase_2_body_parts_04` (`reverse_anchor_match`) nodes so the second `body_parts` batch is actually reachable in product flow instead of remaining content-only.
