# Main Progress Screen UI

## Purpose

Define a child-facing progression screen that appears between puzzle sessions and gives a calm sense of advancement without becoming a busy menu. It should show one obvious next step, a small amount of past progress, and a hidden parent entry that stays secondary.

## Role In Flow

- This is not `HomeScreen`; `HomeScreen` stays a single-action launch surface.
- Use this screen after a session ends or when returning to the progression path between puzzle sessions.
- Unlocking is driven by session completion, not stars, score, or performance grading.

## Layout

- Top band: small title treatment or app mark on the left, hidden parent entry on the far right.
- Main area: a centered curved path with 5 to 7 visible nodes total.
- Visible path should show:
  - 1 completed node behind the child
  - 1 current/next playable node as the clear focus
  - 3 to 5 upcoming nodes fading into lower emphasis
- Bottom area: one large `Play` or `Continue` button tied to the current node.
- Keep the background plain or lightly textured only; the path and nodes should carry the visual interest.

## Node Styling

- Use large circular or rounded nodes with strong silhouette separation from the background.
- Current node should be the largest node and may show the concept picture or a simple category illustration.
- Completed nodes may show a quiet check, filled ring, or soft glow.
- Locked future nodes should remain readable as future steps but low-detail and low-contrast.
- Keep labels minimal; children should not need to read node text to understand what to do next.
- Use warm, calm colors with one stronger accent for the current node only.

## Progress States

- `completed`: filled node, calm success accent, optional short trail connection behind it
- `current`: strongest contrast, subtle pulse or settle animation on first reveal only
- `next_locked`: visible but muted, no playful bounce, no hard lock icon unless needed for clarity
- `far_future`: partially faded or simplified to dots/ghost nodes so the map does not become dense
- `newly_unlocked`: brief reveal animation after session completion, then settle into the normal `current` state

## Parent Entry Placement

- Place parent access in the top-right corner, outside the node path and away from the primary button.
- It should read as a small neutral text/icon target, not a colorful button.
- Preserve the deliberate long-press gate behavior; do not expose direct one-tap entry from this screen.
- Do not place parent access near the current node, bottom CTA, or center of the composition.

## MITA Reference: Copy

- Copy the idea of a simple spatial path with a few large nodes that imply journey and progress.
- Copy the sense that the next destination is visually obvious before any text is read.
- Copy the child-friendly softness of rounded forms and playful path curvature.

## MITA Reference: Do Not Copy

- Do not copy the busy textured background or scrapbook-like clutter.
- Do not copy tiny corner controls, small labels, or low-legibility node art.
- Do not copy a saturated pink path as the dominant visual element.
- Do not copy multiple competing focal points on screen at once.
- Do not copy parent access as a bright, visible corner button.

## Interaction Notes

- Tapping the current node and the bottom CTA should do the same thing.
- Completed and future nodes should not open dense submenus in V1.
- Motion should be brief and orientation-focused: reveal, settle, then stay still.
- The screen should feel like a calm checkpoint between activities, not a level-select playground.
