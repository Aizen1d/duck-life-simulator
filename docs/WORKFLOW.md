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

## Security Test Pass

Before treating remote-heavy gameplay as ready for broader testing, run the invalid remote cases in [Security Test Cases](SECURITY_TESTS.md). These checks cover malformed action names, invalid shop and duck payloads, rename validation, Egg Catch duplicate reward claims, Farm Visit V0 read-only permission checks, and Studio-only tester guards.

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

Save Data V0 is implemented and documented in `docs/SAVE_DATA_DESIGN.md`.

When changing persistence:

- Follow the approved V0 save scope in `docs/SAVE_DATA_DESIGN.md`.
- Check official Roblox DataStore docs again if implementation details have changed.
- Use this current place for V0 DataStore testing, as approved by the user.
- Keep Studio access to API services enabled deliberately for this place while testing persistence.
- Keep Studio-only tester paths guarded by `RunService:IsStudio()`.
- Test first join, rejoin, held eggs, ready nest eggs, coins, Duck Feed, Premium Feed, Treat, Pillow, and Toy inventory, Egg Value level, duck names/profiles, duck level/XP, Quest V0/V1/V2 level/progress, `lastDailyClaimDay`, player leave save, autosave about `3` seconds after a change, shutdown save, malformed loaded data, and DataStore request failures. The farm screen should not show a save status indicator. A load failure must not write a default save over existing data; use Studio Output logs and rejoin checks to verify save behavior.

## Current Prototype Studio Test

After syncing or building the current prototype, use Roblox Studio Play mode to check:

Roblox Studio Play mode includes a small top-center `Tester` panel for speeding through the prototype loop. It is development-only and should not appear outside Studio. Use `+100 Coins`, `+10 Ready`, `+1 Duck`, `Need`, `Hungry`, `Sleepy`, `Dirty`, `Thirsty`, `Bored`, `Guide`, `Sun`/`Cld`/`Rain`/`Stm` weather cycle, and `Reset` when testing later-loop states, persistence, onboarding, or care requests without waiting for normal farming timers. On short landscape screens, tap the compact `TEST` pill to expand the tester controls.

1. Confirm Studio API services are enabled for this place before testing persistence.
2. The farm background, duck, egg icon, and coin icon render.
3. The egg and coin counters start from saved data if it exists, or `0` for a fresh save. Fresh profiles should also start with `Duck Feed x1` and show a one-time `Starter Feed x1` feedback toast that matches the configured starter grant amount.
4. The Studio-only `Tester` panel appears in Play mode and its buttons update the server state.
5. The egg status card shows next-egg progress while no eggs are ready, then switches to ready-egg messaging. Large ready counts should stay readable without overlapping the progress bar.
6. The collect button shows a countdown, then becomes usable after about `5` seconds.
7. The duck idles with small autonomous motion without user movement input.
8. Tap or left-click visible ducks, including compact or overlapping groups, and confirm the nearest intended duck receives the saturated duck-yellow highlight plus care bubble with a `Profile` button. Then tap or click nearby empty scene space and confirm it does not select a duck; empty scene space should close the bubble and profile panel.
9. Use `+1 Duck` until there are several ducks, then select each duck and confirm the quick bubble shows a generated duck name. Names should be unique within the current duck list. Click or tap `Profile` from the bubble and confirm Duck Profile V0 opens with level/XP, mood, need, care readiness, kid-friendly `Egg Boost` and `Level Up` derived stats, Treat count, a `Give Treat` action, Rename V0 controls, and a footer that shows Treat count by default or a rename error when needed. On wider screens, confirm the panel opens beside the selected duck and flips left or right near screen edges. On compact screens, confirm it uses the anchored fallback placement. Click or tap blank space inside the profile panel or selected-duck bubble and confirm it stays open; click or tap outside the panel and selected duck controls to close it.
10. From a duck profile, click `Rename`, submit a valid `2` to `16` character name, and confirm the bubble and profile update after the server response. With multiple ducks, try a duplicate name and confirm `Name already used`. Try too-short and too-long names and confirm the profile footer shows the server error without changing the duck name. If Roblox text filtering fails in Studio, confirm the old name remains and the footer shows `Name could not be checked` or `Try another name`.
11. Use the Studio-only `Hungry` tester button with `0` Duck Feed and confirm the selected duck bubble says `Hungry?` with `Need feed` disabled. Use the Studio-only `Sleepy` tester button and confirm the bubble says `Sleepy?` with a `Rest` action. Use the Studio-only `Dirty` tester button and confirm the bubble says `Dirty?` with a `Clean` action. Use the Studio-only `Thirsty` tester button and confirm the bubble says `Thirsty?` with a `Drink` action and a `Drink +25 XP` feedback when used. Use the Studio-only `Bored` tester button and confirm the bubble says `Bored?` with a `Play` action and a `Play +25 XP` feedback when used with no Toy in inventory. On a fresh profile, confirm the starter `Duck Feed x1` is present. After finishing onboarding on a fresh profile, if the first duck-help action was not hungry, confirm a hungry request appears soon after and can use the starter feed. Buy Duck Feed in the shop or use the starter feed, return to the farm, use `Hungry` again if needed, and confirm the bubble button says `Feed` when only basic feed is stocked. Buy `Premium Feed`, trigger `Hungry` again, and confirm the bubble prefers `Premium Feed`, consumes premium inventory first, and shows the stronger `Premium +55 XP` feedback path. Buy a `Pillow`, trigger `Sleepy` again, and confirm the bubble's `Rest` action now consumes Pillow inventory first and shows the stronger `Pillow +45 XP` feedback path, while a Sleepy request with no Pillow still falls back to `Rest +25 XP`. Buy a `Toy`, trigger `Bored` again, and confirm the bubble's `Play` action now consumes Toy inventory first and shows the stronger `Toy +50 XP` feedback path, while a Bored request with no Toy still falls back to `Play +25 XP`. Then buy a Treat, open a duck profile, click `Give Treat`, and confirm Treat inventory decreases, the treated duck gains XP, and the floating Treat feedback shows the configured XP amount. Item gains should use readable `Feed xN`, `Premium xN`, `Treat xN`, `Pillow xN`, or `Toy xN` feedback.
12. Confirm the farm quest tracker stays compact by default, and tapping or clicking it expands the full quest list. Collect ready eggs and confirm `Collect eggs` progresses by the collected amount. Sell held eggs and confirm `Sell eggs` progresses by the sold amount. Use `Need`, `Hungry`, `Sleepy`, `Dirty`, `Thirsty`, or `Bored`, then care/feed/rest/clean/drink/play with the requested duck and confirm `Help ducks` progresses by `1` and any duck level-up advances `Level up ducks` by the number of levels gained. Use `Give Treat` on a duck profile and confirm `Use treats` progresses by `1` per Treat consumed and any resulting level-up advances `Level up ducks`. Buy a duck and confirm `Buy ducks` progresses by `1` plus `Spend coins` progresses by the duck cost. Buy a shop item or upgrade Egg Value and confirm `Spend coins` progresses by that cost. Finish an Egg Catch round and confirm `Win Egg Catch` progresses by `1` per successful reward claim. Complete quests and confirm coins increase, quest-complete feedback shows the current reward summary, quest levels increase, overflow progress carries into the next level, `Collect eggs` can grant `Duck Feed x1` every `3` completed levels, `Sell eggs` can grant `Duck Feed x1` every `2` completed levels, `Help ducks` can grant `Treat x1` every `3` completed levels, `Use treats` can grant `Treat x1` every `4` completed levels, `Buy ducks` can grant `Pillow x1` every `3` completed levels, and `Spend coins` can grant `Duck Feed x1` every `3` completed levels. When the current quest level will grant an item milestone, confirm the expanded quest row shows that Duck Feed, Treat, or Pillow reward beside the coin reward.
13. Use the Studio-only weather tester button and confirm it cycles `Sun` → `Cld` → `Rain` → `Stm` → `Sun`, the farm weather badge updates to `Sunny`, `Cloudy`, `Rainy`, or `Stormy` with distinct text and color, rainy weather adds a soft overlay, stormy adds a darker overlay with more rain particles, sunny and cloudy clear it, cloudy mildly increases `Dirty?` frequency, rainy increases `Sleepy?` frequency, stormy increases both, and weather does not change eggs, coins, prices, inventory, or saved values.
14. Tap or left-click the prompted duck, confirm the care bubble says `Pet me?`, `Hungry?`, `Sleepy?`, or `Dirty?`, click `Profile`, confirm the profile panel matches the request, then click `Care`, `Feed`, `Rest`, or `Clean` and confirm the request clears. While a request is active, tap another duck and confirm its profile can still be opened while its care action is disabled until the request is handled.
15. Clicking `Care`, `Feed`, `Rest`, or `Clean` from a duck bubble changes only the targeted duck mood to `Happy`, shows `Care +25 XP`, `Feed +35 XP`, `Premium +55 XP`, `Rest +25 XP`, or `Clean +25 XP` feedback as appropriate, briefly pulses only that duck, starts that duck cooldown, and consumes feed only for `Hungry?` requests.
16. Select a duck after care, feed, rest, clean, or a Treat and confirm its bubble shows level progress. Open `Profile` and confirm the profile panel also shows level progress. Repeat care/feed/rest/clean or use Treats enough times to reach `100` XP and confirm `Level up` feedback appears.
17. After a duck levels up, keep farming for several egg cycles and confirm higher-level ducks contribute more egg output than level `1` ducks at the approved `+10%` per-level bonus. Use the selected-duck profile subtitle multiplier and the egg status card rate readout to verify the bonus directly. Because production uses fractional carry, verify the bonus over multiple egg cycles instead of expecting every cycle to round up immediately.
18. Confirm care, feed, rest, and clean do not instantly change prices, coin value, or quest rewards, and that caring for one duck does not put every duck on cooldown. The only current production gain from care should come through duck level progression.
19. Confirm the duck-level production bonus only changes egg output pace and available egg totals; it should not change egg value, shop prices, quest math, or upgrade costs, and caring for one duck should still not put every duck on cooldown.
20. The egg-ready badge and nest egg pile appear when at least one egg is available.
21. Clicking `Collect` clears the nest egg pile, moves ready eggs into the egg counter, and shows egg feedback.
22. Clicking `Sell` converts eggs into coins and shows coin feedback.
23. After reaching `10` coins, the Egg Value upgrade can be bought, raising sell value from `1` to `2`. Continue earning coins and confirm each subsequent tier costs `25`, `60`, `140`, and `320` coins, that the egg value rises by `1` each tier, that the upgrade button only shows the max state after the fifth tier, that `Spend coins` quest progresses by each tier's cost, and that upgrade feedback appears.
24. After all five upgrade tiers, the egg value displays as `6` coins per egg and the upgrade button is maxed.
25. After reaching `25` coins, `Buy Duck` can be bought.
26. Buying a duck subtracts the shown cost, increases the duck count, gives the new duck a generated unique name, shows duck feedback, displays more ducks up to the visible cap, and increases egg production on later egg cycles.
27. Confirm the next Buy Duck costs scale as `25`, `50`, `75`, `100` for duck counts `1`, `2`, `3`, `4`.
28. Click or tap `Shop`, confirm the farm fades to a placeholder shop scene, the back button returns to the farm/lawn with a fade, the item cards clearly show each item's purpose, cost, and owned count, and normal farm controls resume after returning. In short landscape, confirm the three shop cards fit below the header without overlapping their buy buttons.
29. In the shop, buy `Duck Feed` after earning at least `5` coins, `Premium Feed` after earning at least `12` coins, `Treat` after earning at least `15` coins, `Pillow` after earning at least `8` coins, and `Toy` after earning at least `10` coins. Confirm coins decrease by the shown costs, feed, Treat, Pillow, or Toy counts increase, and the matching feedback appears. The bag readout in the shop should show `Feed`, `Premium`, `Treat`, `Pillow`, and `Toy` counts.
30. Click `Minigames`, confirm the farm fades to a minigames menu, start `Egg Catch`, and confirm the round uses a full-screen play scene. On desktop, move the mouse and confirm the catcher follows it; also confirm `A`/`D` or arrow keys still work. On touch/mobile, confirm drag and the on-screen `Left` and `Right` buttons both move the catcher. Finish the `20` second round, confirm the results screen appears with caught, missed, best-streak, and reward text, and confirm the Duck UI stays mounted instead of dropping back to the Roblox world. Wait for the automatic reward claim, then return to the farm and confirm coins, Duck Feed, or Treat update only when the result earned them, while duck XP, quests, and unrelated save fields do not change.
31. Change coins, held eggs, ready nest eggs, duck count, duck names, duck level/XP, Duck Feed, Premium Feed, Treat, Pillow, Toy inventory, Egg Value level, Quest V0/V1/V2 progress, or claim Daily Check-in, then wait a few seconds for autosave. Confirm Studio Output prints `[Duck] Saved data`. Stop Play, start Play again, confirm Output prints `[Duck] Loaded save data`, and confirm those values reload. For leave-save specifically, change a value and stop before autosave completes; Output should print `[Duck] Saving data for ... on leave` or `[Duck] Saving data for ... during shutdown`, followed by `[Duck] Saved data`.
32. Resize the Studio viewport or use device emulation to confirm the compact UI layout remains usable, including iPhone 14 landscape around `852x393`; counters, buttons, tester controls, weather badge, expandable compact quest tracker, secondary Minigames button, and the collapsed `Upgrades` panel should feel scene-framing rather than dominant. Open `Upgrades` in short landscape and confirm the horizontal Egg Value/Buy Duck tray stays above the action bar with the close button still reachable. Confirm Egg Value and Buy Duck are accessible from `Upgrades`, and that the Buy Duck onboarding step still opens/highlights the needed action.
33. With a fresh profile or cleared save, confirm Guide/Tutorial V0 auto-opens on the farm after loading, starts with starter `Duck Feed x1`, walks through `Collect`, `Sell`, `Buy Duck`, `Shop`, and duck care, and stays readable in compact/mobile layouts. Confirm there are no manual `Back`, `Next`, `Skip`, or `Done` controls. Confirm each successful required action auto-advances the guide, only the current highlighted action is usable on the farm, other farm actions and Studio tester controls stay blocked, and the Buy Duck step still allows `Collect` and `Sell` until Buy Duck is affordable. Confirm the duck-care step allows only the requested duck and its care action, opening `Shop` keeps the guide on the shop step, the shop view highlights `Back` as the only useful action there, returning to the farm advances the guide to duck care, the guide ends after the first successful duck-help action, and if that action was not hungry a hungry request appears soon after for the starter feed.
34. In a multi-player Studio test, open `Visit`, confirm the panel shows same-server farm cards or the same-server-only empty state in a bottom drawer/tray above the action bar, with compact/mobile using full width and desktop using a centered tray. Choose another loaded same-server player's farm by clicking or tapping either its row or `View`/`Help` badge, and confirm the viewed farm shows the owner's counters, ducks, weather, quests, and egg status. Confirm the owner-side `Visitor Help` toggle defaults off, farm cards and the visited-farm banner update when it is turned on, visitors can help only active `Pet me?`, `Sleepy?`, or `Dirty?` requests, and `Hungry?` remains blocked from visitor help. Confirm visitor help clears the request but does not change owner XP, quest progress, coins, inventory, save data, production, names, or rewards. Confirm `Collect`, `Sell`, `Shop`, `Upgrades`, `Games`, tester buttons, normal care, Treat, and Rename actions cannot affect the owner while visiting, then use `Home` and confirm the viewer's own farm state returns unchanged.
35. Run the invalid remote cases in [Security Test Cases](SECURITY_TESTS.md), especially malformed payloads, duplicate Egg Catch reward claims, direct gameplay actions while visiting another farm, visitor help permission checks, and tester-action guards.
36. Earn enough coins for the counter to cross `1000`, `10000`, `100000`, and `1000000` thresholds (use the Studio-only `+100` tester button repeatedly or grant a large coin balance manually). Confirm the farm coin counter and shop coin counter both switch from exact integers to `1.2k`, `12k`, `120k`, and `1.2M` style abbreviations while shop item costs and progression card `Need X coins` copy still show exact coin counts.
37. On a fresh profile or after rolling a fresh UTC day, confirm joining the farm produces a `Daily +20 coins` toast and the coins counter rises by `20` once. Rejoin within the same UTC day (or trigger `claim_daily_check_in` again directly) and confirm no further coin grant occurs. Re-test on the next UTC day or by manually advancing the system clock and confirm the claim is offered again. The toast should not affect Quest V0/V1/V2 progress, inventory, or any other save value besides `coins` and `lastDailyClaimDay`.
38. Roblox Studio Output has no script errors or infinite-yield warnings from the Duck source scripts.

## Studio-Only Changes

Some Roblox assets and settings may be easier to create in Studio. If a change cannot be represented cleanly in Rojo source files, document the manual Studio step and consider whether the asset should be exported into the repository later.

## Git Note

This workspace may report a Git safe-directory warning if the repository owner differs from the current Windows user. Do not change global Git config unless the user approves it.









