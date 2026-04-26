# Puzzle Taxonomy

## Core Puzzle Types

### Anchor Match
- target: picture
- action: drag the correct Bliss symbol from a small option set
- use: first introduction of a concept

### Reverse Anchor Match
- target: Bliss symbol
- action: drag the correct picture from a small option set
- use: verify understanding in the reverse direction

### Pair Completion
- target: a composed Bliss meaning such as `small + apple`
- action: place the missing symbol into a symbol-composition formula
- use: lower-pressure reinforcement and early symbol-combination teaching
- first implementation: `Composition Line`
- later variant: `Intersection Table`
- current implementation: `small/big` combined with `apple/ball` through an 8-round `phase_1_pair_01` node

### Discrimination Match
- target: picture or symbol
- action: choose among more similar distractors
- use: later precision and reduced guessing

### Category Sort
- target: category homes
- action: sort completed picture-symbol pairs into categories
- use: generalization across concepts

### Odd One Out
- target: small visible set of symbols, pictures, or paired meanings
- action: choose the item that breaks the semantic rule
- use: category contrast and concept discrimination without time pressure

### Sequence Ordering
- target: 2 to 4 symbol, picture, or paired steps
- action: arrange the items into the intended order
- use: routine structure, adjective+noun phrasing support, and early language-like sequencing

### Mixed Review Chain
- target: short sequence of mixed puzzle prompts
- action: complete several quick review tasks in one session
- use: end-of-session reinforcement and reward gating

## Progression Bands

### Band A: First Contact
- puzzle types: Anchor Match, Pair Completion
- low choice count
- one category at a time

### Band B: Core Recognition
- puzzle types: Anchor Match, Reverse Anchor Match, Pair Completion
- mix known and new concepts

### Band C: Discrimination
- puzzle types: Discrimination Match, Reverse Anchor Match, Mixed Review Chain
- closer distractors

### Band D: Category Generalization
- puzzle types: Category Sort, Mixed Review Chain, harder anchor variants
- mixed categories in one session

## Error Handling

- first wrong answer: remove one wrong option
- repeated struggle: step back one difficulty level
- no hard fail state

## Puzzle Fit By Symbol Semantics

### Symbol-First
- `Reverse Anchor Match`
- `Pair Completion`
- `Odd One Out`
- `Category Sort`
- `Sequence Ordering`
- `Target-to-Field Matching`
- `Pattern Continuation`
- `Pattern Repair`
- `Same / Different`
- `Attribute Sorting`

These are strongest when the child is learning what a Bliss symbol means, belongs with, or combines with.

### Picture-First Side Content
- `Shadow Matching`
- `Shape-Slot Fitting`
- `Exact Picture Matching`
- `Part-Whole Assembly`
- `Visual Closure`

These can support picture-side perception but should not define the core Bliss symbol-learning path.

### Avoid For Core Bliss
- `Hidden-Object Search`
- `Face-down Memory Match`
- `Tangram / Free Assembly`
- `Tiny-detail Spot-the-Difference`

These increase clutter, search fatigue, or arbitrary difficulty without helping symbol meaning enough.

## Current Build Order

1. `Reverse Anchor Match`
2. `Pair Completion` via `Composition Line`
3. `Odd One Out`
4. `Category Sort`
5. `Sequence Ordering`

Implemented so far:
- `Reverse Anchor Match`
- `Pair Completion` via `Composition Line`

## Symbol Combination Rule

- Adjective+noun meanings such as `small apple` or `big tree` should be taught as combinable symbol phrases, not as raw picture-size comparison.
- `Composition Line` should use the form `result = symbol1 + symbol2`, with one symbol missing at first.
- `Intersection Table` should be treated as a later, more abstract composition puzzle once `Composition Line` is stable.
