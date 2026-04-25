# Game Design

## Scope

This document defines the Milestone 1 first-playable game loop for Bliss.

It is intentionally narrow:
- one puzzle type: `Anchor Match`
- one starter concept slice: `apple`, `water`, `ball`, `book`, `dog`, `cat`
- one calm 3 to 5 minute session structure

## First-Playable Loop: Anchor Match

Child sees one large target picture in the center.

A small tray below shows Bliss symbol cards that can be dragged into one drop slot under the target picture.

The child goal is simple:
- look at the picture
- drag the matching Bliss symbol into place
- receive calm confirmation
- move to the next round

The first playable should avoid mode switching, reading, and layered instructions. The same interaction pattern repeats for the full session.

## First Concept Slice

Use only these six concepts:
- `apple`
- `water`
- `ball`
- `book`
- `dog`
- `cat`

These concepts are enough to test:
- three curriculum categories
- concrete noun recognition
- repeated exposure without a large content load

## Exact Round Structure

Each round contains:
- one target picture
- one correct Bliss symbol
- one or two distractor symbols depending on difficulty step
- one drop slot

Round flow:
1. Show the target picture already settled on screen.
2. Reveal the draggable symbol choices in the tray.
3. Child drags one symbol to the drop slot.
4. If correct, snap the symbol into place, play one gentle success sound, show a brief visual confirmation, then advance automatically after a short pause.
5. If incorrect, return the symbol to the tray with no harsh sound or fail state.
6. On the first wrong answer, remove one distractor if more than one distractor remains.
7. If the child still struggles, keep only the correct symbol and let the round finish as a supported success.

Milestone 1 default round count for a full session:
- `8` rounds total

Recommended concept distribution across those 8 rounds:
- rounds 1 to 6: one exposure each for `apple`, `water`, `ball`, `book`, `dog`, `cat`
- rounds 7 to 8: two repeat rounds drawn from concepts already shown in the same session

This gives one full pass across the concept slice plus light reinforcement without making the session long.

## Difficulty Behavior

Milestone 1 should use fixed simple difficulty steps, not full adaptation.

### Step 1: Guided Intro
- used for the first 2 rounds of a child’s first completed session
- `2` choices total: `1` correct, `1` distractor
- if wrong, remove the distractor immediately

### Step 2: Standard First Playable
- used for the remaining rounds once the child has completed the intro rounds
- `3` choices total: `1` correct, `2` distractors
- first wrong answer removes `1` distractor
- second wrong answer removes the remaining distractor

### Step-Down Rule
- if two consecutive rounds need supported success, the next round should start at `2` choices instead of `3`
- once the child completes two rounds in a row without support, return to `3` choices

This is enough adaptation for Milestone 1:
- it lowers pressure
- it limits repeated wrong attempts
- it avoids complex per-concept difficulty state

## Wrong-Answer Handling

Wrong-answer handling must stay neutral and supportive.

Rules:
- no buzzer, shake, red flash, or sad character reaction
- incorrect card returns smoothly to the tray
- target picture stays visible
- the layout becomes easier after the first mistake
- repeated struggle resolves into a supported success, not a fail screen

Supported success is preferable to requiring repeated retries. The product goal is calm recognition practice, not testing endurance.

## Session Flow For A 3 To 5 Minute Slice

Milestone 1 session flow:
1. Child enters `HomeScreen`.
2. Child taps the single prominent play affordance.
3. Session runs `8` Anchor Match rounds in sequence.
4. Session ends on a summary screen with stars, gentle praise, and one visible completion outcome.
5. Child returns to `HomeScreen`.

Pacing rules:
- no timer is shown
- rounds should advance quickly after a correct answer
- no interstitial instruction screens between rounds
- no reward popups after every round beyond brief confirmation

Practical target:
- most rounds should resolve in 15 to 25 seconds
- supported rounds may resolve faster once distractors are removed
- the full session should usually land around 3 to 4 minutes

## Star And Reward Logic

Stars are awarded only at session end.

Milestone 1 rule:
- `3` stars: child completes the session with `0` or `1` supported-success rounds
- `2` stars: child completes the session with `2` to `3` supported-success rounds
- `1` star: child completes the session with `4` or more supported-success rounds

Notes:
- every completed session earns at least `1` star
- stars reflect support needed, not pass or fail
- session summary may include a short calm animation and one praise sound effect
- no currency, streaks, loot, or variable chest rewards in Milestone 1

Unlock behavior for Milestone 1:
- finishing a session counts as successful completion
- unlock progression should depend on session completion, not star count

## Simple Progression And Mastery Rules

Milestone 1 progression should be shallow and easy to track in one save file.

### Per-Concept Tracking

For each concept, track:
- exposure count
- independent success count
- supported success count

### Learned Rule

Mark a concept as `learned` when both conditions are met:
- it has at least `3` total exposures across completed sessions
- it has at least `2` independent successes

### Category Mastery Rule

A category is `mastered` when all currently released concepts in that category are marked `learned`.

For the first playable slice this means:
- food mastery requires `apple` and `water`
- objects mastery requires `ball` and `book`
- animals mastery requires `dog` and `cat`

### Session Completion Progression

Milestone 1 progression unlocks by session count, not by branching content logic:
- session 1 onward: play `Anchor Match` only
- later release phases may be unlocked after completed sessions, but that content is deferred from this document

This keeps parent reporting possible without forcing a complex progression tree.

## Deliberately Deferred

Do not design these into Milestone 1:
- reverse-direction puzzle mixing inside the same session
- per-concept spaced repetition scheduling
- large adaptive difficulty trees
- streak systems
- mid-session celebration scenes
- failure recovery menus
- text instructions or reading-dependent prompts
- sentence building or communication features
- parent-controlled lesson setup complexity
- content gating based on star thresholds

## Gameplay Anti-Patterns To Avoid

- Adding timers, countdowns, or any other speed pressure
- Treating wrong answers as failures that block completion
- Showing long written instructions to the child
- Mixing several puzzle rules into the first playable session
- Overusing sounds, particle bursts, or constant reward animation
- Asking the child to navigate menus between rounds
- Hiding the correct answer for too long after repeated struggle
- Building progression around perfect performance instead of calm repetition
- Turning the first playable into a quiz instead of a supported learning loop

## Milestone 1 Implementation Contract

If implementation needs a concrete target, use this:
- puzzle type: `Anchor Match`
- session length: `8` rounds
- first concept slice: `apple`, `water`, `ball`, `book`, `dog`, `cat`
- choices per round: `2` in guided intro, otherwise `3`
- first wrong answer removes one distractor
- repeated struggle resolves to supported success
- stars awarded only at session end
- progression unlocks on session completion
