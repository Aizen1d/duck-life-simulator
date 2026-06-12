# Coding Standards

These standards apply to Luau code added to the `Duck` project.

## General Style

- Write clear Luau with descriptive names.
- Keep modules focused on one responsibility.
- Prefer explicit returns over hidden side effects.
- Use comments only when they explain a non-obvious decision.
- Keep starter or prototype code easy to replace.

## File Placement

- Client-only behavior belongs in `src/client`.
- Server-only behavior belongs in `src/server`.
- Shared modules belong in `src/shared`.
- Do not put server-authoritative decisions in client code.
- Do not put UI-only logic in server code.
- In Rojo folders that use `init.client.luau` or `init.server.luau`, sibling modules become children of the generated script. Require those modules from `script`, not `script.Parent`.

## Naming

- Use PascalCase for ModuleScript names that return tables or classes.
- Use camelCase for local variables and functions.
- Use uppercase names for constants only when they are truly constant.
- Name RemoteEvents and RemoteFunctions by their purpose, not by the caller.

## Client and Server Rules

The server owns authoritative gameplay state. The client may request actions and display feedback, but server code must validate requests before changing shared state.

Server validation should consider:

- Whether the player is allowed to perform the action.
- Whether the action is possible from the current state.
- Whether the provided values are the expected type and range.
- Whether the request rate is reasonable.

## React UI Structure

- `src/client/init.client.luau` mounts one `DuckApp` ScreenGui.
- `src/client/App.luau` owns the top-level React app.
- `src/client/Screens` contains screen-level components.
- `src/client/Components` contains reusable UI components.
- `src/client/UI/Theme.luau` contains temporary UI theme values for the prototype.
- UI code may show placeholder state, selection state, and local interaction bubbles, but it must not own authoritative gameplay state.
- Use `src/shared/RemoteProtocol.luau` for current gameplay remotes. Ask before adding new remotes or payload shapes.
- Use clear ZIndex layers for background, scene, and UI elements so decorative shapes cannot cover counters, buttons, or panels.
- Image-backed prototype UI should keep visible placeholder fallbacks until the imported image asset is confirmed in Studio.
- Responsive farm-screen layout should use Roblox display-size information such as `GuiService.ViewportDisplaySize` plus explicit viewport dimensions when orientation or short-height layouts matter.
- Duck selection should use the farm screen scene-level nearest-duck oval hit testing: `UserInputService.InputEnded` for desktop mouse clicks and `UserInputService.TouchTap` for mobile or Studio device-emulator taps. Touch positions should be adjusted with `GuiService:GetGuiInset()` because the app `ScreenGui` ignores the GUI inset. Avoid full-screen transparent buttons or separate rectangular buttons on each duck sprite because they can block normal UI controls or select the wrong duck in compact flocks.

## Current Remote Contract

The gameplay loop uses two `RemoteEvent` instances created by the server under `ReplicatedStorage.DuckRemotes`.

- `DuckAction`: client sends a named action from `RemoteProtocol.actions`. The `care_for_ducks`, `use_treat_on_duck`, and `visitor_help_duck` actions may include a payload with `duckIndex`; the `buy_shop_item` action may include an `itemId`; the `rename_duck` action may include `duckIndex` and requested `name`; the `visit_farm` action may include a target same-server `UserId`; the server must validate payloads before changing duck state, duck names, economy, inventory, or the viewer's current farm visit target. `toggle_visitor_help` has no payload and only changes the owner's session-only visitor-help permission.
- `DuckState`: server sends a dictionary containing eggs, coins, available eggs, Duck Feed and Treat counts, duck count, individual duck summaries including generated or renamed display name and level/XP progress, aggregate duck mood, care request duck index, care request kind, care request text, aggregate care availability, rename validation error state, egg value, upgrade level, upgrade cost, buy eligibility, shop item affordability, Quest V0 summaries, Farm Visit metadata including visitor-help permission, countdown seconds, current session weather id/display/detail, next-weather countdown, and internal save status text that is not shown on the farm screen.

Current allowed gameplay actions are request state, collect eggs, sell eggs, buy Egg Value, buy duck, buy a shop item, care for ducks, use a Treat on a duck, rename ducks, visit another loaded same-server farm, return home from a farm visit, toggle session-only visitor help, use visitor help on an eligible active duck request, and claim the Daily Check-in reward when it is available. Daily Check-in claims are validated server-side against the player's persisted `lastDailyClaimDay`; the server auto-claims on join when eligible and otherwise rejects repeat claims for the same UTC day. The server owns real duck records, each duck's generated or renamed display name, each duck's level and XP, server-owned Duck Feed and Treat inventory, Quest V0 progress, quest levels, quest targets, quest rewards, current session weather, each viewer's current Farm Visit target, session-only visitor-help permission, and which visible duck currently requests care. Save Data V0 persists the approved player state through server-only DataStore code, but visitor-help permission and visitor-help effects are session-only. Selecting a visible duck, showing its local highlight, generated name, level progress, and quick care bubble, opening Duck Profile V0 from the bubble's `Profile` button, editing profile rename text, clearing that selection from empty scene clicks, and transitioning between farm and shop scenes are client-local presentation; caring for a duck sends a selected duck index that the server validates, using a Treat sends a selected duck index that the server validates, buying a shop item sends an item id that the server validates, renaming a duck sends a selected duck index plus requested name that the server validates and filters, visiting a farm sends a target `UserId` that the server validates against currently connected loaded players, and visitor help sends a selected owner duck index that the server validates against the current visit target and owner permission.

Current Studio-only tester actions are add coins, add ready eggs, add duck, force a pet care request, force a hungry request, force a sleepy request, force a dirty request, force a thirsty request, force a bored care request, cycle Sunny/Cloudy/Rainy weather, and reset state. These actions exist only to speed up Roblox Studio testing. Client UI may hide them outside Studio, but server code must still guard every tester action with `RunService:IsStudio()` before changing state.

Client code must not send economy values, timers, prices, upgrade levels, duck counts, duck mood values, authoritative duck display names, duck level or XP values, quest progress, quest levels, quest targets, quest rewards, care request duck indexes, care cooldowns, weather values, or inventory amounts. Current client payloads are the selected `duckIndex` for `care_for_ducks`, the selected `duckIndex` for `use_treat_on_duck`, the selected owner `duckIndex` for `visitor_help_duck`, the `itemId` for `buy_shop_item`, the selected `duckIndex` plus requested `name` for `rename_duck`, and the target same-server `UserId` for `visit_farm`; server code must validate them against server-owned duck records, approved shop item definitions, current economy state, rename length limits, per-player duplicate rules, Roblox text filtering, currently connected loaded player state, current farm visit target, owner visitor-help opt-in, active request duck, and allowed visitor-help request kinds. While a player is viewing another farm, the server should ignore non-navigation gameplay actions except the narrow `visitor_help_duck` action, which must never grant XP, quest progress, coins, items, inventory changes, save-data changes, or owner feed consumption.

Remote validation changes should be checked against [Security Test Cases](SECURITY_TESTS.md), including malformed action names, invalid payload types, invalid duck indexes, duplicate reward claims, Farm Visit read-only and visitor-help behavior, and Studio-only tester action guards.

Client-played minigames must keep rewards server-owned. For Egg Catch V0, the server tracks the round session, rejects early or duplicate claims, clamps rewards to configured limits, and rejects scores that are impossible for the elapsed round timing. Do not treat client-submitted minigame scores as fully authoritative anti-cheat data without a separate server-simulation or input-validation design.

Numeric payload and persistence validation should reject `NaN` and infinite values before integer checks or clamping. Treat non-finite values as invalid input, not as large numbers.

## Shared Modules

Shared modules should be safe to require from both client and server. Avoid direct access to services that only exist on one side unless the module clearly documents that limitation.

Good shared module candidates:

- Constants
- Pure utility functions
- Type definitions
- Data tables used by both runtimes

Poor shared module candidates:

- Server persistence
- Client UI control
- Studio-only tooling
- Code with side effects on require

## Error Handling

- Fail clearly when required data is missing.
- Validate external input before use.
- Avoid swallowing errors without recording enough context to debug them.
- Prefer simple guard clauses over deeply nested conditionals.

## Persistence

Save Data V0 is implemented in `src/server/PlayerDataService.luau` and integrated by `src/server/PlayerStateService.luau`. Follow `docs/SAVE_DATA_DESIGN.md` before changing the save scope, store name, migration rules, or DataStore write cadence.

Persistence code must live on the server, validate all loaded fields, and serialize only server-owned state. Client code must never submit a full save object or authoritative coins, eggs, duck counts, upgrades, inventory, duck names, level, XP, quest progress, quest levels, timers, or cooldowns.

Use one related player-data object per player for Save Data V0 unless the design changes. Do not add OrderedDataStores, global name reservations, trading, leaderboards, or cross-server systems without a separate approved design.
## Player-Entered Text

Duck Rename V0 treats submitted duck names as player-generated text. The client may send a requested name, but the server must validate ownership, `2` to `16` character length, and case-insensitive uniqueness within the player's current duck list. The server must run Roblox text filtering through `TextService:FilterStringAsync()` and return the filtered result with `TextFilterResult:GetNonChatStringForUserAsync()` before replicating the display name back to that player. If filtering fails or the filtered result is empty or heavily filtered, do not display or store the submitted name.

## Roblox API Verification

Before using Roblox APIs that are unfamiliar, platform-sensitive, deprecated, beta, or likely to have changed, check the official Roblox Creator Docs or Engine API Reference. Follow `docs/REFERENCE_POLICY.md` for source rules.

This is required for DataStore, remotes, MarketplaceService, text filtering, moderation, policy-sensitive systems, rate limits, and security-sensitive client/server behavior.

## Dependencies

Libraries are allowed when they reduce complexity and fit the project. Follow `docs/LIBRARY_POLICY.md` before recommending, installing, or updating dependencies.

This project uses Wally for Luau dependencies. Runtime packages are installed into `Packages` and mapped to `ReplicatedStorage.Packages` by Rojo.

Current approved dependencies:

- `React`: Declarative UI library for the 2D simulator interface.
- `ReactRoblox`: Roblox renderer for React Luau.

For each dependency, document:

- Why it is needed.
- Where it is used.
- How it affects setup.
- What alternatives were considered.
- Source, license, maintenance status, and installation path.

## Documentation Expectations

Follow `docs/DOC_UPDATE_POLICY.md` before finishing code changes.

Update project docs when code changes affect:

- Setup or workflow.
- Folder structure.
- Public module behavior.
- Client/server communication.
- Game design decisions.
- Bug fixes or regression risks.
- Economy, rewards, ducks, eggs, upgrades, UI, or player progression.

If a bug fix reveals a rule that would prevent the same mistake later, add that rule here or in `docs/WORKFLOW.md`.
