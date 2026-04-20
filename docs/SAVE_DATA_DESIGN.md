# Save Data Design

Save Data V0 is a design pass for persistent player progress in `Duck`. It does not implement DataStore code yet.

The goal is to define what should persist, what should remain session-only, and what rules future implementation must follow before the project starts writing player data.

## Current Decision

Save Data V0 is approved for design, not runtime implementation.

The current playable prototype still runs session-only. The next implementation pass may add DataStore persistence only after this design is reviewed and the Studio testing setup is confirmed.

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
- `eggValueLevel`
- owned ducks
- per-duck stable id
- per-duck display name
- per-duck level
- per-duck XP

Do not save these in V0:

- available uncollected eggs on the nest
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

These values are session presentation or timers. They should restart cleanly on join.

## Proposed Data Shape

Use one standard DataStore object per player.

Suggested store name:

```text
DuckPlayerDataV1
```

Suggested key:

```text
player_<UserId>
```

Suggested object:

```lua
{
	schemaVersion = 1,
	coins = 0,
	eggs = 0,
	duckFeed = 0,
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
}
```

`nextDuckId` should be saved so future ducks can keep stable IDs even after deletes, breeding, mutation, or sorting are added.

## Load Rules

When a player joins:

- Server loads the player object from DataStore.
- If no data exists, server creates a default state from `PrototypeConfig`.
- If data exists, server validates every field before using it.
- Missing fields fall back to safe defaults.
- Invalid numbers are clamped to allowed ranges.
- Invalid duck records are skipped or repaired.
- If all duck records are invalid or missing, create one default duck.
- Do not trust saved display names blindly if future cross-user display rules change.

## Save Rules

When a player leaves:

- Server saves the latest validated persistent state.
- Use a protected call and record failures.
- Do not block gameplay on successful save during normal actions.

During long sessions:

- Autosave periodically.
- Use a modest interval, such as `120` seconds, until the game needs a different cadence.
- Avoid saving on every click, egg tick, care action, or UI interaction.
- Save after meaningful state changes only if the save is debounced.

On server shutdown:

- Use `BindToClose` to attempt final saves for players still in the server.
- Keep the shutdown save path bounded and resilient to failed requests.

## Write Method Recommendation

Prefer `UpdateAsync` for player saves so the save path can compare and replace a single player object safely.

The first implementation does not need OrderedDataStores, leaderboards, global name reservations, trading, or cross-server mutation systems.

## Validation Rules

Persistent values must stay server-owned:

- `coins`: integer, minimum `0`
- `eggs`: integer, minimum `0`
- `duckFeed`: integer, minimum `0`
- `eggValueLevel`: integer, minimum `0`, maximum current upgrade max
- `nextDuckId`: integer, at least one greater than the highest saved duck id
- duck `id`: positive integer, unique within that player's save
- duck `name`: string, `2` to `16` characters after trim, unique within that player's duck list
- duck `level`: integer, between `PrototypeConfig.duckLevel.startingLevel` and `PrototypeConfig.duckLevel.maxLevel`
- duck `xp`: integer, minimum `0`, below `xpPerLevel` unless max-level rules intentionally allow otherwise

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

- `schemaVersion = 1`
- Unknown future fields should be ignored by older code.
- New future fields should have defaults.
- Migration code should be explicit and recorded in this document before implementation.

Expected future migration pressures:

- mutations
- breeding
- duck traits
- duck appearance variants
- profile history
- expanded inventory
- more upgrades
- weather or event progress

## Studio Testing Requirements

Before implementing persistence:

- Publish or use a separate test experience.
- Enable Studio access to API services only for the test experience.
- Do not point Studio tests at a live production data store.
- Add a Studio-only reset/save debug path only if it is guarded by `RunService:IsStudio()`.
- Test load, save on leave, autosave, invalid data fallback, and DataStore failure handling.

## Security Requirements

- DataStoreService must only be used from server code under `src/server`.
- The client may request gameplay actions, but the server derives and saves the resulting state.
- Do not add a remote that lets the client submit a full save object.
- Validate every loaded value because old saves, test data, or manual edits can be malformed.
- Keep Studio tester actions guarded by `RunService:IsStudio()`.

## V0 Implementation Checklist

Before coding:

- Review this design and confirm the save scope.
- Decide whether `eggs` should persist or whether only `coins` and ducks should persist.
- Decide whether the first implementation should include an on-screen save status indicator.
- Confirm Studio API-services setup is using a test experience.

Implementation steps:

1. Add a server `PlayerDataService`.
2. Add serialization from runtime state to the V0 save shape.
3. Add validation from loaded data into runtime state.
4. Load on `PlayerAdded`.
5. Save on `PlayerRemoving`.
6. Add periodic autosave.
7. Add `BindToClose` final save attempts.
8. Add Studio-only testing helpers only if needed.
9. Update `docs/WORKFLOW.md` with persistence test steps.
10. Update this document with any implementation deviations.

## Open Questions

- Should held eggs persist, or should only coins and duck ownership persist?
- Should unavailable ready eggs be discarded on rejoin or converted into held eggs?
- Should the first save implementation expose a small `Saved` or `Saving` status in UI?
- Should save failures show a player-facing warning in the prototype?
- Should future duck IDs become strings before mutation and breeding add parent/child references?