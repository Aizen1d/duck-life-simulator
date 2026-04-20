# Tasks

Use this file for known work that is not finished yet. Keep tasks concrete and avoid adding speculative mechanics.

## Backlog
- [ ] Play-test Shop and Hungry V0 in Roblox Studio, including the farm `Shop` button, fade transition, placeholder shop screen, back button, Duck Feed purchase, coin subtraction, feed inventory count, `Hungry` tester request, `Need feed` state, feeding with Duck Feed, feed consumption, and mobile layout.
- [ ] Design or approve the final Shop V0 background asset prompt or image.
- [ ] Review Shop V0 after play-testing and decide whether to keep Duck Feed at `5` coins or rebalance it.
- [ ] Play-test Duck Level/Progress V0 in Roblox Studio, including Care XP, Feed XP, selected-duck level bar, level-up feedback, max-level behavior, per-duck targeting, compact layout, and no production/economy changes.
- [ ] Define future duck level rewards, mutation or breeding interaction, and whether levels need save data.
- [ ] Play-test Duck Names V0 in Roblox Studio, including starting duck name, Buy Duck generated names, per-player duplicate avoidance, selected-duck bubble display, and compact layout readability.
- [ ] Play-test Duck Profile and Rename V0 in Roblox Studio, including `Profile` button opening, beside-duck wide-screen placement, edge flipping, anchored compact fallback, outside-click close, compact layout readability, name display, level/XP display, mood, need, care readiness, Rename/Save/Cancel flow, rename error messaging, and session-only note.
- [ ] Review and approve the large curated random duck name pool in `PrototypeConfig.duckNames`.
- [ ] Play-test Rename V0 server validation in Roblox Studio, including valid `2` to `16` character names, duplicate names, too-short names, too-long names, text-filter failure handling, and confirming rejected names do not replace the previous name.
- [ ] Review docs/SAVE_DATA_DESIGN.md and confirm the Save Data V0 scope before implementation.
- [ ] Decide whether held eggs should persist or whether only coins, ducks, upgrades, and inventory should persist in Save Data V0.
- [ ] Confirm a separate Studio test experience and API-services setup before DataStore testing.
- [ ] Decide whether duck names and profiles stay session-only until Save Data V0 implementation, or should be included in the first DataStore pass as proposed.

- [ ] Define the initial player experience and success criteria.
- [ ] Define what duck life simulator means beyond farming after the first prototype.
- [ ] Define future mutation and breeding direction before implementation.
- [ ] Design expanded duck care request types beyond petting, such as feeding, cleaning, resting, or weather reactions.
- [ ] Research mechanic patterns that could improve the duck life loop.
- [ ] Design the first 2D UI layout for the farm screen.
- [ ] Provide remaining minimum design inputs from `docs/DESIGN_INPUTS.md`.
- [ ] Play-test Buy Duck in Roblox Studio, including scaling cost, coin subtraction, duck count, visible ducks, and faster production.
- [ ] Play-test Duck Mood / Care V1 in Roblox Studio, including real individual duck cooldowns, random care request timing, the `Need` tester button, multi-duck requested-duck targeting, happy feedback, duck tap/click care bubble, duck-yellow selected-duck highlight, empty-scene deselect, and confirming no production bonus.
- [ ] Play-test the Studio-only tester panel and confirm it speeds up coin, ready egg, duck, and reset checks.
- [ ] Play-test the compact farm-screen layout by resizing the Studio viewport or using device emulation, including iPhone 14 landscape around `852x393`.
- [ ] Play-test the autonomous duck motion, nest egg pile, egg-ready badge, and floating feedback in Roblox Studio.
- [ ] Import a matching left-facing duck asset if the temporary thumbnail flip fallback is not clean enough.
- [ ] Add security test cases for invalid remotes once gameplay remotes exist.
- [ ] Decide which Roblox Studio assets should be source-controlled through Rojo.
- [ ] Review the first Nano Banana Pro batch and choose approved assets.
- [ ] Move approved Nano Banana Pro outputs from `assets/design/generated` into tracked asset folders.
- [ ] Add changelog entries as meaningful project milestones are completed.

## Agent Follow-Up Tasks

- [ ] Keep `README.md` aligned with setup changes.
- [ ] Keep `docs/PROJECT_STRUCTURE.md` aligned with Rojo mapping changes.
- [ ] Keep `docs/CODING_STANDARDS.md` aligned with any new architecture decisions.
- [ ] Run the documentation impact check before finishing code, mechanic, workflow, or bug-fix tasks.
- [ ] Ask before adding external dependencies or changing tool versions.
- [ ] Resolve the Git safe-directory warning if Git status or commits are needed from this environment.

## Done

- [x] Add Save Data V0 design doc with proposed persistence scope, DataStore constraints, validation rules, migration notes, and implementation checklist.

- [x] Implement Rename V0 as session-only profile editing with server-side length validation, per-player duplicate checks, Roblox text filtering, and profile footer errors.
- [x] Define Rename V0 rules: `2` to `16` character names, case-insensitive uniqueness within the player's current session duck list, and no global uniqueness until save data or reservation rules exist.
- [x] Implement Duck Profile V0 as a lightweight selected-duck identity/status panel.
- [x] Implement Duck Names V0 as server-generated session-only duck names with per-player duplicate avoidance and selected-duck bubble display.
- [x] Implement Duck Level/Progress V0 as session-only per-duck XP, selected-duck level bars, and visual-only level-up feedback.
- [x] Implement Hungry Request V0 using Duck Feed, including `Hungry?`, `Need feed`, `Feed`, server-side feed consumption, and a Studio-only `Hungry` tester action.
- [x] Implement Shop V0 shell with a farm `Shop` button, placeholder shop scene, fade transition, back button, and server-owned Duck Feed purchase.

- [x] Initialize Rojo project.
- [x] Add starter documentation plan.
- [x] Confirm the core game concept as a 2D UI-first duck life simulator with farming as the first activity.
- [x] Define the main gameplay loop in `docs/GAME_BRIEF.md`.
- [x] Add documentation update policy for future agents.
- [x] Add official Roblox documentation check policy for future agents.
- [x] Approve using libraries when they are justified and documented.
- [x] Review official Roblox GitHub library candidates for the 2D UI simulator.
- [x] Choose Wally as the Luau package workflow.
- [x] Approve React Luau as the first UI library stack.
- [x] Add niche agent roles for design, economy, React UI, Roblox systems, and content.
- [x] Add design input checklist for the first prototype.
- [x] Add design prompt library for Nano Banana Pro workflow.
- [x] Add asset folders and workflow for generated and approved design images.
- [x] Approve one-variant prototype polish rule for first visuals.
- [x] Approve Cozy Pond Farm as the visual direction.
- [x] Populate ready-to-run Nano Banana Pro prompts for the first design batch.
- [x] Generate the first Nano Banana Pro batch into `assets/design/generated`.
- [x] Clarify prompt and asset rules for plain backgrounds versus UI mockups.
- [x] Confirm Option 1 as a project constraint: UI controls with autonomous duck animation, not player-controlled movement or click-to-move.
- [x] Record weather events as a future system idea.
- [x] Record broader duck life simulator direction with farming as the first activity.
- [x] Add Gameplay Research Agent and research notes workflow.
- [x] Add Prototype Scope Agent and niche agent mode selection rule.
- [x] Add dedicated Security Agent for exploit, trust-boundary, and data-integrity reviews.
- [x] Run pre-build readiness audit: Wally install, Markdown links, config readability, and Rojo build.
- [x] Approve single-player-first as the first prototype mode.
- [x] Approve temporary Roblox UI placeholders until one approved visual variant is prepared for each target.
- [x] Approve Egg Value as the first upgrade.
- [x] Approve starter economy defaults for the first prototype.
- [x] Confirm save data is not included in the first prototype.
- [x] Add the initial Luau implementation scaffold before gameplay code.
- [x] Add runtime image asset slots for the farm background, duck, egg icon, and coin icon.
- [x] Set the approved farm background runtime asset reference.
- [x] Set the approved duck runtime asset reference.
- [x] Set the approved egg and coin icon runtime asset references.
- [x] Complete the first visual runtime asset set for background, duck, egg icon, and coin icon.
- [x] Re-test the scaffold in Roblox Studio after the Rojo `init.*.luau` child-module require fix.
- [x] Implement the first server-authoritative egg, coin, collect, sell, and upgrade loop.
- [x] Wire the React farm screen to server-sent gameplay state.
- [x] Add a Studio testing checklist for the first playable prototype loop.
- [x] Play-test the first server-authoritative egg and coin loop in Roblox Studio.
- [x] Add the first autonomous duck presentation states: idle bobbing, short visual wandering, and collect reaction.
- [x] Add first-pass UI feedback for egg readiness, collected eggs, earned coins, and the Egg Value upgrade.
- [x] Smooth the duck animation update rate and add direction-aware facing support.
- [x] Add a capped visual egg pile with a total-count badge on the nest for available eggs.
- [x] Add Buy Duck as the first duck progression action.
- [x] Convert the lower-right upgrade area into a right-side progression stack.
- [x] Show up to 10 smaller ducks visually when duck count increases.
- [x] Add a Studio-only tester panel for speeding up prototype loop checks.
- [x] Add an egg status/progress card to clarify the next production moment.
- [x] Add compact sizing for the first farm-screen UI controls.
- [x] Approve Duck Mood / Care V0 as a feedback-only life-sim mechanic.
- [x] Implement Duck Mood / Care V0 with a server-authoritative `Care` action.
- [x] Add tap/left-click duck selection with a local care bubble.
- [x] Add server-owned per-duck Care Request V0 with a `Pet me?` prompt and Studio `Need` tester action.
- [x] Convert ducks into real session-only individual server records with per-duck care cooldowns.