# Owner Backlog

Things only the project owner can provide: Roblox platform setup, asset generation, IDs, approvals, and Studio play-testing. Agents keep this list current and wire in whatever gets provided; the owner can simply paste IDs or drop files in chat and an agent will route them.

Where provided IDs end up:

- Image asset IDs: `src/shared/AssetIds.luau`
- Badge IDs: a `badges` table in `src/shared/PrototypeConfig.luau` (created with Badges V0)
- Audio IDs: a shared audio registry (created with Audio V0)

## Now (unblocks the rest of Phase 4)

- [ ] Studio smoke test (about 10 minutes): Play mode → expect the `Day 1 streak!` toast and three `Daily:` rows at the top of the quest panel → collect/sell to advance a daily → stop → wait a few minutes → rejoin → expect the welcome-back offline-eggs toast and persisted daily progress. Full per-feature checklists are in `docs/TASKS.md`.
- [ ] Create the `5` Badges V0 badges in the Creator Dashboard for this experience (small Robux creation fee each) and provide the badge IDs: `First Duck!`, `First Rename`, `100 Eggs Collected`, `Level 5 Duck`, `7-Day Streak`.
- [ ] Audio V0 input: either pick one cozy acoustic/ambient music loop plus core sound effects (collect, sell, buy, level-up, care, button tap) from the Roblox Creator Store and provide the asset IDs, or ask an agent to shortlist candidates to audition. Settings V0 ships together with this.
- [ ] Generate the Phase 4 art-pass batch from `docs/DESIGN_PROMPTS.md` into `assets/design/generated` and review: `Badge and Achievement Icon Sheet`, `Daily Streak Calendar UI Mockup`, plus the still-ungenerated first-batch prompts (`Shop Background - Plain Environment`, `Duck Mood / Need Icon Sheet`, `Duck Profile Portrait Sheet`, `UI Kit`, `Duck Feed Icon`, `Egg and Coin Counter Concepts`, `Upgrade Icon Candidates`, `Upgrade Button Concepts`).
- [ ] Upload approved images to Roblox and provide each `rbxassetid`. Longest-standing empty slot: `duckLeft` (a left-facing duck) in `src/shared/AssetIds.luau`.

## Soon (gates Phase 5)

- [ ] Generate the `Duck Family Lineup Sheet` (one image that locks all seven family palettes) and review it scaled down to roughly `64px` sprite size before approving.
- [ ] After lineup approval: run the `Duck Family Asset Set - Template` once per family, review, upload, and provide sprite IDs.
- [ ] Review and approve the curated duck name pool in `PrototypeConfig.duckNames` (long-standing open task).

## Before soft launch (end of Phase 4)

- [ ] Complete the experience content maturity questionnaire, targeting an all-ages rating.
- [ ] Confirm the published place has Studio API services configured and run one save/rejoin check on the live place.
- [ ] Walk through both recovery dry runs with an agent: restoring a player save from DataStore version history, and rolling back to a previous published place version.

## Later milestones (no action yet)

- [ ] Create the official Roblox group with the one-time `Treat x1` join gift (before full launch).
- [ ] Generate the store presence set: `Game Icon` plus the five `Store Thumbnail - Template` scenes; decide the full-launch display title (`Duck` versus a more searchable title).
- [ ] Monetization Wave 1: one-line sign-off of products and prices, then live test purchases (with Phase 6).
- [ ] Pick real-world dates for the Phase 11 seasonal event calendar.
