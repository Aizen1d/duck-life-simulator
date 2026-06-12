# Design Inputs

Use this checklist when preparing designs for `Duck`, a 2D UI-first duck life simulator.

The first prototype does not need finished art. It needs enough direction to build readable UI, test the loop, and avoid guessing.

## Minimum Needed for the First Prototype

- Visual mood: Cozy Pond Farm is approved as cute, cozy, friendly, and relaxing.
- First farm screen layout: where ducks, eggs, coins, collect, sell, and upgrade controls should appear.
- First upgrade choice: Egg Value is approved for the first prototype.
- First economy numbers: 1 duck, 0 eggs, 0 coins, 1 egg every 5 seconds per duck, 1 coin per egg, 10 coins for the first Egg Value upgrade, +1 coin per egg from that upgrade, Buy Duck starts at 25 coins, Buy Duck scales as 25 times current duck count, and each purchase adds +1 duck.
- Initial player mode: single-player first.
- Movement model: Option 1 is approved as a project constraint, meaning no player-controlled movement or click-to-move is planned; ducks may move or react autonomously.
- Prototype polish rule: use one approved variant per needed visual target, with temporary placeholders only until that variant is chosen or prepared.
- Placeholder asset style: simple colored Roblox UI placeholders are approved until the one approved visual variant is prepared for each target.

## Helpful References

The user can provide any of these:

- Hand sketch or screenshot markup.
- UI references from other Roblox simulator games.
- Color palette or mood board.
- Duck, egg, coin, nest, pond, or farm image references.
- Font or button style references.
- Nano Banana Pro outputs, prompt notes, or prompt preferences.
- Notes about what should feel satisfying or annoying.

Use [Design Prompts](DESIGN_PROMPTS.md) to manage reusable image-generation prompts and generated-design review notes.

## Screen Decisions

Confirm which screens are needed before building beyond the first prototype.

First prototype recommendation:

- Farm screen with egg, coin, duck, collect, sell, and a right-side progression stack for Egg Value and Buy Duck.

Implemented screens: farm, shop, minigames menu, Egg Catch scene and results, farm visit drawer/tray, guide overlay, duck profile panel.

UI surface budget (binding, per `docs/ROADMAP.md` comprehension guardrails): the farm screen is capped at `3` primary action buttons and `6` always-visible secondary controls. New systems consolidate into hubs instead of adding buttons, and fresh profiles reveal controls progressively through the Feature Unlock Ladder.

Planned screens by roadmap phase (`docs/ROADMAP.md`):

- Settings screen with music, sound, and reduced-motion toggles (Phase 4).
- Daily streak calendar and daily quest panel (Phase 4).
- Duckdex collection book screen with family cards, silhouettes for unowned entries, and completion rewards (Phase 5, expanded in Phases 7 and 9).
- Hatchery/incubator screen with egg slots, timers, visible odds, and a hatch reveal moment (Phase 6).
- Evolution celebration scene, short and skippable (Phase 7).
- Zone switcher and decoration placement mode using predefined anchor slots (Phase 8).
- Breeding/nursery screen (Phase 9).
- Leaderboards and visitor book panels, plus the farm sign (Phase 10).
- Event hub with banner, event quests, ticket counter, and event shop (Phase 11).
- Legacy confirmation flow, Legacy shop, and mastery panel (Phase 12).

## Asset Decisions

Required assets can start as placeholders. The approved visual direction is Cozy Pond Farm: yellow ducks, teal pond water, green grass, sky blue, coral buttons, white rounded panels, soft 2D cartoon shapes, and mobile-friendly readability.

Asset work should define:

- Duck icon or sprite style, including right-facing and left-facing versions if autonomous wandering should clearly switch direction.
- Future duck visuals should follow the locked rule set: shop variation = base family, evolution = upgraded form of that same family, mutation = separate overlay trait.
- Egg icon style.
- Coin icon style.
- Farm background.
- Button style.
- Upgrade icon style.
- Success, error, and reward feedback.
- Optional sound effects.

Future-content asset targets (prompts live in `docs/DESIGN_PROMPTS.md` under the Future Content Prompt Batch; all must keep one consistent duck body template across families):

- Six duck family asset sets plus the hatch-only `Golden` family (Phase 5).
- Rarity frames and tags from Common to Legendary (Phase 5).
- Egg type icons: Plain, Speckled, Golden, Festival (Phase 6).
- Incubator/nest stages and a hatch reveal background (Phase 6).
- Per-family evolution stage art and an evolution celebration background (Phase 7).
- Meadow and Orchard zone backgrounds, decoration icon set, nest upgrade stages (Phase 8).
- Mutation overlay sheet and breeding nursery background (Phase 9).
- Farm sign, gift box, leaderboard and visitor book UI (Phase 10).
- Four seasonal event backgrounds, event duck concepts, event decoration sets, ticket icon (Phase 11).
- Bread Toss and Lily Hop minigame scene mockups (Phase 11).
- Golden Pond background variant, Legacy Feather and mastery medal icons, Legacy Mark overlay (Phase 12).
- Cosmetic accessory sheet (monetization-gated; do not produce final accessory art until products are approved).
- Badge icon sheet and daily streak calendar UI (Phase 4).

## Current UI and Design Gaps

These gaps are known and should not block gameplay prototyping. Treat the current Roblox UI as functional prototype UI until each resource is approved.

- Final UI style reference is not approved yet for buttons, counters, cards, profile panels, shop panels, tester-only controls, and status messages.
- Final shop background is not approved yet. Shop V0 may use a placeholder scene until a clean 16:9 plain background without built-in UI is ready.
- Final item icons are not approved yet. Duck Feed is the first required shop item icon; future food, fertilizer, care, and event items are undecided.
- Final mood and need icons are not approved yet for pet/care, hungry/feed, sleepy/rest, clean/refresh, weather, or future needs.
- Final duck mood portraits or sprite variants are not approved yet for content, happy, hungry, sleepy, rested, or future mood appearances.
- Final guide-character visual direction is not approved yet. If added later, this should be an original helper or host character for onboarding and future feature messaging, not the player avatar.
- The high-level duck visual rule is now approved: shop variations are base families, evolution stays within that family line, and mutation is a separate overlay trait. The exact first variants, evolution stages, mutation sheets, and breeding visuals are still not approved.
- Final shop item layout, category tabs, item-card style, inventory display, and purchase feedback are not designed yet.
- Final minigames button, minigames menu layout, scene-transition style, round HUD, results screen, and Egg Catch visual theme are not designed yet.
- Final Egg Catch catcher or basket art is not approved yet. The current catcher uses a placeholder Roblox UI shape and should be replaced with a real basket icon or image-backed asset.
- Final friends/farm visit card UI is not designed yet, including friend farm boxes, online/offline state, visit buttons, and privacy indicators.
- Final mobile layout polish is still pending for small landscape screens; current compact UI is tuned for testing, not final art direction.
- Audio direction is approved at a high level (cozy acoustic and ambient pond sounds, Phase 4), but exact tracks and sound effects are not chosen yet.
- No future-content art (duck families, rarity frames, eggs, incubator, evolution stages, mutations, zones, decorations, event sets, badges, legacy visuals) is generated or approved yet. The ready-to-run prompts in `docs/DESIGN_PROMPTS.md` under the Future Content Prompt Batch are the starting point, and every generated batch still needs review and approval before promotion.
- Generated images should stay in `assets/design/generated` until approved, then move to the appropriate approved or runtime asset folder.

## Economy Decisions

Before implementation, decide or approve starter values for:

- Starting ducks.
- Egg production interval.
- Egg storage limit, if any.
- Egg sell value.
- Starting coins.
- First upgrade cost.
- First upgrade effect.
- Whether offline progress exists.
- Whether future save-data scope expands beyond Save Data V0.
- Whether weather events affect production, duck mood, visuals, or only presentation later.

## Agent Defaults When Details Are Missing

If details are missing, agents may use temporary placeholder UI only when the user has approved prototyping. Placeholders must be documented as temporary and should not be treated as final art direction.

Agents must ask before deciding final art style, monetization, save-data scope, rarity tiers, duck breeds, or economy scaling.