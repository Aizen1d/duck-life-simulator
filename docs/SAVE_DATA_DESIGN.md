# Save Data Design

Save Data V0 defines and implements persistent player progress for `Duck`.

The goal is to keep the first persistence pass small, server-owned, validated, and easy to reset during Studio testing.

## Current Decision

Save Data V0 is implemented in `src/server/PlayerDataService.luau` and integrated through `src/server/PlayerStateService.luau`.

The current playable prototype loads player data on join, autosaves dirty state about `3` seconds after meaningful changes, retries failed autosaves after a longer delay, saves on leave, attempts final saves on shutdown, and includes Studio-only tester controls guarded by `RunService:IsStudio()`. The visible farm-screen save status indicator has been removed; save verification should use Studio Output logs and rejoin checks. The current saved schema is `schemaVersion = 6` because Toy inventory and `lastDailyClaimDay` now persist alongside Duck Feed, Premium Feed, Treat, Pillow, and Quest V0/V1/V2 progress.

## Official Roblox References Checked

- [Data stores](https://create.roblox.com/docs/cloud-services/data-stores)
- [Best practices for data stores](https://create.roblox.com/docs/cloud-services/data-stores/best-practices)
- [Data store error codes and limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits)
- [Save player data with standard data stores](https://create.roblox.com/docs/tutorials/use-case-tutorials/data-storage/save-player-data)

Relevant constraints from the official docs:

- DataStore access belongs on the server. Clients must not read or write persistent data directly.
- Studio DataStore access requires `Enable Studio Access to API Services`, and Studio can touch the same stores as a live experience if pointed at the same published place.
- Related player data should be stored in one object per player when practical.
- DataStore request budgets, throttling, queue limits, and per-key throughput matter.
- Temporary or cache-like data should not be saved in DataStores.

## V0 Save Scope

Save the smallest set of values that make the current prototype feel continuous across sessions:

- `schemaVersion`
- `coins`
- `eggs`
- `duckFeed`
- `premiumFeed`
- `duckTreat`
- `pillow`
- `toy`
- `availableEggs`
- `eggValueLevel`
- owned ducks
- per-duck stable id
- per-duck display name
- per-duck level
- per-duck XP
- quest level/progress for Quest V0/V1/V2 collect, sell, help, use-treats, buy-ducks, and spend-coins quests
- `lastDailyClaimDay` (integer day-since-epoch for Daily Check-in V0)

Do not save these in V0:

- seconds until next egg
- temporary happy mood timers
- care cooldown timers
- active care request duck index
- active care request kind
- rename error messages
- floating feedback
- selected duck UI state
- profile panel state
- shop screen state
- Studio tester state
- quest completion floating feedback

These values are session presentation or timers. They should restart cleanly on join. Ready eggs on the nest are not treated as temporary for V0; `availableEggs` should persist so players do not lose ready-to-collect eggs when rejoining.

## Data Shape

Use one standard DataStore object per player.

Store name:

```text
DuckPlayerDataV1
```

Key:

```text
player_<UserId>
```

Object:

```lua
{
	schemaVersion = 6,
	coins = 0,
	eggs = 0,
	duckFeed = 0,
	premiumFeed = 0,
	duckTreat = 0,
	pillow = 0,
	toy = 0,
	availableEggs = 0,
	eggValueLevel = 0,
	nextDuckId = 2,
	ducks = {
		{
			id = 1,
			name = "Waddles",
			level = 1,
			xp = 0,
		},
	},
	quests = {
		collect_eggs = {
			level = 1,
			progress = 0,
		},
		sell_eggs = {
			level = 1,
			progress = 0,
		},
		help_ducks = {
			level = 1,
			progress = 0,
		},
		use_treats = {
			level = 1,
			progress = 0,
		},
		buy_ducks = {
			level = 1,
			progress = 0,
		},
		spend_coins = {
			level = 1,
			progress = 0,
		},
	},
	lastDailyClaimDay = 0,
}
```

`nextDuckId` should be saved so future ducks can keep stable IDs even after deletes, breeding, mutation, or sorting are added.

## Load Rules

When a player joins:

- Server loads the player object from DataStore.
- If no data exists, server creates a default state from `PrototypeConfig`.
- If data exists, server validates every field before using it.
- Missing fields fall back to safe defaults.
- Invalid, `NaN`, or infinite numbers fall back to safe defaults or are clamped to allowed ranges.
- Invalid duck records are skipped or repaired.
- If all duck records are invalid or missing, create one default duck.
- Missing quest records fall back to level `1` and progress `0`.
- Do not trust saved display names blindly if future cross-user display rules change.
- If load fails, do not autosave a fresh default state over a possible existing save.

## Save Rules

When a player leaves:

- Server saves the latest validated persistent state.
- Use a protected call and record failures.
- Do not block gameplay on successful save during normal actions.

During long sessions:

- Autosave shortly after meaningful state changes.
- Debounce autosave so repeated egg ticks or UI actions do not save on every click.
- Current prototype cadence is about `3` seconds after the first dirty change.
- If a save attempt fails, wait longer before retrying so DataStore errors do not cause rapid repeated writes.

On server shutdown:

- Use `BindToClose` to attempt final saves for players still in the server.
- Keep the shutdown save path bounded and resilient to failed requests.

## Write Method Recommendation

Prefer `UpdateAsync` for player saves so the save path can compare and replace a single player object safely.

The first implementation does not need OrderedDataStores, leaderboards, global name reservations, trading, or cross-server mutation systems.

## Validation Rules

Persistent values must stay server-owned:

- `coins`: finite integer, minimum `0`
- `eggs`: finite integer, minimum `0`
- `duckFeed`: finite integer, minimum `0`
- `premiumFeed`: finite integer, minimum `0`
- `duckTreat`: finite integer, minimum `0`
- `pillow`: finite integer, minimum `0`
- `toy`: finite integer, minimum `0`
- `lastDailyClaimDay`: finite integer day-since-epoch, minimum `0`
- `availableEggs`: finite integer, minimum `0`
- `eggValueLevel`: finite integer, minimum `0`, maximum `PrototypeConfig.firstUpgrade.maxLevel`
- `nextDuckId`: finite integer, at least one greater than the highest saved duck id
- duck `id`: positive finite integer, unique within that player's save
- duck `name`: string, `2` to `16` characters after trim, unique within that player's duck list
- duck `level`: finite integer, between `PrototypeConfig.duckLevel.startingLevel` and `PrototypeConfig.duckLevel.maxLevel`
- duck `xp`: finite integer, minimum `0`, below `xpPerLevel` unless max-level rules intentionally allow otherwise
- quest `level`: finite integer, minimum `1`
- quest `progress`: finite integer, minimum `0`, below that quest level target

Client requests must never send these values as authoritative save data.

## Text Filtering and Names

Rename V0 already filters player-submitted names before they enter server state. When saving names:

- Save only server-accepted display names.
- Do not save raw unfiltered rename submissions.
- Continue duplicate checks within the player's duck list.
- Do not add global or cross-player name uniqueness in Save Data V0.

Global duck-name uniqueness would require a separate reservation design and is not approved.

## Migration Plan

Every saved object must include `schemaVersion`.

For V0:

- `schemaVersion = 6`
- Existing `schemaVersion = 5` saves load with default Toy inventory at `0`, default `lastDailyClaimDay` at `0`, and default `buy_ducks`/`spend_coins` quests at level `1`, progress `0`.
- Existing `schemaVersion = 4` saves load with default Pillow inventory at `0`, default Toy inventory at `0`, default `lastDailyClaimDay` at `0`, and default `use_treats`/`buy_ducks`/`spend_coins` quests at level `1`, progress `0`.
- Existing `schemaVersion = 3` saves load with default Premium Feed inventory at `0`, default Pillow inventory at `0`, default Toy inventory at `0`, default `lastDailyClaimDay` at `0`, and default `use_treats`/`buy_ducks`/`spend_coins` quests at level `1`, progress `0`.
- Existing `schemaVersion = 2` saves load with default Treat inventory at `0`, Premium Feed inventory at `0`, Pillow inventory at `0`, Toy inventory at `0`, default `lastDailyClaimDay` at `0`, and default `use_treats`/`buy_ducks`/`spend_coins` quests at level `1`, progress `0`.
- Existing `schemaVersion = 1` saves load with default Quest V0/V1/V2 records at level `1`, progress `0`, default Treat/Pillow/Toy inventories at `0`, and default `lastDailyClaimDay` at `0`.
- Unknown future fields should be ignored by older code.
- New future fields should have defaults.
- Migration code should be explicit and recorded in this document before implementation.

## Planned Schema Growth by Roadmap Phase

The approved long-term roadmap (`docs/ROADMAP.md`, 2026-06-11) maps expected schema versions to content phases. These are planning targets, not implemented schemas: before each bump, the exact fields, defaults, validation rules, and migration steps must be recorded in this document, and each phase may merge or split versions if implementation order changes.

- `schemaVersion = 7` (Phase 4): last-seen UTC timestamp for Offline Progress V0, streak count and streak last-claim day, daily quest day stamp and slot states, badge grant flags, settings (music, sfx, reduced motion), and Feature Unlock Ladder flags only where a rung cannot be derived from existing server-owned progress (derive instead of save wherever possible).
- `schemaVersion = 8` (Phase 5): per-duck family id and rarity, Duckdex discovered map, collection reward claim flags, starter-choice completion flag, Mystery Duck Box inventory. Existing ducks migrate as `Classic Yellow`.
- `schemaVersion = 9` (Phase 6): egg inventory by type, incubator slot states with finish timestamps, hatch pity counters.
- `schemaVersion = 10` (Phase 7): per-duck evolution stage, Star Grain inventory, duck level cap validation raised from `5` to `10`, per-duck daily XP counter and day stamp for the `150` XP/day pacing cap.
- `schemaVersion = 11` (Phase 8): farm level and farm points, unlocked zones, decoration inventory, placed decoration anchor assignments.
- `schemaVersion = 12` (Phase 9): per-duck mutation id, breeding timers and per-duck cooldowns, breeding pity counter.
- `schemaVersion = 13` (Phase 10): gift cooldowns, like counters, visitor book entries, profile titles. Leaderboards use separate OrderedDataStore keys, and offline farm snapshots require their own store and privacy design doc before implementation.
- `schemaVersion = 14` (Phase 11): per-event progress, Festival Tickets, claimed event stock, owned event items. Event definitions stay server config, not save data.
- `schemaVersion = 15` (Phase 12): legacy count, Legacy Feathers, owned legacy boosts, per-family mastery XP, legacy duck mark.

Phase 7B (Pond Games) adds fields to whichever schema version is current when it ships: saved battle team duck ids, Pond Tour stage progress, first-clear reward flags, per-duck trained stat bonuses (`Heart`/`Splash`/`Pace`/`Spirit`, each capped at `+20`), and the active Training Camp session (duck id, stat id, server-derived finish timestamp). Training timestamps follow the same rules as all timers: server-derived, validated against forged or future-dated values on load, and a duck in training is excluded from egg production and offline accrual. Battle outcomes themselves are never saved as trust inputs; every match is server-resolved at play time.

Monetization waves (`docs/PRODUCT_PLAN.md`) add fields to whichever schema version is current when the wave ships: a capped list of processed developer-product receipt ids for idempotent grants, owned-cosmetic flags (accessory packs, decoration themes, event bundles), and a per-duck equipped cosmetic accessory slot. Gamepass ownership is platform-owned and is checked via `MarketplaceService`, not saved. Receipt processing must write the grant and receipt id before returning `PurchaseGranted`.

General rules for every bump: timestamps are server-derived (`os.time`) and never client-reported; all timers validate against forged or future-dated values on load; counters are finite non-negative integers; and every new field gets a safe default so older saves load cleanly.

## Studio Testing Requirements

- Use this current place for V0 testing, as approved by the user.
- Enable Studio access to API services deliberately for this place before testing.
- Use the versioned `DuckPlayerDataV1` store name, Studio Output logs, and stop/rejoin checks to verify prototype data during testing.
- Test load, save on leave, autosave, shutdown save, invalid data fallback, Quest V0 persistence, Premium Feed and Treat inventory persistence, and DataStore failure handling. Load failure must not write default data over a possible existing save.

## Security Requirements

- DataStoreService must only be used from server code under `src/server`.
- The client may request gameplay actions, but the server derives and saves the resulting state.
- Do not add a remote that lets the client submit a full save object.
- Validate every loaded value because old saves, test data, or manual edits can be malformed.
- Keep Studio tester actions guarded by `RunService:IsStudio()`.

## V0 Implementation Status

- [x] Added server `PlayerDataService`.
- [x] Added serialization from runtime state to the V0 save shape.
- [x] Added validation from loaded data into runtime state.
- [x] Load on `PlayerAdded`.
- [x] Save on `PlayerRemoving`.
- [x] Add periodic autosave.
- [x] Add `BindToClose` final save attempts.
- [x] Add Studio-only tester helpers guarded by `RunService:IsStudio()`.
- [x] Remove the visible save status UI after autosave and leave-save behavior were verified; keep internal save status for server flow and debugging.
- [x] Update `docs/WORKFLOW.md` with persistence test steps.
- [x] Persist Quest V0 level/progress, Treat inventory, and Premium Feed inventory in schema version `4`.
- [x] Persist Pillow inventory and Quest V1 `use_treats` level/progress in schema version `5`.
- [x] Persist Toy inventory, `lastDailyClaimDay`, and Quest V2 `buy_ducks`/`spend_coins` level/progress in schema version `6`.

## Approved V0 Decisions

- Held eggs persist.
- Ready eggs on the nest persist as `availableEggs`.
- Duck Feed, Premium Feed, Treat inventory, duck names, profiles, level, XP, stable duck IDs, and Quest V0 level/progress persist.
- Visible save status UI is not included in the current farm screen; save behavior is verified with Studio Output logs and rejoin checks.
- Player-facing save failure warnings are not included in V0; failures should be logged and represented internally first.
- DataStore testing can use this current place, with deliberate Studio API-services setup, Studio Output logs, and reload checks.

## Remaining Open Questions

- Should future duck IDs become strings before mutation and breeding add parent/child references? This must be answered before the Phase 9 (`schemaVersion = 12`) breeding implementation; the current integer `nextDuckId` scheme looks sufficient if breeding only stores parent ids, not full lineage trees.

