# Changelog

All meaningful project changes should be recorded here.

Use short entries that describe what changed and why. Keep implementation details in the relevant docs or code comments.

## Unreleased

### Added

- Implemented Phase 5 client UI V0 (2026-06-13): `families` info guide step added as the final tutorial step (same `Got it!` pattern as `streak` and `quests`); `createStarterChoiceOverlay` shows a centered modal with 3 family cards (name, rarity badge, `Choose` button) on a dim backdrop — no dismiss, fires `pick_starter_choice` to the server; `createMysteryDuckBoxPickPanel` shows 3 rarity-colored candidate cards with `Pick!` buttons, driven directly by `farmState.pendingDuckBoxCandidates` (authoritative server state); notice handlers added for `pending_starter_choice` (opens overlay after guide completes), `collection_reward_granted` (floating toast), and `duck_box_candidate_picked` (floating toast with duck name and rarity). Buy Duck V1 family-selector and Duckdex tab deferred to Phase 5 polish pass.

- Implemented Phase 5 server logic (2026-06-13): schema bumped to `11`; per-duck `family` and `rarity` saved and loaded with `"classic_yellow"`/`"common"` migration defaults for pre-Phase-5 ducks; rarity egg-production bonus (`+0%` Common through `+35%` Legendary) applied per-duck on top of the existing level bonus; `collectionRewardsClaimed`, `starterChoiceCompleted`, and `mysteryDuckBoxes` persisted; `checkCollectionMilestones` auto-runs after every duck grant and on load (idempotent, grants coins/treats/boxes with a notice per milestone); `open_mystery_duck_box` generates 3 rarity-weighted candidates (`60/30/10` Uncommon/Rare/Epic) and fires `mystery_duck_box_opened`; `pick_duck_box_candidate` validates the index, grants the chosen duck, and fires `duck_box_candidate_picked`; `pick_starter_choice` validates against `starterChoiceFamilies`, grants the duck with correct rarity, and saves `starterChoiceCompleted = true`; `pending_starter_choice` notice queued on load for all profiles where `starterChoiceCompleted = false`. New actions and notices added to `RemoteProtocol.luau`.

- Implemented Phase 5 data layer (2026-06-13): `DuckState` gains `family` and `rarity`; `FarmState` gains `collectionRewardsClaimed`, `starterChoiceCompleted`, `mysteryDuckBoxes`, and `pendingDuckBoxCandidates`; four new shared types added (`DuckBoxCandidate`, `DuckFamilyDefinition`, `CollectionRewardDefinition`, `MysteryDuckBoxDefinition`); `PrototypeConfig` type and runtime table populated with 7 duck families (`classic_yellow` through `golden`), 4 Duckdex collection-reward milestones (25%/50%/75%/100%), Mystery Duck Box drop odds (`60/30/10` Uncommon/Rare/Epic), and 3 Starter Choice families; `SAVE_DATA_DESIGN.md` updated with full schema `11` shape and per-field validation rules.

- Added `docs/STUDIO_MCP.md` (2026-06-13) documenting the Roblox Studio MCP for cross-agent use: the connected server set, the full `Roblox_Studio` tool inventory (27 tools, grouped by purpose), a testing rule (exercise the live code through the MCP when it is connected, rather than static reasoning alone), the safe save backup/clear/restore procedure for state and persistence tests, key test constants (DataStore name/key, remote names, tester actions), and the line between MCP-verifiable server logic and the visuals/multiplayer checks that still need a human in Play mode. Referenced from `AGENTS.md`, `docs/WORKFLOW.md`, and the doc-update policy.

- Completed security review of Offline Progress V0 and Daily Streak V1 claim paths (2026-06-13): reviewed four threat vectors — forged `lastSeenUtc` timestamps, clock skew, duplicate daily claims, and rejoin spam. All four are secure. `lastSeenUtc` is server-written to DataStore; `math.clamp` handles negative and future-dated values; the `currentDay <= lastDailyClaimDay` idempotency guard has no race window in the single-threaded server; the `0.15 s` per-action rate limiter and the `isLoaded` gate block racing the auto-claim on join; `waitForActiveSave` in leave prevents save-skipping rejoin spam. No code changes required. Findings recorded in `docs/SECURITY_TESTS.md`.

- Implemented Settings V0 (2026-06-13): a `Settings` pill button (dark, top-right below the coin counter) visible on the farm screen opens a centered modal with a semi-transparent backdrop. The modal contains three toggle rows — Music, Sound Effects, and Reduced Motion — each with a coral `On` / gray `Off` pill toggle. Tapping the backdrop or the `x` button closes the panel. Toggle state is session-only for now; Audio V0 will wire the sound controls when asset IDs are provided. The Settings button counts as the sixth secondary farm-screen control, filling the UI budget.

- Implemented Badges V0 server scaffold (2026-06-13): `BadgeService:AwardBadge()` wired at all five trigger points — first duck bought, first successful rename, 100 session eggs collected, any duck reaching level 5, and the 7-day streak claim (both auto-claim on join and manual claim action). Badge IDs live in a new `PrototypeConfig.badges` table initialized to `0` (no-op placeholders until the owner fills them in from the Creator Dashboard). `renameDuck` now returns a boolean so the action handler can distinguish success. Session egg totals are tracked per-player in a module-level table and cleaned up on leave.

- Added first-use guide steps for Phase 4 systems (2026-06-13): two new informational guide steps (`streak` and `quests`) appended to the tutorial sequence, showing immediately after the care step completes when the streak panel and daily quests are first revealed. Each step shows a full dim overlay with a title, body explanation, and a coral `Got it!` button; farm actions stay freely available during these steps. Satisfies the no-system-ships-untaught comprehension guardrail for Phase 4.

- Built the 7-day streak track panel (2026-06-13): compact white panel on the farm screen left side showing seven circular day slots — coral-filled for claimed days, warm-highlighted for today's claimable day, gray for future ones, day 7 slightly larger with a star badge hinting at the Treat reward — plus a `Day N` label and a `Claim!` button shown only when the daily reward is unclaimed. Gated on the `featureUnlocks.minigames` unlock rung (visible after guide completion). The quest panel shifts down via a new `yOffset` parameter so the two panels stack cleanly without overlap.

- Implemented Feature Unlock Ladder V0 (2026-06-12) per the comprehension guardrails: fresh profiles start with only Collect, Sell, and counters, then reveal the quest tracker and `Upgrades` after the first sell, `Shop` once the second duck is owned (matching the guide order), and `Games`/`Visit` after the first duck-help action. Unlock rungs derive entirely from server-owned progress that only increases, so nothing can re-lock; ladder-locked actions are also rejected server-side; unlock flags always reflect the viewer's own progress during farm visits; and a single saved `unlockLadder` flag (`schemaVersion = 10`) limits the ladder to profiles created after it shipped, so existing players keep every feature.
- Added `docs/OWNER_BACKLOG.md` (2026-06-12), a checkable list of everything blocked on the project owner — Studio play-tests, badge creation and IDs, audio selection, art generation batches, asset uploads, the maturity questionnaire, and later milestone actions — with notes on where each provided ID gets wired. Registered in the README and doc-update policy.
- Implemented Comeback Gift V0 (2026-06-12): players returning after `7` or more days away receive `Duck Feed x2` and `Treat x1` on load with a `Your ducks missed you!` toast. The away time derives from the same server-owned `lastSeenUtc` timestamp as offline progress (uncapped for the gift check), requires no new save fields, and is framed as a welcome rather than recovered losses per the cozy promise.
- Implemented Daily Quests V0 (2026-06-12): three rotating UTC-day goals drawn deterministically from an `8`-goal pool over existing tracked actions (collect, sell, help, shop purchases, spending, treats, Egg Catch wins, duck level-ups), with the same selection for every player each day derived from the day number so no selection state is saved. Completion auto-grants coins plus small item rewards with a toast, completing all three grants a `+30` coin bonus toast, daily rows render at the top of the existing quest panel (no new UI surface), and progress persists behind `schemaVersion = 9` with self-resetting day stamps. Completion notices queue on server state and flush with the next state send, since reward paths do not receive the Player object.
- Implemented Daily Streak V1 (2026-06-12) on top of Daily Check-in V0: a persistent 7-day streak position with escalating rewards (`20/30/40/50/60/80` coins, day 7 `100` coins plus `Treat x1`, repeating), the cozy pause rule (missing `1-3` days holds the streak position, longer absences restart at day `1`), a streak-aware claim toast (`Day N streak! +coins`), the `streakDay` field replicated in farm state for the future streak track panel, and Save Data V0 persistence behind `schemaVersion = 8`. Pre-v8 saves start their streak at day `1` on the next claim.
- Implemented Offline Progress V0 (2026-06-12), the first Phase 4 retention feature: ducks keep producing at `50%` of the online rate while the player is away, capped at `2` hours, computed server-side from a saved `lastSeenUtc` timestamp that is written from server time and clamped against forged or future-dated values on load. Offline eggs are granted to the nest on load with a one-time welcome-back toast showing eggs and away-minutes. Pre-v7 saves load with `lastSeenUtc = 0` and grant nothing on their first rejoin. Save schema is now `schemaVersion = 7`.
- Added a local project map dashboard at `docs/project-map/index.html` (2026-06-12) with static HTML/CSS/JS for analyzing Rojo mappings, source modules, runtime remotes, server-owned state, save-data flow, UI screens, high-level gameplay loop, supporting gameplay systems, roadmap direction, and related docs without adding a build step or dependency.
- Added a left-to-right autoplay gameplay simulator at `docs/project-map/gameplay-flow.html` (2026-06-12) showing the current confirmed farm loop with moving box-component flow for eggs, coins, care, shop items, quests, duck XP, weather, and save-state analysis.

- Approved three binding comprehension guardrails (2026-06-12) after a complexity audit found system overload to be the project's top remaining risk: a per-player Feature Unlock Ladder (V0 in Phase 4) so fresh profiles meet systems one at a time no matter how much content the live game has, with unlock state derived from existing progress and nothing ever re-locking; a no-system-ships-untaught rule folding each phase's guide step or first-use tooltip into its exit criteria; and a UI surface budget capping the farm screen at `3` primary actions and `6` always-visible secondary controls, with hub consolidation starting in Phase 6 and special currencies capped at the four already planned. Recorded in the roadmap (new Comprehension Guardrails section), brief, research notes, save-schema plan, design inputs, and Phase 4 tasks.
- Approved Photo Mode V0 for Phase 8 (2026-06-12): a camera button that hides the HUD, briefly posing ducks, `4` earnable starter frames and `8` text-free stickers, capture through the platform capture flow into the player's Roblox gallery, a corner game stamp for organic sharing, and visitor access on visited farms. No custom uploads, no text input, no monetized frames without a wave sign-off; recorded in the roadmap, brief, research notes, product plan marketing section, and a new `Photo Frame and Sticker Sheet` prompt.
- Resolved the care-XP versus battle-power conflict and deepened duck growth (2026-06-12): added daily duck XP pacing to Phase 7 (`150` XP per duck per UTC day from all sources, gentle capped messaging, Treat use blocked at cap so no item is wasted) so coin-bought treats cannot create same-day overpowered battle ducks; gave Pond Games battles duck XP (`+15` win / `+5` loss inside the same cap); expanded ducks to a four-stat block (`Heart`, `Splash`, `Pace`, `Spirit`) derived from class/level/rarity/stage that affects battles only and never farm output; and added Training Camp V0 to Phase 7B (send one duck into visible stasis for `4h/8h/24h` at `25/40/80` coins for permanent `+2/+5/+12` gains to one chosen stat, capped at `+20` per stat, no eggs/care/battles/breeding while away, offline accrual excluded, cancel returns the duck with a full refund and no gain). Farm level now also unlocks Training Camp slot `2` in Phase 8. Recorded in the roadmap, brief, research notes, save-schema plan, tasks, and a new `Training Camp Scene and Stat Icon Sheet` prompt.
- Approved Pond Games (Duck Battles V0) as new roadmap Phase 7B (2026-06-12): an optional friendly contest mode with `3v3` turn-based PvE, per-turn skill picks instead of auto attacks, four classes assigned by duck family (`Guard`, `Splasher`, `Quacker`, `Helper`), a capped `16`-skill V0 set unlocked by existing duck levels and evolution stages, stats derived from level/rarity/stage with no second grind, tired-not-hurt presentation, no-loss outcomes per the cozy promise, server-resolved matches, opt-in challenges only, no live real-time PvP, and battle power added to the product plan never-for-sale list. Recorded in the roadmap, brief, research notes (with an honest cozy-fit caveat), save-schema plan, tasks, and two new design prompts (`Pond Games Battle Scene Mockup`, `Battle Skill and Class Icon Sheet`) with a no-weapons art rule.
- Approved duck-grant reward moments (2026-06-12) after genre research: a one-time Starter Choice Duck at guide completion (pick `1` of `3` starter cards: Mallard Green, Choco Brown, Snowy White), a reward-only Mystery Duck Box (see `3` rarity-weighted ducks at displayed `60/30/10` odds, keep `1`; sourced from the first 7-day streak, Duckdex `50%`, event finales, and first Legacy; never sold), and a Phase 4 Comeback Gift for players away `7+` days. Direct duck grants stay bounded one-time or rare-milestone moments so hatching remains the core acquisition loop; recorded in the roadmap, brief, research notes, save-schema plan, tasks, and a new `Mystery Duck Box and Starter Choice Mockup` design prompt.
- Added `docs/PRODUCT_PLAN.md` (2026-06-11), the master product/business plan covering positioning and audience, three cosmetic-only monetization waves with concrete Robux starter prices (`Supporter Pass` `199`, `Cozy Basics Accessory Pack` `99`, `Starlight Garden Decoration Theme` `149` at full launch; `Velvet Family` `399` at Phase 8; per-event cosmetic bundles `199-249` at Phase 11), a never-for-sale list (coins, eggs, odds, boosts, incubator slots, quest skips, Legacy Feathers, any paid random item), calm-storefront rules, receipt-processing implementation requirements, analytics targets and `AnalyticsService` event instrumentation, the soft-launch/full-launch marketing sequence with decision gates, community and localization policy, trust/safety/compliance commitments, operations and recovery procedures, and risks with mitigations.
- Added Marketing Asset Prompts to `docs/DESIGN_PROMPTS.md`: a `Game Icon` prompt and a five-scene `Store Thumbnail - Template` with a scene table, all text-free for later compositing.
- Added product-plan tasks to `docs/TASKS.md`: analytics events, automatic translation, the content maturity questionnaire, recovery dry runs, marketing assets, store description and display-title decision, the official group, and the gated Monetization Wave 1 implementation.
- Recorded planned monetization save fields in `docs/SAVE_DATA_DESIGN.md`: capped processed-receipt ids for idempotent grants, owned-cosmetic flags, and a per-duck equipped accessory slot.

- Approved and documented the full long-term content roadmap through endgame in `docs/ROADMAP.md` (2026-06-11): Phase 4 retention foundations (offline progress, daily streaks, daily quests, badges, settings, audio, first art pass), Phase 5 duck families and the Duckdex, Phase 6 egg hatching with an incubator and pity counters, Phase 7 deterministic evolution stages, Phase 8 farm zones and decorations, Phase 9 mutations and breeding, Phase 10 gifting/likes/leaderboards, Phase 11 seasonal event framework with two new minigames, and Phase 12 Duck Legacy prestige with mastery, plus a live-ops cadence and release milestones.
- Recorded the roadmap's retention design pillars, including the hard `cozy promise` rule that no mechanic may punish absence or neglect.
- Recorded the approved monetization gate: cosmetic-first direction with hard rules (no paid random eggs, no premium currency in V1, no pay-to-win), with exact products and prices still requiring explicit approval.
- Added gameplay research entries with scores for the long-term retention plan, offline progress, daily streaks and daily quests, the Duckdex and rarity, hatching, Duck Legacy prestige, the social layer, and an explicit `Avoid For Now` decision on player trading; refreshed stale idea-backlog buckets to their roadmap phases.
- Added the Future Content Prompt Batch to `docs/DESIGN_PROMPTS.md`: a Duck Body Template Anchor, family palette and season theme tables, and ready-to-run consistent prompts for badges, the streak calendar, the family lineup and per-family sets, rarity frames, the Duckdex screen, egg types, incubator stages, hatch reveal, evolution stages and celebration, progression items, Meadow and Orchard zones, decorations, mutation overlays, the nursery, social UI, seasonal event backgrounds and event ducks, Bread Toss and Lily Hop scenes, the Golden Pond, and a monetization-gated accessory concept sheet.
- Added planned save schema growth (`schemaVersion = 7` through `15`) mapped to roadmap phases in `docs/SAVE_DATA_DESIGN.md`, with server-derived timestamp and validation rules for every future bump.
- Added Roadmap Phase 4 implementation tasks to `docs/TASKS.md`, including a security review task for the new offline and streak claim paths.

- Added Weather/Event V2 with a fourth Stormy weather state that combines mild `Sleepy?` and `Dirty?` request weighting, four-way random weather rolls, a darker rain overlay during stormy weather, distinct badge text and colors for sunny/cloudy/rainy/stormy, and a Studio-only tester that cycles Sunny → Cloudy → Rainy → Stormy → Sunny.
- Added Quest V3 with two new repeatable quests: `Win Egg Catch` (+1 per successful Egg Catch reward claim) and `Level up ducks` (+1 per duck level-up from any care, feed, rest, clean, drink, play, or Treat). Both quests grant milestone `Treat x1` rewards every three completed levels and reuse the existing quest framework with DataStore persistence.
- Added a coin counter abbreviation helper (`formatCoinCount`) so the farm and shop coin counters render compact `1.2k`-style values above `1000`, whole-number `k` above `100k`, and `M`-style values above `1000000`, while shop cards and progression cards still show exact coin costs.
- Added Egg Value V1, expanding the first upgrade from a single tier into five tiers with rising costs (`10`, `25`, `60`, `140`, `320` coins) that each raise the egg sell value by `1`, with server-clamped persistence.
- Added Quest V2 with two new repeatable quests: `Buy ducks` (+1 per duck purchased) granting milestone `Pillow x1` every three completed levels, and `Spend coins` (+cost per shop, duck, or Egg Value purchase) granting milestone `Duck Feed x1` every three completed levels. Quest framework now also supports `Pillow` as a quest milestone reward type.
- Added Care V3 with a feedback-only Bored/Play duck need including `Bored?`, a `Play` action, played-duck feedback, `25` XP from free play, help-quest progress, and a Studio-only `Bored` tester action.
- Added Toy V0 as a fifth shop item with persistent inventory, a `10` coin cost, optional Toy consumption during bored care, `Toy +50 XP` priority over free `Play +25 XP`, a Toy row in the shop bag, and Save Data V0 persistence behind `schemaVersion = 6`.
- Added Daily Check-in V0 as a server-validated first-of-UTC-day join reward granting `+20` coins, a client `Daily +N coins` toast feedback, persistent `lastDailyClaimDay`, and an explicit `claim_daily_check_in` action guarded by day-comparison validation.
- Added Weather/Event V1 with a Cloudy weather state between Sunny and Rainy, mildly increased `Dirty?` request weighting during cloudy weather, three-way random weather rolls, and a Studio-only tester that cycles Sunny → Cloudy → Rainy → Sunny.
- Added Care V2 with a feedback-only Thirsty/Drink duck need including `Thirsty?`, a `Drink` action, hydrated-duck feedback, `25` XP, help-quest progress, and a Studio-only `Thirsty` tester action.
- Added Quest V1 with a fourth repeatable `Use treats` quest that progresses by `1` each time a Treat is given to a duck, including coin rewards, milestone Treat rewards every four levels, level scaling, overflow progress, farm-screen quest panel, and DataStore persistence under the existing quest dictionary shape.
- Added Pillow V0 as a fourth shop item with persistent inventory, an `8` coin cost, optional Pillow consumption during sleepy care, `Pillow +45 XP` priority over free `Rest +25 XP`, a Pillow row in the shop bag, and Save Data V0 persistence behind `schemaVersion = 5`.
- Added Farm Visit V1 with a session-only owner `Visitor Help` toggle, same-server help badges, and a server-validated `visitor_help_duck` action that lets opted-in visitors clear `Pet me?`, `Sleepy?`, `Dirty?`, or `Thirsty?` requests without granting XP, quests, rewards, inventory changes, save data, or economy impact.
- Added `docs/SECURITY_TESTS.md` with Studio QA cases for malformed remote actions, invalid payloads, duplicate Egg Catch reward claims, Farm Visit V0 read-only permission checks, and Studio-only tester guards.
- Added Farm Visit V0 with a same-server `Visit` farm list, read-only viewing of another loaded player's farm state, a `Home` return action, server-validated visit targets, and no visitor economy/save impact.
- Added Premium Feed V0 as a third shop item with inventory persistence, a higher-cost hungry-care option, and stronger hungry-duck XP than basic Duck Feed.
- Added Guide/Tutorial V0 as a session-only fresh-profile farm overlay with spotlight steps for `Collect`, `Sell`, `Buy Duck`, `Shop`, and duck care, using a compact/mobile-safe card layout and no save-data flag yet. Roblox Studio now also has a local `Guide` tester button for reopening it without clearing save data.
- Added a small fresh-profile starter grant of Duck Feed x1 so first-session players can reach their first hungry-duck interaction without needing an immediate shop purchase.
- Added a one-time fresh-profile hungry follow-up after onboarding so if the first duck-help action was not hungry, the server schedules a hungry request soon after to give the starter feed an immediate use.
- Added a one-time Starter Feed x1 client feedback toast for fresh profiles so the starter grant is visible without adding another tutorial step.
- Added a feedback-only Dirty/Clean duck need with `Dirty?`, a `Clean` action, cleaned-duck feedback, `25` XP, help-quest progress, and a Studio-only `Dirty` tester action.

- Added Egg Catch reward claims with a server-tracked round start, validated score claim, automatic results-screen payout, modest coin rewards, and score-threshold Duck Feed or Treat bonuses.
- Added Treat V0 with a second shop item, server-owned Treat inventory, Duck Profile V0 `Give Treat`, targeted duck XP, Treat feedback, and Save Data V0 persistence.
- Added Quest V0 with repeatable server-owned collect, sell, and help quests, coin rewards, level scaling, overflow progress, farm-screen quest panel, and DataStore persistence.
- Added Weather/Event V0 with session-only sunny/rainy weather, a farm weather badge, rainy UI overlay, rainy sleepy-request weighting, and a Studio-only `Rain`/`Sun` tester toggle.
- Added Minigames V0 as a same-place UI-scene shell with a farm `Minigames` button, a menu scene, Egg Catch V0, a results screen, desktop and touch movement controls, and no reward or save-data impact yet.
- Recorded the multiplayer direction as personal farms inside multiplayer-capable servers, with same-server read-only visits first, visitor help actions later, and offline/friend farm visits last.
- Recorded duck evolution as a future-system direction tied to level progression, with chance-based triggers and cutscene presentation left undecided.
- Locked the future duck visual rule set so shop-bought variations define base families, evolution stays within the same family line, and mutation remains a separate overlay trait.
- Recorded minigames as a future same-place UI-scene system with a farm `Minigames` button, menu, and separate minigame screens instead of separate-place teleports.

- Recorded a future original guide-character direction for onboarding and reusable helper scenes, without defining the final art or dialogue yet.
- Documented current UI and design resource gaps so missing assets and final design decisions can be addressed without blocking gameplay prototyping.
- Added Save Data V0 design documentation with proposed persistence scope, DataStore constraints, validation rules, migration notes, and implementation checklist.
- Added Rename V0 through Duck Profile V0, with `Rename`, `Save`, and `Cancel` UI, server-side `2` to `16` character validation, per-player duplicate checks, Roblox text filtering, and profile footer errors.
- Added Duck Profile V0 as a lightweight selected-duck panel for name, level/XP, mood, need, care readiness, and saved-profile status.
- Added Duck Names V0 with server-generated names, per-player duplicate avoidance, and selected-duck bubble display.
- Researched Duck Profile, Names, and Rename V0 direction using animal-profile patterns plus Roblox text-filtering guidance, and recorded generated names plus rename constraints.
- Added Duck Level/Progress V0 with server-owned per-duck XP, selected-duck level bars, and visual-only level-up feedback.
- Added production readouts to the duck profile subtitle and egg status card so level-based egg output is easier to verify on crowded farms.
- Added kid-friendly `Egg Boost` and `Level Up` stats to Duck Profile V0 so individual duck value is easier to read without expanding save scope.
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
- Added a Studio-only tester panel for granting coins, ready eggs, ducks, and resetting current state during Play mode testing.
- Added a farm-screen egg status card with next-egg progress and ready-egg messaging.
- Added Duck Mood / Care V0 with server-owned `Content` and temporary `Happy` mood states, a `Care` action, cooldown, and client feedback.
- Added tap/left-click selection for visible ducks with a local `Pet me?` care bubble that reuses the server-owned `Care` action.
- Added server-owned per-duck Care Request V0 so one visible duck can ask for care with a `Pet me?` prompt.
- Added real individual duck records with per-duck care cooldown, temporary cared mood, and validated care targeting.
- Added a Studio-only `Need` tester action for forcing a duck care request during Play mode.
- Recorded mutation and breeding as future-system directions without defining mechanics yet.

### Changed

- Changed join-time reward presentation from floating toasts into a single Welcome Back card (2026-06-12): offline eggs, the streak claim, and the comeback gift now aggregate into one centered tap-to-dismiss card when they arrive within `15` seconds of the farm screen mounting, instead of three brief overlapping toasts a loading player can miss. The same notices later in a session still use floating toasts, the card is suppressed during fresh-profile onboarding and while visiting another farm, and mid-game feedback toasts are unchanged. Prompted by owner play-testing.
- Strengthened three retention guards in the duck variant design after review: every mutation now requires a bold always-visible farm-scale tell so visitors can spot special ducks at a glance (the subtle-only mutation rule was rejected as a retention risk), Phase 5 now guarantees the second duck family is affordable within a fresh player's first one or two sessions, and Phase 7 now targets the first Stage 2 evolution landing within days for an engaged player. Duck variant art sheets must be reviewed scaled to in-game sprite size before approval, and the mutation overlay prompt was rewritten for bold high-contrast tells.
- Changed the roadmap monetization section from an approval gate into planned waves that reference `docs/PRODUCT_PLAN.md`, keeping the hard rules and the per-wave one-line user sign-off; updated `docs/GAME_BRIEF.md`, `docs/DOC_UPDATE_POLICY.md`, and `README.md` to register the new product plan, and unblocked the accessory concept prompt for Wave 1 exploration while final accessory art still waits for the wave sign-off.
- Updated `docs/GAME_BRIEF.md` to list the approved long-term systems by roadmap phase, separate still-unapproved ideas (trading, production weather effects, surprise life events), and narrow the undecided list to monetization products, final asset approvals, audio tracks, snapshot privacy, event dates, and minigame balance.
- Updated `docs/DESIGN_INPUTS.md` with the planned screens by phase, future-content asset targets, and the approved high-level audio direction.
- Relaxed the design prompt guardrails only for Future Content Prompt Batch prompts that explicitly call for rarity frames, golden eggs, evolution sparkle, mutation overlays, or event theming; all other prompts keep the original rules.
- Changed Farm Visit UI so opening `Visit` shows same-server farm cards in a bottom drawer/tray above the action bar on all layouts, with compact/mobile using full width and desktop using a centered tray.
- Changed Farm Visit V0 UI polish so same-server farm rows look more like selectable cards, the empty state explains same-server-only visits, and visited farms show a clear read-only badge with Home guidance.
- Changed care, feed, rest, clean, quest-complete, and item-gain feedback text to show clearer XP or reward context during play-testing.
- Changed Quest V0 tracker rows to show upcoming milestone Duck Feed or Treat rewards beside coin rewards when the current quest level will grant them.
- Changed Treat V0 feedback to show the configured targeted XP amount when a Treat is consumed, making Duck Level/Progress V0 easier to verify from the compact profile flow.
- Made the Farm HUD V2 quest tracker expandable so the farm stays clean by default but the full quest list is still one tap or click away.
- Expanded Quest V0 rewards so collect, sell, and help quests can now grant milestone Duck Feed or Treat bonuses alongside their existing coin rewards.
- Changed Farm HUD V2 to reduce always-visible clutter by compacting quests, moving Egg Value and Buy Duck behind an `Upgrades` panel, and shrinking Minigames into a secondary farm button.
- Polished Shop V0 copy and layout so Duck Feed and Treat now show clearer purpose, cost, owned count, and buy-button text without changing prices or item behavior.
- Changed Egg Catch V0 so the results screen now waits for an automatic server-backed reward claim before letting the player leave, instead of ending with no progression impact.
- Changed Egg Catch V0 to use direct mouse movement on desktop, touch drag on mobile, and a full-screen active play scene instead of a small framed playfield.
- Updated the saved player schema to version `3` so Treat inventory now persists alongside Quest V0 level and progress across sessions.
- Changed Duck Level/Progress V0 so each duck level above `1` now adds a small egg-production bonus instead of staying presentation-only.
- Moved the Duck Profile V0 `Rename` button into the header row beside the duck name while keeping `Save` and `Cancel` in the footer during active renaming.
- Removed the visible farm-screen save status indicator while keeping autosave, leave-save, shutdown-save, and internal server save status/logging behavior.
- Added friends/farm visit UI planning notes for simple farm boxes or cards so players can choose friends to visit.
- Removed the visible Studio Save/Clear tester buttons now that autosave is the expected persistence path.
- Changed Save Data V0 autosave to trigger shortly after meaningful dirty changes, while keeping a longer retry delay after DataStore failures.
- Recorded approved Save Data V0 decisions: held eggs, ready nest eggs, and duck profile data are in scope; visible save status UI has been removed and player-facing save failure warnings are deferred; this place can be used for V0 DataStore testing with safeguards.
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

- Fixed join-time toasts (streak claim, offline eggs, comeback gift) firing before the client notice listener connects and being lost: all join-time notices now queue on server state and flush only after the client proves it is ready by sending any action. Found during owner play-testing when the streak toast never appeared.
- Capped the expanded quest panel at `6` visible rows (`4` on short landscape) with a scrolling list, after dailies plus the repeatable quest set grew it into an eleven-row wall that covered the farm scene.
- Fixed daily quest rows showing a meaningless quest level (`Daily: Collect... 1`); daily slots now display the goal name alone.

- Fixed Farm Visit V1 panel layout so the owner-side `Visitor Help` toggle reserves visible space below the same-server farm rows instead of clipping under the row cards.
- Fixed Farm Visit V0 polished `View` rows so each visible row has a direct top-level hit target above the regular farm buttons, with row and `View` badge clicks routed to the same visit action.
- Fixed Farm Visit V0 Studio multiplayer visits so same-server test players with nonzero negative Studio `UserId` values can be visited while still requiring a live same-server target player.
- Fixed mobile Duck Profile opening so tapping the selected-duck bubble's `Profile` button no longer also runs the farm-scene tap handler that can immediately close the profile.
- Fixed the one-time fresh-profile Starter Feed toast so it shows the configured starter grant amount instead of the player's current Duck Feed inventory.
- Fixed the Studio-only weather tester label so it switches between `Rain` and `Sun` based on the current weather state.
- Fixed Duck Profile V0 outside-click handling so blank space inside an open profile panel no longer counts as a farm scene click that closes the profile or changes duck selection.
- Fixed Shop V0 short-landscape card layout so the item cards fit below the header and keep their purpose, cost, owned count, and buy button from overlapping.
- Fixed Farm HUD V2 short-landscape `Upgrades` layout so the Egg Value and Buy Duck cards open as a horizontal tray above the action bar instead of overlapping the bottom actions or close button.
- Fixed Guide/Tutorial V0 so the Buy Duck step no longer traps fresh players after the first sell; Collect and Sell remain available until Buy Duck is affordable while unrelated actions stay blocked.
- Hardened save-data and numeric remote validation so `NaN` and infinite numeric values are rejected before integer checks, clamping, or state lookup.
- Hardened Egg Catch reward claims so the server rejects non-finite, negative, fractional, early, duplicate, and impossible submitted scores before granting server-owned rewards.
- Verified Farm Visit V0 in Roblox Studio with at least two players and confirmed the read-only same-server visit flow works properly.
- Fixed the Studio-only weather tester button to send the actual `test_toggle_weather` remote action.
- Fixed Farm HUD V2 quest visibility so the compact quest tracker no longer overlaps the weather badge and stays visible on the farm screen.
- Fixed the Shop V0 polish layout so the placeholder background no longer competes with the item cards, and card description text no longer overlaps the buy buttons on compact screens.
- Tightened Guide/Tutorial V0 duck-care targeting so the care step highlights the actual duck with a compact halo and hint instead of a broad area box that drifted across screen sizes.
- Gated Guide/Tutorial V0 farm interaction so only the current highlighted action stays usable while onboarding is open, restored the Studio Rain tester button beside the new Guide tester button, and blocked unrelated farm or tester actions during the tutorial.
- Converted Guide/Tutorial V0 into a task-driven mandatory flow by removing Back, Next, Skip, and Done, auto-advancing each step from the real required action, and letting the Shop step hand off cleanly back to the farm before the guide ends on duck care.
- Fixed the Guide/Tutorial V0 shop handoff so opening Shop no longer skips ahead to farm-only steps while the player is still in the shop; the shop step now stays active there and advances only after Back returns the player to the farm.
- Restored the dimmed overlay around the duck-care spotlight so step 5 keeps the same guided emphasis as the other onboarding steps without blocking the requested duck interaction.
- Fixed Guide/Tutorial V0 step 5 interaction by auto-selecting the requested duck and raising the duck bubble above the tutorial overlay so the care action stays visible and clickable.
- Fixed Guide/Tutorial V0 step 5 progression so helping the duck now advances only after the server-cleared care request arrives in farm state, instead of depending on the local click alone.
- Removed Minigames from Guide/Tutorial V0 so onboarding now stays focused on the core farming and duck-care loop instead of optional side content.
- Kept Egg Catch results inside a full-screen minigame scene so ending a round no longer exposes the Roblox world behind the UI.
- Kept the React client root alive for the full local-script lifetime so the Duck UI does not disappear after a longer minigame round or other later client activity, and added an in-app fallback panel so a client render error does not drop players back to the bare Roblox world.
- Fixed the Egg Catch results render path so it no longer calls helper functions before they are in scope, which was causing the `attempt to call a nil value` client UI crash.
- Fixed the egg status card layout so large ready counts stay readable without overlapping the progress bar, while keeping a compact rate summary visible.
- Strengthened Save Data V0 leave-save reliability by saving through stable UserId snapshots, giving shutdown a recent leaving-state fallback, waiting for active saves, and preserving dirty changes made during an in-progress save.
- Removed idle Duck Profile saved-status footer copy so the footer only appears for rename errors.
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











