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
- Avoid adding mechanics, rarity tiers, characters, Robux, premium currency, ads, loot boxes, or monetization.

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

## Design Agent Review Notes

For each generated image, review:

- Does it fit Cozy Pond Farm?
- Is it readable on mobile?
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