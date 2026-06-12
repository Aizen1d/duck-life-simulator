# Game Brief

`Duck` is a 2D UI-first duck life simulator for Roblox.

Players manage a cozy duck life scene through UI screens. The player does not directly control movement; user-controlled movement and click-to-move are not planned for this game. Ducks and farm elements may still animate, wander, idle, or react automatically to make the scene feel alive. The first core loop is to collect eggs from ducks, sell eggs for coins, spend coins on upgrades or more ducks, and grow the duck life over time.

The project should prioritize simple simulator progression before adding complex life/event systems. Do not add extra mechanics, lore, monetization, save-data scope, or asset requirements until they are confirmed.

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
- Long-term direction is multiplayer-capable servers with personal player-owned farms. Players see their own farm by default, and Farm Visit V0 lets a player view another loaded same-server player's farm without making one Roblox server per player.
- The first prototype uses temporary UI placeholders until one approved variant is prepared for each needed visual target.
- The first upgrade is Egg Value.
- Save Data V0 is implemented for the approved current persistence scope in `docs/SAVE_DATA_DESIGN.md`.
- The source implementation now includes a server-authoritative session loop for eggs, coins, collecting, selling, the first Egg Value upgrade, Buy Duck progression, Shop V0 Duck Feed, Premium Feed, and Treat inventory, Hungry, Sleepy, and Dirty duck care requests, Guide/Tutorial V0, Weather/Event V0, Quest V0, Minigames V0 with server-backed Egg Catch rewards, Rename V0, Farm Visit V0, Farm Visit V1 visitor help, Daily Check-in V0 extended by Daily Streak V1 (7-day escalating rewards with a pause-not-reset rule), Daily Quests V0 (three rotating UTC-day goals in the quest panel with an all-complete bonus), and Offline Progress V0 (eggs accrue at `50%` of the online rate while away, capped at `2` hours, granted with a one-time welcome-back toast on rejoin).
- The client requests named UI actions. It does not send egg counts, coin counts, duck counts, prices, timers, mood values, level or XP values, inventory counts, upgrade levels, quest progress, quest levels, quest targets, or quest rewards. For `Care`, `Give Treat`, and Farm Visit V1 visitor help, the client sends the selected duck index; for shop purchases, the client sends the shop item id; for Rename V0, the client sends the selected duck index and requested name; for Egg Catch, the client starts a server-tracked round and later submits the finished score to claim a server-validated reward; for Farm Visit V0, the client sends a same-server target `UserId` and the server validates that target before switching the viewer's farm view. Farm Visit V1 also lets an owner toggle session-only visitor help. The server validates payloads before changing state.
- Duck Mood / Care V1 is approved as a feedback-only life-sim layer with real individual duck records. It does not affect egg production or economy balance yet.
- Visible ducks can be tapped on mobile or left-clicked on PC to open a small local care bubble. Right-click is not required for the main interaction. The server can assign one visible duck to ask for care.
- Shop V0 is implemented with a shop GUI button, a fade-to-black transition into a placeholder shop background, purchasable `Duck Feed`, `Premium Feed`, and `Treat`, and a back button returning to the farm/lawn. Fresh profiles now start with `Duck Feed x1` as a small onboarding support grant, and the client shows a one-time `Starter Feed x1` feedback toast on first load. If the first successful duck-help action on a fresh profile was not a hungry request, the server schedules a one-time hungry follow-up soon after onboarding so the starter feed has an immediate use. Hungry duck requests can consume Duck Feed or, if stocked, prefer Premium Feed for higher XP. Treats can grant targeted duck XP from Duck Profile V0, Sleepy duck requests can be resolved with `Rest`, and Dirty duck requests can be resolved with `Clean`.
- Duck Level/Progress V0 is implemented with a small production reward. Care, Feed, Rest, Clean, and Treat grant XP to the targeted duck, selected-duck bubbles show level progress, and each duck level above `1` adds a modest egg output bonus for that duck. Level and XP persist in Save Data V0.
- Duck Names V0 is implemented as server-generated names for real individual duck records. The selected-duck bubble shows the duck name, and accepted names persist in Save Data V0.
- Duck Profile V0 is implemented as an intentional lightweight identity/status panel opened from the selected-duck bubble's `Profile` button. It shows name, level/XP, mood, current need, care availability, derived production stats, current Treat count, a `Give Treat` action, and Rename V0 controls.
- New ducks receive a random generated name when bought. Names can be edited from Duck Profile V0.
- V0 name uniqueness scope is within the player's owned duck list and is checked case-insensitively. Global or cross-player name uniqueness is not approved because it needs a separate central reservation design.
- Player-entered duck names are validated and filtered on the server with Roblox text filtering before they are displayed or stored.
- Weather/Event V0 is implemented as session-only sunny/rainy weather. Rainy weather adds a soft visual overlay and makes sleepy duck care requests more likely, but does not change egg production, coin value, prices, save data, or economy balance yet.
- Quest V0 is implemented as repeatable server-owned goals for collecting eggs, selling eggs, and helping ducks. Quest completion grants coins, can now also grant milestone Duck Feed or Treat bonuses on specific quest levels, advances that quest to the next level, carries overflow progress, and persists quest level/progress in the current DataStore schema.
- Minigames V0 is implemented as a same-place UI-scene shell with a farm `Minigames` button, a minigame menu, one playable `Egg Catch` scene, and a results screen. Egg Catch now starts a server-tracked round and can grant coins, Duck Feed, or Treat through a server-backed reward claim.
- A long-term content roadmap through endgame was approved on 2026-06-11 and lives in `docs/ROADMAP.md` (Phases 4 through 12, a Phase 7B Pond Games battle insert, plus planned monetization waves). The phases are approved as direction with starter numbers; each phase still needs its own design pass, doc updates, and play-testing before implementation. The roadmap's retention pillars include a hard `cozy promise` rule: no mechanic may punish absence or neglect, ducks never die or lose progress, and missed time pauses progress instead of destroying it.
- Three comprehension guardrails were approved on 2026-06-12 and bind every phase like the cozy promise (full spec in `docs/ROADMAP.md`): a per-player Feature Unlock Ladder so fresh profiles meet systems one at a time regardless of how much content the live game has (V0 ships in Phase 4, nothing ever re-locks); a no-system-ships-untaught rule making each phase's guide step or first-use tooltip part of its exit criteria; and a UI surface budget capping the farm screen at `3` primary actions and `6` always-visible secondary controls, with hub consolidation instead of new buttons and special currencies capped at the four already planned.
- A full product plan was approved on 2026-06-11 and lives in `docs/PRODUCT_PLAN.md`, covering positioning, the audience, three cosmetic-only monetization waves with Robux starter prices, analytics targets and instrumentation, the marketing and launch sequence, community policy, localization, trust/safety/compliance, operations, risks, and decision gates. Monetization stays cosmetic-first with hard rules (no paid random eggs, no premium currency, no pay-to-win, no trading of paid items), and each wave still needs a one-line user confirmation before it ships.

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
- Treat cost: `15` coins
- Treat effect: `+40` XP to one selected duck from Duck Profile V0
- Duck Care mood default: `Content`
- Duck Care cared mood: `Happy`
- Duck Care duration: `15` seconds
- Duck Care cooldown: `5` seconds per individual duck
- Duck Care effect: visual/status feedback only for the cared duck, no production or coin bonus
- Duck Care request texts: `Pet me?`, `Hungry?`, `Sleepy?`, and `Dirty?`
- First Duck Care request delay: `8` seconds
- Later Duck Care request interval: `20` seconds after the previous request or care action
- Duck Care request visible cap: the server picks from up to `10` visible ducks
- Duck starting level: `1`
- Duck starting XP: `0`
- Duck XP per Care: `25`
- Duck XP per Feed: `35`
- Duck XP per Premium Feed: `55`
- Duck XP per Rest: `25`, matching pet care
- Duck XP per level: `100`
- Duck max level: `5`
- Duck egg production bonus per level above `1`: `+10%`
- Duck level effect: each duck adds `+10%` egg output per level above `1`, up to `+40%` at level `5`
- Duck rename minimum length: `2` characters
- Duck rename maximum length: `16` characters
- Duck rename uniqueness: case-insensitive within the player's current duck list
- Duck rename filtering: server-side Roblox `TextService` filtering; failed or heavily filtered names are rejected
- Save data: Save Data V0 persists held eggs, ready nest eggs, coins, Duck Feed, Premium Feed, and Treat inventory, Egg Value upgrade level, duck names/profiles, duck level/XP, stable duck IDs, and Quest V0 level/progress
- Offline progress rate: `50%` of online production while away
- Offline progress cap: `2` hours of accrual
- Daily streak rewards: `20/30/40/50/60/80` coins for days `1-6`, then `100` coins plus `Treat x1` on day `7`, repeating
- Daily streak pause rule: missing `1-3` days holds the streak position; missing more than `3` days restarts it at day `1`
- Daily quests: `3` per UTC day from an `8`-goal pool, same selection for every player each day, `12-18` coins each with small feed/treat bonuses on some, and a `+30` coin all-complete bonus
- Weather default: `Sunny`
- Weather cycle interval: `90` seconds
- Rainy weather chance when weather rolls: `35%`
- Rainy weather effect: `+25` percentage points to sleepy request chance, no production or economy change
- Quest V0 collect quest: `Collect eggs`, starts at target `10`, reward `5` coins, scales by quest level, and grants `Duck Feed x1` every `3` completed levels
- Quest V0 sell quest: `Sell eggs`, starts at target `10`, reward `5` coins, scales by quest level, and grants `Duck Feed x1` every `2` completed levels
- Quest V0 help quest: `Help ducks`, starts at target `3`, reward `10` coins, scales by quest level, and grants `Treat x1` every `3` completed levels
- Quest V0 persistence: quest level and progress persist in the current DataStore schema version `4`

## Current Prototype Behavior

The current implementation is intentionally small:

- The server creates runtime remotes for UI action requests and state updates.
- The server tracks each player's eggs, coins, available eggs, egg sell value, Egg Value upgrade level, Duck Feed, Premium Feed, and Treat inventory, per-duck generated or renamed names, per-duck level/XP, current session weather, rename validation errors, and internal save status.
- The server tracks current session weather as `Sunny` or `Rainy`, schedules weather rolls about every `90` seconds, and sends the current weather label, detail text, and next-change countdown to the client.
- One level `1` duck produces one available egg every `5` seconds.
- While a player is away, ducks keep producing at `50%` of the online rate for up to `2` hours, computed on the server from the saved last-seen timestamp. Rejoining adds the offline eggs to the nest and shows a one-time welcome-back toast with the egg count and away-minutes.
- The first join of each UTC day auto-claims the daily check-in, which now advances a persistent 7-day streak with escalating coin rewards and a day-7 Treat bonus. The claim toast shows the streak day, missing `1-3` days holds the streak position instead of resetting it, and the streak position replicates to the client for the future streak track panel.
- Three `Daily:` goals appear at the top of the expanded quest panel each UTC day, drawn from an eight-goal pool with the same selection for every player. Progress comes from normal play (collecting, selling, helping, shopping, treats, Egg Catch, level-ups), completion auto-grants coins and small item rewards with a toast, and finishing all three grants a bonus-coin toast. Slots reset themselves on the next UTC day.
- `Collect` moves available eggs into the player's egg count.
- `Sell` converts held eggs into coins using the server-owned egg value.
- Quest V0 displays a compact farm-screen quest tracker that can be tapped or clicked to expand into the full collect, sell, and help quest list while still keeping all quest progress server-owned. Expanded rows show coin rewards and the current level's milestone Duck Feed or Treat reward when one will be granted.
- Quest V0 advances `Collect eggs` by the number of ready eggs collected, `Sell eggs` by the number of held eggs sold, and `Help ducks` by each successful care, feed, rest, or clean action.
- When a quest reaches its target, the server grants that quest coin reward, subtracts the completed target from progress, increments that quest level, carries any overflow progress into the next level, and the client shows a compact quest reward feedback summary.
- Quest V0 targets and coin rewards scale linearly with quest level from the configured base target and base reward.
- `Egg Value` costs `10` coins, can be bought once, and raises egg value from `1` to `2` coins per egg.
- `Buy Duck` starts at `25` coins, scales as `25 * current duck count`, and adds `1` real duck record with a generated unique name.
- Each level `1` duck produces `1` available egg every `5` seconds, so more ducks increase egg production.
- Each duck level above `1` adds `+10%` egg output for that duck, up to `+40%` at level `5`. The server carries fractional level bonus output between egg cycles so higher-level ducks pay off cleanly over time instead of only on rounded whole-egg breakpoints.
- `Care` validates the selected duck index on the server, temporarily changes only that duck from `Content` to `Happy`, grants that duck `25` XP, shows XP feedback, clears that duck request when relevant, and starts that duck cooldown. If the request is `Hungry?`, resolving it consumes `1` Premium Feed first when stocked for `55` XP, otherwise `1` Duck Feed for `35` XP, and the feedback reflects the feed path. If the request is `Sleepy?`, resolving it uses `Rest`, grants `25` XP, and does not consume an item. If the request is `Dirty?`, resolving it uses `Clean`, grants `25` XP, and does not consume an item.
- `Give Treat` validates the selected duck index on the server, consumes `1` Treat, grants `40` XP to that duck, and does not clear care requests or bypass care cooldown rules.
- Duck Names V0 assigns each new duck a server-generated random name from the large curated `PrototypeConfig.duckNames` pool. Names are unique within the player's current duck list; if the curated pool is exhausted, the server falls back to numbered `Duck N` names.
- Duck Level/Progress V0 is capped at level `5`. Level progress appears in the selected-duck care bubble and Duck Profile V0 panel, level-up feedback still appears, and higher-level ducks now contribute a modest egg-production bonus. Level and XP persist in Save Data V0.
- Duck Profile V0 opens only when the player clicks `Profile` in the selected-duck bubble. On wider screens it opens beside the selected duck and flips left or right to stay on-screen. On compact screens it falls back to an anchored panel so it does not crowd the farm controls. It is client presentation of server-owned duck state and currently shows name, level/XP, mood, need, care readiness/cooldown, kid-friendly `Egg Boost` and `Level Up` derived stats, Treat count, a `Give Treat` button for targeted XP, Rename V0 controls, and rename errors only when needed.
- Rename V0 lets the player edit one duck name from its profile with `Rename`, `Save`, and `Cancel`. The server trims the requested name, requires `2` to `16` characters, rejects duplicates within that player's current duck list, filters the submitted text with Roblox `TextService`, rejects failed or heavily filtered names, and only replicates the filtered display name. Rename errors are shown in the profile footer.
- The server occasionally assigns one visible duck to ask for care with `Pet me?`, `Hungry?`, `Sleepy?`, or `Dirty?`. The first request appears after about `8` seconds, then later requests are scheduled about `20` seconds after the previous request or care action.
- Tapping or left-clicking a visible duck adds a saturated duck-yellow highlight and opens a quick local care bubble with a `Profile` button. Duck selection uses scene-level nearest-duck hit testing instead of separate rectangular duck buttons so compact flocks stay more predictable. The bubble title shows the duck's generated name. If that duck is the server-selected request duck, the status line includes `Pet me?`, `Hungry?`, `Sleepy?`, or `Dirty?`; otherwise it shows the duck level. Clicking `Profile` opens Duck Profile V0. Tapping or clicking empty scene space closes the selection UI and profile panel. When multiple ducks overlap, the requested duck is emphasized and drawn above the flock so it stays easier to identify and tap.
- When a care request is active, other ducks can still be selected for name/level viewing, but their care button is disabled until the active request is handled. Petting one duck does not put every duck on cooldown.
- Duck mood does not change egg production, coins, prices, or upgrade behavior. Duck level now increases only that duck's egg production; it does not directly change coin value, prices, quest rewards, or upgrade behavior.
- The React farm screen displays the latest server-sent state.
- The duck has client-side autonomous idle bobbing, short visual wandering, and direction-aware facing while it wanders.
- The farm screen shows a small egg-ready badge, a capped visual egg pile with a total-count badge on the nest, an egg status/progress card, and floating feedback for collected eggs, earned coins, gained items, care XP, quest completion rewards, and the Egg Value upgrade.
- The farm HUD keeps resources and the primary `Collect`, `Sell`, and `Shop` actions visible, while secondary progression actions such as Egg Value and Buy Duck live behind an `Upgrades` button. Quest progress is shown as a compact tracker instead of a full always-open panel, and Minigames is a smaller secondary button so the farm scene has more space.
- Farm Visit V0 adds a compact `Visit` control to the farm screen. It lists other same-server players with loaded farm state as simple selectable farm cards in a bottom drawer/tray above the action bar, explains when no same-server farms are available, lets the viewer switch to that player's farm view, shows a read-only `Viewing Farm` status, and uses a `Home` action to return to the viewer's own farm.
- While visiting another farm, the client keeps the farm scene readable and allows local duck selection/profile viewing, but disables collect, sell, shop, upgrades, minigames, tester actions, care, treats, and rename controls. The server also ignores non-navigation gameplay actions while a player is in a farm visit view.
- Farm Visit V1 adds a session-only owner `Visitor Help` toggle. When enabled, a visitor can clear an active `Pet me?`, `Sleepy?`, or `Dirty?` request on the viewed farm through a server-validated visitor action. Visitor help does not grant owner XP, quest progress, coins, items, inventory changes, save data, production boosts, rename changes, collect/sell/shop/upgrades/minigames access, or `Hungry?` feed consumption.
- The farm screen has a `Shop` button that fades to a placeholder shop scene. The shop can buy server-owned `Duck Feed` for `5` coins, `Premium Feed` for `12` coins, and `Treat` for `15` coins, and returns to the farm/lawn with a back button and fade transition. The shop cards now surface each item's purpose, cost, and owned count more clearly for mobile and first-session readability. Hungry ducks consume Premium Feed first when stocked, otherwise Duck Feed, while Treat is consumed from Duck Profile V0 to grant `40` XP to the selected duck.
- The first farm-screen UI adapts key controls for compact viewport sizes using Roblox display-size information plus viewport orientation checks. Short landscape layouts collapse Studio-only tester controls, hide duplicate ready messaging, and use smaller phone-landscape controls, but Studio device testing is still required.
- Rainy weather shows a soft blue rain overlay and weather badge on the farm screen. The Studio-only tester can toggle `Rain` or `Sun` so weather behavior can be tested without waiting.
- The farm screen does not show a save status indicator; save behavior is verified through Studio Output logs and rejoin checks.

## Shop, Duck Needs, Duck Level, and Duck Names Direction

Shop V0, Hungry Request V0, Sleepy/Rest V1, Dirty/Clean, Treat V0, Duck Level/Progress V0, Duck Names V0, Duck Profile V0, Rename V0, Quest V0, and Save Data V0 are implemented as a placeholder shop screen, server-owned Duck Feed, Premium Feed, and Treat inventory, a feed interaction for hungry ducks, feedback-only rest and clean interactions for sleepy or dirty ducks, a targeted Treat action for duck XP, per-duck level progress with a small egg-production reward, generated saved duck names, lightweight profiles, server-filtered player rename editing, repeatable collect/sell/help quests, and server-owned persistence for the approved save scope. Larger level-reward expansions remain planned work after the loop is tested.

Implemented Shop V0 direction:

- The farm screen has a `Shop` GUI button.
- Opening the shop uses a short fade-to-black transition, swaps to a placeholder shop background, then fades in.
- The shop has a back button that returns to the farm/lawn with the same fade transition.
- `Duck Feed`, `Premium Feed`, and `Treat` are server-owned inventory items, not just client UI state.

Implemented duck-need direction:

- Hungry duck requests can use basic `Duck Feed` or, if stocked, `Premium Feed` from the shop. Premium Feed is consumed first and grants higher XP than basic feed.
- Treats can be bought from the shop and consumed from Duck Profile V0 to grant `40` XP to the selected duck.
- Feeding a hungry duck clears the request, gives feedback-only happy mood, and consumes `Premium Feed` first for `55` XP or basic `Duck Feed` for `35` XP.
- Resting a sleepy duck clears the request, gives feedback-only happy mood, grants `25` XP, and consumes no item.

Implemented Duck Level/Progress V0 direction:

- Each real duck has a server-owned level and XP value.
- Care grants XP to the targeted duck.
- Feeding a hungry duck grants slightly more XP than pet care. Resting a sleepy duck and cleaning a dirty duck grant the same XP as pet care. Treat grants `40` XP without clearing care requests or bypassing cooldown rules.
- Selected-duck bubbles show a level bar.
- Level-ups still give visual feedback, and each duck level above `1` now adds `+10%` egg output for that duck up to the current level cap.

Implemented Duck Names/Profile/Rename V0 direction:

- New ducks receive server-generated names from the curated name pool.
- Names are unique within the player's current duck list.
- Profiles show identity/status details only; deeper animal-history fields wait until those systems exist.
- Rename V0 uses server-side length validation, per-player duplicate checks, Roblox text filtering, and filtered display-name replication.
- Duck names, profile identity, level, and XP persist in Save Data V0.

Planned next direction:

- Duck variation lines, rarity tiers, egg types and hatching, evolution, mutation, and breeding now have approved direction and starter numbers in `docs/ROADMAP.md` (Phases 5 through 9). Generated name list approval and final per-family art approval are still pending.

Current and future shop items:

- `Duck Feed`: basic food for hungry duck requests.
- `Treat`: targeted duck-XP item implemented in Shop V0 and Duck Profile V0.
- `Premium Feed`: implemented hungry-care item that is consumed before basic feed when stocked and grants `55` XP to the fed duck.
- `Fertilizer`: future farm/nest improvement item, likely not needed until farm upgrades or crops exist.
- `Nest Straw`: comfort or nest upgrade item, exact effect undecided.
- `Toy`: mood or care item, exact effect undecided.

Implementation constraints:

- Keep Shop V0 to the current small three-item inventory until the placeholder shop flow is play-tested.
- Do not add monetization or premium currency unless explicitly approved.
- Do not expand save-data scope beyond `docs/SAVE_DATA_DESIGN.md` without approval.
- Use temporary UI placeholders if final shop art is not ready.

## Locked Duck Visual Rule Set

This visual separation is approved for future duck-content planning:

- Shop-bought duck variations are base duck families. They should define the main body shape, silhouette, and core color palette, and should be the biggest visual difference between ducks.
- Evolution is a future level-based growth layer on top of a duck's current base variation. Evolution should keep the duck in the same family line instead of turning it into a different shop variation.
- Mutation is a separate special-trait overlay that can sit on top of a base variation or future evolution stage. Mutations should add distinctive markings, accents, or small silhouette details without replacing the duck's family identity.
- On the farm, base variation should read first, evolution second, and mutation third. Every layer must stay recognizable at farm sprite size: evolution changes the silhouette, and each mutation includes one small always-visible tell (a glint or bold accent) so visitors can spot a special duck at a glance. Richer mutation detail reads in profile and close-up views, but on-farm legibility is a requirement, not a nice-to-have, because showing off rare ducks is part of the retention loop.
- This rule set locks the visual separation. Trigger rules, stat changes, rarity, and acquisition now have approved direction and starter numbers in `docs/ROADMAP.md`: families and rarity bonuses in Phase 5, hatching acquisition in Phase 6, deterministic player-triggered evolution at levels `5` and `10` with a skippable celebration in Phase 7, and mutation overlays with breeding in Phase 9. Final art per family, stage, and mutation still needs approval.

## Quest V0 Direction

Quest V0 is implemented as a small repeatable goal layer on top of the existing loop.

Implemented Quest V0 direction:

- The farm screen shows a compact quest tracker for the current quest summary, and tapping or clicking it expands the full `Collect eggs`, `Sell eggs`, and `Help ducks` list with visible coin rewards and any current milestone Duck Feed or Treat reward.
- Quests are server-owned. The client displays quest summaries but cannot submit quest progress, levels, targets, or rewards.
- Completing a quest grants coins, can add milestone Duck Feed or Treat bonuses depending on the quest, advances only that quest level, and carries overflow progress into the next level.
- Quest levels and progress persist in the current DataStore schema version `4`.
- Quest V0 does not add daily quests, quest rerolls, premium rewards, badges, streaks, NPC dialogue, or special quest art.

Future quest categories, daily-task variants, larger reward tables, and additional UI polish still need separate approval before implementation.

## Weather/Event V0 Direction

Weather/Event V0 is implemented as a small session-only life-sim layer.

Implemented Weather/Event V0 direction:

- Weather can be `Sunny` or `Rainy`.
- Each player starts in `Sunny` weather when their session state is created or loaded.
- Weather rolls about every `90` seconds; each roll has a `35%` chance to become rainy.
- Rainy weather adds a soft farm-screen tint and light rain streaks using Roblox UI only.
- Rainy weather makes `Sleepy?` duck requests more likely by adding `+25` percentage points to the sleepy request chance.
- The Studio-only tester includes a `Rain` or `Sun` toggle for fast weather testing, with the label showing the opposite weather action from the current state.
- Weather does not persist in Save Data V0 and does not change egg production, coin rewards, prices, inventory, duck XP, or upgrade balance yet.

Future weather effects need separate approval before implementation.

## Guide/Tutorial V0 Direction

Guide/Tutorial V0 is implemented as a session-only onboarding flow for fresh profiles.

Implemented Guide/Tutorial V0 direction:

- The guide opens automatically on the farm for fresh profiles and can also be reopened in Studio with the local `Guide` tester button.
- The guide currently walks through `Collect`, `Sell`, `Buy Duck`, `Shop`, and duck care.
- The guide no longer has manual `Back`, `Next`, `Skip`, or `Done` controls.
- Each successful required action advances the guide automatically.
- While the guide is active on the farm, only the current highlighted action stays usable and unrelated farm or tester actions are blocked. The Buy Duck step narrowly allows `Collect` and `Sell` while Buy Duck is still unaffordable so a fresh player can earn enough coins without getting stuck.
- The duck-care step highlights the actual requested duck and only allows that duck's care action.
- Opening `Shop` keeps the guide on the shop step, highlights `Back` inside the shop, and advances only after the player returns to the farm.
- The guide now ends after the first successful duck-help action.

Future guide-character art, dialogue, and broader onboarding expansion need separate approval before implementation.

## Minigames V0 Direction

Minigames V0 is implemented as a small same-place UI-scene shell.

Implemented Minigames V0 direction:

- The farm screen has a `Minigames` button that opens a separate minigames menu scene without teleporting to another Roblox place.
- Minigames V0 now keeps the active round client-side for movement and catches, but the client starts a server-tracked Egg Catch round and sends the finished score to claim a validated reward.
- The first implemented minigame is `Egg Catch`.
- Egg Catch runs for `20` seconds, uses a full-screen active play scene, shows caught, missed, and best-streak feedback during the round, and ends on a results screen.
- Egg Catch can be played with mouse movement or keyboard `A`/`D` or arrow keys on desktop, and with touch drag or `Left` and `Right` buttons on mobile or touch devices.
- Egg Catch rewards are server-owned and currently use the round score to grant coins, and at higher score thresholds can also grant Duck Feed or Treat. The server rejects scores that are impossible for the elapsed round timing before granting a reward, but Egg Catch V0 is still a client-played minigame and is not a fully server-simulated anti-cheat system. Egg Catch still does not grant duck XP or quest progress.
- Leaving Egg Catch and returning to the farm now changes farm state only when a reward claim succeeds.

Future minigame reward expansions, event-gated availability, additional minigames, and final art direction need separate approval before implementation.

## Multiplayer and Farm Visiting Direction

The approved direction is personal farms inside multiplayer-capable Roblox servers, not one Roblox server per player.

Each player owns their own farm state. When a player joins, the server loads that player's farm and the UI shows that farm by default. Farm visiting switches the visitor's UI/view to another player's farm while keeping authority and permissions on the server.

Farm visiting should grow in phases:

1. Farm Visit V0: implemented as read-only viewing of another loaded player who is currently in the same server.
2. Farm Visit V1: implemented as same-server, online-only, owner opt-in visitor help for non-inventory duck requests with no owner progression, economy, quest, inventory, or save-data impact.
3. Offline or friend farm visits: allow viewing a saved farm snapshot when the owner is offline, only after a separate DataStore snapshot, privacy, and permission design is approved.

Implemented Farm Visit V0 direction:

- The farm screen has a compact `Visit` control near the secondary farm buttons.
- Opening `Visit` shows same-server players whose farm state exists, with a small loaded/loading state, duck count, and selectable card-style rows in a bottom drawer/tray above the action bar. Compact/mobile layouts use a full-width drawer, while desktop uses a centered tray.
- Choosing a loaded same-server player asks the server to switch the viewer to that player's farm state.
- The server validates the requested `UserId`, keeps the viewer's own persistent state separate, and clears the visit target if the owner leaves or is not loaded.
- While visiting, non-navigation gameplay actions are blocked server-side and owner-affecting UI actions are disabled client-side.
- `Home` returns the viewer to their own farm state, and the visited-farm banner reminds players that the view is read-only.

Implemented Farm Visit V1 direction:

- Owners can toggle `Visitor Help` for the current session from the farm visit UI. It defaults off and is not saved.
- Farm cards and the visited-farm banner show whether help is allowed.
- Visitors can use a selected duck bubble `Help` action only for the owner's active `Pet me?`, `Sleepy?`, or `Dirty?` request.
- Visitors cannot help `Hungry?` requests because those consume owner feed inventory.
- Visitor help clears the active request and shows temporary cared mood feedback, but it does not grant owner XP, quest progress, coins, items, inventory changes, save data, production boosts, rename changes, collect/sell/shop/upgrades/minigames access, or rewards.
- The server validates that the requester is visiting the target owner, the owner is connected and loaded, visitor help is enabled, the duck index is valid, the duck is the active requested duck, and the request kind is visitor-help eligible.

The future friends/farm visit UI should use simple friend farm boxes or cards so players can quickly choose a friend to visit. The final card layout, profile information, online/offline state, persistent privacy rules, and offline snapshot behavior are not designed yet.

Official Roblox references checked for Farm Visit V0:

- [Players service](https://create.roblox.com/docs/reference/engine/classes/Players)
- [RemoteEvent](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent)

## Approved Long-Term Systems (Roadmap Phases)

These systems are approved as direction with starter numbers in `docs/ROADMAP.md`. Each phase still needs its own design pass and play-testing before implementation:

- Phase 4: Offline Progress V0 (`50%` rate, `2` hour cap), Daily Streak V1 (7-day track with pause-not-reset rule), Daily Quests V0, Badges V0, Settings V0, Audio V0, Comeback Gift V0 for players away `7+` days, Feature Unlock Ladder V0 for fresh profiles, first approved art pass.
- Phase 5: Duck base families (`Classic Yellow`, `Mallard Green`, `Choco Brown`, `Snowy White`, `Blossom Pink`, `Twilight Blue`, with `Golden` reserved for hatching), rarity tiers with small egg-output bonuses (`+0/5/10/20/35%`), Duckdex collection book with collection rewards. Family art must stay distinct at gameplay sprite size, and the first non-`Classic Yellow` family must be affordable within a fresh player's first one or two sessions so the collection hook sets immediately. A one-time Starter Choice Duck (pick `1` of `3` starter cards) lands when the guide completes, and the reward-only Mystery Duck Box (see `3` rarity-weighted ducks, keep `1`, odds visible, never sold) anchors milestone moments such as the first 7-day streak and the Duckdex `50%` reward.
- Phase 6: Egg types (`Plain`, `Speckled`, `Golden`, `Festival`), Incubator V0 with hatch timers, visible odds, and pity counters. Eggs are never sold for Robux.
- Phase 7: Duck level cap `10`, deterministic player-triggered evolution stages (`Radiant` at level `5`, `Royal` at level `10`) costing earnable `Star Grain`, `+25%` egg output per stage, skippable celebration, and daily duck XP pacing (`150` XP per duck per UTC day from all sources, with no-waste guards) so coin-bought treats cannot pump a duck to overpowered same-day.
- Phase 7B: Pond Games (Duck Battles V0), an optional friendly contest mode: `3v3` turn-based PvE with per-turn skill picks, four classes assigned by family (`Guard`, `Splasher`, `Quacker`, `Helper`), `16` total skills unlocked by existing duck levels and stages, a four-stat block (`Heart`, `Splash`, `Pace`, `Spirit`) derived from class/level/rarity/stage that affects battles only, battle XP (`+15` win / `+5` loss) inside the daily XP cap, a Training Camp that sends one duck into visible stasis (`4h/8h/24h`, permanent capped stat gains, full-refund cancel, no egg production while away), tired-not-hurt presentation, losing never costs anything, battle power never sold, and no live real-time PvP.
- Phase 8: Farm Level, zones (`Pond`, `Meadow`, `Orchard`) with rising duck capacity, Decorations V0 with anchor-slot placement, and Photo Mode V0 (HUD-free framing with earnable frames and text-free stickers, posing ducks, platform capture flow, corner game stamp).
- Phase 9: Mutation overlays (`Sparkle`, `Marble`, `Snowdust`, `Honey`, `Tuxedo`, `Star`, flat `+10%` output), each carrying a small always-visible farm-scale tell so special ducks read at a glance, plus Breeding V0 with `24` hour timers, inheritance odds, and pity. Breeding never consumes or downgrades a duck.
- Phase 10: Gifting V0, Farm Likes, leaderboards, visitor book, profile titles, and offline farm snapshots (snapshots still need their own privacy/permission design doc first).
- Phase 11: Seasonal event framework (`Spring Bloom`, `Summer Splash`, `Autumn Harvest`, `Winter Frost`) with Festival Tickets, event shops, limited Festival duck families that return yearly, weekend mini-events, and Minigames V1 (`Bread Toss`, `Lily Hop`).
- Phase 12: Duck Legacy prestige (resets economy and farm level, keeps Duckdex/cosmetics/badges and one chosen Legacy Duck), Legacy Feathers permanent-boost shop, Golden Pond visuals, Legacy duck family, family Mastery ranks, prestige quests.

## Future Ideas Still Not Approved

These ideas remain outside the approved roadmap and need explicit approval before any planning:

- Player-to-player trading of ducks or items.
- Mood-based production bonuses or feeding boosts.
- Weather effects on production or economy (seasonal visual touches are approved in Phase 11; production effects are not).
- Expanded duck care request types beyond the current pet/hungry/sleepy/dirty/thirsty/bored set.
- Life events and surprise moments (small visitor ducks, found items) beyond the Phase 11 weekend mini-events.
- A reusable guide character beyond Guide/Tutorial V0, including its art and dialogue direction.
- Deeper profile fields such as age, traits, family tree, breeding history, favorite food, or long-term statistics.
- Quest rerolls or paid quest boosts.

## Undecided Game Decisions

The following decisions still need user input before implementation:

- Final per-wave monetization sign-off. The product waves, items, and Robux starter prices are planned in `docs/PRODUCT_PLAN.md`, but each wave still needs a one-line user confirmation of its final product list and prices before it ships.
- The full-launch display title decision (keep `Duck` or use a more searchable title such as `Duck: Cozy Pond Farm`).
- Final asset approvals within the approved Cozy Pond Farm direction: per-family duck art, evolution stages, mutation overlays, screen layouts, decoration sets, event art, and the generated duck name pool.
- Final audio track selection within the approved cozy acoustic/ambient direction.
- Offline farm snapshot privacy rules, permission model, and DataStore snapshot design (required before the Phase 10 snapshot feature).
- The real-world event calendar dates for Phase 11 seasonal events.
- Exact round design, length, and reward balance for `Bread Toss` and `Lily Hop`.
- Economy rebalances when play data disagrees with the roadmap's starter numbers (all roadmap numbers are starter defaults, not final balance).

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






