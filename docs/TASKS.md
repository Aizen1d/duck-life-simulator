# Tasks

Use this file for known work that is not finished yet. Keep tasks concrete and avoid adding speculative mechanics.

## Backlog

Roadmap Phase 4 (Retention Foundations and First Art Pass, per `docs/ROADMAP.md`):

- [ ] Play-test Offline Progress V0 in Roblox Studio with API services enabled: rejoin after a few minutes away and confirm ready eggs grew at the `50%` rate, the welcome-back toast shows eggs and away-minutes exactly once, no grant appears on a fresh profile or on the first rejoin after the schema `7` update, the grant respects the `2` hour cap, higher-level ducks accrue more, and `lastSeenUtc` persistence is visible through Studio Output logs on stop/rejoin.
- [ ] Play-test Daily Streak V1 in Roblox Studio with API services enabled: first claim starts at day `1` with `+20` coins, the toast shows `Day N streak!` with the escalating reward, day `7` grants `100` coins plus `Treat x1` then wraps to day `1`, a `1-3` day gap keeps the streak position, a longer gap restarts at day `1`, pre-v8 saves start at day `1`, and `streakDay` persists across stop/rejoin.
- [ ] Build the visible 7-day streak track panel UI per the approved `Daily Streak Calendar UI Mockup` prompt direction; the current implementation shows streak progress through the claim toast and the server-owned `streakDay` state field only.
- [ ] Play-test the Welcome Back card in Roblox Studio: rejoin with offline eggs and a fresh streak day and confirm one centered card lists both rewards with a working `Collect!` dismiss, no duplicate floating toasts appear at join, the card does not appear during fresh-profile onboarding or while visiting another farm, and a mid-session daily claim still uses a floating toast.
- [ ] Play-test Comeback Gift V0 in Roblox Studio by temporarily lowering `comebackGift.awayDaysThreshold` (or editing a saved `lastSeenUtc`), confirming the `Duck Feed x2` and `Treat x1` grant appears once with the `Your ducks missed you!` toast, inventory persists after autosave, no gift appears for short absences or fresh profiles, and the threshold restores to `7` days after testing.
- [ ] Play-test Daily Quests V0 in Roblox Studio: three `Daily:` rows appear at the top of the expanded quest panel, progress advances from collect/sell/help/shop/treat/Egg Catch/level-up actions, completion grants the coin and item rewards once with a toast, completing all three grants the `+30` coin bonus toast once, progress persists across stop/rejoin within the same UTC day, a new UTC day rolls fresh quests, and the selection matches for two different players on the same day.
- [ ] Implement Badges V0: first duck bought, first rename, `100` eggs collected, first level `5` duck, 7-day streak.
- [ ] Implement Settings V0 screen with music, sound, and reduced-motion toggles.
- [ ] Play-test Feature Unlock Ladder V0 in Roblox Studio with a fresh profile: only Collect/Sell and counters show at start, the quest tracker and `Upgrades` appear after the first sell, `Shop` appears once the second duck is bought (matching the guide order), `Games` and `Visit` appear after the first duck-help action, nothing disappears again afterwards, locked actions fired directly at the server are rejected, and an existing pre-ladder save still shows every feature immediately.
- [ ] Add first-use guide steps or tooltips for the Phase 4 systems (streak panel, daily quests, offline welcome-back summary) per the no-system-ships-untaught rule, and review the farm-screen control count against the `3` primary / `6` secondary UI surface budget.
- [ ] Implement Audio V0 (one cozy ambient loop plus core sound effects) after the user approves exact tracks within the approved cozy acoustic/ambient direction.
- [ ] Security-review the Offline Progress V0 and Daily Streak V1 claim paths against forged timestamps, clock skew, duplicate claims, and rejoin spam before they ship.
- [ ] Generate and review the Phase 4 prompt batch: `Badge and Achievement Icon Sheet` and `Daily Streak Calendar UI Mockup`.
- [ ] Generate and review the `Duck Family Lineup Sheet` so all seven family palettes can be approved in one image before Phase 5 work starts.
- [ ] Run the Phase 5 design pass before implementation: Duckdex data model, family-aware Buy Duck pricing, rarity bonus wiring, migration of existing saved ducks as `Classic Yellow`, the Starter Choice Duck flow (including existing-profile first-load behavior), and the Mystery Duck Box odds display and pick UI.
- [ ] Run the Phase 7B Pond Games design pass before implementation: server battle resolver rules, `Heart`/`Splash`/`Pace`/`Spirit` class stat curves derived from level/rarity/stage, the `16`-skill V0 set with effects and unlock levels, Pond Tour difficulty and reward sizing that keeps battles optional, Training Camp stasis rules (no eggs, care, treats, battles, or breeding while away; offline accrual exclusion; full-refund cancel), battle XP inside the Phase 7 daily cap, and a play-test confirming losing feels fine for a young player.
- [ ] Tune the Phase 7 daily duck XP cap (`150`/day starter) against real care-request pacing during the Phase 7 design pass, and verify the capped-duck message and blocked Treat use read as cozy, not punishing.

Product plan (per `docs/PRODUCT_PLAN.md`):

- [ ] Add `AnalyticsService` custom funnel and economy events during Phase 4 work, and record the event naming convention (`funnel_*`, `econ_source_*`, `econ_sink_*`, `social_*`) in `docs/CODING_STANDARDS.md`.
- [ ] Enable Roblox automatic text translation before soft launch and confirm player-facing strings live in code, not images.
- [ ] Complete the experience content maturity questionnaire before soft launch, targeting an all-ages rating.
- [ ] Dry-run both recovery paths before full launch: restoring a player save from DataStore version history, and rolling back to a previous published place version.
- [ ] Generate and review the marketing assets before full launch: `Game Icon` plus the five `Store Thumbnail - Template` scenes from `docs/DESIGN_PROMPTS.md`.
- [ ] Write the store description per the Product Plan store-presence rules and decide the full-launch display title (`Duck` versus a more searchable title).
- [ ] Create the official Roblox group with a one-time `Treat x1` join gift before full launch.
- [ ] Implement Monetization Wave 1 with Phase 6, after the one-line wave sign-off: cosmetic accessory layer (per-duck server-owned slot), `Supporter Pass` gamepass checks, `Cozy Basics` and `Starlight Garden` developer products with idempotent `ProcessReceipt` grants, owned flags in save data, a kill-switch config flag, Studio and live test purchases, and a Security Agent review of the purchase and grant paths.
- [ ] Play-test the Farm Visit drawer/tray in Roblox Studio, including opening `Visit` on desktop, mobile, and short landscape, tapping same-server farm cards and `View`/`Help` badges, toggling owner `Visitor Help`, and confirming the drawer stays above the action bar.
- [ ] Design a friends/farm visit UI using simple friend farm boxes or cards for choosing farms to visit.
- [ ] Define offline farm snapshot rules before allowing friend farm visits when the owner is offline.
- [ ] Create or approve a compact UI style reference for buttons, counters, panels, profile cards, shop cards, tester-only controls, and status messages.
- [ ] Generate and approve need/mood icon assets for pet/care, hungry/feed, sleepy/rest, and future clean or weather needs.
- [ ] Generate and approve duck mood portrait or sprite variants for content, happy, hungry, sleepy, and rested states.
- [ ] Decide which prototype UI elements should stay as functional Roblox UI and which should become image-backed final assets.
- [ ] Play-test Treat V0 in Roblox Studio, including Treat purchase, Treat count, Duck Profile V0 `Give Treat`, targeted XP gain and feedback text, max-level disable, autosave, and compact/mobile layout.
- [ ] Play-test Dirty/Clean duck need in Roblox Studio, including random dirty requests, the Studio-only `Dirty` tester button, `Dirty?` bubble/profile text, `Clean` action, `Clean +25 XP` feedback, `25` XP gain, autosave, and confirming no item consumption or direct production/economy change beyond duck level progress.
- [ ] Play-test Farm HUD V2 in Roblox Studio on desktop and phone landscape, including compact quest tracker readability, quest tracker expand/collapse behavior, secondary Minigames placement, short-landscape horizontal `Upgrades` tray placement, `Upgrades` panel open/close, Egg Value and Buy Duck actions inside `Upgrades`, and onboarding Buy Duck spotlight behavior.
- [ ] Play-test Shop and Hungry V0 in Roblox Studio, including the farm `Shop` button, fade transition, placeholder shop screen, back button, clearer item-purpose/cost/owned readouts, short-landscape shop card readability, fresh-profile starter `Duck Feed x1`, the one-time post-onboarding hungry follow-up on fresh profiles, Duck Feed purchase, Premium Feed purchase, coin subtraction, feed inventory counts, readable `Feed xN`, `Premium xN`, or `Treat xN` gain feedback, `Hungry` tester request, `Need feed` state, feeding with Duck Feed, Premium Feed priority/consumption, stronger Premium Feed XP feedback, and mobile layout.
- [ ] Play-test fresh-profile starter feedback in Roblox Studio, including the one-time Starter Feed x1 toast using the configured starter grant amount, confirming it appears only once per fresh session and does not re-fire on normal state updates.
- [ ] Design or approve the final Shop V0 background asset prompt or image.
- [ ] Review Shop V0 after play-testing and decide whether to keep Duck Feed at `5` coins, Treat at `15` coins, or rebalance them.
- [ ] Define the first shop-bought duck variation lines, whether they are cosmetic-only at first, and the initial art targets for each line.
- [ ] Play-test Duck Level/Progress V0 in Roblox Studio, including Care XP, Feed XP, Rest XP, Treat XP, selected-duck level bar, level-up feedback, max-level behavior, per-duck targeting, compact layout, and the `+10%` egg-output bonus per level above `1`.
- [ ] Define future advanced duck level rewards beyond the current egg-production bonus, mutation or breeding interaction, and whether levels need additional save data.
- [ ] Play-test Duck Names V0 in Roblox Studio, including starting duck name, Buy Duck generated names, per-player duplicate avoidance, selected-duck bubble display, and compact layout readability.
- [ ] Play-test Duck Profile and Rename V0 in Roblox Studio, including `Profile` button opening on desktop and mobile touch, beside-duck wide-screen placement, edge flipping, anchored compact fallback, outside-click close without closing on blank profile-panel or selected-duck bubble taps, compact layout readability, name display, level/XP display, mood, need, care readiness, kid-friendly `Egg Boost` and `Level Up` stats, Treat count, `Give Treat`, Rename/Save/Cancel flow, rename error messaging, and a footer that shows Treat count by default or a rename error when needed.
- [ ] Review and approve the large curated random duck name pool in `PrototypeConfig.duckNames`.
- [ ] Play-test Rename V0 server validation in Roblox Studio, including valid `2` to `16` character names, duplicate names, too-short names, too-long names, text-filter failure handling, and confirming rejected names do not replace the previous name.
- [ ] Play-test Save Data V0 in Roblox Studio with API services enabled, including first join, stop/rejoin reload, held eggs, ready nest eggs, coins, Duck Feed, Premium Feed, and Treat inventory, Egg Value level, duck names/profiles, duck level/XP, autosave, leave save, shutdown save, no visible save status UI, and reload verification through Studio Output logs.

- [ ] Define the initial player experience and success criteria.
- [ ] Define what duck life simulator means beyond farming after the first prototype.
- [ ] Define exact evolution trigger rules, stage counts, and cutscene behavior before implementation.
- [ ] Define future mutation overlay rules, categories, and trait catalog before implementation.
- [ ] Define future breeding direction before implementation.
- [ ] Play-test Minigames V0 in Roblox Studio, including the farm `Minigames` button, menu scene, full-screen Egg Catch start flow, mouse and keyboard desktop controls, touch drag and on-screen mobile controls, round timer, results screen, automatic server reward claim, confirming the Duck UI stays mounted after the round, return-to-farm flow, compact/mobile layout, and confirming only coins, Duck Feed, or Treat change when earned while duck XP, quests, and unrelated save data stay unchanged.
- [ ] Decide whether Egg Catch needs fully server-simulated scoring or server-validated input samples before rewards become more valuable than modest V0 coin/feed/treat payouts.
- [ ] Play-test Guide/Tutorial V0 in Roblox Studio with a fresh profile or cleared save, including automatic open after load, `Collect`/`Sell`/`Buy Duck`/`Shop`/duck care steps, task-driven auto-advance, no manual tutorial navigation buttons, current-step-only interaction gating, shop transition handling, guide completion after the first successful duck-help action, one-session dismissal behavior, and compact/mobile readability.
- [ ] Review Egg Catch reward balance after play-testing, including coin pacing, Duck Feed threshold, Treat threshold, and whether minigame rewards should stay modest compared with the farm loop.
- [ ] Replace the temporary Egg Catch catcher or basket placeholder with an approved real basket icon or image-backed asset.
- [ ] Define the future guide character role for onboarding and reusable helper scenes before implementation.
- [ ] Design expanded duck care request types beyond petting, feeding, resting, and cleaning, such as weather reactions.
- [ ] Research mechanic patterns that could improve the duck life loop.
- [ ] Design the first 2D UI layout for the farm screen.
- [ ] Provide remaining minimum design inputs from `docs/DESIGN_INPUTS.md`.
- [ ] Play-test Buy Duck in Roblox Studio, including scaling cost, coin subtraction, duck count, visible ducks, and faster production.
- [ ] Play-test Duck Mood / Care V1 in Roblox Studio, including real individual duck cooldowns, random care request timing, the `Need` and `Sleepy` tester buttons, multi-duck requested-duck targeting, happy feedback, duck tap/click care bubble, duck-yellow selected-duck highlight, empty-scene deselect, and confirming care has no direct production bonus outside duck level progress.
- [ ] Play-test the Studio-only tester panel and confirm it speeds up coin, ready egg, duck, and reset checks.
- [ ] Play-test the compact farm-screen layout by resizing the Studio viewport or using device emulation, including iPhone 14 landscape around `852x393`, and confirm large egg-ready counts stay readable in the egg status card while the short-landscape `Upgrades` tray stays clear of the action bar.
- [ ] Play-test the autonomous duck motion, nest egg pile, egg-ready badge, and floating feedback in Roblox Studio.
- [ ] Import a matching left-facing duck asset if the temporary thumbnail flip fallback is not clean enough.
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

- [ ] Play-test Egg Value V1 in Roblox Studio, including the egg value upgrade now spanning five tiers with rising costs (`10`, `25`, `60`, `140`, `320`), each tier raising the egg sell value by `1`, the upgrade button correctly showing max state at level `5`, autosave, and stop/rejoin persistence.
- [ ] Play-test Quest V2 in Roblox Studio, including the new `Buy ducks` quest progressing one step per duck purchased, the new `Spend coins` quest progressing by the coin cost of each shop purchase, duck purchase, or Egg Value upgrade, milestone `Pillow x1` rewards for `Buy ducks` every three completed levels, milestone `Duck Feed x1` rewards for `Spend coins` every three completed levels, quest tracker showing both new quests, autosave, and stop/rejoin persistence.
- [ ] Play-test Care V3 Bored need in Roblox Studio, including random `Bored?` requests, the Studio-only `Bored` tester button, `Bored?` bubble/profile text, `Play` action, `Play +25 XP` feedback when no Toy is owned, `Toy +50 XP` feedback when a Toy is consumed, help-quest progress, autosave, and confirming no direct production/economy change beyond duck level progress.
- [ ] Play-test Toy V0 in Roblox Studio, including Toy purchase from the shop, Toy count in the bag, Toy priority over free play during bored care, stronger Toy XP feedback, autosave, and compact/mobile layout.
- [ ] Play-test Daily Check-in V0 in Roblox Studio, including the first-of-day join granting `+20 coins` and a `Daily +20 coins` toast, repeat joins on the same day not granting more coins, rejoining on the next UTC day granting another claim, autosave of `lastDailyClaimDay`, and confirming no other economy/quest/inventory changes.
- [ ] Play-test Weather/Event V2 in Roblox Studio, including the new Stormy weather state, the Studio-only tester cycling `Sun` → `Cld` → `Rain` → `Stm` → `Sun`, stormy raising both `Sleepy?` and `Dirty?` request frequency, a darker rain overlay during stormy weather, badge text/colors for all four weather states, and confirming no save-data or economy change.
- [ ] Play-test Quest V3 in Roblox Studio, including the new `Win Egg Catch` quest progressing one step per successful Egg Catch reward claim, the new `Level up ducks` quest progressing one step per duck level-up from care/treats, milestone `Treat x1` rewards for both quests every three completed levels, quest tracker showing both new quests, autosave, and stop/rejoin persistence.
- [ ] Play-test the coin counter abbreviation in Roblox Studio, including small coin balances showing the exact number, balances `1000` and above showing `1.0k`-style abbreviations with one decimal, balances `100000` and above showing whole-number `k`, balances `1000000` and above showing `M`-style abbreviations, the shop coin counter using the same abbreviation, and confirming cost text in shop cards and progression cards still shows exact coin amounts.

## Done
- [x] Implement Feature Unlock Ladder V0 per the comprehension guardrails: fresh profiles reveal the quest tracker and `Upgrades` after the first sell, `Shop` at the second duck, and `Minigames`/`Visit` after the first duck-help, with all rungs derived from server-owned progress that only increases (nothing re-locks), server-side rejection of ladder-locked actions, viewer-side unlock flags during farm visits, a saved `unlockLadder` flag behind `schemaVersion = 10`, and pre-ladder profiles keeping every feature.
- [x] Implement Comeback Gift V0 granting `Duck Feed x2` and `Treat x1` with a welcome toast to players away `7+` days, derived from the existing `lastSeenUtc` timestamp with no new save fields.
- [x] Implement Daily Quests V0 with three rotating UTC-day goals drawn deterministically from an `8`-goal pool (same selection for every player each day, derived from the day number with no saved selection state), auto-granted coin and item rewards with completion toasts, a `+30` coin all-complete bonus, rows reusing the existing quest panel at the top of the list, and Save Data V0 persistence behind `schemaVersion = 9`.
- [x] Implement Daily Streak V1 on top of Daily Check-in V0 with a persistent `streakDay` position, escalating rewards (`20/30/40/50/60/80` coins, day 7 `Treat x1` + `100` coins, repeating), the cozy pause rule (`1-3` missed days hold the position, longer gaps restart at day `1`), a streak-aware claim toast, and Save Data V0 persistence behind `schemaVersion = 8`.
- [x] Implement Offline Progress V0 with a server-derived `lastSeenUtc` timestamp, `50%` offline production rate, `2` hour accrual cap, welcome-back toast with away-minutes, forged-timestamp clamping, no-grant migration for pre-v7 saves, and Save Data V0 persistence behind `schemaVersion = 7`.
- [x] Implement Weather/Event V2 with a fourth Stormy weather state that combines mild `Sleepy?` and `Dirty?` request weighting, four-way random weather rolls, a darker farm rain overlay during stormy weather, badge color/text for stormy, and a Studio-only tester that cycles Sunny → Cloudy → Rainy → Stormy → Sunny.
- [x] Implement Quest V3 with two new repeatable quests: `Win Egg Catch` (+1 per successful Egg Catch reward claim) and `Level up ducks` (+1 per duck level-up from any care or Treat). Both grant milestone `Treat x1` every three completed levels and reuse the existing quest framework.
- [x] Implement coin counter abbreviation in the farm and shop coin counters, showing `1.2k`-style values above `1000`, whole-number `k` above `100k`, and `M`-style values above `1000000`, while keeping cost text and progression card copy at exact coin counts.
- [x] Implement Egg Value V1 with five upgrade tiers (`10`, `25`, `60`, `140`, `320` coins), each tier raising the egg sell value by `1`, with server-clamped persistence and unchanged UI flow.
- [x] Implement Quest V2 with two new repeatable quests: `Buy ducks` (+1 per duck purchased) granting milestone `Pillow x1` every three completed levels, and `Spend coins` (+cost per shop/duck/upgrade purchase) granting milestone `Duck Feed x1` every three completed levels. Reused the existing quest framework and added Pillow as a quest milestone reward type.
- [x] Implement Care V3 Bored feedback-only duck need with `Bored?`, a `Play` action, played-duck feedback, `25` XP from free play, `50` XP from Toy-backed play, help-quest progress, and a Studio-only `Bored` tester action.
- [x] Implement Toy V0 as a fifth shop item with persistent inventory, a `10` coin price, optional consumption during bored care, stronger `Toy +50 XP` than free play, and Save Data V0 persistence behind `schemaVersion = 6`.
- [x] Implement Daily Check-in V0 as a server-validated first-of-UTC-day join reward granting `+20` coins, a client `Daily +N coins` toast, persistent `lastDailyClaimDay`, and an explicit `claim_daily_check_in` action behind day-comparison validation.
- [x] Play-test Weather/Event V1 in Roblox Studio, including default Sunny weather, automatic Sunny/Cloudy/Rainy rolls, the Studio-only tester cycling `Sun` → `Cld` → `Rain` → `Sun`, farm weather badge updates, rainy overlay, increased `Sleepy?` during rain, increased `Dirty?` during cloudy, mobile layout, and confirming no save-data or economy change.
- [x] Play-test Care V2 Thirsty need in Roblox Studio, including random `Thirsty?` requests, the Studio-only `Thirsty` tester button, `Thirsty?` bubble/profile text, `Drink` action, `Drink +25 XP` feedback, `25` XP gain, help-quest progress, autosave, and confirming no item consumption or direct production/economy change beyond duck level progress.
- [x] Play-test Quest V1 in Roblox Studio, including the new `Use treats` quest progressing one step per Treat consumed, coin rewards, milestone Treat rewards every four levels, quest-complete feedback, overflow progress, quest level scaling, autosave, and stop/rejoin persistence.
- [x] Play-test Sleepy/Rest V2 in Roblox Studio, including Pillow consumption preferred over free rest, `Pillow +45 XP` versus `Rest +25 XP`, per-duck cooldown, XP gain, autosave, and no immediate production/economy change beyond duck level progress.
- [x] Play-test Pillow V0 in Roblox Studio, including Pillow purchase from the shop, Pillow count in the bag, Pillow priority over free rest during sleepy care, stronger Pillow XP feedback, autosave, and compact/mobile layout.
- [x] Implement Weather/Event V1 with a third Cloudy weather state between Sunny and Rainy, increased `Dirty?` request weighting during cloudy weather, three-way Sunny/Cloudy/Rainy random rolls, and a Studio-only tester that cycles Sunny → Cloudy → Rainy → Sunny.
- [x] Implement Care V2 Thirsty feedback-only duck need with `Thirsty?`, a `Drink` action, drink feedback, `25` XP, help-quest progress, and a Studio-only `Thirsty` tester action.
- [x] Implement Quest V1 with a fourth repeatable `Use treats` quest tracking Treat consumption, coin rewards, milestone Treat rewards every four levels, level scaling, overflow progress, farm quest panel, and DataStore persistence.
- [x] Implement Pillow V0 as a fourth shop item with persistent inventory, an `8` coin price, optional consumption during sleepy care, stronger `Pillow +45 XP` than free rest, and Save Data V0 persistence behind `schemaVersion = 5`.
- [x] Play-test Farm Visit V1 in a multi-player Studio test, including owner `Visitor Help` off/on states, farm card and visited-banner help labels, visitor helping `Pet me?`, `Sleepy?`, and `Dirty?` requests, visitor being blocked from `Hungry?`, no owner XP/quest/reward/inventory/save/economy changes from visitor help, direct remote attempts, and compact/mobile layout.
- [x] Implement Farm Visit V1 as same-server, online-only, owner opt-in visitor help for non-inventory duck requests with no XP, quest, reward, inventory, save-data, or economy impact.
- [x] Define Farm Visit V1 visitor permissions as session-only owner opt-in help for `Pet me?`, `Sleepy?`, and `Dirty?`, excluding `Hungry?`, offline snapshots, friend privacy, cross-server visits, and owner economy/progression changes.
- [x] Play-test the polished Farm Visit V0 panel in a multi-player Studio test, including same-server farm cards, clicking or tapping the row and `View` badge, empty same-server-only state, read-only visiting badge, Home guidance, and compact/mobile layout.
- [x] Fix Guide/Tutorial V0 Buy Duck step so fresh players can keep using Collect and Sell until Buy Duck is affordable.
- [x] Harden Egg Catch reward claims so impossible submitted scores are rejected before server-owned rewards are granted.
- [x] Add security test cases for invalid remotes once gameplay remotes exist.
- [x] Play-test Farm Visit V0 in Roblox Studio with at least two players, including online farm list population, visiting another same-server farm, read-only visitor behavior, disabled visitor actions, and `Home` return.
- [x] Implement Farm Visit V0 as read-only same-server farm viewing with server-owned target validation, a farm list UI, a `Home` return action, and no visitor economy impact.
- [x] Design Farm Visit V0 as read-only same-server farm visiting with server-owned farm state and no visitor economy impact.
- [x] Implement Minigames V0 as a same-place UI-scene shell with a farm `Minigames` button, a menu scene, Egg Catch V0, and a results screen.
- [x] Implement Egg Catch reward claims with a server-tracked round start, validated score claim, automatic results-screen payout, and modest coin or item rewards.
- [x] Implement Treat V0 with shop-purchased Treat inventory, Duck Profile V0 `Give Treat`, targeted duck XP, and Save Data V0 persistence.
- [x] Implement Dirty/Clean duck need with `Dirty?`, `Clean`, cleaned feedback, `25` XP, help-quest progress, and a Studio-only `Dirty` tester action.
- [x] Implement Guide/Tutorial V0 as a session-only fresh-profile farm overlay with spotlight steps for `Collect`, `Sell`, `Buy Duck`, `Shop`, and duck care.
- [x] Implement Quest V0 with repeatable collect, sell, and help quests, coin rewards, level scaling, overflow progress, farm quest panel, and DataStore persistence.

- [x] Remove the visible Save Data status indicator from the farm screen while keeping autosave, leave-save, shutdown-save, and internal server save status/logging behavior.
- [x] Implement Weather/Event V0 as session-only sunny/rainy weather with a rainy farm overlay, weather badge, rainy sleepy-request weighting, and Studio-only weather toggle.
- [x] Approve multiplayer-capable personal farms as the long-term farm visiting direction, with same-server read-only visits first, safe visitor actions later, and offline/friend farm visits last.
- [x] Add Save Data V0 design doc with proposed persistence scope, DataStore constraints, validation rules, migration notes, and implementation checklist.
- [x] Approve Save Data V0 scope: held eggs, ready nest eggs, coins, Duck Feed, Treat inventory, Egg Value level, duck names/profiles, duck level/XP, stable duck IDs, and no visible save status UI on the farm screen.
- [x] Approve using this current place for V0 DataStore testing, with deliberate API-services setup and Studio-only reset/debug safeguards.
- [x] Implement Save Data V0 with held eggs, ready nest eggs, coins, Duck Feed, Treat inventory, Egg Value level, duck names/profiles, duck level/XP, autosave, leave save, shutdown save, validation, no visible save status UI, and Studio-only tester safeguards.

- [x] Implement Rename V0 profile editing with server-side length validation, per-player duplicate checks, Roblox text filtering, and profile footer errors.
- [x] Define Rename V0 rules: `2` to `16` character names, case-insensitive uniqueness within the player's current duck list, and no global uniqueness until reservation rules exist.
- [x] Implement Duck Profile V0 as a lightweight selected-duck identity/status panel.
- [x] Implement Duck Names V0 as server-generated duck names with per-player duplicate avoidance and selected-duck bubble display.
- [x] Implement Duck Level/Progress V0 as per-duck XP, selected-duck level bars, level-based egg-production bonuses, and visual level-up feedback.
- [x] Implement Sleepy/Rest V1 as a feedback-only duck need with `Sleepy?`, `Rest`, XP gain, rested feedback, and a Studio-only `Sleepy` tester action.
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
- [x] Confirm the earliest first prototype did not include save data before Save Data V0 was approved.
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
- [x] Convert ducks into real individual server records with per-duck care cooldowns.







