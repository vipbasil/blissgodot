# Puzzle Expansion QA Findings

Date: 2026-04-26

Scope:
- `phase_1_reverse_01`
- `phase_1_pair_01`
- Android emulator child-flow QA on the current debug APK

## Result

The puzzle-expansion QA pass is still not complete, but the original Android home-screen blocker is no longer active.

Runtime wiring is present and the APK builds, installs, and launches. The earlier relaunch/input failure on `HomeScreen` has been fixed, so the remaining work is to rerun the reverse/pair Android child-flow QA on the repaired build.

## Confirmed

- The current APK exports successfully after restoring the active Godot Android/JDK editor paths.
- The APK installs and launches on the emulator.
- Bliss renders after dismissing an unrelated Android `System UI isn't responding` dialog.
- Headless runtime checks already confirmed:
  - `phase_1_reverse_01` becomes next after `phase_1_anchor_01`
  - `phase_1_pair_01` becomes next after `phase_1_reverse_01`
  - `pair_completion` builds an `8` round plan
  - both reverse and pair scenes initialize

## Previously Blocking Finding

### Home `Play` does not respond after relaunch with loaded save state

Observed behavior:
- after force-stop and relaunch, Bliss shows the home screen normally
- the app window remains focused
- repeated `adb` touchscreen taps on the visible `Play` button do not advance the UI
- `adb` keyevent `ENTER` also does not advance the UI

Evidence gathered during QA:
- `mCurrentFocus` and `mFocusedApp` both stayed on `com.vasilibraga.bliss/com.godot.game.GodotAppLauncher`
- screenshots continued to show the unchanged home screen after repeated input attempts

Impact:
- blocked direct Android child-flow QA for `phase_1_reverse_01`
- blocked direct Android child-flow QA for `phase_1_pair_01`
- could not verify wrong-answer simplification, supported-success completion, or progression handoff on-device

Status:
- fixed in `scripts/screens/home_screen.gd` by adding a direct touch fallback for the visible `Play` and `Parent` buttons
- user verification confirmed the repaired relaunch path now advances correctly

## Environment Note

An Android `System UI` ANR dialog appeared on launch once, but dismissing it revealed Bliss underneath and the focused app remained Bliss. This looks like emulator/system noise, not the primary Bliss blocker for this QA slice.

## Next Step

- rerun the combined reverse/pair child-flow QA on Android now that the home relaunch/input path is reliable again
- validate wrong-answer simplification, supported-success completion, and progression handoff for both new puzzles
