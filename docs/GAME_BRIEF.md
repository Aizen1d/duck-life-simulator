# Game Brief

`Duck` is a 2D UI-first duck life simulator for Roblox.

Players manage a cozy duck life scene through UI screens. The player does not directly control movement; user-controlled movement and click-to-move are not planned for this game. Ducks and farm elements may still animate, wander, idle, or react automatically to make the scene feel alive. The first core loop is to collect eggs from ducks, sell eggs for coins, spend coins on upgrades or more ducks, and grow the duck life over time.

The project should prioritize simple simulator progression before adding complex life/event systems. Do not add extra mechanics, lore, monetization, save data, or asset requirements until they are confirmed.

## Current Known Facts

- The project is named `Duck`.
- The game direction is a 2D UI-first duck life simulator with farming as the first core activity.
- The first core loop is collect eggs, sell eggs, buy upgrades, buy more ducks, and grow egg production.
- Player actions use UI controls. User-controlled movement and click-to-move are not planned for v1 or future scope unless the user explicitly reverses this decision.
- Ducks may animate, wander between small visual spots, idle, sleep, or react automatically as presentation.
- The approved visual direction is Cozy Pond Farm: cute, cozy, friendly, relaxing, and built around a bright pond farm with soft 2D cartoon shapes.
- The project uses Rojo for Roblox file syncing and builds.
- The current source layout has client, server, and shared folders.
- The current Roblox world includes the starter baseplate from the Rojo project template.
- The first prototype is single-player first.
- The first prototype uses temporary UI placeholders until one approved variant is prepared for each needed visual target.
- The first upgrade is Egg Value.
- The first prototype does not use runtime save data. Save Data V0 is documented in `docs/SAVE_DATA_DESIGN.md` as a design pass before DataStore implementation.
- The source implementation now includes a server-authoritative session loop for eggs, coins, collecting, selling, the first Egg Value upgrade, Buy Duck progression, Shop V0 Duck Feed inventory, and Rename V0.
- The client requests named UI actions. It does not send egg counts, coin counts, duck counts, prices, timers, mood values, level or XP values, inventory counts, or upgrade levels. For `Care`, the client sends the selected duck index; for shop purchases, the client sends the shop item id; for Rename V0, the client sends the selected duck index and requested name. The server validates payloads before changing state.
- Duck Mood / Care V1 is approved as a feedback-only life-sim layer with real session-only individual ducks. It does not affect egg production or economy balance yet.
- Visible ducks can be tapped on mobile or left-clicked on PC to open a small local care bubble. Right-click is not required for the main interaction. The server can assign one visible duck to ask for care.
- Shop V0 is implemented with a shop GUI button, a fade-to-black transition into a placeholder shop background, purchasable `Duck Feed`, and a back button returning to the farm/lawn. Hungry duck requests can now consume Duck Feed.
- Duck Level/Progress V0 is implemented as a session-only, feedback-only layer. Care and Feed grant XP to the targeted duck, selected-duck bubbles show level progress, and level-up feedback does not change production, prices, or save data.
- Duck Names V0 is implemented as session-only server-generated names for real individual duck records. The selected-duck bubble shows the duck name.
- Duck Profile V0 is implemented as an intentional lightweight identity/status panel opened from the selected-duck bubble's `Profile` button. It shows name, level/XP, mood, current need, care availability, Rename V0 controls, and a session-only note.
- New ducks receive a random generated name when bought. Names can be edited from Duck Profile V0.
- V0 name uniqueness scope is within the player's owned duck list and is checked case-insensitively. Global or cross-player name uniqueness is not approved because it depends on save data and central reservation rules.
- Player-entered duck names are validated and filtered on the server with Roblox text filtering before they are displayed or stored.

## Core Loop

1. Ducks produce eggs over time.
2. The farm scene presents autonomous duck idle, wander, and reaction animations.
3. The player collects available eggs through UI controls.
4. The player sells eggs for coins.
5. The player can care for ducks for temporary mood feedback.
6. The player spends coins on upgrades, ducks, or farm improvements.
7. Production improves, letting the player collect faster or earn more.
8. The player unlocks more duck-related progression.

## Starter Feature Direction

The first playable prototype should stay small and test the loop clearly.

- Start with one duck.
- Show egg and coin counts in UI.
- Let the player collect eggs through a UI action.
- Let the player sell eggs through a UI action.
- Add at least one basic upgrade, such as egg value or production speed.
- Add simple autonomous duck presentation, such as idle bobbing, sleeping, or short wandering within the farm scene.
- Keep the UI readable and simple before adding polish.

## First Prototype Defaults

These values are approved as starter defaults and may be rebalanced later:

- Starting ducks: `1`
- Starting eggs: `0`
- Starting coins: `0`
- Egg production interval: `5` seconds
- Egg sell value: `1` coin
- First upgrade: `Egg Value`
- First upgrade cost: `10` coins
- First upgrade effect: `+1` coin per egg
- First duck purchase: `Buy Duck`
- First duck purchase cost: starts at `25` coins and scales as `25 * current duck count`
- First duck purchase effect: `+1` duck
- Duck Care mood default: `Content`
- Duck Care cared mood: `Happy`
- Duck Care duration: `15` seconds
- Duck Care cooldown: `5` seconds per individual duck
- Duck Care effect: visual/status feedback only for the cared duck, no production or coin bonus
- Duck Care request texts: `Pet me?` and `Hungry?`
- First Duck Care request delay: `8` seconds
- Later Duck Care request interval: `20` seconds after the previous request or care action
- Duck Care request visible cap: the server picks from up to `10` visible ducks
- Duck starting level: `1`
- Duck starting XP: `0`
- Duck XP per Care: `25`
- Duck XP per Feed: `35`
- Duck XP per level: `100`
- Duck max level: `5`
- Duck level effect: visual/status feedback only, no production or coin bonus
- Duck rename minimum length: `2` characters
- Duck rename maximum length: `16` characters
- Duck rename uniqueness: case-insensitive within the player's current session duck list
- Duck rename filtering: server-side Roblox `TextService` filtering; failed or heavily filtered names are rejected
- Save data: not implemented in the current prototype; `docs/SAVE_DATA_DESIGN.md` defines a proposed V0 persistence scope for future implementation

## Current Prototype Behavior

The current implementation is intentionally small:

- The server creates runtime remotes for UI action requests and state updates.
- The server tracks each player's session eggs, coins, available eggs, egg sell value, Egg Value upgrade level, session-only Duck Feed inventory, per-duck generated or renamed names, per-duck level/XP, and rename validation errors.
- One duck produces one available egg every `5` seconds.
- `Collect` moves available eggs into the player's egg count.
- `Sell` converts held eggs into coins using the server-owned egg value.
- `Egg Value` costs `10` coins, can be bought once, and raises egg value from `1` to `2` coins per egg.
- `Buy Duck` starts at `25` coins, scales as `25 * current duck count`, and adds `1` real session-only duck record with a generated unique name.
- Each duck produces `1` available egg every `5` seconds, so more ducks increase egg production.
- `Care` validates the selected duck index on the server, temporarily changes only that duck from `Content` to `Happy`, grants that duck `25` XP, shows feedback, clears that duck request when relevant, and starts that duck cooldown. If the request is `Hungry?`, resolving it requires and consumes `1` Duck Feed and grants `35` XP instead.
- Duck Names V0 assigns each new duck a server-generated random name from the large curated `PrototypeConfig.duckNames` pool. Names are unique within the player's current session duck list; if the curated pool is exhausted, the server falls back to numbered `Duck N` names.
- Duck Level/Progress V0 is session-only and capped at level `5`. Level progress appears in the selected-duck care bubble and Duck Profile V0 panel, and level-up feedback is presentation-only.
- Duck Profile V0 opens only when the player clicks `Profile` in the selected-duck bubble. On wider screens it opens beside the selected duck and flips left or right to stay on-screen. On compact screens it falls back to an anchored panel so it does not crowd the farm controls. It is client presentation of server-owned duck state and currently shows name, level/XP, mood, need, care readiness/cooldown, Rename V0 controls, and `Session-only duck`.
- Rename V0 lets the player edit one duck name from its profile with `Rename`, `Save`, and `Cancel`. The server trims the requested name, requires `2` to `16` characters, rejects duplicates within that player's current session duck list, filters the submitted text with Roblox `TextService`, rejects failed or heavily filtered names, and only replicates the filtered display name. Rename errors are shown in the profile footer.
- The server occasionally assigns one visible duck to ask for care with either `Pet me?` or `Hungry?`. The first request appears after about `8` seconds, then later requests are scheduled about `20` seconds after the previous request or care action.
- Tapping or left-clicking a visible duck adds a saturated duck-yellow highlight and opens a quick local care bubble with a `Profile` button. Duck selection uses scene-level nearest-duck hit testing instead of separate rectangular duck buttons so compact flocks stay more predictable. The bubble title shows the duck's generated name. If that duck is the server-selected request duck, the status line includes `Pet me?` or `Hungry?`; otherwise it shows the duck level. Clicking `Profile` opens Duck Profile V0. Tapping or clicking empty scene space closes the selection UI and profile panel. When multiple ducks overlap, the requested duck is emphasized and drawn above the flock so it stays easier to identify and tap.
- When a care request is active, other ducks can still be selected for name/level viewing, but their care button is disabled until the active request is handled. Petting one duck does not put every duck on cooldown.
- Duck mood and duck level currently do not change egg production, coins, prices, or upgrade behavior.
- The React farm screen displays the latest server-sent state.
- The duck has client-side autonomous idle bobbing, short visual wandering, and direction-aware facing while it wanders.
- The farm screen shows a small egg-ready badge, a capped visual egg pile with a total-count badge on the nest, an egg status/progress card, and floating feedback for collected eggs, earned coins, and the Egg Value upgrade.
- The farm screen uses a right-side progression stack for coin-spending actions such as Egg Value and Buy Duck.
- The farm screen has a `Shop` button that fades to a placeholder shop scene. The shop can buy server-owned `Duck Feed` for `5` coins and returns to the farm/lawn with a back button and fade transition. Duck Feed is consumed when feeding a `Hungry?` duck request.
- The first farm-screen UI adapts key controls for compact viewport sizes using Roblox display-size information plus viewport orientation checks. Short landscape layouts collapse Studio-only tester controls, hide duplicate ready messaging, and use smaller phone-landscape controls, but Studio device testing is still required.

## Shop, Hunger, Duck Level, and Duck Names Direction

Shop V0, Hungry Request V0, Duck Level/Progress V0, Duck Names V0, Duck Profile V0, and Rename V0 are implemented as a placeholder shop screen, server-owned Duck Feed inventory, a feed interaction for hungry ducks, feedback-only per-duck level progress, generated session-only duck names, lightweight profiles, and server-filtered player rename editing. Duck level rewards, production effects, or saved profile data remain planned work after the loop is tested.

Implemented Shop V0 direction:

- The farm screen has a `Shop` GUI button.
- Opening the shop uses a short fade-to-black transition, swaps to a placeholder shop background, then fades in.
- The shop has a back button that returns to the farm/lawn with the same fade transition.
- `Duck Feed` is a server-owned inventory item, not just client UI state.

Implemented Hungry Request V0 direction:

- Hungry duck requests require Duck Feed from the shop before the player can feed the hungry duck.
- Feeding a hungry duck consumes one Duck Feed, clears the request, and gives feedback-only happy mood.

Implemented Duck Level/Progress V0 direction:

- Each real session-only duck has a server-owned level and XP value.
- Care grants XP to the targeted duck.
- Feeding a hungry duck grants slightly more XP than pet care.
- Selected-duck bubbles show a level bar.
- Level-ups give visual feedback only and do not change economy balance.

Implemented Duck Names/Profile/Rename V0 direction:

- New ducks receive server-generated names from the curated name pool.
- Names are unique within the player's current session duck list.
- Profiles show identity/status details only; deeper animal-history fields wait until those systems exist.
- Rename V0 uses server-side length validation, per-player duplicate checks, Roblox text filtering, and filtered display-name replication.
- Duck names and profile edits are still session-only until save data requirements are approved.

Planned next direction:

- Generated name list approval, level rewards, production effects, mutation interaction, breeding interaction, and persistence are still undecided.

Candidate shop items to review before implementation:

- `Duck Feed`: basic food for hungry duck requests.
- `Premium Feed` or `Treat`: stronger mood/level item, exact effect undecided.
- `Fertilizer`: future farm/nest improvement item, likely not needed until farm upgrades or crops exist.
- `Nest Straw`: comfort or nest upgrade item, exact effect undecided.
- `Toy`: mood or care item, exact effect undecided.

Implementation constraints:

- Keep Shop V0 to one food item until the placeholder shop flow is play-tested.
- Do not add monetization or premium currency unless explicitly approved.
- Do not implement save data until `docs/SAVE_DATA_DESIGN.md` is reviewed, Studio API-services setup is confirmed, and remaining persistence questions are answered.
- Use temporary UI placeholders if final shop art is not ready.

## Possible Future Systems

These ideas fit the broader duck life simulator direction but should not be implemented until approved:

- Duck rarity tiers such as common, rare, epic, or legendary.
- Duck mutations that change a duck's appearance, traits, value, or behavior. The exact mutation types and effects are not defined yet.
- Duck breeding that can create new ducks or pass traits between ducks. The requirements, timing, costs, inheritance rules, and outcomes are not defined yet.
- Different egg types such as normal eggs or golden eggs.
- Hatchable ducks.
- Mood-based production bonuses or feeding boosts.
- More nest, pond, or farm slots.
- Quests or tasks such as collecting eggs or buying ducks.
- Rebirth or prestige progression.
- Limited event ducks.
- Weather events such as sunny or rainy conditions that affect duck mood, production, visuals, or temporary bonuses.
- Expanded duck care request types beyond petting, such as feeding, cleaning, resting, or weather reactions.
- Life events where ducks have small needs, moods, surprises, visitors, or temporary situations that make the farm feel alive.
- Deeper profile fields such as age, traits, family tree, mutation history, breeding history, favorite food, or long-term statistics.

## Undecided Game Decisions

The following decisions need user input before implementation:

- Long-term multiplayer or shared-farm direction beyond the first prototype.
- Specific screen layouts and final asset choices within the approved Cozy Pond Farm direction.
- Exact duck breeds, rarity tiers, egg types, and final generated name pool approval.
- Mutation rules, mutation categories, mutation visuals, and whether mutations affect production or stay cosmetic.
- Breeding rules, breeding requirements, offspring outcomes, inheritance behavior, and whether breeding needs persistent duck identity.
- Expanded economy balance and upgrade prices beyond the starter defaults.
- Required UI screens beyond the first prototype.
- Audio direction.
- Monetization or premium features.
- Whether held eggs should persist and whether duck names/profiles should be saved in the first DataStore implementation exactly as proposed in `docs/SAVE_DATA_DESIGN.md`.
- Save data implementation details beyond the Save Data V0 design pass.

## How to Use This Brief

Before adding gameplay systems, update this file with confirmed decisions. Agents should treat anything not listed here as undecided and ask before expanding scope.

## Starter Success Criteria

The first prototype is successful when:

- The player can understand the egg and coin loop from the UI.
- The player does not control movement to play the first prototype.
- One duck can generate collectible eggs.
- The duck can show at least one simple autonomous animation or reaction.
- The player can use a simple care action for visible duck mood feedback.
- Eggs can be converted into coins.
- Coins can buy at least one meaningful upgrade.
- Coins can buy more ducks to increase egg production.
- The project still builds with Rojo.