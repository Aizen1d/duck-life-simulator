# Changelog

All meaningful project changes should be recorded here.

Use short entries that describe what changed and why. Keep implementation details in the relevant docs or code comments.

## Unreleased

### Added

- Added Save Data V0 design documentation with proposed persistence scope, DataStore constraints, validation rules, migration notes, and implementation checklist.
- Added Rename V0 through Duck Profile V0, with `Rename`, `Save`, and `Cancel` UI, server-side `2` to `16` character validation, per-player duplicate checks, Roblox text filtering, and profile footer errors.
- Added Duck Profile V0 as a lightweight selected-duck panel for name, level/XP, mood, need, care readiness, and session-only status.
- Added Duck Names V0 with server-generated session-only names, per-player duplicate avoidance, and selected-duck bubble display.
- Researched Duck Profile, Names, and Rename V0 direction using animal-profile patterns plus Roblox text-filtering guidance, and recorded generated names plus rename constraints.
- Added Duck Level/Progress V0 with server-owned session-only per-duck XP, selected-duck level bars, and visual-only level-up feedback.
- Added Hungry Request V0 with `Hungry?`, `Need feed`, `Feed`, Duck Feed consumption, fed-duck feedback, and a Studio-only `Hungry` tester action.
- Added Shop V0 with a farm `Shop` button, fade transition, placeholder shop scene, back button, and server-owned `Duck Feed` purchase.
- Recorded planned duck level/progress direction after starting Shop and Hungry V0.
- Added the initial documentation and AI-agent scaffold.
- Added a documentation update policy so agents update docs when mechanics, workflow, tasks, or bug history change.
- Added a reference policy requiring official Roblox docs checks for uncertain platform behavior.
- Added a library policy allowing justified dependencies with source, license, maintenance, and setup checks.
- Added an official Roblox library candidate review for the first prototype.
- Added Wally package configuration for React Luau.
- Added niche AI agent roles for design, economy, React UI, Roblox systems, and content.
- Added a Gameplay Research Agent and gameplay research notes workflow.
- Added a Prototype Scope Agent and niche agent mode selection rule.
- Added a dedicated Security Agent for exploit, trust-boundary, and data-integrity reviews.
- Added a design input checklist for the first prototype.
- Added a design prompt library for Nano Banana Pro workflow.
- Populated ready-to-run Nano Banana Pro prompts for the first design batch.
- Recorded the first generated Nano Banana Pro batch as pending visual review.
- Added asset folders and workflow docs for generated and approved design images.
- Added pre-build readiness guidance and recorded remaining setup decisions before gameplay implementation.
- Added the initial Luau implementation scaffold with a React client app shell, placeholder farm screen, shared prototype config, shared types, and server bootstrap.
- Added runtime image asset slots for the farm background, duck, egg icon, and coin icon.
- Added directional duck asset slots for right-facing and left-facing autonomous wandering.
- Added a shared remote protocol for the first gameplay loop.
- Added a server-authoritative session state service for eggs, coins, egg production, selling, and the first Egg Value upgrade.
- Added client-side autonomous duck idle motion, short visual wandering, and collect reaction.
- Added egg-ready and floating resource feedback to the farm screen.
- Added a capped visual egg pile with a total-count badge on the nest for available eggs.
- Added Buy Duck as the first duck progression action.
- Added multiple-duck visual rendering with up to 10 smaller visible ducks before showing a count badge.
- Added a Studio-only tester panel for granting coins, ready eggs, ducks, and resetting session state during Play mode testing.
- Added a farm-screen egg status card with next-egg progress and ready-egg messaging.
- Added Duck Mood / Care V0 with server-owned `Content` and temporary `Happy` mood states, a `Care` action, cooldown, and client feedback.
- Added tap/left-click selection for visible ducks with a local `Pet me?` care bubble that reuses the server-owned `Care` action.
- Added server-owned per-duck Care Request V0 so one visible duck can ask for care with a `Pet me?` prompt.
- Added real session-only individual duck records with per-duck care cooldown, temporary cared mood, and validated care targeting.
- Added a Studio-only `Need` tester action for forcing a duck care request during Play mode.
- Recorded mutation and breeding as future-system directions without defining mechanics yet.

### Changed

- Added image size targets to design prompts and stored near-term shop, feed, need-icon, and duck-profile portrait prompts with explicit generation sizes.
- Changed Duck Profile V0 placement so wide screens open the panel beside the selected duck with edge flipping, while compact screens keep the anchored fallback panel.
- Changed Duck Profile V0 so it opens from an intentional `Profile` button in the selected-duck bubble instead of opening on every duck selection.
- Expanded the Duck Names V0 generated name pool from a small starter list to a large curated list of 234 names.
- Removed the bottom action-bar `Care` fallback so care is handled through duck tap/click bubbles instead.
- Expanded the project README beyond the default Rojo starter text.
- Defined the initial game direction as a 2D UI-first duck life simulator, with farming as the first core activity.
- Approved Cozy Pond Farm as the visual direction for design prompts and first prototype assets.
- Approved a one-variant prototype polish rule for first visuals.
- Mapped generated Wally packages into `ReplicatedStorage.Packages`.
- Clarified that background prompts and background assets must be plain environments without UI components.
- Confirmed movement direction as a project constraint: player uses UI controls while ducks can animate or wander autonomously; user-controlled movement and click-to-move are not planned.
- Confirmed first prototype defaults: single-player first, temporary UI placeholders, Egg Value as the first upgrade, starter economy values, and no save data.
- Set the approved farm background runtime asset reference for the prototype.
- Set the approved duck runtime asset reference for the prototype.
- Set the approved egg and coin icon runtime asset references for the prototype.
- Switched the duck reference to an asset thumbnail URI for visibility testing after the direct image asset did not render in Studio.
- Recorded sunny/rainy weather events as a future system idea.
- Recorded broader duck life simulator direction while keeping the first prototype focused on the egg and coin loop.
- Wired the React farm screen to server-sent gameplay state instead of static prototype values.
- Converted the collect, sell, and Egg Value controls into server-requesting UI actions.
- Converted the lower-right upgrade area into a right-side progression stack for Egg Value and Buy Duck.
- Changed Buy Duck from a flat `25` coin cost to `25 * current duck count` scaling.
- Confirmed the first server-authoritative egg and coin loop works in Roblox Studio.
- Expanded the Studio test checklist to cover duck motion and resource feedback.
- Increased the duck animation update rate and made autonomous wandering choose a facing direction from movement.
- Updated the Studio test checklist to include the nest egg pile.
- Made farm-screen counters, action buttons, progression cards, and the Studio tester panel adapt to compact viewport sizes using `GuiService.ViewportDisplaySize` plus viewport orientation checks.
- Updated progression card copy to show how many more coins are needed before an upgrade or duck purchase is available.
- Approved Duck Mood / Care V1 as feedback-only; individual duck mood and cooldown do not affect egg production or economy balance yet.
- Confirmed tap on mobile and left-click on PC as the primary duck interaction; right-click is not required.
- Changed the bottom `Care` button to focus/select the requested duck while a care request is active.
- Changed `Care` from a global flock cooldown to a validated per-duck cooldown.
- Changed requested ducks to draw above nearby ducks with stronger duck-yellow emphasis so multi-duck requests are easier to identify and tap.
- Changed the selected-duck highlight to use saturated duck-yellow color and a subtle selected-duck tint.
- Made empty scene taps/clicks clear local duck selection and close the care bubble.

### Fixed

- Fixed Duck Profile V0 spacing so label/value rows and rename footer errors no longer overlap in compact profile panels.
- Fixed duck selection during active care requests so non-request ducks can still be selected for name and level viewing while care remains locked to the requesting duck.
- Fixed mobile/emulator duck tap alignment by applying the GUI inset to touch positions and using a modestly larger touch target.
- Fixed Studio device-emulator duck taps by using `UserInputService.TouchTap` for mobile touch selection while keeping desktop clicks on `InputEnded`.
- Fixed the nearest-duck scene picker so it no longer uses a full-screen transparent button that can block normal UI controls.
- Fixed compact duck selection by replacing per-duck rectangular hitboxes with a scene-level nearest-duck input handler.
- Fixed active care requests so tapping a non-request duck focuses the requesting duck instead of showing a confusing `Find duck` bubble on the wrong duck, and changed the bottom care shortcut to show the request text instead.
- Fixed duck click reliability with modest invisible tap targets around visible duck sprites, while keeping nearby empty-space clicks precise.
- Fixed care feedback animation so petting one duck only pulses the cared duck instead of the whole flock.
- Fixed the Studio-only `Need` tester action so forced care requests clear care timing and can be cared for immediately.
- Fixed Rojo `init.*.luau` scaffold requires so generated `Client` and `Server` scripts load child modules from `script` instead of `script.Parent`.
- Fixed the scaffold layout so counters avoid the Roblox topbar and UI elements render above decorative farm shapes.
- Removed scaffold/debug copy from the farm screen now that the real background is active.
- Kept a visible fallback duck behind the runtime duck image so failed or pending image assets do not leave the farm scene empty.
- Reduced the runtime duck image size and removed the fallback duck when an approved duck image is configured.
- Restored full-screen background coverage while keeping resource counters below the Roblox topbar area.
- Polished resource counter icon badges so real egg and coin icons read more clearly.
- Centered the Studio-only tester panel so it appears in the top-center play-test area.
- Restyled the Studio-only tester panel so it reads as development tooling instead of normal gameplay UI.
- Adjusted the iPhone 14 landscape-style layout so the tester collapses to a compact pill, duplicate ready messaging hides, and progression cards do not stack on top of the farm scene.
- Reduced phone-landscape UI visual weight after UI-agent review by shrinking counters, action buttons, progression cards, icon sizes, text sizes, and compact card copy.