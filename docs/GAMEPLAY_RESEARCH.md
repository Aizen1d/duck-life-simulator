# Gameplay Research

Use this file for research notes and recommendations that could improve `Duck`.

The current direction is a 2D UI-first duck life simulator. Farming is the first core activity. Player actions use UI controls, while ducks can animate autonomously. User-controlled movement and click-to-move are not planned for this game unless the user explicitly reverses that decision.

Research should produce recommendations, not automatic scope changes. Ideas become approved only after the user confirms them and the relevant docs are updated.

## Research Goals

- Improve the egg, coin, upgrade, and duck progression loop.
- Find mechanics that make ducks feel alive without adding player-controlled movement.
- Identify event ideas such as sunny, rainy, surprise, mood, visitor, or seasonal events.
- Compare similar simulator, idle, pet, farming, and life-sim patterns.
- Keep v1 small while preserving room for future systems.

## Research Rules

- Do not copy another game's exact economy, UI, names, assets, or monetization.
- Separate observed patterns from recommendations.
- Prefer mechanics that fit Cozy Pond Farm and duck life simulation.
- Avoid recommending monetization, trading, data persistence, or social systems without extra review.
- Check official Roblox docs when a mechanic touches platform services, policies, DataStore, monetization, badges, groups, text, or social features.

## Recommendation Buckets

Use these buckets for every researched idea:

- `V1 Candidate`: small enough for the first prototype.
- `Early Expansion`: good after the first loop works.
- `Later System`: valuable but too large for early development.
- `Avoid For Now`: does not fit, adds too much risk, or depends on missing systems.

## Evaluation Criteria

Rate each idea from 1 to 5:

- Fun: Does it make the duck life loop more satisfying?
- Fit: Does it match Cozy Pond Farm and the no player-controlled movement constraint?
- Simplicity: Can it be built without derailing v1?
- Retention: Does it give players a reason to return?
- Risk: Does it add balance, technical, platform, or scope risk?

## Research Entry Template

```text
Date:
Research topic:
Source or reference:
Observed pattern:
Duck adaptation:
Recommended bucket:
Scores:
- Fun:
- Fit:
- Simplicity:
- Retention:
- Risk:
Decision:
Follow-up tasks:
```

## Current Research Questions

Earlier questions about variation lines, evolution, mutation, breeding, daily goals, and the first minigame are answered by the approved long-term roadmap (`docs/ROADMAP.md`, 2026-06-11). Current open questions:

- Which Phase 4 retention numbers need the first rebalance after soft launch: the offline `50%` rate and `2` hour cap, streak reward sizes, or daily quest rewards?
- Do the rarity egg-output bonuses (`+0/5/10/20/35%`) stay healthy once players own several Epic ducks, or do Common families stop feeling worth keeping?
- Which hatch timer lengths feel like anticipation instead of friction for a young cozy-game audience: the starter `5m/30m/4h`, or shorter?
- How should Festival duck families compare with the Legacy-gated family so both stay special?
- What community goals could Phase 11 events use without enabling grief or freeloading?
- Should decorations stay anchor-slot only, or is free placement worth the complexity after Phase 8 is play-tested?
- What Legacy pacing lets a committed player reach the first prestige within weeks, not months?

## Reviewed Recommendations

### Duck Mood / Care V1

Date: 2026-04-15
Research topic: Duck mood and care as the next small life-sim mechanic
Source or reference: Project direction, current prototype loop, user approval
Observed pattern: Pet and life-sim games often add a simple care interaction before deeper needs, weather, or event systems.
Duck adaptation: Add a server-authoritative `Care` action that validates a selected duck index, changes only that duck mood from `Content` to `Happy` for a short time, and shows client feedback. V1 lets the server track real individual ducks and assign one visible duck to request care with a `Pet me?`, `Hungry?`, `Sleepy?`, or `Dirty?` prompt. It does not affect egg production, coins, upgrades, or weather yet.
Recommended bucket: `V1 Candidate`
Scores:
- Fun: 3
- Fit: 5
- Simplicity: 5
- Retention: 2
- Risk: 1
Decision: Approved for implementation as feedback-only V1. Keep mood out of economy balance until the base loop is play-tested.
Follow-up tasks: Play-test the care request timer, Studio `Need` tester action, requested duck prompt, duck tap/click care bubble, mood feedback, cooldown, and mobile layout. Later, design expanded request types beyond the current pet/hungry/sleepy/dirty set before making deeper individual duck needs.

### Duck Level/Progress V0

Date: 2026-04-16
Research topic: Lightweight individual-duck progression after care and hunger
Source or reference: Project direction, current prototype loop, user approval
Observed pattern: Pet and simulator games often make individual animals feel more valuable by showing visible progress from repeated care actions before tying that progress to rewards.
Duck adaptation: Add server-owned level and XP per duck. `Care` grants `25` XP, `Feed` grants `35` XP, `Rest` grants `25` XP, level-ups happen every `100` XP up to level `5`, and selected-duck bubbles show progress. The current approved reward is a small egg-production bonus: each duck level above `1` adds `+10%` egg output for that duck. Level and XP now persist through Save Data V0.
Recommended bucket: `V1 Candidate`
Scores:
- Fun: 3
- Fit: 5
- Simplicity: 4
- Retention: 3
- Risk: 2
Decision: Approved for implementation in the first pass, then expanded with a small egg-production reward. Level and XP are included in Save Data V0; larger level rewards remain undecided until the loop is play-tested.
Follow-up tasks: Play-test level-bar readability, level-up feedback, per-duck XP targeting, max-level behavior, and confirm higher-level ducks produce more eggs at the approved `+10%` per-level bonus.

### Duck Profile, Names, and Rename V0

Date: 2026-04-16
Research topic: Lightweight individual-duck profile inspired by Planet Zoo animal profiles
Source or reference: Planet Zoo official guide/search result for animal welfare/profile scope, Planet Zoo 1.1 official update note on family info panels, community references for editable animal names, and Roblox Creator Docs text-filtering guidance.
Observed pattern: Animal-management games often use an animal information panel as a central place for individual identity and management context. Those panels can include name, welfare/status, social or family context, genetics, and other detailed simulation data, but that amount of information is too heavy for the current Duck prototype.
Duck adaptation: Start with a small profile that supports identity and current status only: generated duck name, level/progress, mood or current need, and Rename V0. Duck Names V0 gives new ducks random generated names from a large curated `PrototypeConfig.duckNames` pool and rejects duplicates in the player's owned duck list by selecting an unused name or falling back to numbered `Duck N` names. Rename V0 uses the profile panel, validates `2` to `16` character names, rejects case-insensitive duplicates within the player's current duck list, filters submitted text on the server, and only replicates the filtered display name. Deeper fields such as age, traits, family tree, mutation history, breeding history, favorite food, or long-term stats should wait until those systems exist.
Recommended bucket: `V1 Candidate`
Scores:
- Fun: 4
- Fit: 5
- Simplicity: 4
- Retention: 3
- Risk: 2
Decision: Duck Names V0 is implemented as generated names shown in the selected-duck bubble and persisted by Save Data V0. Duck Profile V0 is implemented as a lightweight selected-duck panel opened from the bubble's `Profile` button for name, level/XP, mood, need, care readiness, and Rename V0. Rename V0 is implemented as server-validated, server-filtered profile editing.
Follow-up tasks: Review the large curated generated name pool, play-test Duck Profile/Rename V0 readability and error messaging, and verify names/profiles reload through Save Data V0.

### Quest V0

Date: 2026-04-20
Research topic: Repeatable goals for the first farming loop
Source or reference: Project direction and user-approved request for infinite quests saved to DataStore
Observed pattern: Simulator and idle games often use simple repeatable goals to give short-term direction while the main resource loop continues.
Duck adaptation: Add three server-owned repeatable quests tied to existing actions: collect eggs, sell eggs, and help ducks. Each quest has its own level, progress, target, and coin reward. Completion carries overflow progress, grants coins, advances that quest level, and persists in the player save.
Recommended bucket: `V1 Candidate`
Scores:
- Fun: 3
- Fit: 4
- Simplicity: 4
- Retention: 4
- Risk: 2
Decision: Approved and implemented as Quest V0. Keep rewards to coins only for now, and avoid daily quests, rerolls, badges, streaks, premium rewards, or special quest art until the base loop is tested.
Follow-up tasks: Play-test quest progress for collect, sell, and help actions; verify completion rewards and overflow progress; stop/rejoin to confirm quest levels and progress persist.
### Weather/Event V0

Date: 2026-04-20
Research topic: Small weather event layer for the duck life loop
Source or reference: Project direction and user-approved sunny/rainy event idea
Observed pattern: Farming and pet-life games often use lightweight weather to make repeated loops feel less static before adding deeper event systems.
Duck adaptation: Add server-owned session weather with `Sunny` and `Rainy`. Rainy weather adds a soft UI-only farm overlay and makes `Sleepy?` duck requests more likely. The first pass avoids production bonuses, save-data scope, event items, or new art requirements.
Recommended bucket: `Early Expansion`
Scores:
- Fun: 3
- Fit: 5
- Simplicity: 4
- Retention: 2
- Risk: 2
Decision: Approved and implemented as Weather/Event V0. Weather is session-only, starts sunny, rolls about every `90` seconds, has a `35%` rainy roll chance, and can be toggled with a Studio-only tester button.
Follow-up tasks: Play-test the weather badge, rainy overlay readability, Rain/Sun tester toggle, sleepy request frequency during rain, mobile layout, and confirm weather does not persist or change economy balance.

### Long-Term Retention Plan (Roadmap Phases 4-12)

Date: 2026-06-11
Research topic: Full retention-focused content plan from the current loop through endgame
Source or reference: Genre-standard patterns across cozy farming sims, pet-collection sims, and idle games (collection books, hatching with timers, daily streaks, offline accrual, seasonal events, prestige loops), filtered through this project's constraints: 2D UI-first, no player movement, kid-safe, no copied economies.
Observed pattern: Long-retention sims layer four loops at different time scales: a minutes-scale session loop (collect/sell/care), an hours-scale return loop (incubation, offline accrual), a days-scale habit loop (streaks, dailies, breeding cooldowns), and a weeks-to-months aspiration loop (collection completion, seasonal events, prestige). Games that punish absence (decay, death) retain worse with young cozy audiences than games that frame absence as a paused bonus.
Duck adaptation: The approved roadmap maps one phase per pillar: Phase 4 habit layer, Phases 5-7 collection and growth depth, Phase 8 expression, Phase 9 long-cycle timers, Phase 10 social proof, Phase 11 seasonal freshness, Phase 12 endgame prestige. A hard `cozy promise` rule forbids punishment mechanics anywhere in the plan.
Recommended bucket: `Later System` (phased; Phase 4 is the next implementation slice)
Scores:
- Fun: 4
- Fit: 5
- Simplicity: 2
- Retention: 5
- Risk: 3
Decision: Approved 2026-06-11 as direction with starter numbers in `docs/ROADMAP.md`. Each phase still gets its own design pass, security review, and play-test before implementation.
Follow-up tasks: Implement Phase 4 features; revisit starter numbers monthly against play data per the live-ops cadence.

### Offline Progress V0

Date: 2026-06-11
Research topic: Offline egg accrual as the strongest single return-tomorrow hook
Source or reference: Idle/sim genre patterns; Roblox DataStore timestamp practices (server time via `os.time` on load/save).
Observed pattern: Idle games convert lapsed players back into active players by making the first session of the day start with a reward. Caps prevent offline accrual from replacing active play.
Duck adaptation: On load, the server compares the saved last-seen timestamp with current time and grants eggs at `50%` of the player's current production rate, capped at `2` hours of accrual. A `Welcome back!` summary toast shows the result. No offline care requests, quest progress, weather, or minigames. Legacy boosts can extend the cap later (Phase 12).
Recommended bucket: `Early Expansion`
Scores:
- Fun: 4
- Fit: 5
- Simplicity: 4
- Retention: 5
- Risk: 2
Decision: Approved for Phase 4. Server-computed only; the client never reports elapsed time.
Follow-up tasks: Decide rounding rules for partial eggs; verify against clock skew and first-join cases; play-test that the cap keeps active play clearly better.

### Daily Streak V1 and Daily Quests V0

Date: 2026-06-11
Research topic: Daily habit layer on top of Daily Check-in V0
Source or reference: Existing Daily Check-in V0 implementation; common streak-pause patterns in kid-friendly games.
Observed pattern: Streaks drive habit but hard resets feel punishing and cause churn spikes when broken. Pause-instead-of-reset preserves the habit pull while honoring a no-punishment tone. Three daily goals with a completion bonus outperform one large daily goal for short-session players.
Duck adaptation: A visible 7-day streak track with escalating rewards (`20/30/40/50/60/80` coins, day 7 `Treat x1` plus `100` coins, repeating). Missing `1-3` days pauses the streak; missing more than `3` resets it. Daily Quests V0 adds `3` rotating UTC-day goals reusing existing tracked actions, each with a small reward plus an all-three bonus.
Recommended bucket: `Early Expansion`
Scores:
- Fun: 3
- Fit: 5
- Simplicity: 4
- Retention: 5
- Risk: 1
Decision: Approved for Phase 4. Reuses the existing quest framework and `lastDailyClaimDay` pattern.
Follow-up tasks: Pick the daily quest pool; confirm UTC rollover messaging is understandable for kids; play-test streak pause edge cases.

### Duckdex Collection and Rarity

Date: 2026-06-11
Research topic: Collection book as the medium-term aspiration loop
Source or reference: Pet-collection sim patterns (collection completion percent, silhouette cards); locked Duck visual rule set.
Observed pattern: A visible collection grid with silhouettes for unowned entries is one of the strongest medium-term goals in pet sims. Rarity needs a small stat hook to matter to progression-minded players, but large stat gaps make low rarities feel like trash and break a cozy tone.
Duck adaptation: Six starter families with rarity tiers carrying modest egg-output bonuses (`+0/5/10/20/35%`). The Duckdex shows family cards, owned counts, rarity, and a completion percent with rewards at `25/50/75/100%`. Later phases add stage rows (Phase 7) and mutation pages (Phase 9) to the same book.
Recommended bucket: `Later System` (Phase 5)
Scores:
- Fun: 5
- Fit: 5
- Simplicity: 3
- Retention: 5
- Risk: 2
Decision: Approved for Phase 5 with the starter lineup and bonuses recorded in the roadmap.
Follow-up tasks: Migrate existing saved ducks as `Classic Yellow`; design the Duckdex screen mockup; approve per-family art.

### Hatching and Incubator

Date: 2026-06-11
Research topic: Egg hatching as acquisition ritual and return timer
Source or reference: Pet sim hatching patterns; Roblox paid-random-item policy awareness (avoided entirely by keeping eggs coin/earn-only).
Observed pattern: Hatching converts acquisition from a transaction into an anticipated event. Timers create planned return visits. Hidden odds erode trust; visible odds plus pity counters keep randomness exciting but fair, which matters doubly for young audiences.
Duck adaptation: Egg types `Plain/Speckled/Golden/Festival` with hatch timers `5m/30m/4h` and one incubator slot growing to three via farm level. Odds always shown before purchase and hatch; pity guarantees Rare+ within `8` Speckled and Legendary within `10` Golden hatches. Eggs are never sold for Robux, keeping the system outside paid-random territory.
Recommended bucket: `Later System` (Phase 6)
Scores:
- Fun: 5
- Fit: 5
- Simplicity: 3
- Retention: 5
- Risk: 3
Decision: Approved for Phase 6 with the hard no-Robux-eggs rule.
Follow-up tasks: Design the hatch reveal moment; security-review the claim path against duplicate-claim and timer-forgery attempts; tune odds tables before implementation.

### Duck Legacy (Prestige) and Mastery

Date: 2026-06-11
Research topic: Endgame loop for finishers
Source or reference: Prestige patterns from idle/sim games adapted to a cozy collection game.
Observed pattern: Prestige systems retain finished players by trading accumulated economy for permanent multipliers and exclusive identity rewards. Prestige that deletes collection or cosmetic progress feels like betrayal in collection-driven games; prestige that only resets economy reads as a fresh start with momentum.
Duck adaptation: Duck Legacy at farm level `20` resets economy, upgrades, farm level, and ducks except one chosen Legacy Duck with a permanent mark. The Duckdex, mutations seen, cosmetics, badges, titles, and streaks never reset. Legacy Feathers buy permanent boosts; Golden Pond and an exclusive Legacy family provide visible status. Family Mastery adds slow-burn per-family ranks.
Recommended bucket: `Later System` (Phase 12)
Scores:
- Fun: 4
- Fit: 4
- Simplicity: 2
- Retention: 5
- Risk: 3
Decision: Approved for Phase 12. The keep-list is part of the cozy promise and is not negotiable in later tuning.
Follow-up tasks: Tune feather payout curve so the first Legacy lands within weeks for committed players; design the Legacy confirmation flow so the reset is fully understood before it happens.

### Social Layer (Gifting, Likes, Leaderboards)

Date: 2026-06-11
Research topic: Light social systems that fit same-server visiting
Source or reference: Existing Farm Visit V0/V1; Roblox OrderedDataStore for leaderboards; platform text-filtering rules.
Observed pattern: In cozy sims, social proof (likes, visitor books) and low-stakes generosity (capped gifting) retain better than competition. Leaderboards work when they celebrate identity (collection percent, cozy ratings) rather than raw grind alone. Uncapped gifting invites alt-account farming.
Duck adaptation: One gift per friend per day from a server whitelist with both sides rewarded; one like per visitor per farm per day feeding a weekly Cozy Farm board; lifetime boards for eggs and Duckdex percent; a visitor book on the farm sign. Offline snapshots stay gated behind their own privacy design doc.
Recommended bucket: `Later System` (Phase 10)
Scores:
- Fun: 4
- Fit: 4
- Simplicity: 3
- Retention: 4
- Risk: 3
Decision: Approved for Phase 10 with caps and whitelist as abuse guards.
Follow-up tasks: Security-review gifting against alt farming and duplication; design like-rate limits; write the snapshot privacy design doc before snapshots.

### Duck Grants: Starter Choice, Mystery Duck Box, and Comeback Gift

Date: 2026-06-12
Research topic: Granting ducks as rewards to deepen early engagement and milestone moments
Source or reference: User-proposed direction; genre-standard patterns in pet-collection games (starter-pet choice screens, first-week milestone pet gifts, comeback packages, pick-one-of-three reward boxes).
Observed pattern: Collection games front-load one special acquisition moment with choice, because picking a starter builds attachment faster than receiving a random grant; the chosen pet becomes "mine" in a way a granted pet does not. Milestone pet gifts around the first week mark support day-7 retention. Pick-one-of-three reward boxes keep randomness exciting while preserving agency, which reads as generous rather than gambling-like. The failure mode is repeatable direct pet grants: they inflate collections, devalue the core acquisition loop, and turn special moments into noise, so direct grants work best as bounded one-time or rare-milestone moments while the repeatable loop stays earned.
Duck adaptation: Three bounded grant moments. Starter Choice Duck (Phase 5): when the guide completes, the player picks `1` free duck from `3` fixed starter cards (`Mallard Green`, `Choco Brown`, `Snowy White`), one-time per profile, setting the Duckdex to two families immediately. Mystery Duck Box (Phase 5): a reward-only item that is never sold; opening shows `3` rarity-weighted ducks side by side (starter odds `60/30/10` Uncommon/Rare/Epic, displayed on the box) and the player keeps exactly `1`; sources are the first-ever day-7 streak completion, the Duckdex `50%` reward, seasonal event finales (Phase 11), and the first Legacy (Phase 12). Comeback Gift (Phase 4): players returning after `7+` days away receive a small care package framed as "the ducks missed you" (`Duck Feed x2`, `Treat x1`, plus a `Speckled Egg` once Phase 6 ships).
Recommended bucket: `Later System` (Phase 5, with the Comeback Gift in Phase 4)
Scores:
- Fun: 5
- Fit: 5
- Simplicity: 3
- Retention: 5
- Risk: 2
Decision: Approved 2026-06-12 and added to the roadmap. Boxes and starter choice must always show what can be obtained, never sell for Robux or coins, and never become repeatable shop items; hatching remains the core acquisition loop.
Follow-up tasks: Design the starter choice screen and box-opening moment (cozy gift, not casino chest); decide existing-profile behavior (offer the starter choice on first post-Phase 5 load); play-test that the box pick moment feels generous; watch duck-count inflation against farm capacity.

### Pond Games (Duck Battles): Classes and Skill Choice

Date: 2026-06-12
Research topic: An optional duck battle mode with player-picked skills and classes
Source or reference: User-proposed direction with a visual reference from the cozy pet-battle genre on Roblox (side-vs-side teams, attack/heart stat chips, prize chest); turn-based team battler patterns from kid-friendly monster collectors.
Observed pattern: Cute-styled pet battle games retain strongly on Roblox because battling gives a collection a purpose: the pet you raised finally gets to do something. Per-turn skill choice retains far better than auto basic-attack exchanges because the player makes decisions instead of watching numbers. The failure modes are well known: live real-time PvP creates networking and toxicity costs a small team cannot pay, deep class/skill matrices become an unwinnable balance treadmill, and selling battle power destroys trust in a kid economy.
Duck adaptation: `Pond Games`, a friendly optional contest mode where moves are splashes, quacks, gusts, and snacks, and tired ducks sit with dizzy sparkles instead of being hurt. 3v3 turn-based PvE with per-turn skill picks, fully server-resolved. Four classes assigned by family so collecting families builds battle depth: `Guard` (Mallard Green), `Splasher` (Classic Yellow, Golden), `Quacker` (Choco Brown, Twilight Blue), `Helper` (Snowy White, Blossom Pink), with every class fielded by a Common or Uncommon family so free players can build any comp. Four skills per class (`16` total at V0), unlocked by existing duck levels and evolution stages. Stats derive from existing level, rarity, and stage progression, so there is no second leveling grind. Losing never costs anything, per the cozy promise. Async snapshot challenges (no live sync) are the V1 candidate alongside Phase 10 social.
Recommended bucket: `Later System` (new Phase 7B, after evolution gives stats meaning)
Scores:
- Fun: 5
- Fit: 3
- Simplicity: 2
- Retention: 5
- Risk: 4
Decision: Approved 2026-06-12 as an optional side mode with a strict V0 cap: PvE only, 4 classes, 16 skills, derived stats, no live PvP, and battle power permanently on the never-for-sale list. The Fit score is honest: battles stretch the cozy identity, and the friendly framing plus no-loss rules are what keep it inside the promise.
Follow-up tasks: Design pass for the battle resolver, class stat curves, the 16-skill set, Pond Tour difficulty, and reward sizing; play-test that losing feels fine for a young player; revisit async PvP only after PvE proves itself.

### Duck Stats, Training Camp, and XP Pacing

Date: 2026-06-12
Research topic: Conflict sweep between care-driven XP and battle power, an expanded duck stat block, and a timer-based training facility
Source or reference: User-identified design conflict (cheap feed/treat XP could produce same-day overpowered battle ducks once Pond Games ships); timer-training and away-state patterns from pet sims and RPG training grounds.
Observed pattern: When one XP currency feeds two power systems (farm economy and battles), the cheapest source becomes the de facto power lever — coin-bought consumables get pumped, pacing collapses, and battle balance inherits the farm economy's loosest valve. Daily per-pet gain caps are the standard fix and read as kid-fair when framed gently and when no item can be wasted at the cap. Separately, timer-based training (the pet goes away and comes back stronger) is a proven return-timer that converts hours away into attachment, but only when being away is a real trade-off rather than free value.
Duck adaptation: Three coordinated changes. XP pacing (Phase 7): each duck gains at most `150` XP per UTC day from all sources; at the cap, care still clears requests and grants quest progress, XP waits for tomorrow behind a gentle `happily full for today` message, and Treat use on a capped duck is blocked before the item is consumed. Battle XP (Phase 7B): Pond Tour matches grant `+15` XP per participating duck on a win and `+5` on a loss (trying counts), inside the same daily cap, and battle level-ups feed the existing `Level up ducks` quest. Stats and training (Phase 7B): every duck gets four kid-readable stats — `Heart` (toughness), `Splash` (move strength), `Pace` (turn order), `Spirit` (heal/shield/charm power) — with base values derived from class, level, rarity, and stage, affecting battles only (egg production stays level/rarity/stage-driven so the farm economy is untouched). The Training Camp sends one duck away to train a chosen stat for `4h/8h/24h` (+`2`/+`5`/+`12`, coin fees `25/40/80`, permanent gains capped at `+20` per stat per duck); a training duck is in full stasis (no eggs including offline accrual, no care, no treats, no battles, later no breeding), and cancelling returns the duck instantly with no gain and a full fee refund so no choice is ever a loss.
Recommended bucket: `Later System` (Phase 7 for pacing, Phase 7B for stats and training)
Scores:
- Fun: 4
- Fit: 4
- Simplicity: 3
- Retention: 5
- Risk: 2
Decision: Approved 2026-06-12. The daily XP cap is the binding fix for the feed-to-OP conflict; battle stats never touch farm output; training stasis must be a visible, charming state (camp sign, halfway postcard) rather than a hidden flag.
Follow-up tasks: Tune the cap against real care-request pacing in the Phase 7 design pass; verify offline progress excludes ducks at camp; play-test that a capped duck's message reads as cozy, not punishing; decide farm-level unlock for training slot `2` in Phase 8.

### Photo Mode

Date: 2026-06-12
Research topic: Letting players frame and share photos of their farm and ducks
Source or reference: Photo modes in cozy games (decorate-then-share loops); Roblox capture/share platform flow.
Observed pattern: In expression-driven cozy games, a photo mode multiplies the value of every cosmetic system: decorating is more motivating when the result is shareable, and every shared screenshot is organic marketing. It is cheap relative to its payoff because it reuses existing scenes. The platform capture flow keeps sharing inside Roblox moderation, avoiding any custom image or text-input safety surface.
Duck adaptation: Photo Mode V0 in Phase 8 (shipping beside decorations, which it amplifies): a camera button hides the HUD, nearby ducks briefly turn and pose, the player frames the shot with `4` starter frames and `8` text-free stickers, and capture goes through the platform capture flow into the player's Roblox gallery. A small corner game stamp turns every shared photo into soft marketing. Frames and stickers are earnable-only; seasonal frames join Phase 11 event rewards. Visitors can use Photo Mode on farms they visit.
Recommended bucket: `Later System` (Phase 8)
Scores:
- Fun: 4
- Fit: 5
- Simplicity: 4
- Retention: 3
- Risk: 1
Decision: Approved 2026-06-12 for Phase 8. No custom upload, no text input, no monetized frames without a future wave sign-off.
Follow-up tasks: Verify capture-service capabilities and policies against official Roblox docs in the Phase 8 design pass; design the duck pose moment; pick the corner stamp from the approved logo work.

### Comprehension Guardrails (Unlock Ladder, Guide Debt, UI Budget)

Date: 2026-06-12
Research topic: Keeping a system-rich live game understandable for new players
Source or reference: Complexity audit of the full approved roadmap (care needs, quests, families, rarity, eggs, evolution, battles, stats, training, zones, decorations, events, Legacy); standard live-game onboarding-debt patterns.
Observed pattern: Live games accumulate systems update by update, which existing players absorb gradually — but a new player joining late meets everything at once. Games that survive this gate features per player behind progression (the game each player sees grows with them), keep tutorials current with content, and resist UI sprawl by consolidating into hubs. Games that skip this earn "confusing" reviews regardless of how good each system is, and kid audiences churn fastest on overload.
Duck adaptation: Three binding guardrails recorded in `docs/ROADMAP.md`: a per-player Feature Unlock Ladder (V0 in Phase 4, a new rung defined in every later phase's design pass, unlock state derived from existing server progress where possible, nothing ever re-locks); a no-system-ships-untaught rule folding guide steps into every phase's exit criteria; and a UI surface budget (`3` primary actions, `6` secondary controls, hub consolidation starting Phase 6, special currencies capped at the four already planned).
Recommended bucket: `Early Expansion` (Phase 4, then every phase)
Scores:
- Fun: 3
- Fit: 5
- Simplicity: 4
- Retention: 5
- Risk: 1
Decision: Approved 2026-06-12. Comprehension is treated as the project's top risk now that retention design is structurally complete; these guardrails bind like the cozy promise.
Follow-up tasks: Implement Ladder V0 in Phase 4; define each phase's ladder rung and guide step during that phase's design pass; review farm-screen control count against the budget at every phase exit.

### Trading

Date: 2026-06-11
Research topic: Player-to-player trading of ducks or items
Source or reference: Trading-driven Roblox sims and their well-documented scam/moderation burden.
Observed pattern: Trading creates enormous retention and social energy but also scams, begging, value-meta distortion, and a permanent moderation workload. It typically demands trade-confirmation UX, value guardrails, logging, and support tooling beyond a small team's budget.
Duck adaptation: Not adapted. Gifting V0 (capped, whitelist, no rare items) covers the generosity need without the scam surface.
Recommended bucket: `Avoid For Now`
Scores:
- Fun: 4
- Fit: 2
- Simplicity: 1
- Retention: 5
- Risk: 5
Decision: Explicitly excluded from the approved roadmap. Revisit only if the game grows enough to staff moderation, and only with a full safety design.
Follow-up tasks: None until revisited.

## Idea Backlog

### Guide Character

Bucket: `Later System`

Notes:

- Record a future original guide-character role similar in function to a strong onboarding host, but not as the player character.
- The guide character should be reusable across onboarding, tutorial prompts, feature explanations, event intros, and other approved helper moments.
- Do not copy an existing game mascot directly. Final personality, silhouette, dialogue style, and visual identity should stay original to Duck.
- Do not implement the guide character, dialogue flow, cut-ins, or scene usage until the role and art direction are approved.

### Minigames

Bucket: `Later System` (Phase 11)

Notes:

- Minigames V0 is implemented as a same-place UI-scene shell with a farm `Minigames` button, a minigame menu, one playable `Egg Catch` scene with server-backed reward claims, and a results screen.
- The approved structure avoids separate-place teleports and keeps minigames as short side activities that support the farm loop rather than replace it.
- Minigames V1 is approved for Phase 11: `Bread Toss` (timing/accuracy arc throws to swimming ducks) and `Lily Hop` (rhythm-lite lily pad hopping), both reusing the Egg Catch server-validated reward pattern, plus a minigame-of-the-day doubled first win.
- Exact round design, length, and reward balance for the two new minigames still need their design pass.

### Duck Variations and Visual Identity

Bucket: `Later System` (Phase 5)

Notes:

- The visual separation is locked: shop variation is the base duck family, evolution is the upgraded form of that same family, and mutation is a separate overlay trait.
- Base variation carries the largest silhouette and palette difference so ducks stay readable on the farm; evolution stays within the family line; mutation stays a secondary overlay.
- The first lineup is approved for Phase 5: `Classic Yellow` and `Mallard Green` (Common), `Choco Brown` and `Snowy White` (Uncommon), `Blossom Pink` (Rare), `Twilight Blue` (Epic), with `Golden` (Legendary) reserved as hatch-only for Phase 6.
- Rarity carries the stat hook (`+0/5/10/20/35%` egg output); family carries the visual identity.
- Final per-family art still needs approval through the design prompt workflow before implementation.

### Duck Evolution

Bucket: `Later System` (Phase 7)

Notes:

- Evolution direction is approved for Phase 7: deterministic and player-triggered, not chance-based. Reaching level `5` unlocks Stage 2 `Radiant` and level `10` unlocks Stage 3 `Royal`, each costing earnable `Star Grain` and granting `+25%` egg output for that duck.
- The earlier chance-on-level-up idea was replaced with the deterministic trigger because guaranteed progress fits the cozy promise and avoids gambling-feel on a kid-facing system.
- Evolution preserves the duck's base family line and plays a short skippable celebration cutscene as a same-place UI scene.
- The duck level cap rises from `5` to `10` with this phase.
- Final stage art per family still needs approval; the celebration flow needs its design pass before implementation.

### Mutation and Breeding

Bucket: `Later System` (Phase 9)

Notes:

- Mutation and breeding direction is approved for Phase 9 with starter numbers in the roadmap.
- Mutations are overlay traits that never replace family silhouettes: launch set `Sparkle`, `Marble`, `Snowdust`, `Honey`, `Tuxedo`, `Star`, each cosmetic-first plus a flat `+10%` egg output so no mutation is a wrong pull.
- Legibility decision (2026-06-11): each mutation carries one bold always-visible tell that stays identifiable at farm sprite size. Collection retains through showing off, so visitors must spot special ducks at a glance; subtle-only mutations were rejected as a retention risk.
- Sources: small chance on Golden and Festival hatches (`5%` starter) and breeding as the main source.
- Breeding V0: two owned Stage 2+ ducks, a `24` hour timer, a `Family Egg` outcome weighted `60/40` toward the higher-rarity parent, `25%` mutation inheritance, `5%` fresh mutation, pity within `12` breedings, coins cost, and per-duck breeding cooldowns. No duck is ever consumed or downgraded.
- Depends on stable duck identity (already saved), Phase 5 families, Phase 6 hatching, and Phase 7 stages.
- Final mutation art and the breeding UI flow still need their design pass before implementation.

### Weather Events

Bucket: `Early Expansion`

Notes:

- Weather/Event V0-V2 is implemented with `Sunny`, `Cloudy`, `Rainy`, and `Stormy` session weather affecting only care-request weighting and visuals.
- Phase 11 adds approved seasonal visual touches (for example a winter snow overlay during `Winter Frost`).
- Weather production bonuses, weather items, or weather-specific duck reactions still need separate approval and stay outside the approved roadmap.

### Duck Mood

Bucket: `V1 Candidate`

Notes:

- Duck Mood / Care V1 is implemented as feedback only.
- Ducks are real individual server records with their own care cooldown and temporary cared mood.
- The server can assign one visible duck to request care with a `Pet me?`, `Hungry?`, `Sleepy?`, or `Dirty?` prompt.
- Ducks can currently be `Content` or temporarily `Happy` after the player uses `Care`.
- Mood can drive autonomous animations, weather reactions, and small bonuses later.
- Do not add full needs management or mood-based economy boosts until the first loop is play-tested.

### Shop, Hunger, Duck Level, and Treat V0

Bucket: `Next Candidate After QA`

Notes:

- A shop screen fits the 2D UI-first direction because it adds progression without player-controlled movement.
- Use a `Shop` GUI button and a short fade-to-black scene transition into a shop background, then return to the farm/lawn with a back button.
- Hungry duck requests are implemented as the first care expansion that requires an inventory item. Sleepy and dirty duck requests are implemented as feedback-only needs that consume no item.
- Shop V0 now includes `Duck Feed` and `Treat` as the first two server-owned inventory items.
- Treat V0 is implemented as a targeted profile action: buy Treats in the shop, then use one from Duck Profile V0 to grant `40` XP to the selected duck.
- Treat V0 does not clear care requests, bypass cooldowns, or add direct coin rewards; it only accelerates duck level progress.
- Candidate future shop items are fertilizer, nest straw, toys, and other approved farm-support items.
- Duck Level/Progress V0 is implemented with level and XP per duck.
- Current XP sources are Care, Feed, Rest, Clean, and Treat; rewards still focus on duck progression rather than direct economy bonuses.
- Do not expand level rewards or inventory persistence beyond Save Data V0 until the next design is approved.

### Expanded Quests

Bucket: `Early Expansion` (Phase 4 and Phase 11)

Notes:

- Quest V0-V3 is implemented with nine repeatable quests across collect, sell, help, treats, buying, spending, minigame wins, and duck level-ups.
- Daily Quests V0 (three rotating UTC-day goals with an all-three bonus) and Badges V0 are approved for Phase 4. Event quests are approved for Phase 11. Prestige quests are approved for Phase 12.
- Quest rerolls and paid quest boosts remain unapproved.

### Surprise Events

Bucket: `Later System`

Notes:

- Random small events could make the farm feel alive.
- Examples: extra egg found, duck nap, visitor duck, pond sparkle.
- Needs careful timing so events feel charming instead of noisy.
- Phase 11 weekend mini-events (two-day boosts on a rotating schedule) cover the scheduled side of this idea; ambient surprise moments remain unapproved and outside the roadmap.