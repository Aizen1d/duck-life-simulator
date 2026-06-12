# Design Prompts

Use this file to manage prompts for Nano Banana Pro or any other image/design generator used for `Duck`.

The goal is to keep visual exploration organized so the UI/UX Design Agent and Asset and Content Agent can compare options, refine prompts, and record approved directions.

## Prompt Workflow

1. Copy a ready-to-run prompt from this file.
2. Generate temporary outputs into `assets/design/generated`.
3. Review outputs with the Design Agent Review Notes below.
4. Move approved images to `assets/design/approved` or the relevant `assets/ui` folder.
5. Record what worked, what failed, and which prompt should be reused.
6. Do not treat generated art as final direction until the user approves it.

## Global Direction

Current confirmed game direction:

- Game: `Duck`
- Genre: 2D UI-first duck life simulator for Roblox, with farming as the first core activity.
- Core loop: collect eggs, sell eggs for coins, buy upgrades, unlock more ducks.
- Movement model: no player-controlled movement or click-to-move is planned; ducks may idle, wander, sleep, and react automatically.
- First UI focus: farm screen with duck, eggs, coins, collect, sell, and one upgrade.

Current visual direction:

- Status: `Approved`
- Style name: `Cozy Pond Farm`
- Mood: cute, cozy, friendly, relaxing.
- Color palette: duck yellow, pond teal, grass green, sky blue, coral action buttons, and white UI panels.
- Duck style: round, friendly, soft 2D cartoon ducks with clear silhouettes.
- UI style: clean rounded panels, soft shadows, bright readable contrast, mobile-friendly spacing.

Use this style anchor in design prompts:

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, clean mobile-friendly UI, yellow ducks, teal pond water, green grass, white panels, coral action buttons, cheerful and readable
```

## Prompt Types

- Background prompts produce plain environment art only. They must not include UI, buttons, counters, panels, cards, text, numbers, labels, icons, or menus.
- Mockup prompts may include UI layout, buttons, panels, counters, and cards for design reference. They are not used directly as game backgrounds.
- Asset prompts produce separated icons, sprites, UI kit pieces, or transparent-background cutouts.
- Logo prompts are the only prompts allowed to include readable text.

## Prompt Rules

- Use the approved Cozy Pond Farm visual direction unless the user explicitly asks to explore another style.
- Prefer clean 2D game UI concepts over realistic 3D renders.
- Avoid baked-in readable text. Roblox UI should render labels directly.
- Ask for separated icons or transparent-background assets when the output is meant to become a game asset.
- Keep prompts clear about aspect ratio and target use.
- Use placeholders until the user approves final art direction.
- For the first prototype, choose one approved variant per needed visual target instead of generating multiple near-duplicate variants.
- Avoid adding unapproved mechanics, Robux, premium currency, ads, loot boxes, or monetization art.
- Rarity frames, golden eggs, evolution stages, mutations, and event theming are allowed only inside the Future Content Prompt Batch prompts that explicitly call for them, because those systems are approved direction in `docs/ROADMAP.md`. Everywhere else the original guardrails stay.
- Every duck prompt must reuse the Duck Body Template Anchor so all families, stages, and mutations read as the same character system.

## Size Targets

Use these size targets in prompts unless a specific asset needs something else:

- Plain landscape backgrounds: `16:9`, target `1920x1080`.
- Desktop UI mockups: `16:9`, target `1920x1080`.
- Mobile UI mockups: `9:16`, target `1080x1920`.
- Square icon sheets: `1:1`, target `2048x2048`, with separated items for cropping.
- Single transparent icons: `1:1`, target `1024x1024`.
- Duck portrait or expression sheets: `1:1`, target `2048x2048`, with separated portraits for cropping.
- UI kit sheets: `1:1`, target `2048x2048`, with separated components.
- Logo concepts: `1:1`, target `1024x1024`, transparent or plain light background.

Roblox UI sizes are still controlled in code. These image sizes are generation/export targets so the source art is clean enough to crop, upload, and scale down.

## Negative Prompt

Use this guardrail when the tool supports negative prompts:

```text
no realistic 3D render, no photorealism, no dark sci-fi style, no cluttered menus, no tiny unreadable text, no final readable text, no Robux, no premium shop, no loot boxes, no rarity effects, no battle pass, no weapons, no combat, no humans, no complex perspective, no copyrighted characters, no brand logos, no watermark
```

For plain backgrounds, also use:

```text
no UI, no buttons, no counters, no panels, no cards, no labels, no readable text, no numbers, no menus, no icons, no upgrade box, no shop, no logo
```

For Future Content Prompt Batch prompts that explicitly ask for rarity frames, golden eggs, evolution sparkle, mutation overlays, or event theming, drop only the conflicting terms (`no rarity effects`, `no golden egg`) from the negative prompt and keep every other guardrail.

For Pond Games battle prompts, drop only `no combat`: those scenes depict friendly splash-and-quack contests. Keep `no weapons` in every prompt — Pond Games never uses weapons, and nothing in the art may look like fighting that hurts.

## Design Agent Review Notes

For each generated image, review:

- Does it fit Cozy Pond Farm?
- Is it readable on mobile?
- For duck variant sheets (families, evolution stages, mutations): scale the image down to roughly in-game sprite size (about 64 pixels) and confirm each variant is still identifiable at a glance; reject sheets that only read at full resolution.
- Does it support the egg, coin, collect, sell, and upgrade loop?
- Could the scene support autonomous duck idle, wander, sleep, or reaction animation without implying player-controlled movement?
- Does it avoid unapproved mechanics or extra systems?
- Can it be implemented with Roblox UI and React Luau?
- Which parts should become actual assets, and which are only inspiration?
- Is this output filed as the correct type: background, mockup, icon, UI kit, or approved asset?

## Run Order

Start with these first:

1. `Farm Screen Concept - Desktop`
2. `Farm Screen Concept - Mobile`
3. `Farm Background - Plain Environment`
4. `UI Kit`
5. `Duck Icon Sheet`
6. `Egg and Coin Icons`
7. `Upgrade Icon Candidates`
8. `Shop Background - Plain Environment`
9. `Duck Feed Icon`
10. `Duck Mood / Need Icon Sheet`
11. `Duck Profile Portrait Sheet`

Save temporary outputs in `assets/design/generated`. Move only approved images into tracked folders.

After the first batch is approved, run the Future Content Prompt Batch in roadmap phase order so art approval stays ahead of implementation:

1. Phase 4: `Badge and Achievement Icon Sheet`, `Daily Streak Calendar UI Mockup`
2. Phase 5: `Duck Family Lineup Sheet` first (approve all palettes in one image), then `Duck Family Asset Set - Template` once per family, `Rarity Frame and Tag Sheet`, `Duckdex Screen Mockup`, `Mystery Duck Box and Starter Choice Mockup`
3. Phase 6: `Egg Type Icon Sheet`, `Incubator and Hatch Stage Sheet`, `Hatch Reveal Background`
4. Phase 7: `Evolution Stage Sheet - Template` per family, `Evolution Celebration Background`, `Progression Item Icon Sheet`; then Phase 7B: `Pond Games Battle Scene Mockup`, `Battle Skill and Class Icon Sheet`, `Training Camp Scene and Stat Icon Sheet`
5. Phase 8: `Farm Zone Background - Meadow`, `Farm Zone Background - Orchard`, `Decoration Icon Sheet - Starter Set`, `Photo Frame and Sticker Sheet`
6. Phase 9: `Mutation Overlay Sheet`, `Breeding Nursery Background`
7. Phase 10: `Social UI Mockup`
8. Phase 11: `Seasonal Event Background - Template` and `Event Duck Concept - Template` per season, `Minigame Scene Mockup - Bread Toss`, `Minigame Scene Mockup - Lily Hop`
9. Phase 12: `Golden Pond Background`
10. Wave 1 prep: `Accessory Icon Sheet - Concept Only` (final art waits for the monetization wave sign-off per `docs/PRODUCT_PLAN.md`).
11. Before full launch: the Marketing Asset Prompts (`Game Icon`, `Store Thumbnail - Template` per scene).

## Ready-To-Run Prompts

### Farm Screen Concept - Desktop

Status: `Ready`

Target use: first full-screen UI mockup.

Suggested save name: `assets/design/generated/farm-screen-desktop-cozy-v1.png`

```text
Create a 16:9 desktop UI mockup for a 2D Roblox duck farming simulator named Duck, using the Cozy Pond Farm style: cute cozy bright pond farm, soft cartoon shapes, yellow ducks, teal pond water, green grass, white rounded UI panels, coral action buttons, cheerful and readable.

Size: 16:9 landscape, target 1920x1080.

Scene and layout: a friendly pond farm background with one cute round yellow duck near a nest, a small egg collection area, a top-left egg counter area, a top-right coin counter area, a large coral collect button near the bottom center, a coral sell button near it, and one simple upgrade card or button on the lower right. Use clean mobile-friendly spacing even though this is desktop.

UI style: white rounded panels, soft shadows, bright contrast, simple icons, large tappable buttons, readable empty label areas. Leave labels as blank spaces or simple placeholder marks; do not bake final readable text into the art.

Keep it simple for the first prototype. No complex menus, no shop tabs, no rarity systems, no Robux, no premium currency, no extra characters, no realistic 3D rendering, no clutter.
```

### Farm Screen Concept - Mobile

Status: `Ready`

Target use: mobile-first layout reference.

Suggested save name: `assets/design/generated/farm-screen-mobile-cozy-v1.png`

```text
Create a 9:16 vertical mobile UI mockup for a 2D Roblox duck farming simulator named Duck, using the Cozy Pond Farm style: cute cozy pond farm, soft cartoon shapes, yellow ducks, teal pond water, grass green, sky blue, white rounded panels, coral action buttons, cheerful and readable.

Size: 9:16 portrait, target 1080x1920.

Layout: top area has large egg and coin counter panels, center area has one cute round yellow duck by a pond and nest, lower area has a large collect eggs button, a sell eggs button, and one upgrade button or card. Make every control large enough for mobile touch. Use simple empty label spaces or generic placeholder marks instead of final readable text.

The design should feel cozy, friendly, and easy to understand at a glance. Do not add side menus, premium shop, rarity effects, Robux, battle pass, extra currencies, or complex systems. No realistic 3D render, no clutter, no tiny unreadable text.
```

### Farm Background - Plain Environment

Status: `Ready`

Target use: reusable plain background behind React UI.

Suggested save name: `assets/ui/backgrounds/farm-background-cozy-v1.png`

```text
Create a clean 16:9 2D background for a Roblox duck farming simulator in the Cozy Pond Farm style. Show only the environment: bright teal pond on the right, soft green grass on the left, simple wooden fence, small straw nest area, blue sky feel, gentle clouds or soft foliage, and open empty areas where UI can be placed later.

Size: 16:9 landscape, target 1920x1080.

Important: do not include any UI elements. No buttons, no counters, no panels, no cards, no icons, no labels, no text, no numbers, no menus, no upgrade box, no shop, no logo. This is only the plain game background behind the interface.

The mood should be cute, cozy, friendly, relaxing, cheerful, and readable. Use soft 2D cartoon shapes, yellow-green grass, teal water, sky blue, warm straw nest colors, and clean game-ready composition. Leave empty space at the top left, top right, bottom center, and right side for UI overlays. No realistic 3D render, no clutter, no complex perspective.
```

### UI Kit

Status: `Ready`

Target use: buttons, counters, cards, and panel style reference.

Suggested save name: `assets/ui/mockups/ui-kit-cozy-v1.png`

```text
Create a 2D UI kit concept sheet for a Roblox duck farming simulator in the Cozy Pond Farm style. Include white rounded panels, coral action buttons, smaller secondary buttons, egg counter panel, coin counter panel, upgrade card, simple progress bar, notification bubble, and small icon slots. Use duck yellow, pond teal, grass green, sky blue, coral buttons, white panels, soft shadows, and bright readable contrast.

Size: 1:1 square sheet, target 2048x2048.

Make components large and mobile-friendly. Leave text areas blank or use simple unreadable placeholder marks; do not bake final readable labels into the art. Keep the sheet clean and organized, with components separated enough to crop or reference. No realistic 3D render, no dark theme, no premium shop elements, no Robux icons.
```

### Duck Icon Sheet

Status: `Ready`

Target use: first duck icon/sprite references.

Suggested save name: `assets/design/generated/duck-icon-sheet-cozy-v1.png`

```text
Create a 2D icon sheet of cute round yellow ducks for a Roblox duck farming simulator, in the Cozy Pond Farm style. Show 6 simple duck variations or expressions: happy idle duck, excited duck, sleepy duck, proud duck, tiny duckling, and duck facing slightly sideways. Each duck should have a strong readable silhouette, soft cartoon shading, friendly expression, and no accessories.

Size: 1:1 square sheet, target 2048x2048.

Use a plain light background or transparent-style presentation. Keep each duck separated with clear spacing so individual icons can be cropped later. No text, no rarity effects, no hats, no realistic feathers, no 3D render, no complex background.
```

### Egg Icon Sheet

Status: `Ready`

Target use: normal egg icon and small UI variations.

Suggested save name: `assets/design/generated/egg-icon-sheet-cozy-v1.png`

```text
Create a 2D icon sheet of simple egg resource icons for a Roblox duck farming simulator in the Cozy Pond Farm style. Show 6 normal egg icon variations that all feel bright, clean, friendly, and readable at small sizes. Use soft highlights and gentle cartoon shading that matches yellow ducks, teal pond water, green grass, white UI panels, and coral buttons.

Size: 1:1 square sheet, target 2048x2048.

Keep icons separated with clear spacing for cropping. Use a plain light background or transparent-style presentation. No text, no cracks, no rarity glow, no golden egg, no rainbow egg, no realistic photography, no 3D render.
```

### Coin Icon Sheet

Status: `Ready`

Target use: coin resource icon and counter reference.

Suggested save name: `assets/design/generated/coin-icon-sheet-cozy-v1.png`

```text
Create a 2D icon sheet of cheerful coin resource icons for a Roblox duck farming simulator in the Cozy Pond Farm style. Show 6 golden coin variations that are readable at small sizes and match a cute cozy pond farm UI. Use simple soft shading, clean silhouettes, warm golden color, and subtle highlights.

Size: 1:1 square sheet, target 2048x2048.

Keep icons separated with clear spacing for cropping. Use a plain light background or transparent-style presentation. No readable text, no currency symbols, no Robux icon, no premium currency, no realistic metal render, no 3D render.
```

### Egg and Coin Counter Concepts

Status: `Ready`

Target use: resource counter UI reference.

Suggested save name: `assets/ui/mockups/resource-counters-cozy-v1.png`

```text
Create a 2D UI concept sheet for resource counters in a Roblox duck farming simulator using the Cozy Pond Farm style. Include several versions of egg counters and coin counters using white rounded panels, soft shadows, duck yellow and pond teal accents, small egg and coin icon areas, and blank spaces where numbers will be rendered in Roblox UI.

Size: 1:1 square sheet, target 2048x2048.

Make the counters readable on mobile and desktop. Keep all components separated and easy to crop or rebuild. Do not include final readable text or exact numbers. No Robux, no premium currency, no rarity icons, no dark theme, no realistic 3D render.
```

### Upgrade Icon Candidates

Status: `Ready`

Target use: choose the first upgrade direction.

Suggested save name: `assets/design/generated/upgrade-icons-cozy-v1.png`

```text
Create a 2D icon sheet of simple upgrade icons for a Roblox duck farming simulator in the Cozy Pond Farm style. Include candidate icons for these first-prototype upgrade ideas: egg value, egg production speed, egg storage, and duck comfort. Use soft cartoon shapes, coral accent badges, white panel-friendly silhouettes, yellow duck and teal pond color harmony.

Size: 1:1 square sheet, target 2048x2048.

Keep each icon separated with clear spacing for cropping. Use a plain light background or transparent-style presentation. Do not add text labels. Do not include rarity effects, premium currency, Robux, complex mechanics, magic effects, or realistic 3D rendering.
```

### Upgrade Button Concepts

Status: `Ready`

Target use: first upgrade button/card style.

Suggested save name: `assets/ui/mockups/upgrade-buttons-cozy-v1.png`

```text
Create a 2D UI concept sheet for upgrade buttons and upgrade cards in a Roblox duck farming simulator using the Cozy Pond Farm style. Include coral rounded buttons, white upgrade cards, small icon slots, cost area placeholders, level indicator placeholders, and simple progress-style accents. The UI should be friendly, clean, cheerful, and readable on mobile.

Size: 1:1 square sheet, target 2048x2048.

Use duck yellow, pond teal, grass green, sky blue, coral action buttons, white panels, and soft shadows. Leave text and numbers blank or as generic placeholder marks because Roblox UI will render final text. No Robux, no premium shop, no rarity pack, no loot box, no dark theme, no realistic 3D render.
```

### Shop Background - Plain Environment

Status: `Ready`

Target use: reusable plain background behind the shop UI.

Suggested save name: `assets/ui/backgrounds/shop-background-cozy-v1.png`

```text
Create a bright 16:9 plain background for a cozy 2D Roblox duck farming simulator shop scene.

Size: 16:9 landscape, target 1920x1080.

Show only the environment: a cute wooden duck farm supply stall, simple shelves, soft feed sacks, baskets, straw, pond teal accents, green grass, warm sunlight, soft cartoon shapes, cozy farm mood. Leave open empty space in the center and right side where Roblox UI panels and buttons can be placed later.

Important: this is a background only. Do not include any UI elements. No buttons, no counters, no cards, no menus, no labels, no readable text, no numbers, no icons, no price tags, no shop title, no logo.

Style: cute cozy 2D Roblox duck farming simulator, bright pond farm, yellow duck accents, teal pond water, green grass, warm wood, soft cartoon shading, clean mobile-friendly composition, cheerful and readable.

Negative prompt: black screen, blank background, dark void, realistic 3D render, photorealism, readable text, UI panels, buttons, menus, Robux, premium shop, loot boxes, rarity effects, humans, watermark.
```

### Duck Feed Icon

Status: `Ready`

Target use: shop item icon and hungry request inventory icon.

Suggested save name: `assets/design/generated/duck-feed-icon-cozy-v1.png`

```text
Create a 2D transparent-background game icon for Duck Feed in a cute cozy Roblox duck farming simulator.

Size: 1:1 square, target 1024x1024.

Icon: a small friendly sack or bowl of duck feed, warm grain colors, simple soft cartoon shading, clean readable silhouette, subtle duck-yellow and pond-teal accents, designed to fit inside a white rounded Roblox UI panel.

Make it readable at small mobile UI size. No readable text, no price tag, no Robux, no premium currency, no rarity glow, no realistic 3D render, no background scene, no watermark.
```

### Duck Mood / Need Icon Sheet

Status: `Ready`

Target use: profile status icons and future care need indicators.

Suggested save name: `assets/design/generated/duck-need-icons-cozy-v1.png`

```text
Create a 2D transparent-background icon sheet for duck mood and care needs in a cute cozy Roblox duck farming simulator.

Size: 1:1 square sheet, target 2048x2048.

Include separated icons with clear spacing: happy mood, content mood, hungry need, pet/care need, sleepy/rest need, clean/refresh need. Use soft cartoon shapes, duck yellow, pond teal, grass green, coral accents, and white-panel-friendly silhouettes.

These are small UI icons, not full buttons. No readable text, no numbers, no premium currency, no rarity effects, no Robux, no realistic 3D render, no humans, no watermark.
```

### Duck Profile Portrait Sheet

Status: `Ready`

Target use: duck profile portrait and future mood presentation references.

Suggested save name: `assets/design/generated/duck-profile-portraits-cozy-v1.png`

```text
Create a 2D transparent-background portrait sheet of one cute round yellow duck for a cozy Roblox duck life simulator.

Size: 1:1 square sheet, target 2048x2048.

Show the same duck character in separated portrait poses: content, happy, hungry, sleepy, curious, proud. Keep the same body shape, colors, and face style across all portraits so it feels like one duck with different moods. Soft cartoon shading, strong readable silhouette, friendly expression, Cozy Pond Farm style.

No accessories, no hats, no text, no background scene, no rarity effects, no realistic feathers, no 3D render, no watermark.
```
### Shop Screen Concept

Status: `Ready`

Target use: later upgrade/shop screen reference.

Suggested save name: `assets/design/generated/shop-screen-cozy-v1.png`

```text
Create a 16:9 2D shop screen concept for a Roblox duck farming simulator UI in the Cozy Pond Farm style. Use white rounded panels, coral action buttons, yellow duck accents, teal pond and green farm colors, soft shadows, and mobile-friendly spacing. Show simple upgrade cards for duck farm improvements, coin cost areas, and friendly button areas.

Size: 16:9 landscape, target 1920x1080.

Keep it clean, cheerful, readable, and easy to implement. Do not include premium currency, Robux purchases, rarity packs, hatch gacha, battle pass, ads, or unapproved mechanics. Avoid final readable text except simple placeholder marks.
```

### Logo Concept

Status: `Optional`

Target use: title/logo exploration only.

Suggested save name: `assets/design/generated/logo-duck-cozy-v1.png`

```text
Create a friendly 2D logo concept for a Roblox duck farming simulator named Duck, using the Cozy Pond Farm style. The logo should feel cute, cozy, simple, and readable, with a round yellow duck or egg shape integrated into the design. Use duck yellow, pond teal, grass green, sky blue, coral accent, and soft cartoon shapes.

Size: 1:1 square, target 1024x1024.

This is the only prompt where readable title text is allowed. Text should say only: Duck. No subtitle, no Robux, no premium badge, no extra mechanics, no realistic 3D render, no clutter.
```

## Future Content Prompt Batch (Roadmap Phases 4-12)

These prompts cover the approved long-term content in `docs/ROADMAP.md`. They are ready to run, but every output still follows the normal review flow: generate into `assets/design/generated`, review, then promote only approved images. Generate batches in phase order so each phase's art is approved before its implementation starts.

Consistency rules for this batch:

- Start every prompt with the Cozy Pond Farm style anchor.
- Include the Duck Body Template Anchor in every prompt that contains a duck.
- Use the family palette table verbatim so the same family always generates with the same colors.
- Templates contain `{PLACEHOLDER}` slots. Fill the slot from the tables below; change nothing else between runs so outputs stay comparable.

### Duck Body Template Anchor

Use this in every duck prompt, in addition to the style anchor:

```text
one consistent duck body template across all ducks: round plump body, simple small flat bill, two small dot eyes, small wing bump, short tail nub, no neck, stubby orange feet, three-quarter side view facing right, soft cartoon shading, flat clean 2D, strong readable silhouette, same proportions as a cute round rubber-duck toy
```

### Duck Family Palette Table

Fill `{FAMILY}` and `{PALETTE}` from this table. Do not invent new families.

| Family | Rarity | Palette text |
| --- | --- | --- |
| Classic Yellow | Common | warm duck-yellow body, orange bill and feet, soft cream belly |
| Mallard Green | Common | soft sage-green head fading to warm cream body, small teal wing accent, amber bill |
| Choco Brown | Uncommon | warm cocoa-brown body, cream chest patch, caramel bill |
| Snowy White | Uncommon | soft warm white body, pale blue-grey shading, light peach bill |
| Blossom Pink | Rare | soft blossom-pink body, tiny white cheek dots, rose-pink bill |
| Twilight Blue | Epic | dusk indigo-blue body, faint pale speckles on the wings, deep coral bill |
| Golden | Legendary | softly glowing warm gold body, gentle shimmer highlights, amber bill |

### Season Theme Table

Fill `{SEASON}` and `{THEME}` from this table.

| Season | Event | Theme text |
| --- | --- | --- |
| Spring | Spring Bloom | cherry blossom petals drifting, tulip beds, pastel flower garlands on the fence |
| Summer | Summer Splash | cheerful bunting, pond floaties, a small lemonade stall, bright sunshine sparkle on water |
| Autumn | Autumn Harvest | pumpkins, golden falling leaves, hay bales, warm string lights |
| Winter | Winter Frost | soft snow cover, frosted pond edge, warm fairy lights, knitted bunting |

### Badge and Achievement Icon Sheet

Status: `Ready` (Phase 4)

Target use: Roblox badge art and in-game milestone feedback.

Suggested save name: `assets/design/generated/badge-icons-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, yellow ducks, teal pond water, green grass, white panels, coral accents, cheerful and readable.

Create a 2D icon sheet of round achievement badge icons for a cozy duck farming simulator. Include separated circular badge icons with clear spacing: first duck, first egg collected, one hundred eggs, level-up star duck, seven-day streak calendar, first rename ribbon, first minigame trophy, first farm visit heart. Each badge is a simple soft circular medallion with one clear symbol, duck-yellow and pond-teal palette, coral ribbon accents.

Size: 1:1 square sheet, target 2048x2048, plain light background, separated for cropping.

No readable text, no numbers, no Robux, no premium currency, no realistic 3D render, no dark theme, no watermark.
```

### Daily Streak Calendar UI Mockup

Status: `Ready` (Phase 4)

Target use: streak track and daily quest panel layout reference.

Suggested save name: `assets/ui/mockups/streak-calendar-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, clean mobile-friendly UI, white panels, coral action buttons, cheerful and readable.

Create a 2D UI mockup of a daily reward streak panel for a cozy duck farming simulator. Show a white rounded panel with a row of seven day slots, the first few slots checked with soft coral check marks, one highlighted today slot with a small gift box, the seventh slot slightly larger with a glowing treat reward, and below it a smaller panel with three daily quest rows each with an icon slot, a progress bar, and a reward chip area.

Size: 1:1 square sheet, target 2048x2048.

Leave all text areas blank or as simple placeholder marks. No readable text, no numbers, no Robux, no premium currency, no battle pass styling, no dark theme, no realistic 3D render, no watermark.
```

### Duck Family Lineup Sheet

Status: `Ready` (Phase 5)

Target use: approve all seven family palettes in one image before per-family sets are generated.

Suggested save name: `assets/design/generated/duck-family-lineup-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

one consistent duck body template across all ducks: round plump body, simple small flat bill, two small dot eyes, small wing bump, short tail nub, no neck, stubby orange feet, three-quarter side view facing right, soft cartoon shading, flat clean 2D, strong readable silhouette, same proportions as a cute round rubber-duck toy.

Create a 2D character lineup sheet of seven ducks standing in one row, all using the exact same body template and pose, differing only in color palette and small markings: 1 warm duck-yellow body with orange bill, 2 soft sage-green head fading to warm cream body with small teal wing accent, 3 warm cocoa-brown body with cream chest patch, 4 soft warm white body with pale blue-grey shading, 5 soft blossom-pink body with tiny white cheek dots, 6 dusk indigo-blue body with faint pale wing speckles and deep coral bill, 7 softly glowing warm gold body with gentle shimmer highlights.

Size: 1:1 square sheet, target 2048x2048, plain light background, equal spacing between ducks for cropping.

No accessories, no hats, no text, no background scene, no realistic feathers, no 3D render, no watermark.
```

### Duck Family Asset Set - Template

Status: `Ready` (Phase 5, run once per approved family)

Target use: runtime sprites and portraits for one family.

Suggested save name: `assets/design/generated/duck-family-{family-slug}-set-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

one consistent duck body template across all ducks: round plump body, simple small flat bill, two small dot eyes, small wing bump, short tail nub, no neck, stubby orange feet, three-quarter side view facing right, soft cartoon shading, flat clean 2D, strong readable silhouette, same proportions as a cute round rubber-duck toy.

Create a 2D transparent-background asset sheet of one duck character: the {FAMILY} duck with {PALETTE}. Show the same duck in separated poses with clear spacing: standing idle facing right, standing idle facing left, sleeping curled with closed eyes, happy with open bill and small joy lines, and one larger front-facing portrait bust for profile UI.

Size: 1:1 square sheet, target 2048x2048, separated for cropping.

Keep the body shape, face, and palette identical across all poses. No accessories, no hats, no text, no background scene, no rarity effects, no realistic feathers, no 3D render, no watermark.
```

### Rarity Frame and Tag Sheet

Status: `Ready` (Phase 5)

Target use: Duckdex cards, hatch reveals, and shop cards.

Suggested save name: `assets/design/generated/rarity-frames-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, clean mobile-friendly UI, white panels, cheerful and readable.

Create a 2D UI sheet of five rounded card frames for rarity tiers in a cozy duck collection book, in one row from plain to fancy: 1 simple soft grey-green frame, 2 fresh leaf-green frame with one small leaf corner accent, 3 sky-blue frame with gentle ribbon corners, 4 violet frame with soft sparkle corner accents, 5 warm gold frame with a gentle glow and tiny star sparkles. All frames stay soft, rounded, and cozy rather than aggressive or dark. Below the frames add five matching small rounded tag chips with blank label space.

Size: 1:1 square sheet, target 2048x2048, plain light background, separated for cropping.

Rarity glow is allowed on the two fanciest frames only and must stay soft and pastel. No readable text, no Robux, no loot box, no dark theme, no realistic 3D render, no watermark.
```

### Duckdex Screen Mockup

Status: `Ready` (Phase 5)

Target use: collection book screen layout reference.

Suggested save name: `assets/ui/mockups/duckdex-screen-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, clean mobile-friendly UI, white panels, coral action buttons, cheerful and readable.

Create a 16:9 UI mockup of a duck collection book screen for a cozy duck farming simulator. Show a soft paper-like book panel with a grid of duck collection cards: some cards show cute round ducks of different colors, some cards show only a dark duck silhouette with a soft question mark feel, each card has a small rarity frame, and the top of the screen has a collection progress bar area and back button area. Keep generous mobile-friendly spacing.

Size: 16:9 landscape, target 1920x1080.

Leave all text areas blank or as placeholder marks. No readable text, no numbers, no Robux, no loot boxes, no dark theme, no realistic 3D render, no watermark.
```

### Mystery Duck Box and Starter Choice Mockup

Status: `Ready` (Phase 5)

Target use: starter duck choice screen and Mystery Duck Box reward moment layout reference.

Suggested save name: `assets/ui/mockups/duck-choice-mockup-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, clean mobile-friendly UI, white panels, coral action buttons, cheerful and readable.

one consistent duck body template across all ducks: round plump body, simple small flat bill, two small dot eyes, small wing bump, short tail nub, no neck, stubby orange feet, three-quarter side view facing right, soft cartoon shading, flat clean 2D, strong readable silhouette, same proportions as a cute round rubber-duck toy.

Create a 2D UI concept sheet with two separated layouts: 1 a starter duck choice screen showing three white rounded cards side by side, each holding one cute round duck of a different color (soft sage green, warm cocoa brown, soft warm white), a blank name bar and a coral pick-button area under each card, and a gentle headline space above; 2 a mystery gift box moment showing a cute wooden gift crate with a coral ribbon, lid popped open with soft pastel sparkles, and three duck cards fanned above it with one card gently raised and highlighted, plus a small blank odds-label area near the box.

Size: 1:1 square sheet, target 2048x2048.

The box must feel like a cozy gift, not a casino chest: soft colors, gentle sparkle, no slot machine, no spinning wheel, no dramatic rarity explosion, no dark vault styling. Leave all text blank or as placeholder marks. No readable text, no numbers, no Robux, no premium currency, no loot box styling, no realistic 3D render, no watermark.
```

### Egg Type Icon Sheet

Status: `Ready` (Phase 6)

Target use: egg inventory, shop, and incubator icons.

Suggested save name: `assets/design/generated/egg-type-icons-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, soft cartoon shapes, cheerful and readable.

Create a 2D transparent-background icon sheet of four egg types for a cozy duck farming simulator, separated with clear spacing: 1 plain warm cream egg, 2 speckled egg with soft teal speckles, 3 golden egg with a gentle warm glow and tiny sparkle, 4 festival egg with soft pastel confetti dots and a tiny ribbon painted band. All eggs share the same simple rounded egg shape and soft highlight style and must read clearly at small mobile UI size.

Size: 1:1 square sheet, target 2048x2048, separated for cropping.

The golden egg glow must stay soft and cozy. No cracks, no readable text, no Robux, no loot box styling, no rainbow gradients, no realistic photography, no 3D render, no watermark.
```

### Incubator and Hatch Stage Sheet

Status: `Ready` (Phase 6)

Target use: incubator slot states and hatch animation references.

Suggested save name: `assets/design/generated/incubator-stages-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

Create a 2D transparent-background sheet of a cozy straw nest incubator in five separated stages with clear spacing: 1 empty straw nest with a soft blanket, 2 nest holding one cream egg, 3 nest with the egg tilted and tiny motion lines as it wiggles, 4 nest with the egg showing a small clean crack line and a soft light seam, 5 nest with a gentle warm glow burst and floating sparkle dots at the hatch moment, no duck visible yet.

Size: 1:1 square sheet, target 2048x2048, separated for cropping.

Keep the same nest drawing across all five stages. The glow stays soft pastel gold. No scary cracks, no readable text, no Robux, no loot box styling, no dark theme, no realistic 3D render, no watermark.
```

### Hatch Reveal Background

Status: `Ready` (Phase 6)

Target use: full-screen background behind the hatch reveal UI moment.

Suggested save name: `assets/ui/backgrounds/hatch-reveal-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, soft cartoon shapes, cheerful and readable.

Create a clean 16:9 2D background for a hatch reveal moment: a soft radial glow of warm cream and pale gold light centered on screen, gentle pastel sparkle dots, soft teal and sky-blue vignette edges, completely empty center where the egg and duck UI will be placed by the game.

Size: 16:9 landscape, target 1920x1080.

This is a background only. No egg, no duck, no UI, no buttons, no panels, no readable text, no numbers, no icons, no logo, no dark void, no realistic 3D render, no watermark.
```

### Evolution Stage Sheet - Template

Status: `Ready` (Phase 7, run once per approved family)

Target use: Stage 1 to Stage 3 art for one family line.

Suggested save name: `assets/design/generated/evolution-stages-{family-slug}-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

one consistent duck body template across all ducks: round plump body, simple small flat bill, two small dot eyes, small wing bump, short tail nub, no neck, stubby orange feet, three-quarter side view facing right, soft cartoon shading, flat clean 2D, strong readable silhouette, same proportions as a cute round rubber-duck toy.

Create a 2D transparent-background evolution sheet of the {FAMILY} duck with {PALETTE}, shown three times in a row with clear spacing, same pose and same palette, growing fancier left to right: stage one is the plain base duck; stage two is slightly larger with a small soft feather crest on the head, slightly brighter palette, and one tiny sparkle accent; stage three is fullest with a graceful plume crest, longer elegant tail feathers, a delicate thin golden leaf circlet resting on the head, and a very soft warm glow rim.

Size: 1:1 square sheet, target 2048x2048, separated for cropping.

The duck must stay clearly the same family across all three stages. Evolution sparkle stays soft and pastel. No other accessories, no readable text, no Robux, no dark theme, no realistic feathers, no 3D render, no watermark.
```

### Evolution Celebration Background

Status: `Ready` (Phase 7)

Target use: background behind the short skippable evolution celebration scene.

Suggested save name: `assets/ui/backgrounds/evolution-celebration-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, soft cartoon shapes, cheerful and readable.

Create a clean 16:9 2D background for a duck evolution celebration: the cozy pond farm at golden hour with warm soft light, gentle floating sparkle motes, a soft light beam falling on an empty grassy spot at center stage where the evolving duck UI will be placed, teal pond glinting warmly in the background.

Size: 16:9 landscape, target 1920x1080.

This is a background only. No duck, no UI, no buttons, no panels, no readable text, no numbers, no icons, no logo, no dark sky, no realistic 3D render, no watermark.
```

### Progression Item Icon Sheet

Status: `Ready` (Phases 7-12)

Target use: Star Grain, Festival Ticket, Legacy Feather, gift box, and mastery medal icons.

Suggested save name: `assets/design/generated/progression-item-icons-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, soft cartoon shapes, cheerful and readable.

Create a 2D transparent-background icon sheet of special progression items for a cozy duck farming simulator, separated with clear spacing: 1 a small pouch of glowing star-shaped golden grain, 2 a single large star grain kernel with a soft twinkle, 3 a rounded pastel festival ticket with a scalloped edge and small duck silhouette stamp, 4 a large elegant golden feather with a soft glow, 5 a cute wrapped gift box with a coral ribbon bow, 6 three round mastery medals in bronze, silver, and gold with a tiny duck emblem.

Size: 1:1 square sheet, target 2048x2048, separated for cropping, readable at small mobile UI size.

Glow stays soft and pastel. No readable text, no numbers, no Robux, no premium currency styling, no loot boxes, no realistic metal render, no 3D render, no watermark.
```

### Pond Games Battle Scene Mockup

Status: `Ready` (Phase 7B)

Target use: friendly duck contest scene layout reference.

Suggested save name: `assets/ui/mockups/pond-games-scene-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, clean mobile-friendly UI, white panels, coral action buttons, cheerful and readable.

one consistent duck body template across all ducks: round plump body, simple small flat bill, two small dot eyes, small wing bump, short tail nub, no neck, stubby orange feet, soft cartoon shading, flat clean 2D, strong readable silhouette, same proportions as a cute round rubber-duck toy.

Create a 16:9 UI mockup of a friendly duck contest scene at a pond: two teams of three cute round ducks of different colors facing each other across calm teal water, one duck mid-turn sending a playful arc of water splash with soft droplets, small heart and energy-bubble chips above each duck, a row of four large rounded skill buttons with blank icon slots along the bottom center, and a small turn-order strip at the top. The mood is a cheerful pond game between friends, like a splash contest at summer camp, not a fight.

Size: 16:9 landscape, target 1920x1080.

Leave all text areas blank or placeholder marks. No weapons, no anger, no damage effects, no dark arena, no readable text, no numbers, no Robux, no premium currency, no realistic 3D render, no watermark.
```

### Battle Skill and Class Icon Sheet

Status: `Ready` (Phase 7B)

Target use: class badges and the V0 skill icon set.

Suggested save name: `assets/design/generated/pond-games-skill-icons-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, soft cartoon shapes, cheerful and readable.

Create a 2D transparent-background icon sheet for a friendly duck contest mode, separated with clear spacing. Top row, four round class badges: 1 guard, a sturdy bubble shield; 2 splasher, a bold water drop with motion lines; 3 quacker, a cheerful musical quack note; 4 helper, a warm heart with a tiny snack. Below them, sixteen small square skill icons in soft pastel tiles, four per class theme: water splashes and waves, bubble shields and shell guards, music notes, charm sparkles and lullaby moons, snacks, cheer pom-poms, gentle hearts, and feather gusts. All icons must read clearly at small mobile button size.

Size: 1:1 square sheet, target 2048x2048, separated for cropping.

No weapons, no fire, no skulls, no anger, no damage slashes, no readable text, no numbers, no Robux, no rarity glow, no dark theme, no realistic 3D render, no watermark.
```

### Training Camp Scene and Stat Icon Sheet

Status: `Ready` (Phase 7B)

Target use: Training Camp corner scene and the four duck stat icons.

Suggested save name: `assets/design/generated/training-camp-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

Create a 2D sheet with two separated parts. Part one: a cozy duck training camp corner of the farm as a small scene — a tiny obstacle course of stepping stones and a little ramp, a small striped camp tent, a balance log over a puddle, a hanging rope with a tiny flag, a water bucket, and a wooden sign post, warm daylight, no ducks present, with open space where a training duck and timer UI will be placed. Part two: four round stat icons separated for cropping — a warm pink heart for toughness, a bold teal water drop for move strength, a small wing with motion lines for quickness, and a gentle golden sparkle star for helper spirit. Icons must read clearly at small mobile size.

Size: 1:1 square sheet, target 2048x2048, separated for cropping.

The camp must feel like playful summer camp, not boot camp: no weights, no military style, no whistles, no weapons. No readable text, no numbers, no Robux, no dark theme, no realistic 3D render, no watermark.
```

### Farm Zone Background - Meadow

Status: `Ready` (Phase 8)

Target use: second farm zone plain background behind the UI.

Suggested save name: `assets/ui/backgrounds/meadow-background-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

Create a clean 16:9 2D background of a cozy flower meadow zone that belongs to the same farm as the approved pond background: rolling soft green meadow with scattered wildflowers, a small winding brook on the right connecting toward the pond, a wooden stile fence, gentle hills and sky-blue horizon, warm daylight, and open empty areas where UI and ducks will be placed later.

Size: 16:9 landscape, target 1920x1080.

Match the exact rendering style, palette softness, and lighting of the Cozy Pond Farm background so zones feel like one world. This is a background only: no UI, no buttons, no counters, no panels, no cards, no labels, no readable text, no numbers, no menus, no icons, no logo, no ducks, no realistic 3D render, no watermark.
```

### Farm Zone Background - Orchard

Status: `Ready` (Phase 8)

Target use: third farm zone plain background behind the UI.

Suggested save name: `assets/ui/backgrounds/orchard-background-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

Create a clean 16:9 2D background of a cozy orchard zone that belongs to the same farm as the approved pond background: a few round friendly apple trees with soft red fruit, dappled warm light on green grass, a small wooden cart, a low stone-and-wood fence, a glimpse of the pond far in the background, and open empty areas where UI and ducks will be placed later.

Size: 16:9 landscape, target 1920x1080.

Match the exact rendering style, palette softness, and lighting of the Cozy Pond Farm background so zones feel like one world. This is a background only: no UI, no buttons, no counters, no panels, no cards, no labels, no readable text, no numbers, no menus, no icons, no logo, no ducks, no realistic 3D render, no watermark.
```

### Decoration Icon Sheet - Starter Set

Status: `Ready` (Phase 8)

Target use: decoration inventory icons and on-farm decoration art.

Suggested save name: `assets/design/generated/decoration-icons-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

Create a 2D transparent-background icon sheet of eight farm decorations for a cozy duck farming simulator, separated with clear spacing: 1 lily pad cluster with one pink lotus, 2 round flower bed with tulips, 3 small wooden lantern with a warm soft light, 4 cozy wooden bench, 5 little birdhouse on a post, 6 straw bale with a tiny sunflower, 7 small stone pond fountain with a gentle water arc, 8 short white picket fence piece with climbing flowers.

Size: 1:1 square sheet, target 2048x2048, separated for cropping.

Match the Cozy Pond Farm palette: teal water accents, grass green, duck yellow, warm wood, coral and pastel flowers. No readable text, no Robux, no premium tags, no dark theme, no realistic 3D render, no watermark.
```

### Photo Frame and Sticker Sheet

Status: `Ready` (Phase 8)

Target use: Photo Mode V0 starter frames and stickers.

Suggested save name: `assets/design/generated/photo-frames-stickers-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, soft cartoon shapes, cheerful and readable.

Create a 2D transparent-background sheet with two separated parts. Part one: four photo frame borders for landscape photos, each an empty rectangular border with a transparent center — 1 a soft white instant-photo style frame with a wider bottom edge, 2 a warm wooden frame with small leaf corners, 3 a pastel flower garland frame, 4 a playful frame of tiny duck footprints and eggs along the border. Part two: eight small stickers separated for cropping — a pink heart, a sparkle cluster, a smiling sun, an empty rounded speech bubble, a tiny egg, a rainbow arc, a small crown of leaves, and a music note.

Size: 1:1 square sheet, target 2048x2048, separated for cropping, frame centers fully transparent.

No readable text inside any frame or sticker, no numbers, no Robux, no premium tags, no dark theme, no realistic 3D render, no watermark.
```

### Mutation Overlay Sheet

Status: `Ready` (Phase 9)

Target use: approve the six mutation overlay looks on the base duck.

Suggested save name: `assets/design/generated/mutation-overlays-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

one consistent duck body template across all ducks: round plump body, simple small flat bill, two small dot eyes, small wing bump, short tail nub, no neck, stubby orange feet, three-quarter side view facing right, soft cartoon shading, flat clean 2D, strong readable silhouette, same proportions as a cute round rubber-duck toy.

Create a 2D transparent-background sheet of the warm duck-yellow Classic duck shown six times in identical pose with clear spacing, each with one different bold overlay trait that never changes the body shape: 1 sparkle, bright star glints scattered over the back with one larger glint above the wing; 2 marble, a clear swirled two-tone marbling across the wing and back; 3 snowdust, a crisp white dusting cap across head and back; 4 honey, a glossy warm honey patch dripping boldly over the head; 5 tuxedo, a clean high-contrast white chest bib with a deeper back tone; 6 star, one big soft white star marking on the flank.

Size: 1:1 square sheet, target 2048x2048, separated for cropping.

The duck stays clearly the same Classic Yellow duck in all six; only the overlay markings differ. Every marking must remain identifiable when the duck is shrunk to small in-game sprite size, so make each tell bold, clean, and high-contrast rather than faint or delicate. No accessories, no readable text, no large glow auras, no Robux, no realistic feathers, no 3D render, no watermark.
```

### Breeding Nursery Background

Status: `Ready` (Phase 9)

Target use: plain background behind the breeding/nursery UI.

Suggested save name: `assets/ui/backgrounds/nursery-background-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

Create a clean 16:9 2D background of a cozy duck nursery corner of the farm: a warm wooden shelter with a soft straw floor, two cushioned nest spots side by side, a small heart-shaped flower wreath on the wall, gentle morning light, pastel blankets, and open empty areas in the center and right where UI panels will be placed later.

Size: 16:9 landscape, target 1920x1080.

This is a background only: no ducks, no eggs, no UI, no buttons, no panels, no cards, no readable text, no numbers, no icons, no logo, no realistic 3D render, no watermark.
```

### Social UI Mockup (Farm Sign, Leaderboard, Visitor Book)

Status: `Ready` (Phase 10)

Target use: layout reference for likes, leaderboards, and the visitor book.

Suggested save name: `assets/ui/mockups/social-ui-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, soft cartoon shapes, clean mobile-friendly UI, white panels, coral action buttons, cheerful and readable.

Create a 2D UI concept sheet for cozy social features in a duck farming simulator, components separated for reference: 1 a cute wooden farm sign with a blank name area, a small heart-like counter chip, and a tiny duck perched on top; 2 a white rounded leaderboard panel with five row slots, each with an avatar circle, blank name bar, and score chip area; 3 a visitor book panel styled like an open soft paper notebook with small avatar circles and blank line areas; 4 a small gift button and gift box chip.

Size: 1:1 square sheet, target 2048x2048.

Leave all text areas blank or placeholder marks. Hearts and likes stay soft and friendly. No readable text, no numbers, no Robux, no premium currency, no dark theme, no realistic 3D render, no watermark.
```

### Seasonal Event Background - Template

Status: `Ready` (Phase 11, run once per season)

Target use: event-dressed farm background behind the UI during {SEASON} events.

Suggested save name: `assets/ui/backgrounds/event-{season-slug}-background-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

Create a clean 16:9 2D background that is the approved Cozy Pond Farm scene dressed for a {SEASON} festival: keep the same pond on the right, grass on the left, wooden fence, and straw nest area, then add {THEME}. Keep the open empty areas at the top left, top right, bottom center, and right side for UI overlays.

Size: 16:9 landscape, target 1920x1080.

Match the exact rendering style, palette softness, and lighting of the approved farm background so the event feels like the same farm on a special day. This is a background only: no UI, no buttons, no counters, no panels, no cards, no labels, no readable text, no numbers, no menus, no icons, no logo, no ducks, no realistic 3D render, no watermark.
```

### Event Duck Concept - Template

Status: `Ready` (Phase 11, run once per season)

Target use: limited Festival duck family concept for the {SEASON} event.

Suggested save name: `assets/design/generated/event-duck-{season-slug}-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

one consistent duck body template across all ducks: round plump body, simple small flat bill, two small dot eyes, small wing bump, short tail nub, no neck, stubby orange feet, three-quarter side view facing right, soft cartoon shading, flat clean 2D, strong readable silhouette, same proportions as a cute round rubber-duck toy.

Create a 2D transparent-background concept sheet of one festival duck family for a {SEASON} event, using the same body template as all other ducks, with a palette and small festive markings inspired by {THEME}. Show the duck in separated poses with clear spacing: idle facing right, sleeping, happy, and one larger front-facing portrait bust.

Size: 1:1 square sheet, target 2048x2048, separated for cropping.

Festive markings stay painted on the body, like patterns or color washes, not attached objects. No accessories, no hats, no props, no readable text, no Robux, no realistic feathers, no 3D render, no watermark.
```

### Minigame Scene Mockup - Bread Toss

Status: `Ready` (Phase 11)

Target use: full-screen minigame scene layout reference.

Suggested save name: `assets/ui/mockups/bread-toss-scene-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, clean mobile-friendly UI, white panels, coral action buttons, cheerful and readable.

Create a 16:9 UI mockup of a cozy bread toss minigame scene: a wide teal pond filling most of the screen with three cute round yellow ducks swimming at different distances, a small wooden dock ledge at the bottom center where bread pieces are thrown from, a soft dotted arc line showing one throw path, a round timer area at top center, and a score chip area at top right. Keep generous mobile-friendly spacing and large readable shapes.

Size: 16:9 landscape, target 1920x1080.

Leave all text areas blank or placeholder marks. No readable text, no numbers, no Robux, no premium currency, no dark theme, no realistic 3D render, no watermark.
```

### Minigame Scene Mockup - Lily Hop

Status: `Ready` (Phase 11)

Target use: full-screen minigame scene layout reference.

Suggested save name: `assets/ui/mockups/lily-hop-scene-cozy-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, clean mobile-friendly UI, white panels, coral action buttons, cheerful and readable.

Create a 16:9 UI mockup of a cozy lily pad hopping minigame scene: a calm teal pond seen slightly from above with a winding path of round lily pads crossing the screen, one cute round yellow duck mid-hop between pads with small motion lines, a few pads gently glowing as the next safe step, a round timer area at top center, and a streak chip area at top right. Keep generous mobile-friendly spacing and large readable shapes.

Size: 16:9 landscape, target 1920x1080.

Leave all text areas blank or placeholder marks. The glow stays soft pastel. No readable text, no numbers, no Robux, no premium currency, no dark theme, no realistic 3D render, no watermark.
```

### Golden Pond Background

Status: `Ready` (Phase 12)

Target use: Legacy farm background variant behind the UI.

Suggested save name: `assets/ui/backgrounds/golden-pond-background-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

Create a clean 16:9 2D background that is the approved Cozy Pond Farm scene with one prestige change: the pond water is a warm shimmering soft gold instead of teal, with gentle golden sparkle motes above the water and a few floating golden lily pads. Everything else stays the same cozy farm: green grass on the left, wooden fence, straw nest area, sky-blue feel, and the same open empty areas for UI overlays.

Size: 16:9 landscape, target 1920x1080.

The gold stays warm, soft, and cozy, never harsh or metallic. This is a background only: no UI, no buttons, no counters, no panels, no cards, no labels, no readable text, no numbers, no menus, no icons, no logo, no ducks, no realistic 3D render, no watermark.
```

### Accessory Icon Sheet - Concept Only

Status: `Ready for concepts (Monetization Wave 1 is planned in docs/PRODUCT_PLAN.md; final art and import wait for the wave sign-off)`

Target use: cosmetic accessory exploration for Wave 1 (`Cozy Basics` pack: coral bow, knitted scarf, flower clip; Supporter `Sunny Bow`) and later packs. Do not import accessory assets into the game before the wave's one-line sign-off.

Suggested save name: `assets/design/generated/accessory-icons-concept-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, soft cartoon shapes, cheerful and readable.

Create a 2D transparent-background icon sheet of small cosmetic duck accessories for a cozy duck farming simulator, separated with clear spacing: a tiny coral bow, a soft knitted scarf, a small flower clip, a tiny straw sun hat, a little leaf cap, and a small round pair of reading glasses. Each accessory is drawn alone at the angle it would sit on a round duck head or neck, small enough to never hide the duck's body silhouette.

Size: 1:1 square sheet, target 2048x2048, separated for cropping.

No ducks in this sheet, no readable text, no Robux, no price tags, no premium badges, no rarity glow, no dark theme, no realistic 3D render, no watermark.
```

## Marketing Asset Prompts

Store presence assets for the full-launch checklist in `docs/PRODUCT_PLAN.md`. Thumbnails carry no baked text; any title or callout text is composited later so it stays editable and translatable.

### Game Icon

Status: `Ready` (before full launch)

Target use: the Roblox experience icon. Must read at very small sizes.

Suggested save name: `assets/design/generated/game-icon-duck-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

Create a 2D game icon: one cute round yellow duck face filling most of the frame, slightly tilted with a happy friendly expression, simple small flat orange bill, two dot eyes, on a soft teal pond-water background with one or two subtle lily pad shapes in the corners. Bold, simple, and readable at thumbnail size with a strong silhouette and high contrast between the yellow duck and teal background.

Size: 1:1 square, target 1024x1024.

No text, no logo, no eggs, no UI, no border, no rarity effects, no Robux, no realistic 3D render, no clutter, no watermark.
```

### Store Thumbnail Scene Table

Fill `{SCENE}` from this table, one run per scene. Refresh the set at each named update.

| Scene | Scene text |
| --- | --- |
| Farm overview | the cozy pond farm in full: pond, grass, fence, nest, and five happy round ducks of different colors wandering and one duck sleeping |
| Hatching moment | a straw nest incubator center frame with a golden egg mid-hatch, a soft warm glow burst, sparkle motes, and two excited ducks watching from the sides |
| Family lineup | six round ducks of different color families standing in a proud row on the grass by the pond, like a team photo |
| Decorated farm | the pond farm dressed with decorations: string lanterns, flower beds, a fountain, a bench, and three ducks enjoying the garden |
| Friends visiting | two groups of colorful ducks greeting each other by the pond with small heart shapes floating above, a gift box on the grass |

### Store Thumbnail - Template

Status: `Ready` (before full launch, run once per scene)

Target use: Roblox experience thumbnails; five scenes per the scene table.

Suggested save name: `assets/design/generated/thumbnail-{scene-slug}-v1.png`

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, cheerful and readable.

one consistent duck body template across all ducks: round plump body, simple small flat bill, two small dot eyes, small wing bump, short tail nub, no neck, stubby orange feet, soft cartoon shading, flat clean 2D, strong readable silhouette, same proportions as a cute round rubber-duck toy.

Create a 16:9 promotional illustration for a cozy duck farming game showing {SCENE}. Composition: bright, warm, and joyful, with the main subject large and centered-left, generous sky and grass space on the right third for later text compositing, saturated but soft Cozy Pond Farm palette: duck yellow, teal pond water, grass green, sky blue, coral and pastel accents.

Size: 16:9 landscape, target 1920x1080.

No readable text, no logo, no UI, no buttons, no panels, no numbers, no Robux, no rarity glow except soft pastel hatch sparkle where the scene calls for it, no humans, no realistic 3D render, no watermark.
```

## Approved Prompts

### Cozy Pond Farm Style Anchor

```text
cute cozy 2D Roblox duck farming simulator, bright pond farm, soft cartoon shapes, clean mobile-friendly UI, yellow ducks, teal pond water, green grass, white panels, coral action buttons, cheerful and readable
```

## Rejected Prompts

No rejected prompts yet.

## Review Log

Record useful generated outputs here.

| Date | Prompt | Output File | Decision | Notes |
| --- | --- | --- | --- | --- |
| 2026-04-14 | Duck Icon Sheet | `assets/design/generated/Duck.png` | Approved duck direction | Strong Cozy Pond Farm duck style and useful expression sheet. Runtime duck asset reference is being tested with `rbxthumb://type=Asset&id=112605029010428&w=420&h=420` in `src/shared/AssetIds.luau` because the direct `rbxassetid` did not render in Studio. |
| 2026-04-14 | Egg Icon Sheet | `assets/design/generated/Egg.png` | Approved icon direction | Clean readable egg shapes that match the style. Runtime egg icon reference set to `rbxthumb://type=Asset&id=78800189100500&w=420&h=420` in `src/shared/AssetIds.luau`. |
| 2026-04-14 | Coin Icon | `Roblox asset 117857407825759` | Approved icon direction | Runtime coin icon reference set to `rbxthumb://type=Asset&id=117857407825759&w=420&h=420` in `src/shared/AssetIds.luau`. |
| 2026-04-14 | Farm Background - Plain Environment | `assets/design/generated/Farm Background.png` | Approved for prototype | Meets plain-background rule: pond, grass, fence, nest, open UI space, and no buttons/counters/panels/text. Runtime asset reference set to `rbxassetid://133911690307166` in `src/shared/AssetIds.luau`. |

## Open Design Questions

- Should the farm screen show a background image, a UI panel layout, or both?
- Should generated assets be square icons, full UI mockups, or separate transparent cutouts?