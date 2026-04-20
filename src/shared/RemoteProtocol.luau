--!strict

local RemoteProtocol = {
	folderName = "DuckRemotes",
	actionEventName = "DuckAction",
	stateEventName = "DuckState",

	actions = {
		requestState = "request_state",
		collectEggs = "collect_eggs",
		sellEggs = "sell_eggs",
		buyEggValueUpgrade = "buy_egg_value_upgrade",
		buyDuck = "buy_duck",
		buyShopItem = "buy_shop_item",
		careForDucks = "care_for_ducks",
		renameDuck = "rename_duck",
		testAddCoins = "test_add_coins",
		testReadyEggs = "test_ready_eggs",
		testAddDuck = "test_add_duck",
		testCareRequest = "test_care_request",
		testHungryRequest = "test_hungry_request",
		testReset = "test_reset",
	},
}

return RemoteProtocol
