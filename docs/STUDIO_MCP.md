# Roblox Studio MCP — Tools and Testing Workflow

This project can be driven and tested through the **Roblox Studio MCP** server, which lets an agent execute Luau inside a live Studio instance, enter/exit Play mode, read the Output log, and inspect the running game. When the MCP is available, agents should use it to verify game behavior — not rely on static reading or headless logic alone.

This list was captured on 2026-06-13. Re-run `claude mcp list` to confirm the server set and `tools/list` (or ask a fresh session to enumerate `mcp__` tools) if the toolset looks different.

## Server Status

`claude mcp list` shows four MCP servers:

- **`Roblox_Studio`** — ✓ Connected. Local stdio server launched via `cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat` (Roblox's official `StudioMCP.exe`). Requires Roblox Studio open. This is the one used for game testing.
- **`claude.ai Gmail`, `claude.ai Google Calendar`, `claude.ai Google Drive`** — each needs authentication and currently exposes only `authenticate` / `complete_authentication` stubs. Their real tools appear only after OAuth. **Not game-related**; ignore for Duck work.

## Roblox_Studio Tools (27)

**Run / inspect the live game**
- `execute_luau` — run Luau in a chosen datamodel (`Edit`, `Client`, or `Server`). The workhorse. `Server`/`Client` require an active Play session; `Edit` works at any time.
- `get_console_output` — read the Studio Output log (e.g. the `[Duck] Saved data ...` / `[Duck] Loaded save data ...` lines).
- `get_studio_state` — current play state and which datamodels are available.
- `start_stop_play` — `is_start: true/false` to enter/exit Play mode for real.
- `inspect_instance` — full properties/attributes/children of one instance (dot-notation path).
- `search_game_tree` — walk the game hierarchy as flat JSON (filter by type/keywords/depth).
- `list_roblox_studios` / `set_active_studio` — pick which Studio instance tool calls target.

**Read / edit scripts in Studio**
- `script_read`, `script_grep`, `script_search`, `multi_edit` (the repo source is the source of truth — prefer editing files on disk via Rojo over `multi_edit`).

**Visual**
- `screen_capture` — capture the editor viewport. **Edit-time only** — it does not reliably show the running Play-mode GUI.
- `user_mouse_input`, `user_keyboard_input`, `character_navigation` — drive real input into a Play session (clicks, typing, movement).

**Assets / content generation**
- `generate_mesh`, `generate_material`, `generate_procedural_model`, `search_creator_store`, `insert_from_creator_store`, `store_image`, `upload_image`, `wait_job_finished`.

**Docs / misc**
- `http_get` (Roblox Creator Docs URLs only), `skill` (`docs-search`, `scene-analysis`), `subagent` (`explore`).

## Testing Rule

When a task asks to verify game behavior (a "Play-test ..." item in `docs/TASKS.md`, a bug fix, or a new feature), and the `Roblox_Studio` MCP is connected, **exercise the real code through the MCP** instead of stopping at static analysis. Server logic verified this way is real verification; **record it in the backlog** using the split described in [Recording Results in the Backlog](#recording-results-in-the-backlog).

What the MCP **can** verify authoritatively:

- Server-authoritative economy/state logic against the real `PlayerStateService` (offline progress, streak, comeback gift, quests, unlock ladder, purchases, care/XP).
- DataStore persistence through real stop/rejoin round-trips.
- Server-side rejection of invalid/locked actions.
- That new code compiles (`rojo build`) and runs without Output errors on join and on each action.

What still needs a **human in Play mode** (record as a separate open item):

- On-screen rendering of toasts, cards, panels, and layout/mobile checks — `screen_capture` is edit-time only. (`search_game_tree` + `inspect_instance` can partially confirm a GUI object exists and its text, short of pixels.)
- 2-player / multiplayer flows (`start_stop_play` runs a single local session).

## Recording Results in the Backlog

After verifying through the MCP, **update `docs/TASKS.md` so the result is visible to the next agent.** Do not leave a tested item looking untested, and do not mark an item fully done when only the server logic was checked. Use the split convention already in that file:

- Mark the **server-logic** portion `- [x]` with the date and exactly what the MCP confirmed (rates, caps, persistence, rejection of invalid/locked actions, etc.).
- Leave or add a separate `- [ ]` line for the **visuals / multiplayer** portion that still needs a human in Play mode (toast/card rendering, layout, 2-player flows).
- If a defect or surprising edge turns up, add a short known-issue line instead of silently checking the item off.
- For a bug fix, also add the `Fixed` entry to `docs/CHANGELOG.md` per `docs/DOC_UPDATE_POLICY.md`.

Follow the existing Phase 4 entries in `docs/TASKS.md` for the established format: `- [x] <Feature> — server logic (MCP-verified <date>): <what was confirmed>` paired with `- [ ] <Feature> — visuals (Play-mode eyes): <what remains>`.

## Recommended Procedure (state + persistence tests)

1. Confirm Studio API services are enabled (a `DataStoreService:GetAsync` in `Edit` succeeds, not a 403). See `docs/WORKFLOW.md` Save Data Work.
2. **Back up and clear** the dev save before a fresh-profile test: in `Edit`, `GetAsync` the key, `SetAsync` it to a `_pretest_backup` key, then `RemoveAsync`. Restore from the backup when done — leave the dev profile as you found it.
3. `start_stop_play(true)`, then in `Server` wait for the player to load.
4. Drive actions from the **`Client`** datamodel by firing the real remote: `ReplicatedStorage.DuckRemotes.DuckAction:FireServer(actionName, payload)`. Capture the replicated state by listening to `DuckRemotes.DuckState.OnClientEvent` in the same script (this gives the full server-serialized state, including `featureUnlocks`).
5. To simulate elapsed time (offline/comeback/streak), stop play and rewrite the saved `lastSeenUtc` / `lastDailyClaimDay` in the DataStore from `Edit`, then rejoin.
6. `get_console_output` to confirm `[Duck] ...` save/load lines and the absence of errors.
7. `start_stop_play(false)` to end the session (do not leave Studio in Play mode), then read the final DataStore record to assert persisted values.
8. Restore the dev save from the backup key; clean up temp files.

### Key constants for tests

- DataStore name: `DuckPlayerDataV1`; key format: `player_<userId>` (in Edit, the local user id is `StudioService:GetUserId()`).
- Remotes folder: `ReplicatedStorage.DuckRemotes` with `DuckAction` (client→server actions), `DuckState` (server→client state), `DuckNotice` (toasts). Action and notice names live in `src/shared/RemoteProtocol.luau`.
- Studio-only tester actions (e.g. `test_ready_eggs` = `+10` ready, `test_add_coins` = `+100`) are gated by `RunService:IsStudio()` and are convenient for driving tests fast.

## Caveats

- The MCP tools may be **deferred** in a given session; if they are not directly callable, reload the IDE window / start a fresh session to register them.
- The MCP depends on the owner's machine (Studio open, API services on). Agents in environments without it should fall back to `rojo build` + code review and clearly mark game behavior as unverified.
- Tester actions and direct DataStore edits change the dev save; always back up and restore.
