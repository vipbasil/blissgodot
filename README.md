# Bliss

Offline-first Android learning game in Godot for teaching Blissymbolics to nonverbal autistic children.

## Product Summary

Bliss is a calm, short-session mobile game designed to help a child learn Bliss symbols through visual pairing puzzles. The first version is focused on learning, not communication output. The child interacts through drag-and-drop only, with no timers, no failure screens, and minimal text.

The app uses:
- Bliss symbols
- Consistent generated pictures
- Short 3-5 minute sessions
- Gentle rewards at the end of a session
- Adaptive difficulty

## Audience

Primary audience:
- Nonverbal autistic children

Initial real-world test:
- One 10-year-old child

## Platform

- Engine: Godot
- First target: Android
- Offline-first: yes
- Profiles in V1: one child profile

## V1 Goals

The first release should teach:
- Symbol recognition
- Picture -> symbol matching
- Symbol -> picture matching

The first release should not yet try to be a full communication tool. It should behave as a learning game first.

## Child Experience Constraints

Required:
- Calm presentation
- Drag-and-drop interaction
- Symbols always paired with pictures at first
- Sound effects only
- Rewards mainly at the end of a session

Avoid:
- Timers
- Failure screens
- Too much text
- Distracting sounds
- Music in V1

## Reward Model

Use:
- Stars
- Small animations
- Unlocking levels or sessions
- Gentle praise

Unlocking is based on:
- Completing a session

## Core Puzzle Taxonomy

### 1. Anchor Match
- One picture target
- Child drags the correct Bliss symbol from a small set of options
- Main entry puzzle for new concepts

### 2. Reverse Anchor Match
- One Bliss symbol target
- Child drags the correct picture from a small set of options
- Confirms understanding in the opposite direction

### 3. Pair Completion
- Partial picture-symbol pairs are shown
- Child drags the missing piece into place
- Lower-pressure reinforcement task

### 4. Discrimination Match
- Same as anchor match, but with closer distractors
- Used after initial familiarity exists

### 5. Category Sort
- Completed pairs are sorted into categories
- Initial V1 categories: food, objects, animals

### 6. Mixed Review Chain
- Short run of mixed puzzle prompts
- Used near the end of a session for reinforcement and session completion

## Difficulty Model

Adaptive difficulty should vary:
- Number of choices
- Similarity of distractors
- Drag distance
- Density of items on screen
- Mix of categories

Error handling:
- First wrong answer: remove one wrong option
- Repeated struggles: step back one difficulty level
- No hard fail state

## Curriculum Structure

### Band A: First Contact
- Teach one picture maps to one Bliss symbol
- Puzzle types: Anchor Match, Pair Completion
- Very low choice count
- One category at a time

### Band B: Core Recognition
- Build stable recognition for concrete concepts
- Puzzle types: Anchor Match, Reverse Anchor Match, Pair Completion
- Mix known and new concepts

### Band C: Discrimination
- Increase precision and reduce guessing
- Puzzle types: Discrimination Match, Reverse Anchor Match, Mixed Review Chain
- More similar distractors

### Band D: Category Generalization
- Strengthen grouping and retention
- Puzzle types: Category Sort, Mixed Review Chain, harder anchor variants
- Mixed categories in one session

## V1 Starter Curriculum

Target scope:
- 40+ concepts

Initial categories:
- Food
- Objects
- Animals

### Food
- apple
- banana
- bread
- water
- cookie
- cheese
- egg
- soup
- rice
- candy
- cup
- bottle
- spoon
- fork

### Objects
- ball
- book
- chair
- bed
- door
- table
- toy
- doll
- block
- pillow
- balloon
- toothbrush
- washcloth
- coloring book

### Animals
- dog
- cat
- bird
- duck
- bear
- pig
- horse
- cow
- rabbit
- fish
- chicken
- elephant
- monkey
- sheep

## Recommended Release Order

### Phase 1
- apple
- water
- ball
- book
- dog
- cat
- spoon
- chair

### Phase 2
- banana
- bread
- cup
- bottle
- bed
- toy
- bird
- duck

### Phase 3
- cookie
- cheese
- egg
- table
- door
- doll
- block
- pillow
- bear
- pig
- fish
- rabbit

### Phase 4
- soup
- rice
- candy
- fork
- balloon
- toothbrush
- washcloth
- coloring book
- horse
- cow
- chicken
- elephant
- monkey
- sheep

## Session Design

Target session length:
- 3-5 minutes

Suggested session flow:
1. One easy warm-up puzzle using a known concept
2. Two teaching puzzles for new or emerging concepts
3. Two reinforcement puzzles in reverse or completion form
4. One mixed review chain
5. End-of-session reward

## Mastery States

Each concept should move through:
- New
- Emerging
- Stable
- Mastered

## Parent View

V1 should include a hidden parent-facing progress screen.

Track at minimum:
- Symbols learned
- Categories mastered

## Project Positioning

This project uses the existing Bliss reference repository as a knowledge base for:
- Bliss symbol content
- Existing puzzle ideas
- Source data and assets

The new project should not reuse that repository as the app codebase.

## Next Steps

Recommended next implementation documents:
1. Godot scene architecture
2. Data model for curriculum and progress
3. Adaptive difficulty rules in exact logic
4. Asset pipeline for Bliss symbols and generated pictures
