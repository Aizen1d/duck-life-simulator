--!strict

local RemoteProtocol = {
	folderName = "DuckRemotes",
	actionEventName = "DuckAction",
	stateEventName = "DuckState",
	noticeEventName = "DuckNotice",

	actions = {
		requestState = "request_state",
		collectEggs = "collect_eggs",
		sellEggs = "sell_eggs",
		buyEggValueUpgrade = "buy_egg_value_upgrade",
		buyDuck = "buy_duck",
		buyShopItem = "buy_shop_item",
		careForDucks = "care_for_ducks",
		useTreatOnDuck = "use_treat_on_duck",
		renameDuck = "rename_duck",
		visitFarm = "visit_farm",
		returnHomeFarm = "return_home_farm",
		toggleVisitorHelp = "toggle_visitor_help",
		visitorHelpDuck = "visitor_help_duck",
		startEggCatchRound = "start_egg_catch_round",
		claimEggCatchReward = "claim_egg_catch_reward",
		testAddCoins = "test_add_coins",
		testReadyEggs = "test_ready_eggs",
		testAddDuck = "test_add_duck",
		testCareRequest = "test_care_request",
		testHungryRequest = "test_hungry_request",
		testSleepyRequest = "test_sleepy_request",
		testDirtyRequest = "test_dirty_request",
		testThirstyRequest = "test_thirsty_request",
		testBoredRequest = "test_bored_request",
		testToggleWeather = "test_toggle_weather",
		testReset = "test_reset",
		claimDailyCheckIn = "claim_daily_check_in",
	},

	notices = {
		eggCatchStarted = "egg_catch_started",
		eggCatchReward = "egg_catch_reward",
		dailyCheckInClaimed = "daily_check_in_claimed",
		dailyCheckInRejected = "daily_check_in_rejected",
	},
}

return RemoteProtocol
