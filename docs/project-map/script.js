const layers = [
	{ id: "project", label: "Project" },
	{ id: "service", label: "Roblox Services" },
	{ id: "folder", label: "Folders" },
	{ id: "module", label: "Luau Modules" },
	{ id: "ui", label: "UI Screens" },
	{ id: "gameplay", label: "Gameplay High Level" },
	{ id: "remote", label: "Remotes" },
	{ id: "runtime", label: "Runtime State" },
	{ id: "external", label: "Roblox APIs" },
	{ id: "docs", label: "Docs" },
];

const edgeTypes = [
	{ id: "maps", label: "Rojo maps" },
	{ id: "requires", label: "Requires" },
	{ id: "remote", label: "Remote flow" },
	{ id: "data", label: "Data flow" },
	{ id: "runtime", label: "Runtime owns" },
	{ id: "loop", label: "Gameplay loop" },
	{ id: "supports", label: "Supports" },
	{ id: "planned", label: "Planned path" },
	{ id: "documents", label: "Documents" },
];

const lenses = [
	{
		id: "architecture",
		label: "Technical",
		description: "Rojo, modules, remotes, state, and docs.",
		layers: ["project", "service", "folder", "module", "ui", "remote", "runtime", "external", "docs"],
		edgeTypes: ["maps", "requires", "remote", "data", "runtime", "documents"],
		selectedNodeId: "root",
	},
	{
		id: "gameplay",
		label: "Gameplay",
		description: "Player loop, current systems, guardrails, and roadmap.",
		layers: ["gameplay", "ui", "runtime", "docs"],
		edgeTypes: ["loop", "supports", "planned", "documents", "runtime", "data"],
		selectedNodeId: "gameplay-core-loop",
	},
	{
		id: "all",
		label: "All",
		description: "Every mapped node and connection.",
		layers: layers.map((layer) => layer.id),
		edgeTypes: edgeTypes.map((type) => type.id),
		selectedNodeId: "root",
	},
];

const nodes = [
	{
		id: "root",
		label: "Duck",
		kind: "Roblox project",
		layer: "project",
		badge: "root",
		x: 890,
		y: 540,
		file: "../../README.md",
		description: "The Rojo-managed 2D UI-first duck life simulator repository.",
		responsibilities: [
			"Coordinates client UI, server-authoritative gameplay, shared config, persistence, assets, and project docs.",
			"Current confirmed direction stays factual in docs and avoids unapproved mechanics.",
		],
	},
	{
		id: "rojo",
		label: "default.project.json",
		kind: "Rojo tree",
		layer: "project",
		badge: "mapping",
		x: 890,
		y: 110,
		file: "../../default.project.json",
		description: "Maps repository folders into Roblox services and creates static Workspace, Lighting, and SoundService entries.",
		responsibilities: [
			"Maps `src/shared` to `ReplicatedStorage.Shared`.",
			"Maps `src/server` to `ServerScriptService.Server`.",
			"Maps `src/client` to `StarterPlayer.StarterPlayerScripts.Client`.",
		],
	},
	{
		id: "aftman",
		label: "aftman.toml",
		kind: "toolchain",
		layer: "project",
		badge: "tools",
		x: 1130,
		y: 110,
		file: "../../aftman.toml",
		description: "Pins project command-line tools such as Rojo.",
		responsibilities: [
			"Supports the documented `aftman install` and Rojo workflow.",
		],
	},
	{
		id: "wally",
		label: "wally.toml",
		kind: "packages",
		layer: "project",
		badge: "deps",
		x: 650,
		y: 110,
		file: "../../wally.toml",
		description: "Declares Luau package dependencies used by the React UI stack.",
		responsibilities: [
			"Provides the source package list for generated `Packages`.",
			"Current README identifies React and ReactRoblox as the approved UI stack.",
		],
	},

	{
		id: "replicated-storage",
		label: "ReplicatedStorage",
		kind: "Roblox service",
		layer: "service",
		badge: "service",
		x: 410,
		y: 250,
		file: "../../default.project.json",
		description: "Shared Roblox storage for generated packages, shared modules, and runtime remotes.",
		responsibilities: [
			"Holds `Packages` and `Shared` through Rojo mappings.",
			"Receives runtime `DuckRemotes` from the server at startup.",
		],
	},
	{
		id: "server-script-service",
		label: "ServerScriptService",
		kind: "Roblox service",
		layer: "service",
		badge: "service",
		x: 900,
		y: 250,
		file: "../../default.project.json",
		description: "Server-only Roblox service that receives the authoritative game modules.",
		responsibilities: [
			"Contains the Rojo-mapped `Server` folder.",
			"Runs `init.server.luau`, which starts the server bootstrap.",
		],
	},
	{
		id: "starter-player",
		label: "StarterPlayerScripts",
		kind: "Roblox service path",
		layer: "service",
		badge: "service",
		x: 1260,
		y: 250,
		file: "../../default.project.json",
		description: "Client runtime path for the LocalScript app.",
		responsibilities: [
			"Contains the Rojo-mapped `Client` folder under `StarterPlayer.StarterPlayerScripts`.",
			"Starts the player-facing React app on each client.",
		],
	},
	{
		id: "workspace",
		label: "Workspace",
		kind: "Roblox service",
		layer: "service",
		badge: "world",
		x: 1540,
		y: 230,
		file: "../../default.project.json",
		description: "Contains the static baseplate defined by the Rojo project file.",
		responsibilities: [
			"Currently minimal because the game is UI-first.",
		],
	},
	{
		id: "lighting",
		label: "Lighting",
		kind: "Roblox service",
		layer: "service",
		badge: "world",
		x: 1540,
		y: 330,
		file: "../../default.project.json",
		description: "Receives static lighting properties from the Rojo project tree.",
		responsibilities: [
			"Configured with Voxel technology, shadows, brightness, and ambient values.",
		],
	},
	{
		id: "sound-service",
		label: "SoundService",
		kind: "Roblox service",
		layer: "service",
		badge: "world",
		x: 1540,
		y: 430,
		file: "../../default.project.json",
		description: "Receives static sound service filtering properties from the Rojo tree.",
		responsibilities: [
			"Currently only defines `RespectFilteringEnabled` in Rojo.",
		],
	},

	{
		id: "packages-folder",
		label: "Packages",
		kind: "generated folder",
		layer: "folder",
		badge: "Wally",
		x: 210,
		y: 360,
		file: "../PROJECT_STRUCTURE.md",
		description: "Generated Wally packages mapped into `ReplicatedStorage.Packages`.",
		responsibilities: [
			"Should be regenerated with `wally install` rather than edited by hand.",
			"Provides React and ReactRoblox to the client scripts.",
		],
	},
	{
		id: "react-stack",
		label: "React + ReactRoblox",
		kind: "package modules",
		layer: "external",
		badge: "UI lib",
		x: 130,
		y: 470,
		file: "../../wally.toml",
		description: "Client UI library stack loaded from generated packages.",
		responsibilities: [
			"Creates the React root in `init.client.luau`.",
			"Builds the app tree rendered by `App.luau` and `FarmScreen.luau`.",
		],
	},
	{
		id: "shared-folder",
		label: "src/shared",
		kind: "shared source folder",
		layer: "folder",
		badge: "shared",
		x: 480,
		y: 360,
		file: "../PROJECT_STRUCTURE.md",
		description: "Modules safe to require from both client and server.",
		responsibilities: [
			"Contains asset ids, prototype config, remote protocol names, and shared type shapes.",
		],
	},
	{
		id: "server-folder",
		label: "src/server",
		kind: "server source folder",
		layer: "folder",
		badge: "server",
		x: 900,
		y: 360,
		file: "../PROJECT_STRUCTURE.md",
		description: "Authoritative server runtime modules.",
		responsibilities: [
			"Owns gameplay state, remote validation, persistence, and periodic updates.",
		],
	},
	{
		id: "client-folder",
		label: "src/client",
		kind: "client source folder",
		layer: "folder",
		badge: "client",
		x: 1260,
		y: 360,
		file: "../PROJECT_STRUCTURE.md",
		description: "Client-only Roblox scripts and React UI components.",
		responsibilities: [
			"Handles presentation, input, UI scenes, local animation, and remote requests.",
		],
	},

	{
		id: "asset-ids",
		label: "AssetIds.luau",
		kind: "shared module",
		layer: "module",
		badge: "assets",
		x: 280,
		y: 540,
		file: "../../src/shared/AssetIds.luau",
		description: "Stores runtime image asset references for the farm background, duck, egg icon, and coin icon.",
		responsibilities: [
			"Used by the farm screen for visual presentation.",
			"Contains current approved runtime image identifiers and fallback slots.",
		],
	},
	{
		id: "prototype-config",
		label: "PrototypeConfig.luau",
		kind: "shared module",
		layer: "module",
		badge: "config",
		x: 480,
		y: 540,
		file: "../../src/shared/PrototypeConfig.luau",
		description: "Central gameplay configuration for starting values, shop costs, quests, weather, care, levels, daily check-in, and Egg Catch rewards.",
		responsibilities: [
			"Read by both client and server for consistent display and rules.",
			"Defines current constants such as save-backed shop item ids and weather state ids.",
		],
	},
	{
		id: "remote-protocol",
		label: "RemoteProtocol.luau",
		kind: "shared module",
		layer: "module",
		badge: "protocol",
		x: 680,
		y: 540,
		file: "../../src/shared/RemoteProtocol.luau",
		description: "The named remote folder, remote events, action ids, and notice ids.",
		responsibilities: [
			"Defines `DuckRemotes`, `DuckAction`, `DuckState`, and `DuckNotice`.",
			"Defines client request names, Studio tester action names, and server notice kinds.",
		],
	},
	{
		id: "types",
		label: "Types.luau",
		kind: "shared module",
		layer: "module",
		badge: "types",
		x: 830,
		y: 500,
		file: "../../src/shared/Types.luau",
		description: "Shared exported Luau type shapes for resources, ducks, quests, farm state, config, weather, and minigames.",
		responsibilities: [
			"Documents common data contracts for the current prototype.",
			"Returns an empty table at runtime because the value is type support.",
		],
	},

	{
		id: "init-client",
		label: "init.client.luau",
		kind: "client script",
		layer: "module",
		badge: "entry",
		x: 1100,
		y: 500,
		file: "../../src/client/init.client.luau",
		description: "Creates the `DuckApp` ScreenGui, loads React and ReactRoblox, mounts `App`, and unmounts on script destruction.",
		responsibilities: [
			"Client entry point under StarterPlayerScripts.",
			"Owns React root creation and ScreenGui setup.",
		],
	},
	{
		id: "app",
		label: "App.luau",
		kind: "client module",
		layer: "module",
		badge: "shell",
		x: 1260,
		y: 510,
		file: "../../src/client/App.luau",
		description: "Small React app shell with an error boundary around the farm screen.",
		responsibilities: [
			"Prevents client render errors from dropping players back to the bare Roblox world.",
			"Renders `FarmScreen` as the main app surface.",
		],
	},
	{
		id: "farm-screen",
		label: "FarmScreen.luau",
		kind: "client module",
		layer: "module",
		badge: "large UI",
		x: 1260,
		y: 670,
		file: "../../src/client/Screens/FarmScreen.luau",
		description: "Main React Luau UI for farm, shop, farm visits, tutorial, minigames, Egg Catch, feedback, animation, and remote traffic.",
		responsibilities: [
			"Receives farm state and notices from server remotes.",
			"Sends named UI actions to the server through `DuckAction`.",
			"Renders layout-responsive HUD, duck interactions, shop, visit panel, and minigame scenes.",
		],
	},
	{
		id: "action-button",
		label: "ActionButton.luau",
		kind: "client component",
		layer: "module",
		badge: "component",
		x: 1070,
		y: 805,
		file: "../../src/client/Components/ActionButton.luau",
		description: "Reusable Roblox UI button component for farm actions.",
		responsibilities: [
			"Applies shared theme styling and disabled behavior.",
		],
	},
	{
		id: "resource-counter",
		label: "ResourceCounter.luau",
		kind: "client component",
		layer: "module",
		badge: "component",
		x: 1240,
		y: 840,
		file: "../../src/client/Components/ResourceCounter.luau",
		description: "Reusable counter component for egg and coin readouts.",
		responsibilities: [
			"Renders an icon badge, title, and value with compact sizing support.",
		],
	},
	{
		id: "theme",
		label: "Theme.luau",
		kind: "client module",
		layer: "module",
		badge: "style",
		x: 1420,
		y: 805,
		file: "../../src/client/UI/Theme.luau",
		description: "Shared client UI colors, corner radii, and z-index values.",
		responsibilities: [
			"Provides the current farm UI visual tokens for React components.",
		],
	},

	{
		id: "farm-mode",
		label: "Farm HUD",
		kind: "UI mode",
		layer: "ui",
		badge: "screen",
		x: 1510,
		y: 600,
		file: "../../src/client/Screens/FarmScreen.luau",
		description: "Primary farm view with ducks, counters, weather, quests, visit panel, upgrades, tutorial overlay, and actions.",
		responsibilities: [
			"Shows server-owned farm state in the main loop.",
			"Routes collect, sell, shop, upgrades, visit, and duck-care interactions.",
		],
	},
	{
		id: "shop-mode",
		label: "Shop Scene",
		kind: "UI mode",
		layer: "ui",
		badge: "screen",
		x: 1510,
		y: 700,
		file: "../../src/client/Screens/FarmScreen.luau",
		description: "Shop scene for Duck Feed, Premium Feed, Treat, Pillow, and Toy purchases.",
		responsibilities: [
			"Sends `buy_shop_item` with a validated item id payload.",
		],
	},
	{
		id: "minigames-mode",
		label: "Minigames Menu",
		kind: "UI mode",
		layer: "ui",
		badge: "screen",
		x: 1510,
		y: 800,
		file: "../../src/client/Screens/FarmScreen.luau",
		description: "Same-place minigames menu that currently starts Egg Catch.",
		responsibilities: [
			"Moves from farm UI into the Egg Catch flow without separate place teleports.",
		],
	},
	{
		id: "egg-catch-mode",
		label: "Egg Catch",
		kind: "UI mode",
		layer: "ui",
		badge: "screen",
		x: 1510,
		y: 900,
		file: "../../src/client/Screens/FarmScreen.luau",
		description: "Client-side play scene with server-backed start and reward claim validation.",
		responsibilities: [
			"Runs local input, movement, drop timing, and result capture.",
			"Claims rewards through the server after the round.",
		],
	},
	{
		id: "tutorial-mode",
		label: "Guide Overlay",
		kind: "UI mode",
		layer: "ui",
		badge: "overlay",
		x: 1510,
		y: 1010,
		file: "../../src/client/Screens/FarmScreen.luau",
		description: "Fresh-profile task-driven onboarding overlay.",
		responsibilities: [
			"Highlights collect, sell, buy duck, shop, and duck-care steps.",
			"Stays session-only in the current implementation.",
		],
	},

	{
		id: "init-server",
		label: "init.server.luau",
		kind: "server script",
		layer: "module",
		badge: "entry",
		x: 820,
		y: 450,
		file: "../../src/server/init.server.luau",
		description: "Server entry point that requires `GameServer` and starts it.",
		responsibilities: [
			"Loads from the Rojo-mapped Server folder.",
		],
	},
	{
		id: "game-server",
		label: "GameServer.luau",
		kind: "server module",
		layer: "module",
		badge: "bootstrap",
		x: 900,
		y: 610,
		file: "../../src/server/GameServer.luau",
		description: "Small bootstrap module that starts `PlayerStateService` once.",
		responsibilities: [
			"Requires `PrototypeConfig` for startup logging.",
			"Calls `PlayerStateService.start()`.",
		],
	},
	{
		id: "player-state-service",
		label: "PlayerStateService.luau",
		kind: "server module",
		layer: "module",
		badge: "authority",
		x: 830,
		y: 800,
		file: "../../src/server/PlayerStateService.luau",
		description: "Authoritative gameplay service for player state, remote validation, update loops, farm visits, care, quests, weather, minigames, and autosave scheduling.",
		responsibilities: [
			"Creates the runtime remote folder and remote events.",
			"Handles all client action names after validation and rate limiting.",
			"Sends serialized farm state to owners and viewers.",
			"Delegates persistent load and save calls to `PlayerDataService`.",
		],
	},
	{
		id: "player-data-service",
		label: "PlayerDataService.luau",
		kind: "server module",
		layer: "module",
		badge: "persistence",
		x: 1010,
		y: 930,
		file: "../../src/server/PlayerDataService.luau",
		description: "DataStore wrapper and sanitizer for saved player data.",
		responsibilities: [
			"Uses `DuckPlayerDataV1` and schema version 10.",
			"Sanitizes saved currencies, ducks, quest progress, daily quest slots, inventory, upgrade level, daily claim day, streak day, the unlock ladder flag, and the last-seen timestamp (clamped against forged future values).",
			"Loads with `GetAsync` and saves with `UpdateAsync`.",
		],
	},

	{
		id: "players-api",
		label: "Players",
		kind: "Roblox service",
		layer: "external",
		badge: "API",
		x: 620,
		y: 800,
		file: "../../src/server/PlayerStateService.luau",
		description: "Roblox player service used by the server to manage joins, leaves, same-server farms, and display names.",
		responsibilities: [
			"Feeds `PlayerAdded`, `PlayerRemoving`, and same-server user lookups.",
		],
	},
	{
		id: "run-service",
		label: "RunService",
		kind: "Roblox service",
		layer: "external",
		badge: "API",
		x: 650,
		y: 660,
		file: "../../src/server/PlayerStateService.luau",
		description: "Used for Studio-only tester gates and environment checks.",
		responsibilities: [
			"Keeps tester actions guarded to Studio.",
		],
	},
	{
		id: "text-service",
		label: "TextService",
		kind: "Roblox service",
		layer: "external",
		badge: "API",
		x: 610,
		y: 940,
		file: "../../src/server/PlayerStateService.luau",
		description: "Filters player-requested duck rename text before saving it.",
		responsibilities: [
			"Supports the server-side rename validation path.",
		],
	},
	{
		id: "datastore-api",
		label: "DataStoreService",
		kind: "Roblox service",
		layer: "external",
		badge: "API",
		x: 1190,
		y: 1030,
		file: "../../src/server/PlayerDataService.luau",
		description: "Roblox persistence service used by `PlayerDataService`.",
		responsibilities: [
			"Backs `DuckPlayerDataV1` save records.",
		],
	},

	{
		id: "duck-remotes",
		label: "DuckRemotes",
		kind: "runtime folder",
		layer: "remote",
		badge: "folder",
		x: 520,
		y: 720,
		file: "../../src/shared/RemoteProtocol.luau",
		description: "Runtime folder created under ReplicatedStorage by the server.",
		responsibilities: [
			"Contains `DuckAction`, `DuckState`, and `DuckNotice` remote events.",
		],
	},
	{
		id: "duck-action",
		label: "DuckAction",
		kind: "RemoteEvent",
		layer: "remote",
		badge: "C2S",
		x: 390,
		y: 820,
		file: "../../src/shared/RemoteProtocol.luau",
		description: "Client-to-server action event for named UI actions.",
		responsibilities: [
			"Carries requests such as collect, sell, buy, care, rename, visit, Egg Catch, daily check-in, and Studio tester actions.",
			"Payloads are validated by `PlayerStateService` before changing state.",
		],
	},
	{
		id: "duck-state",
		label: "DuckState",
		kind: "RemoteEvent",
		layer: "remote",
		badge: "S2C",
		x: 390,
		y: 650,
		file: "../../src/shared/RemoteProtocol.luau",
		description: "Server-to-client farm state event.",
		responsibilities: [
			"Carries serialized farm state for the owner or currently visited farm view.",
		],
	},
	{
		id: "duck-notice",
		label: "DuckNotice",
		kind: "RemoteEvent",
		layer: "remote",
		badge: "S2C",
		x: 390,
		y: 980,
		file: "../../src/shared/RemoteProtocol.luau",
		description: "Server-to-client notice event for one-off events.",
		responsibilities: [
			"Currently includes Egg Catch started, Egg Catch reward, daily claimed, and daily rejected notices.",
		],
	},

	{
		id: "player-state",
		label: "PlayerState",
		kind: "server runtime table",
		layer: "runtime",
		badge: "owned",
		x: 820,
		y: 1010,
		file: "../../src/server/PlayerStateService.luau",
		description: "Server-owned per-player gameplay state kept in memory while loaded.",
		responsibilities: [
			"Tracks eggs, coins, inventory, ducks, quests, weather, care requests, save status, farm visits, Egg Catch session, and daily check-in day.",
		],
	},
	{
		id: "farm-state-payload",
		label: "FarmState Payload",
		kind: "serialized state",
		layer: "runtime",
		badge: "view",
		x: 630,
		y: 1120,
		file: "../../src/shared/Types.luau",
		description: "Client-facing farm state shape sent through `DuckState`.",
		responsibilities: [
			"Includes resources, ducks, shop prices, care state, save status text, weather, quests, visit state, and farm visit summaries.",
		],
	},
	{
		id: "save-data-v10",
		label: "SavedPlayerData v10",
		kind: "saved schema",
		layer: "runtime",
		badge: "schema",
		x: 1010,
		y: 1120,
		file: "../../src/server/PlayerDataService.luau",
		description: "Current saved player schema produced and sanitized by `PlayerDataService`.",
		responsibilities: [
			"Persists coins, eggs, inventory, ready eggs, Egg Value level, ducks, quest progress, daily quest slots, next duck id, last daily claim day, streak day, the unlock ladder flag, and the last-seen timestamp for offline progress.",
		],
	},
	{
		id: "gameplay-systems",
		label: "Gameplay Systems",
		kind: "server-owned rules",
		layer: "runtime",
		badge: "rules",
		x: 780,
		y: 1160,
		file: "../../src/server/PlayerStateService.luau",
		description: "Grouped logic inside `PlayerStateService` for farming, care, quests, shop, weather, daily check-in, farm visits, and Egg Catch rewards.",
		responsibilities: [
			"Mutates `PlayerState` only on the server.",
			"Uses `PrototypeConfig` ids and numbers to stay aligned with the client display.",
		],
	},

	{
		id: "docs-hub",
		label: "docs/",
		kind: "documentation folder",
		layer: "docs",
		badge: "docs",
		x: 1370,
		y: 560,
		file: "../PROJECT_STRUCTURE.md",
		description: "Primary durable project knowledge folder.",
		responsibilities: [
			"Contains structure, workflow, game brief, roadmap, policies, tasks, changelog, save data design, and security tests.",
		],
	},
	{
		id: "readme",
		label: "README.md",
		kind: "project doc",
		layer: "docs",
		badge: "entry",
		x: 1370,
		y: 455,
		file: "../../README.md",
		description: "Project overview, setup commands, layout, and current development notes.",
		responsibilities: [
			"Provides the quickest repository entry point for humans and agents.",
		],
	},
	{
		id: "project-structure-doc",
		label: "PROJECT_STRUCTURE.md",
		kind: "project doc",
		layer: "docs",
		badge: "structure",
		x: 1600,
		y: 610,
		file: "../PROJECT_STRUCTURE.md",
		description: "Documents Rojo mappings, source folders, runtime remotes, services, and generated files.",
		responsibilities: [
			"Should stay aligned with `default.project.json` and source folder layout.",
		],
	},
	{
		id: "game-brief-doc",
		label: "GAME_BRIEF.md",
		kind: "project doc",
		layer: "docs",
		badge: "design",
		x: 1600,
		y: 715,
		file: "../GAME_BRIEF.md",
		description: "Confirmed game direction, player loop, and approved mechanics.",
		responsibilities: [
			"Separates confirmed game facts from undecided ideas.",
		],
	},
	{
		id: "roadmap-tasks-doc",
		label: "ROADMAP + TASKS",
		kind: "project docs",
		layer: "docs",
		badge: "planning",
		x: 1370,
		y: 860,
		file: "../TASKS.md",
		description: "Forward work plan and concrete unfinished work.",
		responsibilities: [
			"Captures backlog, done items, phase plans, and follow-up testing tasks.",
		],
	},
	{
		id: "save-security-doc",
		label: "SAVE + SECURITY",
		kind: "project docs",
		layer: "docs",
		badge: "risk",
		x: 1600,
		y: 900,
		file: "../SAVE_DATA_DESIGN.md",
		description: "Save data design and remote/security testing guidance.",
		responsibilities: [
			"Tracks persistence scope, schema planning, and security test cases.",
		],
	},
	{
		id: "changelog-doc",
		label: "CHANGELOG.md",
		kind: "project doc",
		layer: "docs",
		badge: "history",
		x: 1370,
		y: 1010,
		file: "../CHANGELOG.md",
		description: "Human-readable history of meaningful project changes.",
		responsibilities: [
			"Records new tooling, docs, gameplay changes, and fixes.",
		],
	},
	{
		id: "gameplay-promise",
		label: "Cozy Promise",
		kind: "gameplay guardrail",
		layer: "gameplay",
		badge: "rule",
		x: 250,
		y: 1320,
		file: "../ROADMAP.md",
		description: "Binding design rule: the game should not punish absence or neglect.",
		responsibilities: [
			"Ducks never die, starve, run away, or lose progress.",
			"Missed time pauses progress instead of destroying it.",
			"Needs are opportunities for XP and attention, not threats.",
		],
	},
	{
		id: "gameplay-ui-first",
		label: "2D UI-First Play",
		kind: "gameplay constraint",
		layer: "gameplay",
		badge: "input",
		x: 610,
		y: 1320,
		file: "../GAME_BRIEF.md",
		description: "The player manages a cozy duck scene through UI screens instead of direct character movement.",
		responsibilities: [
			"Player actions are buttons, panels, taps, and screen modes.",
			"Ducks can wander, idle, sleep, and react automatically as presentation.",
			"User-controlled movement and click-to-move are not planned unless the direction changes.",
		],
	},
	{
		id: "gameplay-core-loop",
		label: "Current Core Loop",
		kind: "gameplay loop",
		layer: "gameplay",
		badge: "core",
		x: 890,
		y: 1460,
		file: "../GAME_BRIEF.md",
		description: "High-level current play loop: ducks make eggs, player collects and sells, then spends coins to grow the farm.",
		responsibilities: [
			"Keep the first playable experience readable before adding larger systems.",
			"Connect egg production, currency, upgrades, ducks, care, and repeatable goals.",
			"Stay server-authoritative for any gameplay value that matters.",
		],
	},
	{
		id: "gameplay-produce-eggs",
		label: "Ducks Produce Eggs",
		kind: "loop step",
		layer: "gameplay",
		badge: "eggs",
		x: 610,
		y: 1460,
		file: "../GAME_BRIEF.md",
		description: "Ducks generate ready eggs over time, with higher output from more ducks and current duck level bonuses.",
		responsibilities: [
			"One duck starts the farm loop.",
			"More ducks and higher levels increase production.",
			"Production is owned by the server.",
		],
	},
	{
		id: "gameplay-collect",
		label: "Collect Eggs",
		kind: "loop step",
		layer: "gameplay",
		badge: "action",
		x: 430,
		y: 1600,
		file: "../GAME_BRIEF.md",
		description: "The player moves ready eggs into held eggs with the Collect action.",
		responsibilities: [
			"Creates the first active touchpoint in the loop.",
			"Feeds collect quest progress.",
		],
	},
	{
		id: "gameplay-sell",
		label: "Sell for Coins",
		kind: "loop step",
		layer: "gameplay",
		badge: "coins",
		x: 610,
		y: 1740,
		file: "../GAME_BRIEF.md",
		description: "Held eggs convert into coins using the server-owned egg sell value.",
		responsibilities: [
			"Turns production into spendable currency.",
			"Feeds sell quest progress.",
		],
	},
	{
		id: "gameplay-spend",
		label: "Spend Coins",
		kind: "loop step",
		layer: "gameplay",
		badge: "choice",
		x: 890,
		y: 1810,
		file: "../GAME_BRIEF.md",
		description: "Coins are spent on Egg Value upgrades, ducks, and shop items in the current prototype.",
		responsibilities: [
			"Creates player choice after earning coins.",
			"Supports upgrade, duck purchase, and shop item paths.",
		],
	},
	{
		id: "gameplay-grow",
		label: "Grow Output",
		kind: "loop result",
		layer: "gameplay",
		badge: "growth",
		x: 1170,
		y: 1740,
		file: "../GAME_BRIEF.md",
		description: "Progression makes the same loop stronger through more ducks, higher egg value, and per-duck levels.",
		responsibilities: [
			"Buy Duck increases production by adding real duck records.",
			"Egg Value raises coin value per egg.",
			"Duck levels add a modest per-duck egg output bonus.",
		],
	},
	{
		id: "gameplay-care",
		label: "Duck Care + XP",
		kind: "supporting gameplay",
		layer: "gameplay",
		badge: "life sim",
		x: 1360,
		y: 1580,
		file: "../GAME_BRIEF.md",
		description: "Ducks can ask for care needs such as pet, hungry, sleepy, dirty, thirsty, and bored.",
		responsibilities: [
			"Care gives feedback and duck XP without directly replacing the farm economy.",
			"Inventory-backed needs consume the correct server-owned item when required.",
			"Selected duck bubbles and Duck Profile make individual ducks easier to understand.",
		],
	},
	{
		id: "gameplay-shop",
		label: "Shop Items",
		kind: "supporting gameplay",
		layer: "gameplay",
		badge: "items",
		x: 250,
		y: 1780,
		file: "../GAME_BRIEF.md",
		description: "The shop sells care and XP items currently used by duck needs and Duck Profile.",
		responsibilities: [
			"Current items are Duck Feed, Premium Feed, Treat, Pillow, and Toy.",
			"Purchases and inventory are server-owned.",
		],
	},
	{
		id: "gameplay-quests",
		label: "Repeatable Quests",
		kind: "supporting gameplay",
		layer: "gameplay",
		badge: "goals",
		x: 1160,
		y: 1320,
		file: "../GAME_BRIEF.md",
		description: "Quest goals give lightweight repeatable direction on top of the core loop.",
		responsibilities: [
			"Current quest progress is server-owned and persists.",
			"Rewards can include coins and milestone items.",
			"Quest display stays compact so the farm does not become too busy.",
		],
	},
	{
		id: "gameplay-onboarding",
		label: "Guide + Unlock Ladder",
		kind: "comprehension layer",
		layer: "gameplay",
		badge: "teach",
		x: 250,
		y: 1460,
		file: "../ROADMAP.md",
		description: "Fresh profiles should learn the game one system at a time.",
		responsibilities: [
			"Current guide covers Collect, Sell, Buy Duck, Shop, and duck care.",
			"Phase 4 plans the Feature Unlock Ladder so new players do not see every system at once.",
			"No system should ship without a guide step or first-use explanation.",
		],
	},
	{
		id: "gameplay-visit",
		label: "Farm Visits",
		kind: "social gameplay",
		layer: "gameplay",
		badge: "social",
		x: 1530,
		y: 1320,
		file: "../GAME_BRIEF.md",
		description: "Same-server farm visiting lets players view another loaded player's farm and optionally help with non-inventory needs.",
		responsibilities: [
			"V0 is read-only viewing of same-server farms.",
			"V1 adds owner opt-in visitor help with no owner economy, XP, inventory, reward, or save-data gain.",
			"Offline/friend farm visits remain future work that need privacy and snapshot design.",
		],
	},
	{
		id: "gameplay-minigames",
		label: "Egg Catch",
		kind: "side activity",
		layer: "gameplay",
		badge: "minigame",
		x: 1530,
		y: 1780,
		file: "../GAME_BRIEF.md",
		description: "Current same-place minigame flow with server-backed reward claims.",
		responsibilities: [
			"Runs client-side play for movement and catches.",
			"Starts a server-tracked round and claims server-validated rewards.",
			"Rewards are modest coins or items in the current V0.",
		],
	},
	{
		id: "gameplay-weather-daily",
		label: "Weather + Daily",
		kind: "session and return layer",
		layer: "gameplay",
		badge: "rhythm",
		x: 890,
		y: 1970,
		file: "../GAME_BRIEF.md",
		description: "Small rhythm systems make sessions feel alive and give players a reason to check in.",
		responsibilities: [
			"Weather changes care-request weighting and presentation without economy effects.",
			"Daily Check-in grants a first-of-UTC-day coin reward.",
			"Phase 4 expands return systems with offline progress, streaks, and daily quests.",
		],
	},
	{
		id: "gameplay-roadmap",
		label: "Long-Term Roadmap",
		kind: "planned gameplay",
		layer: "gameplay",
		badge: "future",
		x: 1530,
		y: 1970,
		file: "../ROADMAP.md",
		description: "Approved direction through collection, hatching, evolution, Pond Games, farm expansion, breeding, social, events, and Legacy.",
		responsibilities: [
			"Phases are approved direction, not all implemented systems.",
			"Each phase still needs its own design pass, security review where relevant, and play-testing.",
			"The roadmap grows retention while staying bound by the cozy promise and comprehension guardrails.",
		],
	},
	{
		id: "gameplay-surface-budget",
		label: "UI Surface Budget",
		kind: "comprehension guardrail",
		layer: "gameplay",
		badge: "clarity",
		x: 250,
		y: 1970,
		file: "../ROADMAP.md",
		description: "The farm screen should stay readable as systems grow.",
		responsibilities: [
			"Farm screen is capped at 3 primary actions and 6 always-visible secondary controls.",
			"New systems should consolidate into hubs instead of adding uncontrolled button clutter.",
			"Special currencies are capped to the approved set.",
		],
	},
];

const edges = [
	{ from: "root", to: "rojo", type: "documents", label: "project uses Rojo tree" },
	{ from: "root", to: "aftman", type: "documents", label: "toolchain file" },
	{ from: "root", to: "wally", type: "documents", label: "package file" },
	{ from: "root", to: "readme", type: "documents", label: "overview doc" },
	{ from: "root", to: "docs-hub", type: "documents", label: "documentation folder" },

	{ from: "rojo", to: "replicated-storage", type: "maps", label: "defines service" },
	{ from: "rojo", to: "server-script-service", type: "maps", label: "defines service" },
	{ from: "rojo", to: "starter-player", type: "maps", label: "maps client scripts" },
	{ from: "rojo", to: "workspace", type: "maps", label: "defines baseplate" },
	{ from: "rojo", to: "lighting", type: "maps", label: "defines properties" },
	{ from: "rojo", to: "sound-service", type: "maps", label: "defines properties" },
	{ from: "replicated-storage", to: "packages-folder", type: "maps", label: "contains generated packages" },
	{ from: "replicated-storage", to: "shared-folder", type: "maps", label: "contains shared modules" },
	{ from: "server-script-service", to: "server-folder", type: "maps", label: "contains server modules" },
	{ from: "starter-player", to: "client-folder", type: "maps", label: "contains client modules" },

	{ from: "wally", to: "packages-folder", type: "data", label: "generates packages" },
	{ from: "packages-folder", to: "react-stack", type: "runtime", label: "provides runtime packages" },
	{ from: "shared-folder", to: "asset-ids", type: "maps", label: "contains" },
	{ from: "shared-folder", to: "prototype-config", type: "maps", label: "contains" },
	{ from: "shared-folder", to: "remote-protocol", type: "maps", label: "contains" },
	{ from: "shared-folder", to: "types", type: "maps", label: "contains" },

	{ from: "client-folder", to: "init-client", type: "maps", label: "contains" },
	{ from: "client-folder", to: "app", type: "maps", label: "contains" },
	{ from: "client-folder", to: "farm-screen", type: "maps", label: "contains" },
	{ from: "client-folder", to: "action-button", type: "maps", label: "contains component" },
	{ from: "client-folder", to: "resource-counter", type: "maps", label: "contains component" },
	{ from: "client-folder", to: "theme", type: "maps", label: "contains UI tokens" },

	{ from: "server-folder", to: "init-server", type: "maps", label: "contains" },
	{ from: "server-folder", to: "game-server", type: "maps", label: "contains" },
	{ from: "server-folder", to: "player-state-service", type: "maps", label: "contains" },
	{ from: "server-folder", to: "player-data-service", type: "maps", label: "contains" },

	{ from: "init-client", to: "react-stack", type: "requires", label: "requires React and ReactRoblox" },
	{ from: "init-client", to: "app", type: "requires", label: "requires and mounts app" },
	{ from: "app", to: "react-stack", type: "requires", label: "requires React" },
	{ from: "app", to: "farm-screen", type: "requires", label: "renders farm screen" },
	{ from: "farm-screen", to: "react-stack", type: "requires", label: "requires React" },
	{ from: "farm-screen", to: "asset-ids", type: "requires", label: "requires assets" },
	{ from: "farm-screen", to: "prototype-config", type: "requires", label: "requires config" },
	{ from: "farm-screen", to: "remote-protocol", type: "requires", label: "requires protocol" },
	{ from: "farm-screen", to: "action-button", type: "requires", label: "uses component" },
	{ from: "farm-screen", to: "resource-counter", type: "requires", label: "uses component" },
	{ from: "farm-screen", to: "theme", type: "requires", label: "uses theme" },
	{ from: "action-button", to: "react-stack", type: "requires", label: "requires React" },
	{ from: "action-button", to: "theme", type: "requires", label: "uses theme" },
	{ from: "resource-counter", to: "react-stack", type: "requires", label: "requires React" },
	{ from: "resource-counter", to: "theme", type: "requires", label: "uses theme" },

	{ from: "farm-screen", to: "farm-mode", type: "runtime", label: "renders mode" },
	{ from: "farm-screen", to: "shop-mode", type: "runtime", label: "renders mode" },
	{ from: "farm-screen", to: "minigames-mode", type: "runtime", label: "renders mode" },
	{ from: "farm-screen", to: "egg-catch-mode", type: "runtime", label: "renders mode" },
	{ from: "farm-screen", to: "tutorial-mode", type: "runtime", label: "renders overlay" },

	{ from: "init-server", to: "game-server", type: "requires", label: "requires bootstrap" },
	{ from: "game-server", to: "prototype-config", type: "requires", label: "reads startup constants" },
	{ from: "game-server", to: "player-state-service", type: "requires", label: "starts service" },
	{ from: "player-state-service", to: "prototype-config", type: "requires", label: "reads gameplay config" },
	{ from: "player-state-service", to: "remote-protocol", type: "requires", label: "reads action names" },
	{ from: "player-state-service", to: "player-data-service", type: "requires", label: "loads and saves" },
	{ from: "player-data-service", to: "prototype-config", type: "requires", label: "sanitizes against config" },
	{ from: "player-state-service", to: "players-api", type: "requires", label: "uses player lifecycle" },
	{ from: "player-state-service", to: "run-service", type: "requires", label: "uses Studio gates" },
	{ from: "player-state-service", to: "text-service", type: "requires", label: "filters rename text" },
	{ from: "player-data-service", to: "datastore-api", type: "data", label: "persists data" },

	{ from: "player-state-service", to: "duck-remotes", type: "runtime", label: "creates folder" },
	{ from: "remote-protocol", to: "duck-remotes", type: "documents", label: "defines folder name" },
	{ from: "duck-remotes", to: "duck-action", type: "runtime", label: "contains event" },
	{ from: "duck-remotes", to: "duck-state", type: "runtime", label: "contains event" },
	{ from: "duck-remotes", to: "duck-notice", type: "runtime", label: "contains event" },
	{ from: "remote-protocol", to: "duck-action", type: "documents", label: "defines action event name" },
	{ from: "remote-protocol", to: "duck-state", type: "documents", label: "defines state event name" },
	{ from: "remote-protocol", to: "duck-notice", type: "documents", label: "defines notice event name" },
	{ from: "farm-screen", to: "duck-action", type: "remote", label: "fires named UI actions" },
	{ from: "duck-action", to: "player-state-service", type: "remote", label: "OnServerEvent handled by service" },
	{ from: "player-state-service", to: "duck-state", type: "remote", label: "fires farm state" },
	{ from: "duck-state", to: "farm-screen", type: "remote", label: "OnClientEvent updates UI state" },
	{ from: "player-state-service", to: "duck-notice", type: "remote", label: "fires one-off notices" },
	{ from: "duck-notice", to: "farm-screen", type: "remote", label: "OnClientEvent shows feedback" },

	{ from: "player-state-service", to: "player-state", type: "runtime", label: "owns in-memory state" },
	{ from: "player-state", to: "gameplay-systems", type: "runtime", label: "mutated by gameplay rules" },
	{ from: "gameplay-systems", to: "prototype-config", type: "requires", label: "uses configured numbers and ids" },
	{ from: "player-state-service", to: "farm-state-payload", type: "data", label: "serializes view state" },
	{ from: "farm-state-payload", to: "duck-state", type: "remote", label: "sent over state event" },
	{ from: "farm-state-payload", to: "farm-screen", type: "data", label: "rendered by client UI" },
	{ from: "player-state-service", to: "save-data-v10", type: "data", label: "creates save snapshots" },
	{ from: "save-data-v10", to: "player-data-service", type: "data", label: "sanitized and persisted" },
	{ from: "save-data-v10", to: "datastore-api", type: "data", label: "stored in DuckPlayerDataV1" },

	{ from: "docs-hub", to: "project-structure-doc", type: "documents", label: "contains" },
	{ from: "docs-hub", to: "game-brief-doc", type: "documents", label: "contains" },
	{ from: "docs-hub", to: "roadmap-tasks-doc", type: "documents", label: "contains" },
	{ from: "docs-hub", to: "save-security-doc", type: "documents", label: "contains" },
	{ from: "docs-hub", to: "changelog-doc", type: "documents", label: "contains" },
	{ from: "project-structure-doc", to: "rojo", type: "documents", label: "documents mapping" },
	{ from: "project-structure-doc", to: "duck-remotes", type: "documents", label: "documents runtime remotes" },
	{ from: "game-brief-doc", to: "prototype-config", type: "documents", label: "records confirmed rules" },
	{ from: "roadmap-tasks-doc", to: "gameplay-systems", type: "documents", label: "plans follow-up work" },
	{ from: "save-security-doc", to: "player-data-service", type: "documents", label: "documents save design" },
	{ from: "save-security-doc", to: "duck-action", type: "documents", label: "documents remote tests" },
	{ from: "changelog-doc", to: "root", type: "documents", label: "records changes" },

	{ from: "game-brief-doc", to: "gameplay-core-loop", type: "documents", label: "defines current gameplay loop" },
	{ from: "game-brief-doc", to: "gameplay-ui-first", type: "documents", label: "defines play constraint" },
	{ from: "roadmap-tasks-doc", to: "gameplay-roadmap", type: "documents", label: "tracks planned gameplay growth" },
	{ from: "roadmap-tasks-doc", to: "gameplay-promise", type: "documents", label: "records cozy promise" },
	{ from: "roadmap-tasks-doc", to: "gameplay-surface-budget", type: "documents", label: "records comprehension guardrails" },
	{ from: "gameplay-core-loop", to: "farm-screen", type: "supports", label: "rendered through player UI" },
	{ from: "gameplay-core-loop", to: "player-state-service", type: "supports", label: "server owns gameplay decisions" },
	{ from: "gameplay-core-loop", to: "gameplay-systems", type: "supports", label: "implemented by current server rules" },
	{ from: "gameplay-core-loop", to: "farm-mode", type: "supports", label: "main player surface" },
	{ from: "gameplay-ui-first", to: "gameplay-core-loop", type: "supports", label: "shapes input model" },
	{ from: "gameplay-promise", to: "gameplay-core-loop", type: "supports", label: "bounds player consequences" },
	{ from: "gameplay-surface-budget", to: "gameplay-core-loop", type: "supports", label: "keeps systems readable" },
	{ from: "gameplay-onboarding", to: "gameplay-core-loop", type: "supports", label: "teaches the loop" },
	{ from: "gameplay-onboarding", to: "tutorial-mode", type: "supports", label: "current guide overlay" },
	{ from: "gameplay-quests", to: "gameplay-core-loop", type: "supports", label: "adds repeatable goals" },
	{ from: "gameplay-care", to: "gameplay-core-loop", type: "supports", label: "adds life-sim interaction" },
	{ from: "gameplay-shop", to: "gameplay-care", type: "supports", label: "provides care items" },
	{ from: "gameplay-shop", to: "shop-mode", type: "supports", label: "presented in shop scene" },
	{ from: "gameplay-visit", to: "farm-mode", type: "supports", label: "lives on farm HUD" },
	{ from: "gameplay-minigames", to: "minigames-mode", type: "supports", label: "starts from minigames menu" },
	{ from: "gameplay-minigames", to: "egg-catch-mode", type: "supports", label: "current playable minigame" },
	{ from: "gameplay-weather-daily", to: "gameplay-core-loop", type: "supports", label: "adds session and return rhythm" },

	{ from: "gameplay-core-loop", to: "gameplay-produce-eggs", type: "loop", label: "starts with production" },
	{ from: "gameplay-produce-eggs", to: "gameplay-collect", type: "loop", label: "ready eggs become collectable" },
	{ from: "gameplay-collect", to: "gameplay-sell", type: "loop", label: "held eggs can be sold" },
	{ from: "gameplay-sell", to: "gameplay-spend", type: "loop", label: "coins unlock choices" },
	{ from: "gameplay-spend", to: "gameplay-grow", type: "loop", label: "spending improves output" },
	{ from: "gameplay-grow", to: "gameplay-produce-eggs", type: "loop", label: "stronger farm repeats the loop" },
	{ from: "gameplay-care", to: "gameplay-grow", type: "loop", label: "duck XP can improve production" },
	{ from: "gameplay-quests", to: "gameplay-spend", type: "loop", label: "rewards feed progression" },
	{ from: "gameplay-shop", to: "gameplay-spend", type: "loop", label: "coins buy inventory" },
	{ from: "gameplay-minigames", to: "gameplay-spend", type: "loop", label: "modest rewards feed the farm" },

	{ from: "gameplay-roadmap", to: "gameplay-weather-daily", type: "planned", label: "Phase 4 return systems" },
	{ from: "gameplay-roadmap", to: "gameplay-grow", type: "planned", label: "families, hatching, evolution, farm level" },
	{ from: "gameplay-roadmap", to: "gameplay-visit", type: "planned", label: "future social expansion" },
	{ from: "gameplay-roadmap", to: "gameplay-minigames", type: "planned", label: "future minigame expansion" },
	{ from: "gameplay-roadmap", to: "gameplay-promise", type: "planned", label: "all phases stay cozy" },
];

const nodeById = new Map(nodes.map((node) => [node.id, node]));
const edgeTypeById = new Map(edgeTypes.map((type) => [type.id, type]));
const layerById = new Map(layers.map((layer) => [layer.id, layer]));

const state = {
	activeLayers: new Set(lenses[0].layers),
	activeEdgeTypes: new Set(lenses[0].edgeTypes),
	activeLensId: lenses[0].id,
	selectedNodeId: lenses[0].selectedNodeId,
	searchTerm: "",
	scale: 0.8,
	translateX: 80,
	translateY: 40,
};

const elements = {
	lensButtons: document.getElementById("lensButtons"),
	layerFilters: document.getElementById("layerFilters"),
	edgeFilters: document.getElementById("edgeFilters"),
	searchInput: document.getElementById("searchInput"),
	viewport: document.getElementById("mapViewport"),
	canvas: document.getElementById("mapCanvas"),
	svg: document.getElementById("connectionSvg"),
	nodeLayer: document.getElementById("nodeLayer"),
	fitButton: document.getElementById("fitButton"),
	resetButton: document.getElementById("resetButton"),
	focusButton: document.getElementById("focusButton"),
	zoomInput: document.getElementById("zoomInput"),
	zoomValue: document.getElementById("zoomValue"),
	detailTitle: document.getElementById("detailTitle"),
	detailMeta: document.getElementById("detailMeta"),
	detailDescription: document.getElementById("detailDescription"),
	detailFile: document.getElementById("detailFile"),
	detailResponsibilities: document.getElementById("detailResponsibilities"),
	detailConnections: document.getElementById("detailConnections"),
};

function renderFilters(container, items, activeSet, onToggle) {
	container.innerHTML = "";

	for (const item of items) {
		const chip = document.createElement("button");
		chip.type = "button";
		chip.className = `chip${activeSet.has(item.id) ? " active" : ""}`;
		chip.dataset.filterId = item.id;
		chip.textContent = item.label;
		chip.addEventListener("click", () => {
			if (activeSet.has(item.id)) {
				activeSet.delete(item.id);
			} else {
				activeSet.add(item.id);
			}

			state.activeLensId = "custom";
			updateLensButtons();
			chip.classList.toggle("active", activeSet.has(item.id));
			onToggle();
		});
		container.appendChild(chip);
	}
}

function renderLensButtons() {
	elements.lensButtons.innerHTML = "";

	for (const lens of lenses) {
		const button = document.createElement("button");
		button.type = "button";
		button.className = `lens-button${state.activeLensId === lens.id ? " active" : ""}`;
		button.dataset.lensId = lens.id;
		button.innerHTML = `
			<span>${escapeHtml(lens.label)}</span>
			<small>${escapeHtml(lens.description)}</small>
		`;
		button.addEventListener("click", () => applyLens(lens.id));
		elements.lensButtons.appendChild(button);
	}
}

function applyLens(lensId) {
	const lens = lenses.find((item) => item.id === lensId);

	if (!lens) {
		return;
	}

	state.activeLensId = lens.id;
	state.activeLayers.clear();
	lens.layers.forEach((layerId) => state.activeLayers.add(layerId));
	state.activeEdgeTypes.clear();
	lens.edgeTypes.forEach((edgeTypeId) => state.activeEdgeTypes.add(edgeTypeId));
	state.searchTerm = "";
	elements.searchInput.value = "";
	updateLensButtons();
	updateFilterButtons();
	selectNode(lens.selectedNodeId);
	requestAnimationFrame(fitToVisible);
}

function updateLensButtons() {
	document.querySelectorAll(".lens-button").forEach((button) => {
		button.classList.toggle("active", button.dataset.lensId === state.activeLensId);
	});
}

function updateFilterButtons() {
	elements.layerFilters.querySelectorAll(".chip").forEach((chip) => {
		chip.classList.toggle("active", state.activeLayers.has(chip.dataset.filterId));
	});
	elements.edgeFilters.querySelectorAll(".chip").forEach((chip) => {
		chip.classList.toggle("active", state.activeEdgeTypes.has(chip.dataset.filterId));
	});
}

function renderNodes() {
	elements.nodeLayer.innerHTML = "";

	for (const node of nodes) {
		const button = document.createElement("button");
		button.type = "button";
		button.className = `map-node ${node.layer}`;
		button.dataset.nodeId = node.id;
		button.style.left = `${node.x}px`;
		button.style.top = `${node.y}px`;
		button.innerHTML = `
			<span class="node-meta">${escapeHtml(node.kind)}</span>
			<span class="node-label">${escapeHtml(node.label)}</span>
			<span class="node-badge">${escapeHtml(node.badge || layerById.get(node.layer)?.label || node.layer)}</span>
		`;
		button.addEventListener("click", (event) => {
			event.stopPropagation();
			selectNode(node.id);
		});
		elements.nodeLayer.appendChild(button);
	}
}

function renderEdges() {
	elements.svg.innerHTML = "";
	const fragment = document.createDocumentFragment();

	edges.forEach((edge, index) => {
		const from = nodeById.get(edge.from);
		const to = nodeById.get(edge.to);

		if (!from || !to) {
			return;
		}

		const pathData = createPathData(from, to, edge.curve || 0);
		const visual = document.createElementNS("http://www.w3.org/2000/svg", "path");
		visual.setAttribute("d", pathData);
		visual.setAttribute("class", `connection-line ${edge.type}`);
		visual.dataset.edgeIndex = String(index);

		const title = document.createElementNS("http://www.w3.org/2000/svg", "title");
		title.textContent = `${from.label} -> ${to.label}: ${edge.label}`;
		visual.appendChild(title);

		const hit = document.createElementNS("http://www.w3.org/2000/svg", "path");
		hit.setAttribute("d", pathData);
		hit.setAttribute("class", "connection-hit");
		hit.dataset.edgeIndex = String(index);
		hit.addEventListener("click", (event) => {
			event.stopPropagation();
			selectNode(edge.to);
		});

		fragment.appendChild(visual);
		fragment.appendChild(hit);
	});

	elements.svg.appendChild(fragment);
}

function createPathData(from, to, curve) {
	const dx = to.x - from.x;
	const dy = to.y - from.y;
	const distance = Math.max(1, Math.hypot(dx, dy));
	const bend = curve || Math.min(95, distance * 0.14);
	const normalX = -dy / distance;
	const normalY = dx / distance;
	const controlX = (from.x + to.x) / 2 + normalX * bend;
	const controlY = (from.y + to.y) / 2 + normalY * bend;

	return `M ${from.x} ${from.y} Q ${controlX.toFixed(1)} ${controlY.toFixed(1)} ${to.x} ${to.y}`;
}

function selectNode(nodeId) {
	if (!nodeById.has(nodeId)) {
		return;
	}

	state.selectedNodeId = nodeId;
	renderDetail(nodeById.get(nodeId));
	updateGraphState();
}

function renderDetail(node) {
	elements.detailTitle.textContent = node.label;
	elements.detailMeta.textContent = `${layerById.get(node.layer)?.label || node.layer} - ${node.kind}`;
	elements.detailDescription.textContent = node.description;

	if (node.file) {
		elements.detailFile.hidden = false;
		elements.detailFile.href = node.file;
		elements.detailFile.textContent = node.file.replace(/^\.\.\//, "");
	} else {
		elements.detailFile.hidden = true;
	}

	elements.detailResponsibilities.innerHTML = "";
	for (const item of node.responsibilities || []) {
		const li = document.createElement("li");
		li.textContent = item;
		elements.detailResponsibilities.appendChild(li);
	}

	elements.detailConnections.innerHTML = "";
	const relatedEdges = edges.filter((edge) => edge.from === node.id || edge.to === node.id);

	if (relatedEdges.length === 0) {
		const li = document.createElement("li");
		li.textContent = "No mapped connections yet.";
		elements.detailConnections.appendChild(li);
		return;
	}

	for (const edge of relatedEdges) {
		const outgoing = edge.from === node.id;
		const otherNode = nodeById.get(outgoing ? edge.to : edge.from);

		if (!otherNode) {
			continue;
		}

		const li = document.createElement("li");
		const button = document.createElement("button");
		button.type = "button";
		button.className = "connection-button";
		button.innerHTML = `
			${outgoing ? "To" : "From"} ${escapeHtml(otherNode.label)}
			<small>${escapeHtml(edgeTypeById.get(edge.type)?.label || edge.type)} - ${escapeHtml(edge.label)}</small>
		`;
		button.addEventListener("click", () => selectNode(otherNode.id));
		li.appendChild(button);
		elements.detailConnections.appendChild(li);
	}
}

function updateGraphState() {
	const selectedEdges = getIncidentEdges(state.selectedNodeId);
	const connectedIds = new Set();
	for (const edge of selectedEdges) {
		connectedIds.add(edge.from);
		connectedIds.add(edge.to);
	}

	const searchMatches = getSearchMatches();
	const searchRelated = getSearchRelated(searchMatches);
	const hasSearch = state.searchTerm.trim().length > 0;

	document.querySelectorAll(".map-node").forEach((element) => {
		const node = nodeById.get(element.dataset.nodeId);
		const layerVisible = state.activeLayers.has(node.layer);
		const isSelected = node.id === state.selectedNodeId;
		const isConnected = connectedIds.has(node.id) && !isSelected;
		const isSearchRelated = !hasSearch || searchRelated.has(node.id);

		element.classList.toggle("hidden", !layerVisible);
		element.classList.toggle("selected", isSelected);
		element.classList.toggle("connected", isConnected);
		element.classList.toggle("dimmed", layerVisible && !isSelected && !isSearchRelated);
	});

	document.querySelectorAll(".connection-line").forEach((element) => {
		const edge = edges[Number(element.dataset.edgeIndex)];
		const edgeVisible = isEdgeVisible(edge);
		const selected = edge.from === state.selectedNodeId || edge.to === state.selectedNodeId;
		const searchVisible = !hasSearch || searchRelated.has(edge.from) || searchRelated.has(edge.to);

		element.style.display = edgeVisible ? "" : "none";
		element.classList.toggle("highlighted", selected);
		element.classList.toggle("dimmed", edgeVisible && !selected && !searchVisible);
	});

	document.querySelectorAll(".connection-hit").forEach((element) => {
		const edge = edges[Number(element.dataset.edgeIndex)];
		element.style.display = isEdgeVisible(edge) ? "" : "none";
	});
}

function isEdgeVisible(edge) {
	const from = nodeById.get(edge.from);
	const to = nodeById.get(edge.to);

	return Boolean(
		from &&
		to &&
		state.activeEdgeTypes.has(edge.type) &&
		state.activeLayers.has(from.layer) &&
		state.activeLayers.has(to.layer)
	);
}

function getIncidentEdges(nodeId) {
	return edges.filter((edge) => edge.from === nodeId || edge.to === nodeId);
}

function getSearchMatches() {
	const term = state.searchTerm.trim().toLowerCase();
	const matches = new Set();

	if (!term) {
		return matches;
	}

	for (const node of nodes) {
		const haystack = [
			node.label,
			node.kind,
			node.description,
			node.file,
			...(node.responsibilities || []),
		].join(" ").toLowerCase();

		if (haystack.includes(term)) {
			matches.add(node.id);
		}
	}

	return matches;
}

function getSearchRelated(matches) {
	if (matches.size === 0) {
		return new Set();
	}

	const related = new Set(matches);
	for (const edge of edges) {
		if (matches.has(edge.from) || matches.has(edge.to)) {
			related.add(edge.from);
			related.add(edge.to);
		}
	}
	return related;
}

function updateTransform() {
	elements.canvas.style.transform = `translate(${state.translateX}px, ${state.translateY}px) scale(${state.scale})`;
	elements.zoomInput.value = String(state.scale);
	elements.zoomValue.textContent = `${Math.round(state.scale * 100)}%`;
}

function fitToVisible() {
	const visibleNodes = nodes.filter((node) => state.activeLayers.has(node.layer));

	if (visibleNodes.length === 0) {
		return;
	}

	const bounds = visibleNodes.reduce(
		(acc, node) => ({
			minX: Math.min(acc.minX, node.x),
			minY: Math.min(acc.minY, node.y),
			maxX: Math.max(acc.maxX, node.x),
			maxY: Math.max(acc.maxY, node.y),
		}),
		{ minX: Infinity, minY: Infinity, maxX: -Infinity, maxY: -Infinity }
	);
	const rect = elements.viewport.getBoundingClientRect();
	const margin = 170;
	const width = bounds.maxX - bounds.minX + margin * 2;
	const height = bounds.maxY - bounds.minY + margin * 2;
	const scale = clamp(Math.min(rect.width / width, rect.height / height), 0.45, 1.15);

	state.scale = scale;
	state.translateX = (rect.width - (bounds.maxX - bounds.minX) * scale) / 2 - bounds.minX * scale;
	state.translateY = (rect.height - (bounds.maxY - bounds.minY) * scale) / 2 - bounds.minY * scale;
	updateTransform();
}

function focusSelected() {
	const node = nodeById.get(state.selectedNodeId);
	if (!node) {
		return;
	}

	const rect = elements.viewport.getBoundingClientRect();
	const scale = clamp(Math.max(state.scale, 0.78), 0.45, 1.25);
	state.scale = scale;
	state.translateX = rect.width / 2 - node.x * scale;
	state.translateY = rect.height / 2 - node.y * scale;
	updateTransform();
}

function resetView() {
	state.scale = 0.8;
	state.translateX = 80;
	state.translateY = 40;
	updateTransform();
}

function clamp(value, min, max) {
	return Math.max(min, Math.min(max, value));
}

function escapeHtml(value) {
	return String(value ?? "")
		.replace(/&/g, "&amp;")
		.replace(/</g, "&lt;")
		.replace(/>/g, "&gt;")
		.replace(/"/g, "&quot;")
		.replace(/'/g, "&#039;");
}

function installPanAndZoom() {
	let dragging = false;
	let startX = 0;
	let startY = 0;
	let startTranslateX = 0;
	let startTranslateY = 0;

	elements.viewport.addEventListener("pointerdown", (event) => {
		if (event.target.closest(".map-node")) {
			return;
		}

		dragging = true;
		startX = event.clientX;
		startY = event.clientY;
		startTranslateX = state.translateX;
		startTranslateY = state.translateY;
		elements.viewport.classList.add("dragging");
		elements.viewport.setPointerCapture(event.pointerId);
	});

	elements.viewport.addEventListener("pointermove", (event) => {
		if (!dragging) {
			return;
		}

		state.translateX = startTranslateX + event.clientX - startX;
		state.translateY = startTranslateY + event.clientY - startY;
		updateTransform();
	});

	elements.viewport.addEventListener("pointerup", (event) => {
		if (!dragging) {
			return;
		}

		dragging = false;
		elements.viewport.classList.remove("dragging");
		elements.viewport.releasePointerCapture(event.pointerId);
	});

	elements.viewport.addEventListener("wheel", (event) => {
		event.preventDefault();
		const rect = elements.viewport.getBoundingClientRect();
		const pointerX = event.clientX - rect.left;
		const pointerY = event.clientY - rect.top;
		const worldX = (pointerX - state.translateX) / state.scale;
		const worldY = (pointerY - state.translateY) / state.scale;
		const direction = event.deltaY > 0 ? -1 : 1;
		const nextScale = clamp(state.scale + direction * 0.07, 0.45, 1.45);

		state.scale = nextScale;
		state.translateX = pointerX - worldX * nextScale;
		state.translateY = pointerY - worldY * nextScale;
		updateTransform();
	}, { passive: false });
}

function installEvents() {
	elements.searchInput.addEventListener("input", () => {
		state.searchTerm = elements.searchInput.value;
		const matches = getSearchMatches();
		if (matches.size > 0) {
			const firstMatch = [...matches][0];
			if (firstMatch !== state.selectedNodeId) {
				selectNode(firstMatch);
				return;
			}
		}
		updateGraphState();
	});

	elements.fitButton.addEventListener("click", fitToVisible);
	elements.resetButton.addEventListener("click", resetView);
	elements.focusButton.addEventListener("click", focusSelected);
	elements.zoomInput.addEventListener("input", () => {
		state.scale = Number(elements.zoomInput.value);
		updateTransform();
	});

	window.addEventListener("resize", () => {
		updateTransform();
	});
}

renderLensButtons();
renderFilters(elements.layerFilters, layers, state.activeLayers, updateGraphState);
renderFilters(elements.edgeFilters, edgeTypes, state.activeEdgeTypes, updateGraphState);
renderNodes();
renderEdges();
installPanAndZoom();
installEvents();
selectNode(state.selectedNodeId);
updateTransform();
requestAnimationFrame(fitToVisible);
