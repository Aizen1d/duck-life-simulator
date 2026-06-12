# Product Plan

This is the master plan for `Duck` as a product: positioning, monetization, analytics, marketing, community, localization, safety, and operations. It complements `docs/ROADMAP.md`, which owns gameplay content phasing. The game design source of truth stays `docs/GAME_BRIEF.md`.

Approved on 2026-06-11 as project direction. Like the roadmap, every number here is a starter default for later tuning, and each monetization wave still gets a one-line final confirmation from the user before it ships, plus a security review of its purchase paths.

## Vision and Positioning

One-liner: a cozy 2D duck farm you check on every day, where every duck is yours by name and nothing ever punishes you.

Positioning against the Roblox simulator field:

- Most pet/farm sims compete on scale and speed (huge numbers, fast trades, aggressive monetization). `Duck` competes on warmth: named individual ducks, a no-punishment promise, fair visible odds, and kid-safe spending rules.
- The marketable hooks, in order: cute collectible duck families, hatching moments, decorating your own farm, visiting friends, and a prestige loop that respects your collection.
- Tone in every surface (store page, UI copy, update notes): calm, friendly, zero pressure. No countdown-timer FOMO anywhere, ever. Seasonal content returns yearly by design, and store copy says so.

## Audience

- Primary: Roblox players roughly `8-14` who enjoy pet collection and cozy farm games, majority mobile/touch, short sessions (`10-25` minutes), several sessions per week.
- Secondary: older cozy-game players and parents who co-play; they care about fairness and the absence of gambling-style mechanics, which is a stated selling point, not just a constraint.
- Device floor: low-end Android phones in landscape. Every UI and effect decision respects this floor.

## Product Strategy and Milestones

Content phasing lives in `docs/ROADMAP.md`. The product view of those milestones:

- Soft launch (end of Phase 4): release quietly with no marketing push. Goal: real retention and stability data, not players. Iterate until the soft launch gate passes.
- Full launch (end of Phase 6): collection plus hatching is the marketable hook. Store page refresh, first marketing push, Monetization Wave 1.
- Named update beats (Phases 7, 9, 11, 12): each is a marketing moment with a thumbnail refresh, update notes, and a small in-game welcome gift.
- Live service: per the roadmap live-ops cadence (weekly touch, monthly review, quarterly event plus phase milestone).

## Monetization Plan

### Principles

These are hard rules, restated from `docs/ROADMAP.md` and binding for every future product idea:

- Cosmetic-first. Spending buys identity and expression, never production.
- No paid random items, no loot boxes, no paid odds boosts. Hatching odds are visible and identical for every player.
- No premium currency. All products are direct purchases with clear prices.
- No pay-to-win: no production multipliers, no XP boosts, no paid eggs, no paid coins.
- No trading of paid items.
- Calm storefront: purchases live in one clearly marked, optional place. Gameplay is never interrupted by a purchase prompt, and nothing in the core loop points at the store.
- Everything gameplay-relevant stays earnable by play. Paid duck families are cosmetic-only with Common-tier stats.

### Product Waves

Prices are Robux starter defaults; confirm each wave with the user before it ships.

Wave 1, ships with full launch (end of Phase 6):

- `Supporter Pass` gamepass, `199` Robux: supporter badge on the farm sign, golden display-name color in the visitor book and leaderboards, an exclusive profile flair frame, and one exclusive cosmetic accessory (`Sunny Bow`). Pure identity; no gameplay effect.
- `Cozy Basics Accessory Pack`, `99` Robux: three cosmetic duck accessories (coral bow, knitted scarf, flower clip), equippable per duck from Duck Profile.
- `Starlight Garden Decoration Theme`, `149` Robux: a cosmetic decoration set (string lanterns, glow flowers, star fountain) usable in decoration anchor slots.
- Engineering prerequisite for Wave 1: the cosmetic accessory layer (one cosmetic slot per duck, server-owned, visible to visitors) and decoration theme unlock flags.

Wave 2, ships with Phase 8 (decorations mature):

- `Velvet Family` gamepass, `399` Robux: an exclusive cosmetic-only duck family with Common-tier stats, clearly labeled cosmetic in the Duckdex.
- One or two more accessory packs at `99` Robux and one seasonal decoration theme at `149` Robux.

Wave 3, ships with Phase 11 (events live):

- One cosmetic event bundle per seasonal event, `199-249` Robux: event accessory plus decoration set plus a farm sign trim. Bundles return with their event every year; the store copy says "returns next year" explicitly, so missing one is never permanent.

Explicitly never for sale, recorded so future ideas die fast: coins, eggs, hatch odds, hatch speed, production or XP boosts, extra incubator slots, quest skips, Legacy Feathers, any Pond Games battle power (stats, skills, or boosts), and any randomized paid item.

### Storefront and UX Rules

- One `Supporter` tab inside the existing shop scene, visually separated from the coin shop, with a small heart icon and copy that thanks rather than sells.
- Owned products show as owned; no re-prompting.
- No purchase prompts during onboarding, hatching, events, or anywhere in the core loop.
- Accessory and decoration previews are free and unlimited (try-on), purchase is a deliberate second step.

### Implementation Requirements

- Gamepasses checked server-side via `MarketplaceService:UserOwnsGamePassAsync` with a session cache and a re-check on purchase signal.
- Developer-product purchases processed in `ProcessReceipt` with idempotent grants: store processed receipt ids and granted flags in save data before returning `PurchaseGranted` (planned save fields are listed in `docs/SAVE_DATA_DESIGN.md`).
- All grants are server-owned flags; the client only renders owned cosmetics.
- Each wave requires: official Roblox monetization docs check, a Security Agent review of the purchase and grant paths (duplicate receipts, refund behavior, exploit attempts to set grant flags), and Studio plus live test purchases before announcement.

### Revenue Expectations

Planning-grade honesty, not targets to force: cosmetic-only monetization in this genre converts roughly `1.5-3%` of DAU into payers over time, mostly one-time purchases. At `1,000` DAU that is on the order of `10-30` USD-equivalent per day once a few waves exist. This model deliberately trades short-term revenue for trust, retention, and word of mouth; the lever for more revenue is more cosmetic depth and bigger DAU, never harder monetization.

## Economy Health

- Coin sources: selling eggs, quests, daily streak, daily quests, minigames, events. Coin sinks: ducks, Egg Value tiers, shop items, eggs (Phase 6), decorations (Phase 8), breeding fees (Phase 9).
- Watch for: mid-game coin floods from stacked quest rewards, dead sinks after Egg Value is maxed, and hatch-pity interactions that make Speckled Eggs strictly better per coin than Golden.
- Monthly economy review (per the live-ops cadence): check source/sink ratios from analytics events, top `5%` player balances, and time-to-first-Legacy drift against the `25-40` hour budget.
- Inflation guard: every new system must name its coin sink before it ships; rewards-only features need explicit justification.

## Analytics and KPIs

### Targets

Starter targets; recalibrate after soft launch data exists.

- Day-1 retention: `35%` or better at full launch (soft launch gate: `30%`).
- Day-7 retention: `15%` or better. Day-30: `8%` or better.
- Average session: `12-20` minutes; sessions per DAU: about `2`.
- Tutorial completion: `85%` or better; first hatch within first two sessions for `70%` of players (post-Phase 6).
- Payer conversion: `1.5-3%` of DAU long-term; zero refund-complaint patterns.
- Stability: crash-free sessions `99.5%`, save failure rate under `1%`, server error budget reviewed monthly.

### Instrumentation

- Use the built-in Roblox Analytics dashboards (retention, engagement, monetization) as the baseline; no custom backend.
- Add `AnalyticsService` custom events for the funnel and economy: onboarding step completion, first collect/sell/buy-duck, first care, first shop visit, first minigame, first hatch, first evolution, first breeding, first visit, first like, first Legacy, plus economy source/sink events with category labels.
- Event naming convention: `funnel_*`, `econ_source_*`, `econ_sink_*`, `social_*`, decided once and recorded in `docs/CODING_STANDARDS.md` when implemented (Phase 4 task).
- Weekly glance, monthly deep review per the live-ops cadence; every review writes one short note (what changed, what we tune) into `docs/CHANGELOG.md` or a future analytics log.

## Marketing and Discovery

### Store Presence

- Experience name: `Duck` stays the working title; evaluate a more searchable display title at full launch (for example `Duck: Cozy Pond Farm`) based on search testing. Decision deferred to the full-launch checklist.
- Icon: one cute round duck face, readable at tiny sizes, Cozy Pond Farm palette. Thumbnails: five, refreshed per named update: farm overview, hatching moment, duck families lineup, decorated farm, friends visiting. Prompts live in `docs/DESIGN_PROMPTS.md` (Marketing Asset Prompts).
- Description: first line sells the promise ("Hatch, name, and care for your own ducks on a cozy pond farm"), then feature bullets using genre search words (duck, farm, pet, hatch, cozy, collect), then the fairness promise (no loot boxes, odds always visible).

### Launch Sequence

1. Soft launch (Phase 4 done): public but unannounced. Fix what the data says. No spend.
2. Polish window: `2-6` weeks until the soft launch gate passes.
3. Full launch (Phase 6 done): store page refresh, Wave 1 products, first announcement post, begin update cadence.
4. Paid acquisition test: only after the ads gate passes (below). Small capped budget on Roblox sponsored ads, creatives reusing the best-performing thumbnail; kill the test if cost-per-retained-player is clearly unsustainable.
5. Influencer outreach: a short list of small/mid cozy-Roblox creators (pet sim and farm niches), offered early access codes? Roblox has no codes natively; instead offer a press kit (icon, thumbnails, fact sheet, no-loot-box angle) and an in-game shout-out wall for featured videos. Keep it organic; no paid placements until the game proves retention.

### Update Beats

- Each named update (Evolution, Breeding, Festival, Legacy) gets: refreshed thumbnails, an update post, a welcome-back gift (small, cosmetic or feed), and an event-calendar entry when Phase 11 exists.
- Seasonal events are the recurring marketing engine after Phase 11: four predictable beats per year.
- Photo Mode (Phase 8) is the organic-sharing engine: every screenshot a player shares from their decorated farm carries the corner game stamp, turning expression into zero-cost marketing.

## Community

- Roblox group as the single official channel: announcements, update notes, and a small one-time group-join gift (`Treat x1`) which is allowed and common on the platform.
- In-game `What's New` panel ships with the Phase 11 event framework; until then, update notes live in the group and store description.
- Feedback loop: group wall plus watching analytics; no Discord server until there is real moderation capacity, because the audience skews under 13 and platform rules plus safety practice make an unmoderated server a liability, not an asset.
- Community content policy: celebrate fan art and videos in the group; never run contests with paid entry or randomized prizes.

## Localization

- Enable Roblox automatic text translation at soft launch. The existing rule that final text never gets baked into images makes the whole UI translatable for free.
- Keep all player-facing strings in shared config/UI code rather than hardcoded literals scattered through components, so translation tables stay complete (fold into `docs/CODING_STANDARDS.md` when implemented).
- Post full launch, order human review of the top non-English locales by player share; expected candidates are Spanish, Portuguese (Brazil), and Indonesian, but let the analytics decide.
- Duck names from the curated pool stay English in V1; renames are filtered per locale by Roblox text filtering already.

## Trust, Safety, and Compliance

- Content maturity: complete the experience questionnaire targeting an all-ages rating; the design contains no violence, no gambling-style mechanics, and no paid random items, which keeps the questionnaire clean.
- Paid random items: structurally avoided (eggs are never purchasable with Robux), so paid-random disclosure rules never apply. This is a design guarantee, not just a current state.
- Text safety: all player-entered text (renames today; anything future) goes through Roblox text filtering server-side before display or storage. Already implemented for Rename V0; binding for visitor books and any future text surface.
- Privacy: collect nothing beyond what Roblox provides (UserIds, display names); no off-platform links aimed at minors; no external data collection.
- Spending safety: parents can rely on platform-level spending controls; the game adds its own layer by having no consumable spending spiral (almost everything is one-time) and no purchase prompts inside the play loop.
- Accessibility: reduced-motion setting (Phase 4), colorblind-safe rarity communication (frames differ by shape and ornament, not color alone; this is recorded in the rarity frame prompt review criteria), readable text sizes on the low-end device floor, and full touch support (already standard).

## Technical Operations and Reliability

- Performance budget: stable frame rate on low-end Android in landscape; UI-first rendering keeps cost low, but image memory needs watching as families/zones/events multiply. Compress and size assets per `docs/ASSET_WORKFLOW.md`; audit memory each phase.
- DataStore resilience: existing autosave/retry/shutdown-save rules in `docs/SAVE_DATA_DESIGN.md` stay the foundation; add request-budget monitoring when social features (Phase 10) increase DataStore traffic.
- Recovery: Roblox DataStore versioning is the rollback path for corrupted player saves; place version history is the rollback path for bad deploys. Both procedures get a dry run before full launch.
- Kill switches: events (Phase 11) and each monetization wave ship behind a server-side config flag so a broken feature can be disabled without a redeploy.
- Incident playbook (lightweight): detect via analytics/error logs, disable the feature flag, fix, post a short note, grant a small apology gift if players lost anything. The cozy promise extends to operations.
- Testing: each phase keeps the existing pattern — Studio play-test checklist in `docs/TASKS.md`, security cases in `docs/SECURITY_TESTS.md`, multi-player Studio tests for social surfaces, device emulation for compact layouts.

## Risks and Mitigations

- Discovery failure (most likely risk): the game is good but nobody finds it. Mitigation: retention-first sequencing (the algorithm feeds on it), four predictable seasonal beats, thumbnail iteration, small paid tests only after gates pass. Accept that growth may be slow; the cost structure (solo plus AI agents) tolerates it.
- Soft monetization underperforms: accepted trade-off by design; lever is more cosmetic depth and DAU growth, never harder monetization. Revisit only with real data and never by breaking the hard rules.
- Solo-developer bandwidth: phases are sized to ship in slices; the live-ops cadence is a target, not a contract — a missed weekly touch is fine, a broken cozy promise is not.
- Platform policy shifts: the design already sits in the safest corner (no paid random, no trading, all-ages); re-check official Roblox monetization and safety docs at every wave per the reference policy.
- Copycats: unavoidable on Roblox; the defensible assets are tone, art consistency, and update rhythm, not mechanics.
- Economy drift at scale: monthly review plus the never-sell list prevent the common death spiral (selling progression to fix a broken curve).

## Decision Gates

- Soft launch → full launch: Day-1 retention `30%` or better, save failures under `1%`, no unresolved crash pattern, tutorial completion `85%` or better.
- Full launch → paid ads test: Day-1 `35%` or better and Day-7 `12%` or better, plus Wave 1 live without purchase incidents.
- Each monetization wave: user confirms the product list and prices (one-line sign-off), security review passed, test purchases verified, kill switch in place.
- Each phase ship: the exit criteria in `docs/ROADMAP.md` plus the release checklist there.
- Annual: revisit this whole plan against a year of data; prune what the data disproved.

## Document Maintenance

- This file owns product/business decisions; `docs/ROADMAP.md` owns content phasing; `docs/GAME_BRIEF.md` owns game design facts. When a monetization wave ships, record the final product list and prices here and add the changelog entry.
- The documentation impact check in `docs/DOC_UPDATE_POLICY.md` includes this file for changes touching monetization, analytics, marketing, community, localization, compliance, or operations.
