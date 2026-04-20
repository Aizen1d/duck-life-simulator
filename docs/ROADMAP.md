# Roadmap

This roadmap starts from the confirmed direction: `Duck` is a 2D UI-first duck life simulator with farming as the first core activity, autonomous duck presentation, and no planned player-controlled movement. Add detail only after the user confirms specific mechanics, UI style, economy balance, event behavior, and progression depth.

## Phase 1: Foundation

- Keep Rojo and Aftman setup working.
- Establish documentation and AI-agent workflow.
- Confirm project structure and coding standards.
- Keep the 2D UI-first simulator direction documented in `docs/GAME_BRIEF.md`.
- Define the smallest first prototype scope.

## Phase 2: Prototype

- Implement the smallest playable version of the duck egg loop.
- Add UI for eggs, coins, collect, sell, one basic upgrade, the first Buy Duck progression action, Shop V0, Hungry Request V0, and feedback-only Duck Level/Progress V0.
- Add simple autonomous duck presentation such as idle bobbing, sleeping, or short visual wandering.
- Keep prototype systems easy to replace.
- Test in Roblox Studio with the Rojo plugin.
- Record design decisions in `docs/GAME_BRIEF.md`.

## Phase 3: Core Systems

- Build server-authoritative gameplay systems.
- Add client presentation, feedback, and UI.
- Define shared constants, types, and utilities.
- Add persistence only after `docs/SAVE_DATA_DESIGN.md` is reviewed, Studio API-services setup is confirmed, and DataStore testing requirements are clear.
- Expand duck, egg, upgrade, farm-slot, autonomous animation, weather-event, and duck-life event systems only after the prototype loop works.

## Phase 4: Content and Polish

- Add approved assets, world content, effects, audio, and UI polish.
- Improve onboarding and feedback.
- Test common player flows.
- Track bugs and unfinished work in `docs/TASKS.md`.

## Phase 5: Release Preparation

- Review security and remote validation.
- Test multiplayer behavior where relevant.
- Confirm performance on target devices.
- Prepare release notes and update `docs/CHANGELOG.md`.