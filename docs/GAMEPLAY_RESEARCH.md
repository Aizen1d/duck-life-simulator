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

- What should make the first duck feel alive besides egg production?
- Should weather initially be cosmetic, mechanical, or both?
- What is the smallest event system that fits v1 or early expansion?
- Which upgrade is best for the first prototype: egg value, production speed, storage, or duck happiness?
- What daily or session goals could fit without adding heavy quests?
- How should future mutation and breeding systems fit the duck life simulator without derailing the first farming loop?

## Reviewed Recommendations

### Duck Mood / Care V1

Date: 2026-04-15
Research topic: Duck mood and care as the next small life-sim mechanic
Source or reference: Project direction, current prototype loop, user approval
Observed pattern: Pet and life-sim games often add a simple care interaction before deeper needs, weather, or event systems.
Duck adaptation: Add a server-authoritative `Care` action that validates a selected duck index, changes only that duck mood from `Content` to `Happy` for a short time, and shows client feedback. V1 lets the server track real session-only individual ducks and assign one visible duck to request care with a `Pet me?` prompt. It does not affect egg production, coins, upgrades, save data, or weather yet.
Recommended bucket: `V1 Candidate`
Scores:
- Fun: 3
- Fit: 5
- Simplicity: 5
- Retention: 2
- Risk: 1
Decision: Approved for implementation as feedback-only V1. Keep mood out of economy balance until the base loop is play-tested.
Follow-up tasks: Play-test the care request timer, Studio `Need` tester action, requested duck prompt, duck tap/click care bubble, mood feedback, cooldown, and mobile layout. Later, design expanded request types before making individual duck needs.

### Duck Level/Progress V0

Date: 2026-04-16
Research topic: Lightweight individual-duck progression after care and hunger
Source or reference: Project direction, current prototype loop, user approval
Observed pattern: Pet and simulator games often make individual animals feel more valuable by showing visible progress from repeated care actions before tying that progress to rewards.
Duck adaptation: Add server-owned session-only level and XP per duck. `Care` grants `25` XP, `Feed` grants `35` XP, level-ups happen every `100` XP up to level `5`, and selected-duck bubbles show progress. V0 is feedback-only and does not affect egg production, economy balance, mutation, breeding, or persistence.
Recommended bucket: `V1 Candidate`
Scores:
- Fun: 3
- Fit: 5
- Simplicity: 4
- Retention: 3
- Risk: 2
Decision: Approved for implementation as feedback-only V0. Keep level rewards and persistence undecided until the first loop is tested.
Follow-up tasks: Play-test level-bar readability, level-up feedback, per-duck XP targeting, max-level behavior, and confirm no production or economy changes.

### Duck Profile, Names, and Rename V0

Date: 2026-04-16
Research topic: Lightweight individual-duck profile inspired by Planet Zoo animal profiles
Source or reference: Planet Zoo official guide/search result for animal welfare/profile scope, Planet Zoo 1.1 official update note on family info panels, community references for editable animal names, and Roblox Creator Docs text-filtering guidance.
Observed pattern: Animal-management games often use an animal information panel as a central place for individual identity and management context. Those panels can include name, welfare/status, social or family context, genetics, and other detailed simulation data, but that amount of information is too heavy for the current Duck prototype.
Duck adaptation: Start with a small profile that supports identity and current status only: generated duck name, level/progress, mood or current need, and Rename V0. Duck Names V0 gives new ducks random generated session-only names from a large curated `PrototypeConfig.duckNames` pool and rejects duplicates in the player's owned duck list by selecting an unused name or falling back to numbered `Duck N` names. Rename V0 uses the profile panel, validates `2` to `16` character names, rejects case-insensitive duplicates within the player's current session duck list, filters submitted text on the server, and only replicates the filtered display name. Deeper fields such as age, traits, family tree, mutation history, breeding history, favorite food, or long-term stats should wait until those systems exist.
Recommended bucket: `V1 Candidate`
Scores:
- Fun: 4
- Fit: 5
- Simplicity: 4
- Retention: 3
- Risk: 2
Decision: Duck Names V0 is implemented as session-only generated names shown in the selected-duck bubble. Duck Profile V0 is implemented as a lightweight selected-duck panel opened from the bubble's `Profile` button for name, level/XP, mood, need, care readiness, Rename V0, and session-only status. Rename V0 is implemented as server-validated, server-filtered, session-only profile editing.
Follow-up tasks: Review the large curated generated name pool, play-test Duck Profile/Rename V0 readability and error messaging, and decide whether names/profiles should be saved later.

## Idea Backlog

### Mutation and Breeding

Bucket: `Later System`

Notes:

- Mutation and breeding are confirmed as future directions, but their mechanics are not finalized.
- Do not implement mutation categories, trait inheritance, offspring rules, breeding costs, breeding timers, or mutation bonuses until the design is approved.
- These systems likely depend on persistent individual duck identity, save data, additional duck visuals, economy balance, and clear player goals.
- Early research should explore how mutation and breeding could make ducks feel collectible without copying another game's exact rarity, breeding, or monetization structure.

### Weather Events

Bucket: `Early Expansion`

Notes:

- Sunny weather could increase duck happiness or production.
- Rainy weather could make ducks sleepy, cozy, or produce a temporary bonus.
- For v1, weather should remain visual or mocked until the core loop works.

### Duck Mood

Bucket: `V1 Candidate`

Notes:

- Duck Mood / Care V1 is implemented as feedback only.
- Ducks are real session-only individual server records with their own care cooldown and temporary cared mood.
- The server can assign one visible duck to request care with a `Pet me?` prompt.
- Ducks can currently be `Content` or temporarily `Happy` after the player uses `Care`.
- Mood can drive autonomous animations, weather reactions, and small bonuses later.
- Do not add full needs management or mood-based economy boosts until the first loop is play-tested.

### Shop, Hunger, and Duck Level

Bucket: `Next Candidate After QA`

Notes:

- A shop screen fits the 2D UI-first direction because it adds progression without player-controlled movement.
- Use a `Shop` GUI button and a short fade-to-black scene transition into a shop background, then return to the farm/lawn with a back button.
- Hungry duck requests are implemented as the first care expansion that requires an inventory item.
- Shop V0 starts with one useful food item, Duck Feed, before adding a larger catalog.
- Candidate future shop items are basic duck feed, treats, fertilizer, nest straw, and toys.
- Duck Level/Progress V0 is implemented with session-only level and XP per duck.
- Current XP sources are Care and Feed; rewards are visual feedback only.
- Avoid persistence-dependent level or inventory promises until save data requirements are approved.

### Surprise Events

Bucket: `Later System`

Notes:

- Random small events could make the farm feel alive.
- Examples: extra egg found, duck nap, visitor duck, pond sparkle.
- Needs careful timing so events feel charming instead of noisy.