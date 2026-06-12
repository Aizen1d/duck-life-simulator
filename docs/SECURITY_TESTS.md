# Security Test Cases

Use these checks to verify that gameplay remotes stay server-authoritative and ignore malformed or unauthorized client requests.

These are Studio QA test cases, not an automated test runner. The project has not approved a Luau test dependency yet, so run them from a client-side Studio context such as a temporary LocalScript during Play mode or a client Command Bar context if available.

Official Roblox references checked:

- [Remote events and callbacks](https://create.roblox.com/docs/scripting/events/remote)
- [RemoteEvent API reference](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent)

## Test Setup

1. Start Play mode from the Rojo-synced place or a fresh `Duck.rbxlx` build.
2. Wait until the farm UI has loaded and the server has sent the first normal state.
3. Use a test profile or Studio session where economy and save changes can be reset.
4. Record the visible state before each check: eggs, coins, ready eggs, Duck Feed, Premium Feed, Treat, duck count, selected duck level/XP, quest progress, and whether the player is visiting another farm.
5. Fire each remote request from the client. The server should never trust client-submitted economy values, duck values, quest values, timers, cooldowns, inventory amounts, or farm ownership.

Helper snippet:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("DuckRemotes")
local action = remotes:WaitForChild("DuckAction")
local notice = remotes:WaitForChild("DuckNotice")
```

When testing several actions in a row, wait at least `0.2` seconds between requests so the project's own action cooldown does not hide the validation path being checked.

## Invalid Action Names

Run:

```lua
action:FireServer("not_a_duck_action")
task.wait(0.2)
action:FireServer(12345)
task.wait(0.2)
action:FireServer({})
```

Expected:

- No server errors.
- No state changes.
- No coins, eggs, inventory, ducks, quests, weather, or visit target changes.

## Invalid Shop Payloads

Run each payload with enough coins to buy at least one real shop item, then compare state:

```lua
action:FireServer("buy_shop_item", "unknown_item")
task.wait(0.2)
action:FireServer("buy_shop_item", { itemId = "unknown_item" })
task.wait(0.2)
action:FireServer("buy_shop_item", { itemId = 5 })
task.wait(0.2)
action:FireServer("buy_shop_item", {})
```

Expected:

- No server errors.
- Coins do not decrease.
- Duck Feed, Premium Feed, Treat, Pillow, and Toy counts do not increase.

## Invalid Duck Index Payloads

Run these for both `care_for_ducks` and `use_treat_on_duck`:

```lua
local payloads = {
	0,
	-1,
	1.5,
	999,
	math.huge,
	0 / 0,
	"1",
	{ duckIndex = 0 },
	{ duckIndex = -1 },
	{ duckIndex = 1.5 },
	{ duckIndex = 999 },
	{ duckIndex = math.huge },
	{ duckIndex = 0 / 0 },
	{ duckIndex = "1" },
	{},
}

for _, payload in payloads do
	action:FireServer("care_for_ducks", payload)
	task.wait(0.2)
end

for _, payload in payloads do
	action:FireServer("use_treat_on_duck", payload)
	task.wait(0.2)
end
```

Expected:

- No server errors.
- Duck level/XP does not change from invalid indexes.
- Treat inventory does not decrease from invalid indexes.
- Help quest progress does not increase.
- Active care requests are not cleared by invalid indexes.

## Rename Payload Validation

Run:

```lua
action:FireServer("rename_duck", {})
task.wait(0.2)
action:FireServer("rename_duck", { duckIndex = 999, name = "Quack" })
task.wait(0.2)
action:FireServer("rename_duck", { duckIndex = 1, name = "A" })
task.wait(0.2)
action:FireServer("rename_duck", { duckIndex = 1, name = "ThisNameIsFarTooLongForTheLimit" })
```

Expected:

- No server errors.
- Invalid or rejected names do not replace the previous duck name.
- The profile may show the expected server validation error for rename-specific failures.

For duplicate-name testing, use two ducks and submit the first duck's current name for the second duck.

Expected:

- The duplicate is rejected case-insensitively.
- The old name remains.

## Egg Catch Reward Abuse

Run without a started round:

```lua
action:FireServer("claim_egg_catch_reward", { sessionId = 1, score = 60 })
```

Expected:

- The reward notice reports failure or expiry.
- Coins, Duck Feed, and Treat do not change.

Start a round, capture the server-issued session id, then claim immediately:

```lua
local startedSessionId = nil
local connection = notice.OnClientEvent:Connect(function(message)
	if message.kind == "egg_catch_started" then
		startedSessionId = message.sessionId
	end
end)

action:FireServer("start_egg_catch_round")
task.wait(0.5)
action:FireServer("claim_egg_catch_reward", { sessionId = startedSessionId, score = 60 })
connection:Disconnect()
```

Expected:

- The reward notice reports that the round is still running.
- No reward is granted.

After a normal Egg Catch round has actually finished and one reward claim succeeds, fire the same claim again.

Expected:

- The duplicate claim is rejected.
- The second claim does not grant more coins, Duck Feed, or Treat.

After a normal Egg Catch round has finished, try submitting an impossible high score for the active session before making the real claim.

Expected:

- The reward notice reports `Score rejected`.
- Coins, Duck Feed, and Treat do not change.
- A normal claim with the actual round score can still be made afterward if the reward was not already claimed.

## Farm Visit Permission Checks

Run:

```lua
action:FireServer("visit_farm", "not_a_user_id")
task.wait(0.2)
action:FireServer("visit_farm", { userId = "not_a_user_id" })
task.wait(0.2)
action:FireServer("visit_farm", { userId = -1 })
task.wait(0.2)
action:FireServer("visit_farm", { userId = math.huge })
task.wait(0.2)
action:FireServer("visit_farm", { userId = 0 / 0 })
task.wait(0.2)
action:FireServer("visit_farm", { userId = 999999999999 })
```

Expected:

- No server errors.
- The player does not enter a farm visit view for invalid, offline, or unloaded targets.

In a two-player Studio test, enter another player's farm through the normal `Visit` UI, then run:

```lua
action:FireServer("toggle_visitor_help")
task.wait(0.2)
action:FireServer("collect_eggs")
task.wait(0.2)
action:FireServer("sell_eggs")
task.wait(0.2)
action:FireServer("buy_duck")
task.wait(0.2)
action:FireServer("buy_egg_value_upgrade")
task.wait(0.2)
action:FireServer("buy_shop_item", { itemId = "duck_feed" })
task.wait(0.2)
action:FireServer("care_for_ducks", { duckIndex = 1 })
task.wait(0.2)
action:FireServer("use_treat_on_duck", { duckIndex = 1 })
task.wait(0.2)
action:FireServer("rename_duck", { duckIndex = 1, name = "VisitorEdit" })
task.wait(0.2)
action:FireServer("visitor_help_duck", { duckIndex = 1 })
```

Expected:

- The visitor remains unable to affect the owner's farm through normal owner actions.
- The owner's eggs, coins, inventory, duck names, duck XP, quests, and upgrades do not change from visitor actions.
- The visitor's own persistent farm state does not receive rewards from actions attempted while visiting.
- `toggle_visitor_help` does not enable visitor help while the caller is visiting someone else.
- `visitor_help_duck` does not affect the owner while owner visitor help is off or while there is no eligible active requested duck.
- `return_home_farm` still works.

For Farm Visit V1, have the owner turn `Visitor Help` on from their own farm, force or wait for a `Pet me?`, `Sleepy?`, or `Dirty?` request, then have the visitor run:

```lua
action:FireServer("visitor_help_duck", {})
task.wait(0.2)
action:FireServer("visitor_help_duck", { duckIndex = "1" })
task.wait(0.2)
action:FireServer("visitor_help_duck", { duckIndex = 999 })
task.wait(0.2)
action:FireServer("visitor_help_duck", { duckIndex = 1 })
```

Expected:

- Malformed and out-of-range visitor help payloads produce no server errors and no owner state changes.
- The valid visitor help request can clear only the active `Pet me?`, `Sleepy?`, or `Dirty?` request when owner help is on.
- Visitor help does not clear `Hungry?` requests, consume owner Duck Feed or Premium Feed, grant owner duck XP, progress quests, grant rewards, change coins, change inventory, rename ducks, or mark save data dirty.
- Repeating `visitor_help_duck` after the request is cleared does not create extra effects.

## Daily Check-in Abuse

After the server auto-claim on join (or after waiting for the `Daily +N coins` toast), record current coins and fire repeat claims for the same UTC day:

```lua
action:FireServer("claim_daily_check_in")
task.wait(0.2)
action:FireServer("claim_daily_check_in")
task.wait(0.2)
action:FireServer("claim_daily_check_in")
```

Expected:

- No server errors.
- Coins do not increase beyond the single Daily reward.
- `lastDailyClaimDay` does not change to a later day until the real UTC day rolls over.
- The repeat-claim path produces a `daily_check_in_rejected` notice on the client.

## Studio Tester Guards

In a published/non-Studio environment, tester actions must not grant rewards or reset state. If this cannot be checked outside Studio during the current pass, keep it recorded as unverified.

Studio-only actions:

- `test_add_coins`
- `test_ready_eggs`
- `test_add_duck`
- `test_care_request`
- `test_hungry_request`
- `test_sleepy_request`
- `test_dirty_request`
- `test_thirsty_request`
- `test_bored_request`
- `test_toggle_weather`
- `test_reset`

Expected:

- In Studio, they work only as tester helpers.
- Outside Studio, the server guard prevents state changes from those action names.

## Pass Criteria

The remote security pass is complete when:

- All malformed payload checks produce no server errors.
- Invalid requests do not change server-owned economy, inventory (Duck Feed, Premium Feed, Treat, Pillow, Toy), duck, quest, save, weather, farm visit, or daily check-in state.
- Repeated Egg Catch reward claims cannot pay out twice.
- Repeated Daily Check-in claims within the same UTC day cannot pay out twice.
- Farm Visit remains read-only for normal owner actions from both UI and direct remote attempts.
- Farm Visit V1 visitor help only works for opted-in owners and eligible non-inventory requests, and it never changes owner economy, inventory, XP, quests, names, rewards, or save data.
- Any unverified Studio-only or multiplayer-only checks are added back to [Tasks](TASKS.md).
