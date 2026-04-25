# Bliss UI/UX Principles

## Scope

This document defines the first-pass UI/UX rules for Milestone 1.

It is intentionally narrow:
- child-facing flow for `HomeScreen`, `SessionScreen`, and `SessionSummaryScreen`
- hidden parent-facing flow for `ParentGateScreen` and `ParentProgressScreen`
- reusable presentation guidance for the first playable `Anchor Match`

The goal is a calm, highly legible, low-text interface that is realistic to implement in Godot `4.6`.

## Core Principles

- calm over excitement
- recognition over reading
- one main action per screen
- generous spacing over dense information
- predictable placement over clever variation
- supportive recovery over error emphasis

If a UI choice makes the screen busier, louder, faster, or more text-dependent, it is probably wrong for V1.

## Child-Facing Visual Direction

Milestone 1 should feel soft, stable, and uncluttered.

- use large simple shapes and clear card boundaries
- prefer warm neutral backgrounds with one gentle accent palette
- keep the play area visually centered and easy to scan
- use picture and Bliss symbol art as the primary meaning carriers
- use short parent-readable labels only where the child does not depend on them

Visual rules:
- backgrounds should be plain or lightly textured, never busy or illustrated
- surfaces should rely on 2 to 3 calm base colors plus 1 success accent
- outlines and shadows should be subtle and used to separate layers, not decorate them
- iconography should stay simple, rounded, and consistent in stroke weight

## Layout Rules By Screen

### HomeScreen

Purpose:
- present one obvious start action for the child
- avoid menu-like choice overload

Layout:
- top area: small app mark only if needed, otherwise empty breathing room
- center: one large play button or play card as the primary focus
- lower area: optional small visual hint that today means a short activity, not a long menu
- hidden parent access must stay visually secondary and out of accidental tap paths

Rules:
- only one prominent interactive element should compete for attention
- do not show progress stats, settings grids, or content maps here
- no carousel, tabs, or scrolling child UI in V1

### SessionScreen

Purpose:
- hold the full round loop with minimal variation between rounds

Layout:
- top: progress dots centered with ample margin
- middle: one large target card
- below target: one centered drop slot with clear empty and filled states
- bottom: horizontal tray of 2 to 3 choice cards with generous spacing
- feedback should appear close to the target and slot, not as a full-screen interruption

Rules:
- keep all round-critical elements visible without scrolling
- preserve stable vertical order across every round
- avoid floating secondary controls inside the main play area
- do not show timers, score counters, or written instructions

### SessionSummaryScreen

Purpose:
- mark completion with gentle reward and a clear return path

Layout:
- top: calm completion headline or icon treatment
- center: star result as the main summary element
- secondary area: one short praise line and one visible completion outcome
- bottom: one large continue button back to `HomeScreen`

Rules:
- reward happens once here, not after every round
- keep motion brief and front-loaded, then settle quickly
- avoid dense stats, charts, or per-round breakdowns on the child summary

### ParentGateScreen

Purpose:
- separate child flow from parent information without feeling punitive

Layout:
- centered compact challenge panel
- simple prompt area with large tap targets
- clear cancel/back path to `HomeScreen`

Rules:
- gate must not look like a failure or warning screen
- use parent-readable text here because this screen is not child-directed
- interaction should be short and reliable, not puzzle-like or decorative

### ParentProgressScreen

Purpose:
- present progress clearly for adults without leaking complexity into the child flow

Layout:
- top: title and close/back action
- main area: compact summary cards for sessions completed, symbols learned, and categories mastered
- lower area: simple category list or grouped concept progress rows

Rules:
- prioritize scanability over visual flair
- use plain language labels and stable ordering
- no celebratory animation loops here
- keep this screen informative, quiet, and obviously adult-facing

## Component Guidance

### Target Card

- this is the visual anchor of the round and should be the largest card on screen
- show the target picture clearly with enough padding that the image never feels cramped
- if the Bliss symbol is paired on the same card, it should be secondary to the picture in `Anchor Match`
- card should feel stable and already settled before choices appear

### Choice Cards

- choice cards must be large enough for comfortable dragging on Android tablets or phones
- keep all choices equal in size so correctness is not implied by scale
- use clear resting states, hover-over-slot states, and disabled/removed states
- when a distractor is removed after a wrong answer, fade or slide it out quietly without spectacle

### Drop Slot

- the slot should read as the destination before the child interacts
- use a simple outline, soft fill, or subtle glow to indicate the drop area
- on correct drop, the card should snap neatly into place and hold
- on incorrect drop, return the card smoothly to its original tray position

### Progress Dots

- use progress dots only for round count awareness, not performance judgment
- dots should indicate current position and completed rounds with calm state changes
- avoid numbers, percentage text, or star overlays during the session

### Feedback

- correct feedback: brief success sound, soft highlight, and short settle animation
- wrong feedback: neutral return motion only, with no red flash, shake, buzzer, or sad reaction
- supported success should feel like reduced complexity, not correction or punishment
- feedback must never block the next round for long

## Calmness Rules

### Color

- favor desaturated, friendly colors with high contrast between card surfaces and background
- reserve stronger color accents for success confirmation and primary actions
- avoid harsh red error states in the child flow
- avoid rainbow palettes that make every element compete equally

### Motion

- use short easing-based transitions that help orientation
- prefer fades, slight scale settles, and short position shifts
- keep motion under control: one meaningful animation at a time
- do not use constant pulsing, bouncing idle states, parallax, or particle-heavy effects

### Sound Coupling

- pair sound only with meaningful events such as correct placement or session completion
- keep sounds short, soft, and consistent in volume
- no layered reward stacks, jingles after every action, or ambient music in V1
- every important state change must still be understandable with sound off

### Information Density

- one task, one focus, one visual hierarchy
- child screens should use very little text and no instructional paragraphs
- if a screen needs more than one sentence to explain itself, the layout is too complex
- parent information belongs behind the gate, not in the child play loop

## Parent-Facing Presentation Rules

- parent screens may use text labels, counts, and grouped summaries
- visual style should stay consistent with the app but slightly more neutral and utilitarian
- use readable spacing, moderate type sizes, and obvious labels
- present progress as supportive reporting, not diagnosis or judgment
- avoid infantilized decoration on parent screens

## Accessibility And Comprehension Constraints

- all essential child interactions must be understandable without reading
- tap and drag targets must be large and well separated
- do not rely on color alone to communicate correctness or state
- preserve strong contrast between foreground cards and background
- avoid requiring precise motor control or quick reaction speed
- keep screen structure stable so repeated sessions build familiarity
- feedback and progression cues must remain comprehensible with sound muted
- any parent text should use plain language and short labels

## Deliberately Avoid In V1

- busy illustrated backgrounds
- multi-step child menus
- text-heavy onboarding
- timers, countdowns, or urgency cues
- failure screens or retry pressure
- mid-session reward popups
- leaderboard, streak, currency, or loot presentation
- dense analytics in the child flow
- adult settings controls mixed into child screens

## UI/UX Anti-Patterns

- making the primary play action smaller than decorative elements
- changing layout structure between rounds
- using red, shaking, or loud audio for wrong answers
- rewarding every micro-action with animation and sound
- hiding the drop target or making it ambiguous
- putting progress metrics on the child home screen
- relying on tiny icons without clear spatial grouping
- using long transitions that slow down an 8-round session
- designing parent screens like child game screens
