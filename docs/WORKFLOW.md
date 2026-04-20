# Development Workflow

This project is set up for file-based Roblox development with Rojo.

## One-Time Setup

Install Aftman tools from the repository root:

```powershell
aftman install
```

Confirm Rojo is available:

```powershell
rojo --version
```

The Rojo and Wally versions are defined in `aftman.toml`.

Install Luau packages:

```powershell
wally install
```

Run `wally install` after changing `wally.toml` or `wally.lock`.

## Build a Place File

Create a Roblox place file from the repository:

```powershell
rojo build -o "Duck.rbxlx"
```

Open `Duck.rbxlx` in Roblox Studio when you want a file-based snapshot of the current project.

## Sync with Roblox Studio

Start the Rojo server from the repository root:

```powershell
rojo serve
```

Then connect from Roblox Studio using the Rojo plugin. Studio will receive changes from the mapped source folders.

## Typical Edit Loop

1. Edit files under `src` or `docs`.
2. If Studio sync is needed, keep `rojo serve` running.
3. Test behavior in Roblox Studio.
4. Run `wally install` after dependency changes.
5. For project mapping changes, run `rojo build -o "Duck.rbxlx"`.
6. Run the documentation impact check in `docs/DOC_UPDATE_POLICY.md`.
7. Update docs when workflow, behavior, bug history, or project structure changes.

## Pre-Build Readiness Check

Before starting a new gameplay implementation pass:

1. Run `wally install` if dependencies changed or `Packages` is missing.
2. Run `rojo build -o "Duck.rbxlx"` to confirm the place builds.
3. Verify Markdown links when docs changed.
4. Check `docs/TASKS.md` for unresolved setup or design decisions.
5. Confirm whether the prototype should use temporary placeholders or approved assets.

The project can start coding when Rojo builds, packages are installed, and any required product decisions for the next feature are confirmed.

## Documentation Impact Check

Before finishing any task, check whether the work changed mechanics, UI, economy, project structure, workflow, known bugs, tasks, or decisions. If it did, update the relevant Markdown files in the same change.

Use `docs/DOC_UPDATE_POLICY.md` as the source of truth for when and where to update docs.

For bug fixes, update `docs/CHANGELOG.md` under `Fixed`. If testing is incomplete or a regression check is needed, add a task to `docs/TASKS.md`.

## Documentation Changes

For documentation-only work:

- Do not change Luau files.
- Do not change `default.project.json`.
- Verify README links and docs links.
- Update `docs/CHANGELOG.md` for meaningful documentation milestones.

## Code Changes

For Luau changes:

- Keep client code in `src/client`.
- Keep server-authoritative logic in `src/server`.
- Put shared modules in `src/shared` only when both runtimes need them.
- Use Wally packages from `ReplicatedStorage.Packages` after they are installed.
- Validate all client input on the server.
- Prefer small modules with explicit responsibilities.

## Save Data Work

Save Data V0 is documented in `docs/SAVE_DATA_DESIGN.md` but is not implemented yet.

Before implementing persistence:

- Review the proposed V0 save scope and open questions.
- Check official Roblox DataStore docs again if implementation details have changed.
- Use a separate test experience for Studio DataStore testing.
- Enable Studio access to API services only for that test experience.
- Do not point Studio tests at live production data.
- Plan tests for first join, rejoin, player leave save, autosave, server shutdown save, malformed loaded data, and DataStore request failures.
## Current Prototype Studio Test

After syncing or building the current prototype, use Roblox Studio Play mode to check:

Roblox Studio Play mode includes a small top-center `Tester` panel for speeding through the session-only prototype loop. It is development-only and should not appear outside Studio. Use `+100 Coins`, `+10 Ready`, `+1 Duck`, `Need`, `Hungry`, and `Reset` when testing later-loop states or care requests without waiting for normal farming timers. On short landscape screens, tap the compact `TEST` pill to expand the tester controls.

1. The farm background, duck, egg icon, and coin icon render.
2. The egg and coin counters start at `0`.
3. The Studio-only `Tester` panel appears in Play mode and its buttons update the session state.
4. The egg status card shows next-egg progress while no eggs are ready, then switches to ready-egg messaging.
5. The collect button shows a countdown, then becomes usable after about `5` seconds.
6. The duck idles with small autonomous motion without user movement input.
7. Tap or left-click visible ducks, including compact or overlapping groups, and confirm the nearest intended duck receives the saturated duck-yellow highlight plus care bubble with a `Profile` button. Then tap or click nearby empty scene space and confirm it does not select a duck; empty scene space should close the bubble and profile panel.
8. Use `+1 Duck` until there are several ducks, then select each duck and confirm the quick bubble shows a generated duck name. Names should be unique within the current session duck list. Click `Profile` from the bubble and confirm Duck Profile V0 opens with level/XP, mood, need, care readiness, Rename V0 controls, and `Session-only duck`. On wider screens, confirm the panel opens beside the selected duck and flips left or right near screen edges. On compact screens, confirm it uses the anchored fallback placement.
9. From a duck profile, click `Rename`, submit a valid `2` to `16` character name, and confirm the bubble and profile update after the server response. With multiple ducks, try a duplicate name and confirm `Name already used`. Try too-short and too-long names and confirm the profile footer shows the server error without changing the duck name. If Roblox text filtering fails in Studio, confirm the old name remains and the footer shows `Name could not be checked` or `Try another name`.
10. Use the Studio-only `Hungry` tester button with `0` Duck Feed and confirm the selected duck bubble says `Hungry?` with `Need feed` disabled. Buy Duck Feed in the shop, return to the farm, use `Hungry` again if needed, and confirm the bubble button says `Feed`.
11. Tap or left-click the prompted duck, confirm the care bubble says `Pet me?` or `Hungry?`, click `Profile`, confirm the profile panel matches the request, then click `Care` or `Feed` and confirm the request clears. While a request is active, tap another duck and confirm its profile can still be opened while its care action is disabled until the request is handled.
12. Clicking `Care` or `Feed` from a duck bubble changes only the targeted duck mood to `Happy`, shows happy or fed feedback, briefly pulses only that duck, starts that duck cooldown, and consumes `1` Duck Feed only for `Hungry?` requests.
13. Select a duck after care or feed and confirm its bubble shows level progress. Open `Profile` and confirm the profile panel also shows level progress. Repeat care/feed enough times to reach `100` XP and confirm `Level up` feedback appears.
14. Confirm care and feed level progress does not change egg production, prices, upgrade state, or save data, and that caring for one duck does not put every duck on cooldown.
15. The egg-ready badge and nest egg pile appear when at least one egg is available.
16. Clicking `Collect` clears the nest egg pile, moves ready eggs into the egg counter, and shows egg feedback.
17. Clicking `Sell` converts eggs into coins and shows coin feedback.
18. After reaching `10` coins, the Egg Value upgrade can be bought once.
19. After the upgrade, the egg value displays as `2` coins per egg, the upgrade button is maxed, and upgrade feedback appears.
20. After reaching `25` coins, `Buy Duck` can be bought.
21. Buying a duck subtracts the shown cost, increases the duck count, gives the new duck a generated unique name, shows duck feedback, displays more ducks up to the visible cap, and increases egg production on later egg cycles.
22. Confirm the next Buy Duck costs scale as `25`, `50`, `75`, `100` for duck counts `1`, `2`, `3`, `4`.
23. Click or tap `Shop`, confirm the farm fades to a placeholder shop scene, the back button returns to the farm/lawn with a fade, and normal farm controls resume after returning.
24. In the shop, buy `Duck Feed` after earning at least `5` coins. Confirm coins decrease by `5`, feed count increases, and feed feedback appears.
25. Resize the Studio viewport or use device emulation to confirm the compact UI layout remains usable, including iPhone 14 landscape around `852x393`; counters, buttons, and progression cards should feel scene-framing rather than dominant.
26. Roblox Studio Output has no script errors or infinite-yield warnings from the Duck source scripts.

## Studio-Only Changes

Some Roblox assets and settings may be easier to create in Studio. If a change cannot be represented cleanly in Rojo source files, document the manual Studio step and consider whether the asset should be exported into the repository later.

## Git Note

This workspace may report a Git safe-directory warning if the repository owner differs from the current Windows user. Do not change global Git config unless the user approves it.

