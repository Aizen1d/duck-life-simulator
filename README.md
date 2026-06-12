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
- `src/server`: Server-side Roblox scripts, including the server bootstrap and server state and persistence services.
- `src/shared`: Modules shared by client and server, including prototype config, asset IDs, shared types, and the remote protocol.
- `Packages`: Generated Wally packages mapped into `ReplicatedStorage.Packages`.
- `assets`: Design references, approved generated images, and UI assets.
- `docs`: Project documentation, including the local [project map dashboard](docs/project-map/index.html) and [gameplay simulator](docs/project-map/gameplay-flow.html).
- `AGENTS.md`: Instructions for AI coding agents.

## Documentation

- [AI agent instructions](AGENTS.md)
- [AI agent roles](docs/AI_AGENT_ROLES.md)
- [Project structure](docs/PROJECT_STRUCTURE.md)
- [Project map dashboard](docs/project-map/index.html)
- [Gameplay simulator](docs/project-map/gameplay-flow.html)
- [Development workflow](docs/WORKFLOW.md)
- [Documentation update policy](docs/DOC_UPDATE_POLICY.md)
- [Reference policy](docs/REFERENCE_POLICY.md)
- [Save data design](docs/SAVE_DATA_DESIGN.md)
- [Security tests](docs/SECURITY_TESTS.md)
- [Library policy](docs/LIBRARY_POLICY.md)
- [Library candidates](docs/LIBRARY_CANDIDATES.md)
- [Design inputs](docs/DESIGN_INPUTS.md)
- [Design prompts](docs/DESIGN_PROMPTS.md)
- [Asset workflow](docs/ASSET_WORKFLOW.md)
- [Coding standards](docs/CODING_STANDARDS.md)
- [Gameplay research](docs/GAMEPLAY_RESEARCH.md)
- [Game brief](docs/GAME_BRIEF.md)
- [Roadmap](docs/ROADMAP.md)
- [Product plan](docs/PRODUCT_PLAN.md)
- [Tasks](docs/TASKS.md)
- [Changelog](docs/CHANGELOG.md)

## Development Notes

- Use `src/client` for client-only behavior.
- Use `src/server` for server-authoritative logic.
- Use `src/shared` for modules that are safe to require from both runtimes.
- Use `ReplicatedStorage.Packages.React` and `ReplicatedStorage.Packages.ReactRoblox` for React Luau UI code after running `wally install`.
- The current prototype uses single-player-first server state with Save Data V0 persistence, approved runtime image assets, simple autonomous duck motion, real individual duck records with generated or renamed saved names, an egg status/progress card, server-owned per-duck pet, hungry, and sleepy care requests with frontmost requested-duck emphasis, tap/left-click duck care bubbles with a saturated duck-yellow selected-duck highlight, Duck Profile V0 opened from a `Profile` button, Rename V0 with server-side validation and Roblox text filtering, and empty-scene deselect, Duck Mood / Care V1 as feedback-only life-sim interaction, Duck Level/Progress V0 with per-duck XP and a small egg-production bonus from higher duck levels, Egg Value as the first upgrade, Buy Duck with scaling costs, Shop V0 with server-owned Duck Feed, Premium Feed, and Treat inventory, Weather/Event V0 with sunny/rainy session weather, Quest V0 with repeatable saved collect/sell/help quest progress, and Farm Visit V0 for read-only same-server farm viewing.
- Future multiplayer direction is personal player-owned farms inside multiplayer-capable servers, with Farm Visit V0 implemented as read-only same-server viewing. Visitor help actions, friend/offline farm cards, privacy rules, and owner-impact behavior remain future work.
- Gameplay state for eggs, coins, production, upgrades, Duck Feed, Premium Feed, and Treat inventory, individual duck care state, per-duck generated or renamed names, per-duck level/XP, quest progress, quest rewards, and current session weather is owned by the server. The client sends named UI action requests, and payloads such as selected duck index, shop item id, or requested rename text are validated on the server.
- Save Data V0 is implemented and documented in `docs/SAVE_DATA_DESIGN.md`; the current saved schema is version `4` because Premium Feed inventory now persists alongside Duck Feed, Treat, and Quest V0 progress. Studio DataStore testing requires API services to stay enabled for this place. The farm screen does not show a save status indicator; verify saves with Studio Output logs and stop/rejoin checks.
- Weather/Event V0 is session-only: sunny/rainy weather can change during play and rainy weather makes sleepy duck requests more likely, but weather does not persist or change economy balance yet.
- Roblox Studio Play mode includes a Studio-only tester panel for quickly granting coins, ready eggs, ducks, forcing pet, hungry, sleepy, or dirty care requests, reopening the guide, toggling sunny/rainy weather, or resetting current state while testing.
- Do not hand-edit generated `.rbxlx` files.
- Run the documentation impact check before finishing changes.
- Update docs when project structure, workflow, mechanics, bug history, or confirmed design decisions change.

For more Rojo help, read the [Rojo documentation](https://rojo.space/docs).
