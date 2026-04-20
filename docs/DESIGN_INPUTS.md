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

Likely later screens:

- Shop screen. The next planned shop direction needs a `Shop` farm button, a shop background, a back button, and a fade-to-black transition between farm/lawn and shop.
- Duck collection screen.
- Tasks or quests screen.
- Settings screen.
- Hatch or unlock screen.

## Asset Decisions

Required assets can start as placeholders. The approved visual direction is Cozy Pond Farm: yellow ducks, teal pond water, green grass, sky blue, coral buttons, white rounded panels, soft 2D cartoon shapes, and mobile-friendly readability.

Asset work should define:

- Duck icon or sprite style, including right-facing and left-facing versions if autonomous wandering should clearly switch direction.
- Egg icon style.
- Coin icon style.
- Farm background.
- Button style.
- Upgrade icon style.
- Success, error, and reward feedback.
- Optional sound effects.

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
- Whether save data exists after the first prototype. Save data is not included in the first prototype.
- Whether weather events affect production, duck mood, visuals, or only presentation later.

## Agent Defaults When Details Are Missing

If details are missing, agents may use temporary placeholder UI only when the user has approved prototyping. Placeholders must be documented as temporary and should not be treated as final art direction.

Agents must ask before deciding final art style, monetization, save data, rarity tiers, duck breeds, or economy scaling.