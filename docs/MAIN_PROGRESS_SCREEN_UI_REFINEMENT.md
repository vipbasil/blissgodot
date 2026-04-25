# Main Progress Screen UI Refinement

Status: specialist UI/UX refinement for the real `MainProgressScreen`

Scope:
- design-only guidance for the future node-path screen
- no runtime ownership changes
- no gameplay, unlock, or save-rule changes

## Why This Refinement Exists

The current `MainProgressScreen` is still a shell card with a title, debug-like subtitle, a large continue button, and a visible parent button inside the same stack. The real screen should instead communicate:

- where the child is on a short journey
- which node is the obvious next action
- that earlier progress is safe and calm
- that parent access exists but does not compete

## Core Screen Message

With minimal reading, the child should understand:

- I already did some steps
- this big step is the one to do now
- more steps come later

Everything else is secondary.

## Presentation Regions

Replace the centered-card composition with a full-screen three-region layout:

1. `TopRail`
   - small quiet brand/title treatment on the left
   - small neutral parent entry on the far right
   - no progress stats, session counts, node ids, or instructional sentences

2. `JourneyStage`
   - the main visual field
   - contains the curved path, visible nodes, and any soft completion/focus cues
   - should own most of the vertical space

3. `FooterAction`
   - one large primary action tied to the `next` node
   - optional tiny supporting label above the button only if it clarifies the current node without introducing reading load

The path must be the center of the composition. The CTA supports the path; it should not replace it.

## Visible Path Contract

- Keep `5` visible nodes as the default implementation target.
- Show at most:
  - `2` completed nodes behind the child
  - `1` `next` node as the dominant focal point
  - `2` future nodes ahead
- If more authored nodes exist, compress the far future into partial off-path hints or do not show them yet. Do not densify the first screen.
- Use a gentle rising curve or stepped arc, not a straight row and not a maze-like map.
- Keep the path line quieter than the nodes. The line explains order; the nodes carry meaning.

## Node Spacing And Placement

- Use one large focal node near the visual center, slightly above the footer CTA.
- Keep at least `0.9x` regular-node diameter between neighboring node edges.
- Make the `next` node about `1.2x` to `1.35x` the diameter of other visible nodes.
- Keep the nearest completed node clearly behind the current node on the path, not level with it.
- Keep future nodes lighter and slightly smaller in perceived weight so they read as later, not equal choices.
- Reserve a quiet top-right corner for parent entry by keeping all node centers at least one regular-node diameter away from that corner zone.
- Leave a clear vertical breathing gap between the current node and the footer CTA so the button does not feel attached to the node.

Recommended reading flow on portrait mobile:

- completed nodes begin lower-left to left-center
- `next` node lands center to center-low
- future nodes rise toward upper-center or upper-left
- top-right remains visually quiet for the parent entry

## State Clarity Contract

### `completed`

- filled or softly tinted node
- one calm completion marker, such as a ring settle or small check
- still tappable for replay, but visually secondary
- no celebratory burst loop

### `next`

- strongest contrast and largest size
- clear picture-first art inside the node
- one-time reveal or settle cue when the screen opens or after unlock
- should feel safe and inviting, never urgent

### `available`

- only use if V1 actually exposes a replay-ready visible node beyond the completed style
- must still remain weaker than `next`
- do not let `available` nodes read as equal forward options

### `locked`

- visible as future progress, not as denial
- lower contrast, simplified art, reduced detail
- avoid heavy lock icons unless tap testing shows confusion
- on tap, allow only a small quiet response such as a soft pulse

## Parent Entry Placement

- Parent entry belongs in `TopRail`, aligned to the far right.
- It should not sit inside the node field, beside the main CTA, or inside the current-node cluster.
- Use a neutral chip, icon-text, or understated button treatment.
- Keep the hit target comfortable, but keep the visual weight low.
- Preserve the existing long-press gate flow; this screen should only present the entry quietly.

## Calm Progression Cues

- Motion should orient, then stop.
- Use only brief transitions:
  - node reveal
  - completion settle
  - focus handoff to the new `next` node
- Avoid continuous bobbing, sparkling trails, frequent pulse loops, or reward-like idle animation.
- The most useful cue is a short handoff from `just_completed_node_id` to the new `next` node, then a fully settled screen.

## Minimal Text Contract

Child-facing text should be reduced to:

- a small screen title or brand marker
- the primary CTA label such as `Play` or `Continue`
- optional one-line cue for the current node if implementation needs it

Do not show on the child surface:

- raw node ids
- session counters
- release phase labels
- mastery language
- dense instructions
- stat summaries

If the node art and path state are readable, the screen is doing its job.

## Current Shell To Real Screen Translation

When the shell is replaced:

- remove the large centered panel as the main organizing shape
- remove the subtitle pattern that exposes debug/status text
- move parent access out of the primary content stack
- promote the node path into the main surface, not into a small inset card
- keep one bottom CTA, but let it confirm the visible `next` node rather than carry the whole screen alone

## Recommended Presentation-Only Scene Slots

This is a UI scaffold recommendation, not a runtime ownership change:

- `MainProgressScreen`
- `SafeArea`
- `TopRail`
- `JourneyStage`
- `PathLine`
- `NodeLayer`
- `FooterAction`

Implementation may use different node names, but the visual separation of these regions should remain.

## Acceptance Check For Later Implementation

The real screen is aligned with this refinement if:

- the first glance shows one obvious next node without reading
- the path reads as short progress, not a menu
- completed, next, and locked states are distinguishable without labels
- parent entry is present but easy to ignore
- the screen communicates progress without counters or debug text
- the composition stays calm on a small portrait Android screen
