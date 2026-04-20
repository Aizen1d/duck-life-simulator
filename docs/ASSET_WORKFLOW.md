# Asset Workflow

Use `assets` for design references, approved generated images, and UI assets that are useful to the project.

Do not store every generated experiment in Git. Keep the repo focused on assets that help build or explain the game.

## Folder Structure

```text
assets/
  design/
    references/
    generated/
    approved/
  ui/
    icons/
    backgrounds/
    mockups/
```

## Folder Rules

- `assets/design/references`: Style references, sketches, screenshots, and inspiration that explain the intended design direction.
- `assets/design/generated`: Temporary Nano Banana Pro outputs and experiments. This folder is ignored by Git.
- `assets/design/approved`: Generated or edited images approved as useful project direction.
- `assets/ui/icons`: Final or likely-final icon assets, such as duck, egg, coin, and upgrade icons.
- `assets/ui/backgrounds`: Plain background images only. Do not put screenshots or mockups with buttons, counters, panels, text, or UI components here.
- `assets/ui/mockups`: UI mockups and layout references. These may include buttons, counters, panels, and other interface components.

## Size Guidelines

- Prefer compressed `.png`, `.jpg`, or `.webp` files.
- Use `.png` for transparent icons and UI cutouts.
- Use `.jpg` or `.webp` for large backgrounds and mockups when transparency is not needed.
- Keep individual files under 1-2 MB when practical.
- If tracked assets grow past 50-100 MB, review and remove unused or duplicate files.

## Promotion Flow

1. Generate experiments into `assets/design/generated`.
2. Review the outputs against `docs/DESIGN_PROMPTS.md`.
3. Move only useful images into the correct tracked folder: plain environments to `assets/ui/backgrounds`, UI layout concepts to `assets/ui/mockups`, cropped icons to `assets/ui/icons`, and broader approved references to `assets/design/approved`.
4. Update `docs/DESIGN_PROMPTS.md` with prompt notes and approval status.
5. Update `docs/DESIGN_INPUTS.md` when a design direction becomes confirmed.

## Runtime Image Assets

Roblox UI cannot display the temporary local `.png` files from `assets/design/generated` by path. Approved images need to be imported into Roblox Studio or uploaded to Roblox, then referenced from code with a Roblox content string.

Use `src/shared/AssetIds.luau` as the single runtime registry for image references. Do not hardcode image IDs directly inside UI components.

First runtime image slots:

- `farmBackground`: plain farm background behind the UI.
- `duck`: first duck visual or cropped duck asset.
- `duckRight`: right-facing duck visual for autonomous wandering.
- `duckLeft`: left-facing duck visual for autonomous wandering. If this is empty, the UI may use a thumbnail rectangle flip fallback only when the configured duck image exposes a known thumbnail size.
- `eggIcon`: egg counter icon.
- `coinIcon`: coin counter icon.

Accepted values:

- `rbxgameasset://Images/asset-name` for images imported into the current experience through Studio.
- `rbxassetid://123456789` for uploaded Roblox image assets.
- `rbxthumb://type=Asset&id=123456789&w=420&h=420` for quick visibility testing when a direct image content ID is not resolving yet.

Recommended first import names:

- `farm-background-cozy-v1`
- `duck-yellow-right-v1`
- `duck-yellow-left-v1`
- `egg-icon-v1`
- `coin-icon-v1`

If an asset slot is empty, the UI renders the current simple placeholder shape. This keeps the game testable while real assets are still being prepared.

## Prototype Variant Rule

For the first playable prototype, use one approved variant per needed visual target. Do not keep generating or shipping multiple near-duplicate variants for the same purpose.

Recommended first targets:

- One plain farm background.
- One right-facing duck visual and one matching left-facing duck visual.
- One egg icon.
- One coin icon.
- One UI button and panel style.

Use temporary placeholders only when the approved variant has not been chosen or prepared yet. Once a variant is approved, promote it into the correct tracked folder and treat later alternatives as future polish, not prototype blockers.

## Agent Rules

- Do not commit large batches of near-duplicate generated images.
- Do not treat generated art as final until the user approves it.
- Do not add copyrighted or unclear-license images as source assets unless the user confirms they can be used.
- Keep image filenames descriptive, lowercase, and hyphenated, such as `duck-icon-yellow-v1.png`.