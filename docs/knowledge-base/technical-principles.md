# Technical Principles

## Platform

- engine: Godot
- first target: Android
- offline-first: yes
- profile count in V1: one child profile

## Product Architecture Direction

The shipped app should be a single Godot application.

Use multi-agent Codex only as a development workflow, not as runtime product architecture.

## Old Repo Usage

Use `/Users/vasilibraga/Downloads/Bliss` only for:
- Bliss symbol knowledge
- puzzle inspiration
- source datasets and reference assets

Do not treat it as the new app codebase.

## Content Direction

- generated pictures should use a consistent visual style
- V1 child flow should show picture and Bliss symbol together
- no text-dependent gameplay in the child flow

## UX Direction

- calm visual hierarchy
- no timer pressure
- no explicit fail screens
- low-noise audio only
- rewards concentrated at session end
