# Duck

`Duck` is a Roblox game project managed with [Rojo](https://github.com/rojo-rbx/rojo) and [Aftman](https://github.com/LPGhatguy/aftman).

The confirmed direction is a 2D UI-first duck life simulator, with farming as the first core activity. Project docs should stay factual and should not invent extra mechanics, lore, assets, or systems before they are confirmed.

## Getting Started

Install the project tools:

```powershell
aftman install
```

Build the place file:

```powershell
rojo build -o "Duck.rbxlx"
```

Open `Duck.rbxlx` in Roblox Studio, then start the Rojo server:

```powershell
rojo serve
```

Connect from Roblox Studio with the Rojo plugin to sync source files into the open place.

Install Luau packages after changing `wally.toml`:

```powershell
wally install
```

## Project Layout

- `default.project.json`: Rojo project tree.
- `aftman.toml`: Tool versions managed by Aftman.
- `wally.toml`: Luau package dependencies.
- `src/client`: Client-side Roblox scripts, including the React app shell and farm screen.
- `src/server`: Server-side Roblox scripts, including the server bootstrap and session state service.
- `src/shared`: Modules shared by client and server, including prototype config, asset IDs, shared types, and the remote protocol.
- `Packages`: Generated Wally packages mapped into `ReplicatedStorage.Packages`.
- `assets`: Design references, approved generated images, and UI assets.
- `docs`: Project documentation.
- `AGENTS.md`: Instructions for AI coding agents.

## Documentation

- [AI agent instructions](AGENTS.md)
- [AI agent roles](docs/AI_AGENT_ROLES.md)
- [Project structure](docs/PROJECT_STRUCTURE.md)
- [Development workflow](docs/WORKFLOW.md)
- [Documentation update policy](docs/DOC_UPDATE_POLICY.md)
- [Reference policy](docs/REFERENCE_POLICY.md)
- [Save data design](docs/SAVE_DATA_DESIGN.md)
- [Library policy](docs/LIBRARY_POLICY.md)
- [Library candidates](docs/LIBRARY_CANDIDATES.md)
- [Design inputs](docs/DESIGN_INPUTS.md)
- [Design prompts](docs/DESIGN_PROMPTS.md)
- [Asset workflow](docs/ASSET_WORKFLOW.md)
- [Coding standards](docs/CODING_STANDARDS.md)
- [Gameplay research](docs/GAMEPLAY_RESEARCH.md)
- [Game brief](docs/GAME_BRIEF.md)
- [Roadmap](docs/ROADMAP.md)
- [Tasks](docs/TASKS.md)
- [Changelog](docs/CHANGELOG.md)

## Development Notes

- Use `src/client` for client-only behavior.
- Use `src/server` for server-authoritative logic.
- Use `src/shared` for modules that are safe to require from both runtimes.
- Use `ReplicatedStorage.Packages.React` and `ReplicatedStorage.Packages.ReactRoblox` for React Luau UI code after running `wally install`.
- The current prototype uses single-player-first session state, approved runtime image assets, simple autonomous duck motion, real session-only individual duck records with generated or renamed session names, an egg status/progress card, server-owned per-duck pet and hungry care requests with frontmost requested-duck emphasis, tap/left-click duck care bubbles with a saturated duck-yellow selected-duck highlight, Duck Profile V0 opened from a `Profile` button, Rename V0 with server-side validation and Roblox text filtering, and empty-scene deselect, Duck Mood / Care V1 as feedback-only life-sim interaction, Duck Level/Progress V0 as feedback-only per-duck XP, Egg Value as the first upgrade, Buy Duck with scaling costs, Shop V0 with server-owned Duck Feed inventory, and no runtime save data yet.
- Gameplay state for eggs, coins, production, upgrades, Duck Feed inventory, individual duck care state, per-duck generated or renamed names, and per-duck level/XP is owned by the server. The client sends named UI action requests, and payloads such as selected duck index, shop item id, or requested rename text are validated on the server.
- Save Data V0 is documented in `docs/SAVE_DATA_DESIGN.md`; implementation should wait until the save scope, Studio API-services setup, and DataStore testing plan are confirmed.
- Roblox Studio Play mode includes a Studio-only tester panel for quickly granting coins, ready eggs, ducks, forcing pet or hungry care requests, or resetting session state while testing.
- Do not hand-edit generated `.rbxlx` files.
- Run the documentation impact check before finishing changes.
- Update docs when project structure, workflow, mechanics, bug history, or confirmed design decisions change.

For more Rojo help, read the [Rojo documentation](https://rojo.space/docs).
