# Godot Architecture Agent Worklog

## Current Focus

- Android export preset hardening is complete on the project side; remaining Android export risk is now machine-level validation only

## Active Tasks

- Track follow-up risks around content schema, parent metrics, and asset pipeline dependencies
- Promote only lead-approved durable runtime contracts beyond the local worklog
- Keep Android export follow-up narrow to environment validation rather than more speculative preset churn

## Local Notes

- Use this file for scene-tree ideas, autoload notes, and save-schema drafts.
- First-pass architecture should stay narrow: one app shell, one child profile, one save file, and one fully playable puzzle loop.
- Recommended engine baseline is Godot `4.6` stable with `GDScript`, not `.NET`, for the lowest-friction Android and editor workflow.
- Keep curriculum data read-only in `res://data/` and progression data in `user://save_v1.json`.
- Active session state should stay owned by `SessionScreen`, not expanded into a global singleton.
- Puzzle scenes should use composition around shared components instead of a deep inheritance tree.
- First playable target should be `Anchor Match` using the milestone starter concept slice.
- Main progress should resolve authored node state through a provider fed by `ContentDB` and `AppState`, not inside screen scripts.
- Architecture plan approved `MainProgressScreen` with provider-owned node resolution and summary-gated progression commits through `main.gd`.
- Android preset now uses `com.vasilibraga.bliss`, `Bliss`, `0.1.0`, `min_sdk 24`, `target_sdk 35`, `builds/android/bliss.apk`, and `gradle_build/use_gradle_build=false`; launcher icon fields intentionally remain blank because no Android-specific icon assets exist in the repo and the project does not use a custom Android source template.

## Risks

- Exact concept metadata schema still needs alignment with the content agent.
- Parent mastery thresholds and reporting rules still need alignment with the parent-progress agent.
- Asset import and naming pipeline for Bliss symbols and generated pictures is still open across roles.
- If multiple agents define competing runtime contracts before lead integration, drift will appear quickly.
- Android export can still fail until the machine has valid Java SDK and Android SDK paths configured in Godot Editor Settings.

## Next Update

- Promote only durable cross-role runtime contracts after lead-agent review.
