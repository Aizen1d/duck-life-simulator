# Roadmap

This roadmap covers the full planned life of `Duck`, from the confirmed direction (a 2D UI-first duck life simulator with farming as the first core activity, autonomous duck presentation, and no player-controlled movement) through launch, long-term content, and endgame.

The long-term content plan below was approved on 2026-06-11 as project direction. Each phase is approved as direction, not as final detail: before implementation, each phase still gets its own design pass, doc updates, security review where relevant, and play-testing. All numbers in this file are starter defaults that may be rebalanced.

## How to Read This Roadmap

- Phases are ordered by dependency, not by calendar dates. Ship one phase's core before starting the next phase's implementation.
- Each phase lists its goal, the retention pillar it serves, its feature scope, its expected save-data impact, its asset needs, and its exit criteria.
- `Done` phases are kept for history. `Next` is the active phase. `Planned` phases need their design pass before implementation.
- Asset prompts for future phases live in `docs/DESIGN_PROMPTS.md` under the Future Content Prompt Batch.
- Planned save schema changes per phase live in `docs/SAVE_DATA_DESIGN.md` under Planned Schema Growth.

## Retention Design Pillars

Every phase should serve at least one of these pillars. When cutting scope inside a phase, keep the pillar; cut the decoration around it.

1. A reason to return tomorrow: offline egg progress, daily streaks, daily quests, incubation timers, breeding cooldowns.
2. A collection to finish: the Duckdex across families, rarities, evolution stages, and mutations.
3. Growth that never fully stops: farm level, Duck Legacy (prestige), mastery, infinite quest levels.
4. Self-expression: farm decorations, cosmetic duck accessories, a farm worth showing off.
5. Playing together: farm visits, gifting, farm likes, leaderboards, event community goals.
6. Seasonal freshness: four seasonal events per year plus small weekend events.
7. The cozy promise: `Duck` never punishes. Ducks never die, starve, run away, or lose levels. Missed days pause progress; they do not destroy it. Needs are opportunities for XP, not threats.

The cozy promise is a hard design rule. Any proposed mechanic that punishes absence or neglect must be redesigned as a missed bonus instead of a loss.

## Comprehension Guardrails

The retention pillars answer "why return"; these guardrails answer "can a new player understand the game." They were approved 2026-06-12, when the system count made complexity the project's top risk, and they bind every phase the same way the cozy promise does.

1. Feature Unlock Ladder: fresh profiles do not see every system at once. Features reveal per player as their progress earns them, so the farm starts as the simple egg-and-coin game and grows one system at a time, no matter how much content the live game has. Starter ladder (V0 ships in Phase 4): Collect, Sell, and counters from the start; quest tracker and `Upgrades` after the first sell; `Shop` with its guide step; `Minigames`, `Visit`, daily streak, and daily quests after the guide completes. Each later phase defines its own rung in its design pass (planned examples: Duckdex appears with the Starter Choice, the Hatchery after the first egg is obtained, Pond Games after owning `3` ducks, Training Camp after the first match, Decorate and Photo Mode at farm level `2`). Rules: unlock state derives from existing server-owned progress wherever possible instead of new save fields, nothing ever re-locks once seen, and existing profiles keep everything they already had.
2. No system ships untaught: every phase must ship the first-use guide step or tooltip for what it adds, and this is part of every phase's exit criteria even where not restated. The guide grows with the game so a player who joins after Phase 12 still learns one system at a time, in ladder order.
3. UI surface budget: the farm screen is capped at `3` primary action buttons and `6` always-visible secondary controls. When a new system would exceed the cap, it consolidates into a hub instead of adding a button (first hub consolidation is planned with Phase 6, when the Hatchery arrives). Special currencies are capped at the four already planned (`Star Grain`, farm points, `Festival Tickets`, `Legacy Feathers`); any proposal needing a fifth must reuse one of these instead.

## Phase 1: Foundation

Status: `Done`

- Rojo and Aftman setup, documentation and AI-agent workflow, project structure, coding standards.
- 2D UI-first simulator direction documented in `docs/GAME_BRIEF.md`.
- Smallest first prototype scope defined.

## Phase 2: Prototype

Status: `Done`

- Smallest playable duck egg loop: eggs, coins, collect, sell, Egg Value upgrade, Buy Duck.
- Autonomous duck presentation: idle bobbing, short wandering, reactions.
- Tested in Roblox Studio with the Rojo plugin; decisions recorded in `docs/GAME_BRIEF.md`.

## Phase 3: Core Systems

Status: `Done`

- Server-authoritative gameplay for the full current loop: collect, sell, Egg Value V1 (five tiers), Buy Duck, Shop V0 (Duck Feed, Premium Feed, Treat, Pillow, Toy), duck care needs (pet, hungry, sleepy, dirty, thirsty, bored), Duck Level/Progress V0, Duck Names/Profile/Rename V0, Quest V0-V3 (nine repeatable quests), Weather/Event V0-V2 (four weather states), Guide/Tutorial V0, Minigames V0 (Egg Catch with server-backed rewards), Daily Check-in V0, Farm Visit V0/V1.
- Save Data V0 at `schemaVersion = 6` per `docs/SAVE_DATA_DESIGN.md`.
- Security test cases in `docs/SECURITY_TESTS.md`.

## Phase 4: Retention Foundations and First Art Pass

Status: `Next`

Goal: make one day of play feel complete and make tomorrow worth coming back for, before adding new collection content.

Retention pillars: return tomorrow, cozy promise.

Features:

- Offline Progress V0: while a player is away, ducks keep producing at `50%` of the online rate, capped at `2` hours of accrual. On join, a `Welcome back!` summary shows eggs earned while away. Requires saving a last-seen timestamp. No offline care requests, quests, weather, or minigame progress.
- Daily Streak V1: extend Daily Check-in V0 into a 7-day visible streak track with escalating rewards (starter: `20`, `30`, `40`, `50`, `60`, `80` coins, then `Treat x1` plus `100` coins on day 7, repeating). Cozy rule: missing `1` to `3` days pauses the streak at its current day; missing more than `3` days resets it to day 1.
- Daily Quests V0: `3` rotating daily goals per UTC day on top of the existing infinite quests, drawn from existing tracked actions (collect, sell, help, minigame, shop). Each grants coins plus one small item; completing all three grants a daily bonus chest of coins (later: a Speckled Egg once Phase 6 ships).
- Badges V0: first Roblox badges for kid-visible milestones (first duck bought, first rename, `100` eggs collected, first level `5` duck, 7-day streak).
- Comeback Gift V0: players returning after `7` or more days away receive a small care package on load (`Duck Feed x2`, `Treat x1`; a `Speckled Egg x1` joins the package once Phase 6 ships). Framed as "the ducks missed you", never as recovered losses, per the cozy promise. Derived from the same last-seen timestamp as Offline Progress V0.
- Settings V0: a small settings screen with music and sound toggles and a reduced-motion option.
- Feature Unlock Ladder V0: implement the comprehension guardrail's starter ladder for fresh profiles (Collect/Sell first, quest tracker and `Upgrades` after the first sell, `Shop` with its guide step, `Minigames`/`Visit`/streak/dailies after the guide completes), deriving unlock state from existing server progress and never re-locking anything. Existing profiles keep all features.
- Audio V0: one cozy ambient music loop and core sound effects (collect, sell, buy, level-up, care, hatch placeholder, button tap). Direction: soft acoustic and ambient pond sounds; exact tracks need approval before import.
- First approved art pass: replace remaining placeholder UI targets (shop background, basket/catcher, need icons, mood portraits, UI kit) with one approved variant each per the existing one-variant rule.
- Burn down the existing play-test backlog in `docs/TASKS.md`.

Save data: `schemaVersion = 7` (last-seen timestamp, streak count and last claim day, daily quest day stamp and slots, badge grant flags, settings).

Assets: shop background, need/mood icons, UI kit, basket, streak calendar UI mockup, badge icon sheet, audio set.

Exit criteria: a new player can play a full first session with no placeholder-feeling screens, sees a streak and daily goals, returns the next day to offline eggs and a streak advance. This is the soft launch candidate.

## Phase 5: Collection Update (Duck Families and the Duckdex)

Status: `Planned`

Goal: turn ducks from interchangeable units into a collection.

Retention pillars: collection, expression.

Features:

- Duck base families per the locked visual rule set (family = body shape, silhouette, and core palette). Starter lineup of `6` families: `Classic Yellow` (Common, the existing duck), `Mallard Green` (Common), `Choco Brown` (Uncommon), `Snowy White` (Uncommon), `Blossom Pink` (Rare), `Twilight Blue` (Epic). `Golden` (Legendary) is reserved as hatch-only for Phase 6.
- Rarity tiers: `Common`, `Uncommon`, `Rare`, `Epic`, `Legendary`. Rarity carries a small egg-output bonus so collecting matters without breaking balance: `+0%`, `+5%`, `+10%`, `+20%`, `+35%`. Family stays the visual identity; rarity stays the stat identity.
- Shop V1: Buy Duck becomes family-aware. Common families purchasable with coins at scaled prices; Rare and above are intentionally hard or impossible to buy directly so Phase 6 hatching has a job.
- Starter Choice Duck: when the guide completes (or on first post-Phase 5 load for existing profiles), the player picks `1` free duck from `3` fixed starter cards: `Mallard Green`, `Choco Brown`, `Snowy White`. One-time per profile. Choice builds attachment faster than a random grant, and the Duckdex starts at two families immediately.
- Early variety guarantee: on top of the starter choice, the second buyable family (`Mallard Green`) is priced so a fresh player can afford it within their first one or two sessions. The collection hook must set immediately; if a player's third session is still all-yellow, Phase 5 has failed regardless of how good the Duckdex looks.
- Mystery Duck Box V0: a reward-only item that is never sold for coins or Robux. Opening shows `3` rarity-weighted ducks side by side (starter odds `60/30/10` Uncommon/Rare/Epic, displayed on the box) and the player keeps exactly `1`. The pick keeps the moment kid-fair and agency-driven instead of a pure gacha. Sources: the first-ever day-7 streak completion (one-time), the Duckdex `50%` collection reward, seasonal event finales (Phase 11, event-themed), and the first Legacy (Phase 12). The presentation is a cozy gift moment, not a casino chest.
- Duckdex V0: a collection book screen showing every family as a card (silhouette until first owned), owned count, rarity, and a collection percent. Collection rewards at `25%`, `50%`, `75%`, `100%` (coins, Treats, and one exclusive decoration at `100%`).
- Existing saved ducks migrate as `Classic Yellow`.

Save data: `schemaVersion = 8` (per-duck family id and rarity, Duckdex discovered map, collection reward claims, starter-choice completion flag, Mystery Duck Box inventory).

Assets: duck family lineup sheet, per-family asset sets (idle, sleep, happy, portrait), rarity frames and tags, Duckdex screen mockup, Mystery Duck Box and starter-choice screen mockup.

Exit criteria: a player can own ducks from at least `4` families, see them clearly differ on the farm at gameplay sprite size (family art is reviewed scaled down, not just at full resolution), own a second family within their first sessions, open the Duckdex, and want the missing cards.

## Phase 6: Hatching Update (Eggs and the Incubator)

Status: `Planned`

Goal: make acquiring new ducks an event, not a button press, and create natural return timers.

Retention pillars: return tomorrow, collection.

Features:

- Egg types as inventory items: `Plain Egg` (Common/Uncommon families), `Speckled Egg` (Uncommon/Rare, small Epic chance), `Golden Egg` (Rare/Epic, Legendary chance), plus `Festival Egg` reserved for events.
- Incubator V0: one incubator slot on the farm (up to `3` slots unlocked later by farm level in Phase 8). Hatch timers create return visits: Plain `5` minutes, Speckled `30` minutes, Golden `4` hours. Hatching plays a short wiggle-crack-reveal moment.
- Sources: eggs are bought with coins or earned from quests, daily bonus, minigames, and events. Hard rule: eggs and their odds are never sold directly for Robux. This keeps the game outside paid-random-item territory and keeps hatching kid-fair.
- Odds are shown in the UI before purchase or hatch (starter: Speckled `60/30/9/1` percent for Uncommon/Rare/Epic/Legendary-excluded; Golden `0/55/35/10`). Pity counters guarantee a Rare or better within `8` Speckled hatches and a Legendary within `10` Golden hatches.
- Buy Duck remains for Common families; hatching becomes the main path to Rare and above.
- First hub consolidation per the UI surface budget: the Hatchery joins the farm without adding a permanent button beyond the cap — incubator slots live on the farm scene itself (nest area), and secondary activities begin consolidating into a single hub control so the farm stays readable as systems accumulate.

Save data: `schemaVersion = 9` (egg inventory by type, incubator slot states with finish timestamps, pity counters).

Assets: egg type icon sheet, incubator and nest stages sheet, hatch reveal background and glow effects.

Exit criteria: hatching feels like the best moment in the game, odds are visible, pity works, and players plan sessions around hatch timers. This is the full launch candidate.

## Phase 7: Evolution Update

Status: `Planned`

Goal: give long-owned ducks a future, so leveling stays meaningful past the early game.

Retention pillars: growth, collection.

Features:

- Duck level cap raises from `5` to `10`.
- Daily duck XP pacing: each duck can gain up to `150` XP per UTC day from all sources (care, feed, treats, and later Pond Games). At the cap, care still clears requests and grants quest progress, but XP waits for tomorrow behind a gentle `happily full for today` message, and Treat use on a capped duck is blocked before the item is consumed so nothing is wasted. This keeps coin-bought treat-pumping from trivializing evolution pacing and, once Phase 7B ships, from producing same-day overpowered battle ducks.
- Evolution stages within a family line per the locked visual rule set: Stage 1 (base), Stage 2 `Radiant` available at level `5`, Stage 3 `Royal` available at level `10`.
- Evolution is deterministic and player-triggered: reaching the level makes the `Evolve` button available in Duck Profile; evolving costs `Star Grain`, a new earnable item from quests, daily bonuses, and minigame thresholds (starter: `3` Star Grain for Stage 2, `8` for Stage 3). No random evolution failure, per the cozy promise.
- Evolution plays a short skippable celebration cutscene (UI scene, same-place).
- Each stage adds `+25%` egg output for that duck, multiplicative with level and rarity bonuses.
- Duckdex V1: family cards gain stage rows; collection percent now counts stages.

Save data: `schemaVersion = 10` (per-duck stage, Star Grain inventory, raised level cap validation, per-duck daily XP counter and day stamp).

Assets: per-family evolution stage sheets, evolution celebration background, Star Grain icon.

Exit criteria: a level-capped duck has a visible next goal, evolution feels like a celebration, the first Stage 2 evolution lands within days (not weeks) for an engaged player with Star Grain flow tuned to that target, and farm output math stays server-validated and readable in Duck Profile.

## Phase 7B: Pond Games Update (Duck Battles V0)

Status: `Planned` (inserted 2026-06-12; lettered so existing phase references stay stable)

Goal: give the collection a purpose beyond production — an optional, friendly battle mode where the ducks a player raised, evolved, and collected get to shine.

Retention pillars: collection, growth (and together, once V1 adds async challenges).

Features:

- Pond Games framing: battles are friendly duck contests at the pond, never violence. Moves are splashes, quacks, gusts, and snacks. A duck that runs out of energy is `tired out` (sits with dizzy sparkles) and is cheerful again right after the match. Per the cozy promise: losing costs nothing — no entry fees, no item loss, no lasting effect on any duck — and participation always pays a small reward.
- Battle format V0: `3v3` turn-based PvE. The player fields a team of `3` owned ducks; turn order comes from Speed; on each duck's turn the player picks one of its `3-4` skills — no auto basic-attack loop, because per-turn choice is what makes it a game. Target match length `1-3` minutes. Fully server-resolved: the client sends a skill choice, the server validates it and computes the outcome, reusing the existing remote-action pattern.
- Classes V0, assigned by family so collection depth is battle depth: `Guard` (sturdy protector: Mallard Green), `Splasher` (direct splash attacker: Classic Yellow, Golden), `Quacker` (sound and charm tricks: Choco Brown, Twilight Blue), `Helper` (cheers, snacks, shields: Snowy White, Blossom Pink). Every class is fielded by a Common or Uncommon family, so free players can build any composition.
- Skills V0: `4` skills per class, `16` total. Each duck starts with its class skill `1`, unlocks skill `2` at duck level `3`, skill `3` at level `5`, and skill `4` at evolution Stage 2. Skills are fixed per class in V0; loadout customization is a V1 candidate, not a V0 requirement.
- Duck stat block V0: every duck gets four visible, kid-readable stats — `Heart` (toughness), `Splash` (move strength), `Pace` (turn order), and `Spirit` (power of heals, shields, and charms, so Helpers and Quackers have their own scaling). Base values derive from class curve, duck level, rarity, and evolution stage, so existing progression stays the foundation and there is no second leveling grind. A mutation adds a flat `+5%` to one class-relevant stat. Stats affect Pond Games only: egg production stays driven by level, rarity, and stage, so the farm economy is untouched by battle balance.
- Battles feed leveling: each Pond Tour match grants duck XP to all three participating ducks (starter `+15` per win, `+5` per loss because trying counts), inside the same daily XP pacing cap defined in Phase 7. Battle level-ups count toward the `Level up ducks` quest like any other level-up.
- Training Camp V0: send a duck to camp to train one chosen stat. Sessions are `4h` (+`2`), `8h` (+`5`), or `24h` (+`12`) with coin fees (starter `25/40/80`) and one training slot at V0. A duck at camp is fully away, in visible cozy stasis: hidden from the farm, no egg production (including offline accrual), no care or treats, no battles, and later no breeding — a real now-versus-later choice. Cancelling returns the duck instantly with no gain and a full fee refund, so no choice is ever a loss. Trained bonuses are permanent and capped at `+20` per stat per duck at V0; the camp slot shows a timer and the duck sends a little postcard at the halfway mark.
- Pond Tour V0: a chain of themed AI rival flocks with rising difficulty, one-time first-clear rewards (coins, Star Grain, an egg at milestone stages), and small repeatable rewards. Battles stay an optional side mode: the farm loop never requires battling, and battling never out-earns the farm.
- Hard rules: battle power is never sold (no paid stats, skills, or boosts — added to the product plan never-sell list); no live real-time PvP in any version currently planned; challenges are always opt-in, so no player can be battled unwillingly.

Pond Games V1 (later, anchored to Phase 10 social): friendly async challenges against saved snapshots of other players' teams, both sides rewarded, still no live-sync PvP.

Save data: battle fields land in whichever schema version is current when this ships: saved team duck ids, Pond Tour progress, first-clear reward flags, per-duck trained stat bonuses, and the active training session (duck id, stat id, server-derived finish timestamp validated against forged or future-dated values).

Assets: Pond Games battle scene mockup, battle skill and class icon sheet, Training Camp scene and stat icons; duck poses reuse the existing family asset sets.

Exit criteria: a player can take three ducks they care about into a two-minute friendly contest, make a meaningful skill choice every turn, lose without losing anything, come away wanting to level, train, or evolve a specific duck for their team, and a duck sent to camp comes back meaningfully stronger without the farm loop ever requiring it.

## Phase 8: Farm Expansion Update (Zones, Farm Level, Decorations)

Status: `Planned`

Goal: let the farm itself grow and become the player's own place.

Retention pillars: growth, expression.

Features:

- Farm Level V0: farm points accrue from collecting, quests, care, and hatching. Farm level unlocks capacity, zones, incubator slots `2` and `3`, Training Camp slot `2`, and decoration slots. Starter curve: level `N` needs `100 * N` farm points.
- Zones as UI scenes consistent with the 2D UI-first rule: `Pond` (start), `Meadow` (farm level `5`), `Orchard` (farm level `10`). Each zone raises visible duck capacity (`10` → `15` → `20`) and adds its own background and decoration anchors. A simple zone switcher lives on the farm screen.
- Decorations V0: decorations are inventory items placed into predefined anchor slots per zone (no free dragging in V0). Starter set of `8` decorations (examples: lily pad cluster, flower bed, lantern, bench, birdhouse, straw bale, pond fountain, picket flower fence) purchasable with coins; the Duckdex `100%` decoration and future event decorations slot in here.
- Nest upgrade visuals tied to farm level so progress is visible at a glance.
- Photo Mode V0: a camera button hides the HUD and lets the player frame their farm and ducks, with nearby ducks briefly turning to pose. `4` starter frames and `8` text-free stickers (hearts, sparkles, sun, blank speech bubble, and friends), all earnable-only. Capture uses the platform capture flow so screenshots land in the player's Roblox gallery for sharing, with a small corner game stamp so every shared photo is soft marketing. Visitors can use Photo Mode on farms they visit. Seasonal frames join event rewards in Phase 11; verify capture-service capabilities against official Roblox docs in this phase's design pass.

Save data: `schemaVersion = 11` (farm level and points, unlocked zones, decoration inventory, placed decoration slots; Photo Mode V0 needs no save fields while all frames and stickers are starter content).

Assets: Meadow background, Orchard background, decoration icon sheet, nest upgrade stages, photo frame and sticker sheet.

Exit criteria: two farms at different farm levels look meaningfully different, a visitor can tell effort went into a decorated farm, and Photo Mode makes that farm worth sharing.

## Phase 9: Mutation and Breeding Update

Status: `Planned`

Goal: complete the collection depth and add the longest-cycle return timer.

Retention pillars: collection, return tomorrow.

Features:

- Mutations per the locked visual rule set: overlay traits that never replace family identity. Launch set of `6`: `Sparkle`, `Marble`, `Snowdust`, `Honey`, `Tuxedo`, `Star`. Mutations are cosmetic-first plus a flat `+10%` egg output regardless of which mutation (so no mutation is the wrong one to love).
- On-farm legibility rule: every mutation includes one small always-visible tell (a glint or bold accent) that stays identifiable at farm sprite size, with richer detail in profile. Visitors must be able to spot a mutated or evolved duck at a glance; show-off value is half of what makes collection retain.
- Sources: small chance on Golden and Festival hatches (starter `5%`), and breeding as the main source.
- Breeding V0: choose `2` owned Stage 2+ ducks; after a `24` hour breeding timer, receive a `Family Egg` that hatches into one parent's family (starter split `60/40` toward the higher-rarity parent). Mutation inheritance: `25%` chance to pass a parent's mutation, `5%` chance of a fresh random mutation, with a pity guarantee of some mutation within `12` breedings. Each duck has its own breeding cooldown (`24` hours). Breeding costs coins (starter `500`).
- Duckdex V2: mutation page; collection percent now includes mutations seen per family.
- No duck is ever consumed, lost, or downgraded by breeding, per the cozy promise.

Save data: `schemaVersion = 12` (per-duck mutation id, breeding timers and cooldowns, breeding pity counter).

Assets: mutation overlay sheet, breeding nursery scene background, Family Egg icon.

Exit criteria: breeding gives committed players a daily ritual, every mutation is identifiable at a glance on the farm via its tell and reads richly in profile, and the Duckdex now has real long-term depth.

## Phase 10: Social and Community Update

Status: `Planned`

Goal: make other players a reason to return, safely.

Retention pillars: together, expression.

Features:

- Gifting V0: send `1` gift per friend per UTC day from a server-owned whitelist (Duck Feed, Treat, Pillow, Toy, Plain Egg; never coins, never rare eggs). Both sender and receiver get a small thank-you bonus so gifting is never a loss.
- Farm Likes V0: each visitor can leave `1` like per farm per UTC day. Likes feed a weekly `Cozy Farm` leaderboard and a lifetime count on the farm sign.
- Leaderboards V0: lifetime eggs collected, Duckdex percent, weekly likes. Server-owned via OrderedDataStore, with display names filtered per platform rules.
- Visitor Book V0: the last `10` visitors and their likes, shown on the farm sign.
- Offline farm snapshots: viewing a saved read-only snapshot of an offline friend's farm. This still requires its own DataStore snapshot, privacy, and permission design doc before implementation, as previously recorded.
- Profile titles from collection and mastery milestones (cosmetic text only).

Save data: `schemaVersion = 13` (gift cooldowns, like counters, visitor book entries, titles), plus separate OrderedDataStore keys for leaderboards and a separate snapshot store design.

Assets: leaderboard and visitor book UI mockups, farm sign, gift box icon.

Exit criteria: visiting a farm gives both players something (a like, a gift, an idea to copy), and leaderboards celebrate cozy goals rather than pure grinding.

## Phase 11: Events and Live-Ops Update

Status: `Planned`

Goal: a repeatable event framework so the game stays fresh on a calendar, not just on a roadmap.

Retention pillars: seasonal freshness, together.

Features:

- Event framework V0: server-owned event definition (id, dates, theme, quest set, currency, shop stock), an event banner on the farm, event quests beside dailies, `Festival Tickets` as a per-event earnable currency, and an event shop.
- Four seasonal events per year: `Spring Bloom`, `Summer Splash`, `Autumn Harvest`, `Winter Frost`. Each brings one limited Festival duck family (hatched from Festival Eggs earned via event quests), one decoration set, one weather/visual touch (for example snow overlay in winter), and returns in future years so missing one is never permanent, per the cozy promise.
- Weekend mini-events: small `2`-day boosts (double minigame first-win, bonus care XP) on a rotating schedule.
- Minigames V1: two new minigames, `Bread Toss` (timing/accuracy arc throws to swimming ducks) and `Lily Hop` (rhythm-lite hopping across lily pads), built on the Egg Catch server-validated reward pattern. Minigame of the day grants a doubled first-win reward.
- Quest V4: event quest category wired into the existing quest framework.

Save data: `schemaVersion = 14` (per-event progress, tickets, claimed stock, owned event items; event definitions themselves stay server config, not save data).

Assets: seasonal background set (four), event duck concepts per season, event decoration sheets, Bread Toss and Lily Hop scene mockups, ticket icon.

Exit criteria: an event can be configured, run, and ended without code changes beyond content definition, and players who missed an event know it will return.

## Phase 12: Endgame (Duck Legacy and Mastery)

Status: `Planned`

Goal: an honest endgame loop for finishers, so the most invested players always have a horizon.

Retention pillars: growth, collection, expression.

Features:

- Duck Legacy V0 (prestige): available at farm level `20`. Performing a Legacy resets coins, eggs, egg inventory, Egg Value tier, farm level, decorations placement (inventory is kept), and all ducks except `1` chosen `Legacy Duck`, which keeps its family, stage, mutation, and gains a permanent visible `Legacy Mark`. The Duckdex, mutations seen, cosmetics, event items, badges, titles, and streaks are never reset, per the cozy promise.
- Each Legacy grants `Legacy Feathers` based on farm level beyond `20`. Feathers buy permanent boosts in a Legacy shop: global egg output (starter `+10%` per tier), offline cap extension (`+1` hour per tier up to `8` hours), hatch speed (`-10%` per tier up to `-50%`), and starting coins after Legacy.
- Golden Pond: the farm's pond turns visibly golden at Legacy `1`, with further subtle flourishes at Legacy `3` and `5`. Legacy count shows on the farm sign and in the visitor view.
- Legacy duck family: an exclusive `Legacy` family unlockable at Legacy `3` (the only family gated behind prestige).
- Mastery V0: per-family lifetime XP earned by that family's ducks grants mastery ranks (Bronze, Silver, Gold) with cosmetic titles and a tiny `+2%` family egg bonus per rank.
- Prestige quests: a small infinite quest set that only counts post-Legacy progress, keeping the quest framework alive at endgame.

Save data: `schemaVersion = 15` (legacy count, feathers, owned legacy boosts, mastery XP per family, legacy duck mark).

Assets: Golden Pond background variant, Legacy Feather and mastery medal icon sheet, Legacy Mark overlay.

Exit criteria: a player who has finished the Duckdex and maxed a farm still has a clear, satisfying loop (Legacy, mastery, events) and a farm that shows off that history.

## Monetization Direction (Planned Waves)

Status: `Planned in docs/PRODUCT_PLAN.md`

The full monetization plan, including concrete products, Robux starter prices, storefront rules, implementation requirements, and revenue expectations, lives in `docs/PRODUCT_PLAN.md`. Summary:

- Wave 1 ships with full launch (end of Phase 6): `Supporter Pass` gamepass (`199` Robux), `Cozy Basics Accessory Pack` (`99`), `Starlight Garden Decoration Theme` (`149`). Requires the cosmetic accessory layer.
- Wave 2 ships with Phase 8: `Velvet Family` cosmetic-only gamepass (`399`), more accessory packs and a seasonal decoration theme.
- Wave 3 ships with Phase 11: one cosmetic event bundle per seasonal event (`199-249`), returning yearly with its event.
- Hard rules (binding for all waves): cosmetic-first, no paid random eggs or loot boxes, no premium currency, no pay-to-win, no trading of paid items, calm storefront with no purchase prompts in the play loop, and everything gameplay-relevant stays earnable by play.
- Each wave still needs a one-line user confirmation of products and prices before it ships, plus a security review of the purchase and grant paths.

## Live-Ops Cadence (Post-Launch)

Once Phase 6 ships, target this steady rhythm alongside phase development:

- Weekly: one small touch (weekend mini-event, new decoration, balance tweak, or quest variant).
- Monthly: economy and retention review against the pillar list; rebalance starter numbers where play data disagrees with them.
- Quarterly: one seasonal event (Phase 11 framework) and one roadmap phase milestone.
- Continuous: play-test backlog burn-down in `docs/TASKS.md`, security review for every new remote or reward path, doc updates per `docs/DOC_UPDATE_POLICY.md`.

## Release Milestones

- Soft launch: end of Phase 4 (polished core loop, retention foundations, first art pass).
- Full launch: end of Phase 6 (collection plus hatching is the marketable hook).
- Major update marketing beats: Phases 7, 9, 11, and 12 each carry a named update (`Evolution Update`, `Breeding Update`, `Festival Update`, `Legacy Update`).
- Release preparation checklist for each milestone: security and remote validation review, multiplayer behavior test, performance on low-end mobile, DataStore failure handling, `docs/CHANGELOG.md` release notes.
