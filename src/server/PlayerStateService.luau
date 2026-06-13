--!strict

local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PrototypeConfig = require(Shared:WaitForChild("PrototypeConfig"))
local RemoteProtocol = require(Shared:WaitForChild("RemoteProtocol"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local AnalyticsService = require(script.Parent:WaitForChild("AnalyticsService"))

type DuckState = {
	id: number,
	name: string,
	level: number,
	xp: number,
	careUntil: number,
	lastCareAt: number,
	hasCareRequest: boolean,
	careRequestKind: string,
	family: string,
	rarity: string,
}

type QuestState = {
	level: number,
	progress: number,
}

type DailyQuestsState = {
	dayStamp: number,
	progress: {number},
	bonusGranted: boolean,
}

type EggCatchSession = {
	sessionId: number,
	startedAt: number,
	claimed: boolean,
}

type PlayerState = {
	eggs: number,
	coins: number,
	availableEggs: number,
	inventory: {[string]: number},
	ducks: {DuckState},
	nextDuckId: number,
	quests: {[string]: QuestState},
	eggSellValue: number,
	eggValueLevel: number,
	nextCareRequestAt: number,
	nextEggAt: number,
	eggProductionCarry: number,
	eggCatchSession: EggCatchSession?,
	nextEggCatchSessionId: number,
	weatherId: string,
	nextWeatherAt: number,
	lastActionAt: {[string]: number},
	renameError: string,
	renameErrorDuckIndex: number,
	isLoaded: boolean,
	saveDirty: boolean,
	saveInProgress: boolean,
	saveRevision: number,
	lastSaveAttemptAt: number,
	nextAutosaveAt: number,
	saveStatus: string,
	saveStatusText: string,
	isFreshProfile: boolean,
	freshProfileNeedsHungryFollowUp: boolean,
	freshProfileHungryHandled: boolean,
	pendingForcedCareRequestKind: string,
	visitorHelpEnabled: boolean,
	lastDailyClaimDay: number,
	streakDay: number,
	pendingOfflineEggs: number,
	pendingOfflineSeconds: number,
	dailyQuests: DailyQuestsState,
	pendingNotices: {{[string]: any}},
	pendingComebackGift: boolean,
	clientReady: boolean,
	unlockLadder: boolean,
	collectionRewardsClaimed: {string},
	starterChoiceCompleted: boolean,
	mysteryDuckBoxes: number,
	pendingDuckBoxCandidates: {{family: string, rarity: string, displayName: string}}?,
	pendingAnalytics: {{[string]: any}},
	funnelMilestones: {[string]: boolean},
	eggInventory: {[string]: number},
	incubatorSlots: {{eggType: string, finishUtc: number}},
	hatchPity: {[string]: number},
}

type SaveEntry = {
	userId: number,
	playerName: string,
	state: PlayerState,
}

local PlayerStateService = {}

local ACTION_COOLDOWN_SECONDS = 0.15
local AUTOSAVE_DELAY_SECONDS = 3
local AUTOSAVE_RETRY_DELAY_SECONDS = 120
local SAVE_WAIT_TIMEOUT_SECONDS = 10
local EGG_VALUE_MAX_LEVEL = PrototypeConfig.firstUpgrade.maxLevel
local UPDATE_INTERVAL_SECONDS = 1
local TESTER_COIN_GRANT = 100
local TESTER_READY_EGG_GRANT = 10
local PET_REQUEST_KIND = PrototypeConfig.duckCare.requestKinds.pet.id
local HUNGRY_REQUEST_KIND = PrototypeConfig.duckCare.requestKinds.hungry.id
local SLEEPY_REQUEST_KIND = PrototypeConfig.duckCare.requestKinds.sleepy.id
local DIRTY_REQUEST_KIND = PrototypeConfig.duckCare.requestKinds.clean.id
local THIRSTY_REQUEST_KIND = PrototypeConfig.duckCare.requestKinds.thirsty.id
local BORED_REQUEST_KIND = PrototypeConfig.duckCare.requestKinds.bored.id
local WEATHER_SUNNY_ID = PrototypeConfig.weather.states.sunny.id
local WEATHER_CLOUDY_ID = PrototypeConfig.weather.states.cloudy.id
local WEATHER_RAINY_ID = PrototypeConfig.weather.states.rainy.id
local WEATHER_STORMY_ID = PrototypeConfig.weather.states.stormy.id
local QUEST_COLLECT_EGGS_ID = PrototypeConfig.quests.collectEggs.id
local QUEST_SELL_EGGS_ID = PrototypeConfig.quests.sellEggs.id
local QUEST_HELP_DUCKS_ID = PrototypeConfig.quests.helpDucks.id
local QUEST_USE_TREATS_ID = PrototypeConfig.quests.useTreats.id
local QUEST_BUY_DUCKS_ID = PrototypeConfig.quests.buyDucks.id
local QUEST_SPEND_COINS_ID = PrototypeConfig.quests.spendCoins.id
local QUEST_WIN_EGG_CATCH_ID = PrototypeConfig.quests.winEggCatch.id
local QUEST_LEVEL_UP_DUCKS_ID = PrototypeConfig.quests.levelUpDucks.id
local EGG_CATCH_CONFIG = PrototypeConfig.minigames.eggCatch
local SAVE_STATUS_LOADING = "loading"
local SAVE_STATUS_PENDING = "pending"
local SAVE_STATUS_SAVING = "saving"
local SAVE_STATUS_SAVED = "saved"
local SAVE_STATUS_FAILED = "failed"

local started = false
local statesByPlayer: {[Player]: PlayerState} = {}
local recentSaveEntriesByUserId: {[number]: SaveEntry} = {}
local farmViewTargetsByPlayer: {[Player]: Player} = {}
local sessionEggsCollectedByPlayer: {[Player]: number} = {}

-- Wraps BadgeService:AwardBadge in a task.spawn+pcall so badge failures never
-- interrupt gameplay. Id = 0 means the badge hasn't been created yet; skip silently.
local function tryAwardBadge(player: Player, badgeId: number)
	if badgeId == 0 then
		return
	end

	task.spawn(function()
		local ok, err = pcall(function()
			BadgeService:AwardBadge(player.UserId, badgeId)
		end)

		if not ok then
			warn(string.format("[Badges] AwardBadge failed for %s (id %d): %s", player.Name, badgeId, tostring(err)))
		end
	end)
end

local function hasDuckAtLevel(state: PlayerState, targetLevel: number): boolean
	for _, duck in state.ducks do
		if duck.level >= targetLevel then
			return true
		end
	end

	return false
end
local actionEvent: RemoteEvent
local stateEvent: RemoteEvent
local noticeEvent: RemoteEvent

local validActions: {[string]: boolean} = {}
for _, actionName in RemoteProtocol.actions do
	validActions[actionName] = true
end

local testerActions = {
	[RemoteProtocol.actions.testAddCoins] = true,
	[RemoteProtocol.actions.testReadyEggs] = true,
	[RemoteProtocol.actions.testAddDuck] = true,
	[RemoteProtocol.actions.testCareRequest] = true,
	[RemoteProtocol.actions.testHungryRequest] = true,
	[RemoteProtocol.actions.testSleepyRequest] = true,
	[RemoteProtocol.actions.testDirtyRequest] = true,
	[RemoteProtocol.actions.testThirstyRequest] = true,
	[RemoteProtocol.actions.testBoredRequest] = true,
	[RemoteProtocol.actions.testToggleWeather] = true,
	[RemoteProtocol.actions.testReset] = true,
}

local function getOrCreateRemoteFolder(): Folder
	local existingFolder = ReplicatedStorage:FindFirstChild(RemoteProtocol.folderName)

	if existingFolder and existingFolder:IsA("Folder") then
		return existingFolder
	end

	local folder = Instance.new("Folder")
	folder.Name = RemoteProtocol.folderName
	folder.Parent = ReplicatedStorage

	return folder
end

local function getOrCreateRemoteEvent(folder: Folder, eventName: string): RemoteEvent
	local existingEvent = folder:FindFirstChild(eventName)

	if existingEvent and existingEvent:IsA("RemoteEvent") then
		return existingEvent
	end

	local event = Instance.new("RemoteEvent")
	event.Name = eventName
	event.Parent = folder

	return event
end

local function getSaveStatusText(status: string): string
	if status == SAVE_STATUS_LOADING then
		return "Loading"
	elseif status == SAVE_STATUS_PENDING then
		return "Saving soon"
	elseif status == SAVE_STATUS_SAVING then
		return "Saving"
	elseif status == SAVE_STATUS_FAILED then
		return "Save delayed"
	end

	return "Saved"
end

local function setSaveStatus(state: PlayerState, status: string, customText: string?)
	state.saveStatus = status
	state.saveStatusText = customText or getSaveStatusText(status)
end

local function getStudioSaveFailureText(message: string?): string
	if not RunService:IsStudio() then
		return getSaveStatusText(SAVE_STATUS_FAILED)
	end

	if game.GameId == 0 or game.PlaceId == 0 then
		return "Publish first"
	end

	local lowerMessage = string.lower(message or "")

	if string.find(lowerMessage, "api") or string.find(lowerMessage, "studio access") then
		return "Enable API services"
	end

	if string.find(lowerMessage, "403") or string.find(lowerMessage, "unauthorized") then
		return "API blocked"
	end

	return getSaveStatusText(SAVE_STATUS_FAILED)
end

local function markSaveDirty(state: PlayerState)
	state.saveRevision += 1

	if not state.saveDirty or state.nextAutosaveAt <= 0 then
		state.nextAutosaveAt = os.clock() + AUTOSAVE_DELAY_SECONDS
	end

	state.saveDirty = true

	if state.saveStatus ~= SAVE_STATUS_LOADING and state.saveStatus ~= SAVE_STATUS_SAVING then
		setSaveStatus(state, SAVE_STATUS_PENDING)
	end
end

-- Analytics events queue on the state and flush in sendState, which holds the Player object
-- the Roblox AnalyticsService requires. This mirrors the pendingNotices deferral used by the
-- reward paths that run without a Player (daily quests, collection milestones, offline grants).
local function queueEconomyEvent(
	state: PlayerState,
	flow: string,
	amount: number,
	transactionType: string,
	category: string
)
	if amount <= 0 then
		return
	end

	-- The coin balance is already mutated by the time this is called, so it is the ending balance.
	table.insert(state.pendingAnalytics, {
		kind = "economy",
		flow = flow,
		currency = "Coins",
		amount = amount,
		endingBalance = state.coins,
		transactionType = transactionType,
		category = category,
	})
end

-- Funnel/social "first X" moments fire once per profile lifetime. The fired set persists in
-- save data so returning players never re-enter the funnel and skew conversion/social metrics.
local function markFunnelMilestone(state: PlayerState, eventName: string)
	if state.funnelMilestones[eventName] then
		return
	end

	state.funnelMilestones[eventName] = true
	table.insert(state.pendingAnalytics, { kind = "custom", event = eventName })
	markSaveDirty(state)
end

-- Grants eggs into the inventory (Phase 6 reward sources: daily bonus, comeback gift, etc.).
local function grantEgg(state: PlayerState, eggType: string, amount: number)
	if amount <= 0 then
		return
	end

	state.eggInventory[eggType] = (state.eggInventory[eggType] or 0) + amount
	markSaveDirty(state)
end

local function getDuckCount(state: PlayerState): number
	return #state.ducks
end

local function getPlayerDisplayName(player: Player): string
	if player.DisplayName ~= "" then
		return player.DisplayName
	end

	return player.Name
end

local function normalizeDuckName(name: string): string
	return string.lower(name)
end

local function trimText(text: string): string
	return text:match("^%s*(.-)%s*$") or ""
end

local function getTextLength(text: string): number
	local success, length = pcall(function()
		return utf8.len(text)
	end)

	if success and length then
		return length
	end

	return #text
end

local function isFiniteNumber(value: number): boolean
	return value == value and value > -math.huge and value < math.huge
end

local function isDuckNameUsed(state: PlayerState, name: string, ignoredDuck: DuckState?): boolean
	local normalizedName = normalizeDuckName(name)

	for _, duck in state.ducks do
		if duck ~= ignoredDuck and normalizeDuckName(duck.name) == normalizedName then
			return true
		end
	end

	return false
end

local function generateDuckName(state: PlayerState): string
	local availableNames = {}

	for _, name in PrototypeConfig.duckNames do
		if name ~= "" and not isDuckNameUsed(state, name, nil) then
			table.insert(availableNames, name)
		end
	end

	if #availableNames > 0 then
		return availableNames[math.random(1, #availableNames)]
	end

	local suffix = state.nextDuckId
	local fallbackName = "Duck " .. tostring(suffix)

	while isDuckNameUsed(state, fallbackName, nil) do
		suffix += 1
		fallbackName = "Duck " .. tostring(suffix)
	end

	return fallbackName
end

local function addDuck(state: PlayerState, family: string?, rarity: string?)
	local now = os.clock()

	table.insert(state.ducks, {
		id = state.nextDuckId,
		name = generateDuckName(state),
		level = PrototypeConfig.duckLevel.startingLevel,
		xp = PrototypeConfig.duckLevel.startingXp,
		careUntil = 0,
		lastCareAt = now - PrototypeConfig.duckCare.cooldownSeconds,
		hasCareRequest = false,
		careRequestKind = "",
		family = family or "classic_yellow",
		rarity = rarity or "common",
	})
	state.nextDuckId += 1
end

local function getEggValueUpgradeCost(state: PlayerState): number
	if state.eggValueLevel >= EGG_VALUE_MAX_LEVEL then
		return 0
	end

	local tierIndex = state.eggValueLevel + 1
	local cost = PrototypeConfig.firstUpgrade.costs[tierIndex]

	if typeof(cost) == "number" and cost > 0 then
		return cost
	end

	return PrototypeConfig.firstUpgrade.firstCost
end

local function getDuckPurchaseCost(state: PlayerState): number
	return PrototypeConfig.duckPurchase.baseCost * math.max(1, getDuckCount(state))
end

local function getDuckFeedCount(state: PlayerState): number
	return state.inventory[PrototypeConfig.shop.duckFeed.id] or 0
end

local function getPremiumFeedCount(state: PlayerState): number
	return state.inventory[PrototypeConfig.shop.premiumFeed.id] or 0
end

local function getDuckTreatCount(state: PlayerState): number
	return state.inventory[PrototypeConfig.shop.duckTreat.id] or 0
end

local function getPillowCount(state: PlayerState): number
	return state.inventory[PrototypeConfig.shop.pillow.id] or 0
end

local function getToyCount(state: PlayerState): number
	return state.inventory[PrototypeConfig.shop.toy.id] or 0
end

local function getDuckEggProductionMultiplier(duck: DuckState): number
	local levelOffset = math.max(0, duck.level - PrototypeConfig.duckLevel.startingLevel)
	local levelBonus = levelOffset * PrototypeConfig.duckLevel.eggProductionBonusPerLevel
	local rarityBonus = 0

	for _, family in PrototypeConfig.families do
		if family.id == duck.family then
			rarityBonus = family.eggBonus
			break
		end
	end

	return 1 + levelBonus + rarityBonus
end

local function getEggProductionPerCycle(state: PlayerState): number
	local productionPerCycle = 0

	for _, duck in state.ducks do
		productionPerCycle += getDuckEggProductionMultiplier(duck)
	end

	return productionPerCycle
end

local function getQuestDefinitions(): {{[string]: any}}
	return {
		PrototypeConfig.quests.collectEggs,
		PrototypeConfig.quests.sellEggs,
		PrototypeConfig.quests.helpDucks,
		PrototypeConfig.quests.useTreats,
		PrototypeConfig.quests.buyDucks,
		PrototypeConfig.quests.spendCoins,
		PrototypeConfig.quests.winEggCatch,
		PrototypeConfig.quests.levelUpDucks,
	}
end

local function getQuestDefinition(questId: string): {[string]: any}?
	for _, questDefinition in getQuestDefinitions() do
		if questDefinition.id == questId then
			return questDefinition
		end
	end

	return nil
end

local function getQuestTarget(questDefinition: {[string]: any}, level: number): number
	return math.max(1, questDefinition.baseTarget * level)
end

local function getQuestRewardCoins(questDefinition: {[string]: any}, level: number): number
	return math.max(1, questDefinition.baseRewardCoins * level)
end

local function getQuestRewardDuckFeed(questDefinition: {[string]: any}, completedLevel: number): number
	local everyLevels = questDefinition.rewardDuckFeedEveryLevels
	local amount = questDefinition.rewardDuckFeedAmount

	if typeof(everyLevels) ~= "number" or typeof(amount) ~= "number" or everyLevels <= 0 or amount <= 0 then
		return 0
	end

	if completedLevel % everyLevels ~= 0 then
		return 0
	end

	return amount
end

local function getQuestRewardDuckTreat(questDefinition: {[string]: any}, completedLevel: number): number
	local everyLevels = questDefinition.rewardDuckTreatEveryLevels
	local amount = questDefinition.rewardDuckTreatAmount

	if typeof(everyLevels) ~= "number" or typeof(amount) ~= "number" or everyLevels <= 0 or amount <= 0 then
		return 0
	end

	if completedLevel % everyLevels ~= 0 then
		return 0
	end

	return amount
end

local function getQuestRewardPillow(questDefinition: {[string]: any}, completedLevel: number): number
	local everyLevels = questDefinition.rewardPillowEveryLevels
	local amount = questDefinition.rewardPillowAmount

	if typeof(everyLevels) ~= "number" or typeof(amount) ~= "number" or everyLevels <= 0 or amount <= 0 then
		return 0
	end

	if completedLevel % everyLevels ~= 0 then
		return 0
	end

	return amount
end

local function createQuestStates(): {[string]: QuestState}
	local quests = {}

	for _, questDefinition in getQuestDefinitions() do
		quests[questDefinition.id] = {
			level = 1,
			progress = 0,
		}
	end

	return quests
end

local function getQuestState(state: PlayerState, questId: string): QuestState?
	local quest = state.quests[questId]

	if quest then
		return quest
	end

	local questDefinition = getQuestDefinition(questId)

	if not questDefinition then
		return nil
	end

	quest = {
		level = 1,
		progress = 0,
	}
	state.quests[questId] = quest

	return quest
end

local function grantQuestProgress(state: PlayerState, questId: string, amount: number)
	local questDefinition = getQuestDefinition(questId)
	local quest = getQuestState(state, questId)

	if not questDefinition or not quest or amount <= 0 then
		return
	end

	quest.progress += amount

	local completionCount = 0

	while quest.progress >= getQuestTarget(questDefinition, quest.level) and completionCount < 100 do
		local completedLevel = quest.level
		local target = getQuestTarget(questDefinition, quest.level)
		local rewardCoins = getQuestRewardCoins(questDefinition, quest.level)
		local rewardDuckFeed = getQuestRewardDuckFeed(questDefinition, completedLevel)
		local rewardDuckTreat = getQuestRewardDuckTreat(questDefinition, completedLevel)
		local rewardPillow = getQuestRewardPillow(questDefinition, completedLevel)

		quest.progress -= target
		state.coins += rewardCoins
		queueEconomyEvent(state, "source", rewardCoins, "Gameplay", "quest_reward")
		if rewardDuckFeed > 0 then
			state.inventory[PrototypeConfig.shop.duckFeed.id] = (state.inventory[PrototypeConfig.shop.duckFeed.id] or 0) + rewardDuckFeed
		end
		if rewardDuckTreat > 0 then
			state.inventory[PrototypeConfig.shop.duckTreat.id] = (state.inventory[PrototypeConfig.shop.duckTreat.id] or 0) + rewardDuckTreat
		end
		if rewardPillow > 0 then
			state.inventory[PrototypeConfig.shop.pillow.id] = (state.inventory[PrototypeConfig.shop.pillow.id] or 0) + rewardPillow
		end
		quest.level += 1
		completionCount += 1
	end
end

-- Daily quest handlers run inside action paths that do not receive the Player, so completion
-- notices queue on the state and flush with the next sendState call for that player.
local function queueNotice(state: PlayerState, payload: {[string]: any})
	table.insert(state.pendingNotices, payload)
end

-- The same three daily quests roll for every player each UTC day, derived from the day number,
-- so the selection needs no save fields and resets itself on rollover.
local function getDailyQuestDefinition(slotIndex: number, dayStamp: number): {[string]: any}
	local dailyConfig = PrototypeConfig.dailyQuests
	local poolIndex = (dayStamp + dailyConfig.slotOffsets[slotIndex]) % #dailyConfig.pool + 1

	return dailyConfig.pool[poolIndex]
end

local function ensureDailyQuestsCurrent(state: PlayerState)
	local currentDay = math.floor(os.time() / 86400)

	if state.dailyQuests.dayStamp ~= currentDay then
		state.dailyQuests = {
			dayStamp = currentDay,
			progress = { 0, 0, 0 },
			bonusGranted = false,
		}
		markSaveDirty(state)
	end
end

local function grantDailyQuestProgress(state: PlayerState, actionKind: string, amount: number)
	if amount <= 0 then
		return
	end

	ensureDailyQuestsCurrent(state)

	local dailyConfig = PrototypeConfig.dailyQuests
	local daily = state.dailyQuests
	local completedCount = 0

	for slotIndex = 1, dailyConfig.questCount do
		local definition = getDailyQuestDefinition(slotIndex, daily.dayStamp)
		local progress = daily.progress[slotIndex]

		if definition.action == actionKind and progress < definition.target then
			progress = math.min(definition.target, progress + amount)
			daily.progress[slotIndex] = progress

			if progress >= definition.target then
				state.coins += definition.rewardCoins
				queueEconomyEvent(state, "source", definition.rewardCoins, "Gameplay", "daily_quest_reward")

				if definition.rewardDuckFeedAmount > 0 then
					local duckFeedId = PrototypeConfig.shop.duckFeed.id
					state.inventory[duckFeedId] = (state.inventory[duckFeedId] or 0) + definition.rewardDuckFeedAmount
				end

				if definition.rewardDuckTreatAmount > 0 then
					local duckTreatId = PrototypeConfig.shop.duckTreat.id
					state.inventory[duckTreatId] = (state.inventory[duckTreatId] or 0) + definition.rewardDuckTreatAmount
				end

				queueNotice(state, {
					kind = RemoteProtocol.notices.dailyQuestCompleted,
					displayName = definition.displayName,
					rewardCoins = definition.rewardCoins,
					rewardDuckFeed = definition.rewardDuckFeedAmount,
					rewardDuckTreat = definition.rewardDuckTreatAmount,
				})
			end

			markSaveDirty(state)
		end

		if daily.progress[slotIndex] >= definition.target then
			completedCount += 1
		end
	end

	if completedCount >= dailyConfig.questCount and not daily.bonusGranted then
		daily.bonusGranted = true
		state.coins += dailyConfig.allCompleteBonusCoins
		queueEconomyEvent(state, "source", dailyConfig.allCompleteBonusCoins, "Gameplay", "daily_quest_bonus")
		grantEgg(state, dailyConfig.allCompleteBonusEggType, dailyConfig.allCompleteBonusEggAmount)
		queueNotice(state, {
			kind = RemoteProtocol.notices.dailyQuestBonus,
			bonusCoins = dailyConfig.allCompleteBonusCoins,
			bonusEggType = dailyConfig.allCompleteBonusEggType,
			bonusEggAmount = dailyConfig.allCompleteBonusEggAmount,
		})
		markSaveDirty(state)
	end
end

local function hasQuestActivity(state: PlayerState, questId: string): boolean
	local quest = state.quests[questId]

	return quest ~= nil and (quest.level > 1 or quest.progress > 0)
end

-- Feature Unlock Ladder V0 (comprehension guardrail): fresh profiles reveal systems as their
-- progress earns them, derived entirely from server-owned state that only ever increases, so
-- nothing can re-lock. Profiles saved before the ladder shipped load with unlockLadder = false
-- and keep every feature they already had.
local function getFeatureUnlocks(state: PlayerState): {[string]: boolean}
	if not state.unlockLadder then
		return {
			upgrades = true,
			quests = true,
			shop = true,
			minigames = true,
			visit = true,
		}
	end

	local hasSold = hasQuestActivity(state, QUEST_SELL_EGGS_ID)
	local hasSecondDuck = getDuckCount(state) >= 2
	local hasHelped = hasQuestActivity(state, QUEST_HELP_DUCKS_ID)

	return {
		upgrades = hasSold,
		quests = hasSold,
		shop = hasSecondDuck,
		minigames = hasHelped,
		visit = hasHelped,
	}
end

local function getVisibleCareDuckCount(state: PlayerState): number
	return math.min(getDuckCount(state), PrototypeConfig.duckCare.requestVisibleDuckCap)
end

local function scheduleNextCareRequest(state: PlayerState, now: number)
	state.nextCareRequestAt = now + PrototypeConfig.duckCare.requestIntervalSeconds
end

local function getWeatherDefinition(weatherId: string)
	if weatherId == WEATHER_RAINY_ID then
		return PrototypeConfig.weather.states.rainy
	elseif weatherId == WEATHER_CLOUDY_ID then
		return PrototypeConfig.weather.states.cloudy
	elseif weatherId == WEATHER_STORMY_ID then
		return PrototypeConfig.weather.states.stormy
	end

	return PrototypeConfig.weather.states.sunny
end

local function scheduleNextWeather(state: PlayerState, now: number)
	state.nextWeatherAt = now + PrototypeConfig.weather.cycleIntervalSeconds
end

local function chooseWeatherId(): string
	local roll = math.random()
	local stormyChance = PrototypeConfig.weather.stormyChance
	local rainyChance = PrototypeConfig.weather.rainyChance
	local cloudyChance = PrototypeConfig.weather.cloudyChance

	if roll <= stormyChance then
		return WEATHER_STORMY_ID
	elseif roll <= stormyChance + rainyChance then
		return WEATHER_RAINY_ID
	elseif roll <= stormyChance + rainyChance + cloudyChance then
		return WEATHER_CLOUDY_ID
	end

	return WEATHER_SUNNY_ID
end

local function updateWeather(state: PlayerState)
	local now = os.clock()

	if now < state.nextWeatherAt then
		return
	end

	state.weatherId = chooseWeatherId()
	scheduleNextWeather(state, now)
end

local function toggleWeather(state: PlayerState)
	local now = os.clock()

	if state.weatherId == WEATHER_SUNNY_ID then
		state.weatherId = WEATHER_CLOUDY_ID
	elseif state.weatherId == WEATHER_CLOUDY_ID then
		state.weatherId = WEATHER_RAINY_ID
	elseif state.weatherId == WEATHER_RAINY_ID then
		state.weatherId = WEATHER_STORMY_ID
	else
		state.weatherId = WEATHER_SUNNY_ID
	end

	scheduleNextWeather(state, now)
end

local function clearCareRequests(state: PlayerState)
	for _, duck in state.ducks do
		duck.hasCareRequest = false
		duck.careRequestKind = ""
	end
end

local function getCareRequestKind(state: PlayerState): string
	local visibleDuckCount = getVisibleCareDuckCount(state)

	for index = 1, visibleDuckCount do
		local duck = state.ducks[index]

		if duck.hasCareRequest then
			return if duck.careRequestKind ~= "" then duck.careRequestKind else PET_REQUEST_KIND
		end
	end

	return ""
end

local function getCareRequestDefinition(requestKind: string)
	if requestKind == HUNGRY_REQUEST_KIND then
		return PrototypeConfig.duckCare.requestKinds.hungry
	elseif requestKind == SLEEPY_REQUEST_KIND then
		return PrototypeConfig.duckCare.requestKinds.sleepy
	elseif requestKind == DIRTY_REQUEST_KIND then
		return PrototypeConfig.duckCare.requestKinds.clean
	elseif requestKind == THIRSTY_REQUEST_KIND then
		return PrototypeConfig.duckCare.requestKinds.thirsty
	elseif requestKind == BORED_REQUEST_KIND then
		return PrototypeConfig.duckCare.requestKinds.bored
	end

	return PrototypeConfig.duckCare.requestKinds.pet
end

local function chooseCareRequestKind(state: PlayerState): string
	local roll = math.random()
	local weatherDefinition = getWeatherDefinition(state.weatherId)
	local hungryChance = PrototypeConfig.duckCare.hungryRequestChance
	local sleepyChance = math.clamp(
		PrototypeConfig.duckCare.sleepyRequestChance + weatherDefinition.sleepyRequestChanceBonus,
		0,
		math.max(0, 1 - hungryChance)
	)
	local dirtyChance = math.clamp(
		PrototypeConfig.duckCare.dirtyRequestChance + weatherDefinition.dirtyRequestChanceBonus,
		0,
		math.max(0, 1 - hungryChance - sleepyChance)
	)
	local thirstyChance = math.clamp(
		PrototypeConfig.duckCare.thirstyRequestChance,
		0,
		math.max(0, 1 - hungryChance - sleepyChance - dirtyChance)
	)
	local boredChance = math.clamp(
		PrototypeConfig.duckCare.boredRequestChance,
		0,
		math.max(0, 1 - hungryChance - sleepyChance - dirtyChance - thirstyChance)
	)

	if roll <= hungryChance then
		return HUNGRY_REQUEST_KIND
	elseif roll <= hungryChance + sleepyChance then
		return SLEEPY_REQUEST_KIND
	elseif roll <= hungryChance + sleepyChance + dirtyChance then
		return DIRTY_REQUEST_KIND
	elseif roll <= hungryChance + sleepyChance + dirtyChance + thirstyChance then
		return THIRSTY_REQUEST_KIND
	elseif roll <= hungryChance + sleepyChance + dirtyChance + thirstyChance + boredChance then
		return BORED_REQUEST_KIND
	end

	return PET_REQUEST_KIND
end

local function getCareRequestDuckIndex(state: PlayerState): number
	local visibleDuckCount = getVisibleCareDuckCount(state)

	for index = 1, visibleDuckCount do
		if state.ducks[index].hasCareRequest then
			return index
		end
	end

	return 0
end

local function getDuckByPayloadIndex(state: PlayerState, payload: any): (DuckState?, number)
	local duckIndex = nil

	if typeof(payload) == "number" then
		duckIndex = payload
	elseif typeof(payload) == "table" then
		local payloadTable = payload :: {[string]: any}

		if typeof(payloadTable.duckIndex) == "number" then
			duckIndex = payloadTable.duckIndex
		end
	end

	if
		not duckIndex
		or not isFiniteNumber(duckIndex)
		or duckIndex % 1 ~= 0
		or duckIndex < 1
		or duckIndex > getDuckCount(state)
	then
		return nil, 0
	end

	return state.ducks[duckIndex], duckIndex
end

local function canDuckCare(duck: DuckState, now: number): boolean
	return now - duck.lastCareAt >= PrototypeConfig.duckCare.cooldownSeconds
end

local function getDuckXpToNextLevel(duck: DuckState): number
	if duck.level >= PrototypeConfig.duckLevel.maxLevel then
		return 0
	end

	return PrototypeConfig.duckLevel.xpPerLevel
end

local function addDuckXp(duck: DuckState, amount: number): number
	local levelConfig = PrototypeConfig.duckLevel

	if amount <= 0 then
		return 0
	end

	if duck.level >= levelConfig.maxLevel then
		duck.level = levelConfig.maxLevel
		duck.xp = 0
		return 0
	end

	local startingLevel = duck.level
	duck.xp += amount

	while duck.xp >= levelConfig.xpPerLevel and duck.level < levelConfig.maxLevel do
		duck.xp -= levelConfig.xpPerLevel
		duck.level += 1
	end

	if duck.level >= levelConfig.maxLevel then
		duck.level = levelConfig.maxLevel
		duck.xp = 0
	end

	return duck.level - startingLevel
end

local function assignCareRequest(state: PlayerState, now: number, forcedKind: string?)
	local visibleDuckCount = getVisibleCareDuckCount(state)
	local candidates = {}

	clearCareRequests(state)

	for index = 1, visibleDuckCount do
		local duck = state.ducks[index]

		if canDuckCare(duck, now) then
			table.insert(candidates, index)
		end
	end

	if #candidates <= 0 then
		scheduleNextCareRequest(state, now)
		return
	end

	local requestDuckIndex = candidates[math.random(1, #candidates)]
	local requestKind = forcedKind

	if not requestKind or requestKind == "" then
		requestKind = if state.pendingForcedCareRequestKind ~= "" then state.pendingForcedCareRequestKind else chooseCareRequestKind(state)
	end

	state.ducks[requestDuckIndex].hasCareRequest = true
	state.ducks[requestDuckIndex].careRequestKind = requestKind
	state.pendingForcedCareRequestKind = ""
	scheduleNextCareRequest(state, now)
end

local function createPlayerState(): PlayerState
	local now = os.clock()
	local duckFeedId = PrototypeConfig.shop.duckFeed.id
	local premiumFeedId = PrototypeConfig.shop.premiumFeed.id
	local state: PlayerState = {
		eggs = PrototypeConfig.startingEggs,
		coins = PrototypeConfig.startingCoins,
		availableEggs = 0,
		inventory = {
			[duckFeedId] = PrototypeConfig.startingDuckFeed,
			[premiumFeedId] = PrototypeConfig.startingPremiumFeed,
		},
		ducks = {},
		nextDuckId = 1,
		quests = createQuestStates(),
		eggSellValue = PrototypeConfig.eggSellValue,
		eggValueLevel = PrototypeConfig.firstUpgrade.startingLevel,
		nextCareRequestAt = now + PrototypeConfig.duckCare.firstRequestDelaySeconds,
		nextEggAt = now + PrototypeConfig.eggProductionIntervalSeconds,
		eggProductionCarry = 0,
		eggCatchSession = nil,
		nextEggCatchSessionId = 1,
		weatherId = PrototypeConfig.weather.defaultId,
		nextWeatherAt = now + PrototypeConfig.weather.cycleIntervalSeconds,
		lastActionAt = {},
		renameError = "",
		renameErrorDuckIndex = 0,
		isLoaded = false,
		saveDirty = false,
		saveInProgress = false,
		saveRevision = 0,
		lastSaveAttemptAt = now,
		nextAutosaveAt = 0,
		saveStatus = SAVE_STATUS_LOADING,
		saveStatusText = getSaveStatusText(SAVE_STATUS_LOADING),
		isFreshProfile = false,
		freshProfileNeedsHungryFollowUp = false,
		freshProfileHungryHandled = false,
		pendingForcedCareRequestKind = "",
		visitorHelpEnabled = false,
		lastDailyClaimDay = 0,
		streakDay = 0,
		pendingOfflineEggs = 0,
		pendingOfflineSeconds = 0,
		dailyQuests = {
			dayStamp = 0,
			progress = { 0, 0, 0 },
			bonusGranted = false,
		},
		pendingNotices = {},
		pendingComebackGift = false,
		clientReady = false,
		unlockLadder = true,
		collectionRewardsClaimed = {},
		starterChoiceCompleted = false,
		mysteryDuckBoxes = 0,
		pendingDuckBoxCandidates = nil,
		pendingAnalytics = {},
		funnelMilestones = {},
		eggInventory = {},
		incubatorSlots = {},
		hatchPity = {},
	}

	for _ = 1, PrototypeConfig.startingDucks do
		addDuck(state)
	end

	return state
end

local function createDuckFromSavedData(savedDuck: {[string]: any}, now: number): DuckState
	return {
		id = savedDuck.id,
		name = savedDuck.name,
		level = savedDuck.level,
		xp = savedDuck.xp,
		careUntil = 0,
		lastCareAt = now - PrototypeConfig.duckCare.cooldownSeconds,
		hasCareRequest = false,
		careRequestKind = "",
		family = if typeof(savedDuck.family) == "string" and savedDuck.family ~= "" then savedDuck.family else "classic_yellow",
		rarity = if typeof(savedDuck.rarity) == "string" and savedDuck.rarity ~= "" then savedDuck.rarity else "common",
	}
end

-- Offline accrual is server-derived only: the saved last-seen timestamp is written from os.time()
-- on save and clamped to now on load, so the client can never report or inflate away-time.
local function computeOfflineProduction(state: PlayerState, lastSeenUtc: number): (number, number)
	local offlineConfig = PrototypeConfig.offlineProgress

	-- Saves from before schema 7 load with lastSeenUtc = 0 and grant nothing on their first rejoin.
	if lastSeenUtc <= 0 then
		return 0, 0
	end

	local elapsedSeconds = math.clamp(os.time() - lastSeenUtc, 0, offlineConfig.capSeconds)

	if elapsedSeconds <= 0 then
		return 0, 0
	end

	local cycles = elapsedSeconds / PrototypeConfig.eggProductionIntervalSeconds
	local producedEggs = math.floor(cycles * getEggProductionPerCycle(state) * offlineConfig.rate)

	return producedEggs, elapsedSeconds
end

local function applySavedData(state: PlayerState, savedData: {[string]: any})
	local now = os.clock()
	local duckFeed = PrototypeConfig.shop.duckFeed
	local premiumFeed = PrototypeConfig.shop.premiumFeed
	local duckTreat = PrototypeConfig.shop.duckTreat
	local pillow = PrototypeConfig.shop.pillow
	local toy = PrototypeConfig.shop.toy
	local highestDuckId = 0

	state.eggs = savedData.eggs
	state.coins = savedData.coins
	state.availableEggs = savedData.availableEggs
	state.inventory = {
		[duckFeed.id] = savedData.duckFeed,
		[premiumFeed.id] = savedData.premiumFeed,
		[duckTreat.id] = savedData.duckTreat,
		[pillow.id] = savedData.pillow,
		[toy.id] = savedData.toy,
	}
	state.lastDailyClaimDay = savedData.lastDailyClaimDay or 0
	state.streakDay = savedData.streakDay or 0
	state.dailyQuests = savedData.dailyQuests or {
		dayStamp = 0,
		progress = { 0, 0, 0 },
		bonusGranted = false,
	}
	state.unlockLadder = savedData.unlockLadder == true
	state.collectionRewardsClaimed = if typeof(savedData.collectionRewardsClaimed) == "table" then savedData.collectionRewardsClaimed else {}
	state.starterChoiceCompleted = savedData.starterChoiceCompleted == true
	state.mysteryDuckBoxes = math.max(0, math.floor(typeof(savedData.mysteryDuckBoxes) == "number" and savedData.mysteryDuckBoxes or 0))
	state.pendingDuckBoxCandidates = nil
	state.funnelMilestones = if typeof(savedData.funnelMilestones) == "table" then savedData.funnelMilestones else {}
	state.pendingAnalytics = {}

	-- Phase 6 (Hatching): egg inventory, incubator slots, and pity counters. All counts are
	-- clamped to non-negative integers; incubator slots keep only known egg types with a finite
	-- finishUtc and are capped at the configured slot count. A finishUtc already in the past is
	-- legitimate (the egg finished while the player was away) — it becomes collectable on load.
	local savedEggInventory = if typeof(savedData.eggInventory) == "table" then savedData.eggInventory else {}
	state.eggInventory = {}
	for _, eggDef in PrototypeConfig.eggTypes do
		local count = savedEggInventory[eggDef.id]
		state.eggInventory[eggDef.id] = if typeof(count) == "number" and count == count and count ~= math.huge
			then math.max(0, math.floor(count))
			else 0
	end

	state.hatchPity = {}
	local savedHatchPity = if typeof(savedData.hatchPity) == "table" then savedData.hatchPity else {}
	for _, eggDef in PrototypeConfig.eggTypes do
		if eggDef.pityThreshold ~= nil then
			local pity = savedHatchPity[eggDef.id]
			state.hatchPity[eggDef.id] = if typeof(pity) == "number" and pity == pity and pity ~= math.huge
				then math.clamp(math.floor(pity), 0, eggDef.pityThreshold)
				else 0
		end
	end

	state.incubatorSlots = {}
	local savedSlots = if typeof(savedData.incubatorSlots) == "table" then savedData.incubatorSlots else {}
	for _, slot in savedSlots do
		if #state.incubatorSlots >= PrototypeConfig.incubator.slotCount then
			break
		end

		if typeof(slot) == "table" and typeof(slot.eggType) == "string" and typeof(slot.finishUtc) == "number" and slot.finishUtc == slot.finishUtc then
			local knownEgg = false
			for _, eggDef in PrototypeConfig.eggTypes do
				if eggDef.id == slot.eggType then
					knownEgg = true
					break
				end
			end

			if knownEgg then
				table.insert(state.incubatorSlots, { eggType = slot.eggType, finishUtc = math.floor(slot.finishUtc) })
			end
		end
	end
	state.eggValueLevel = math.clamp(savedData.eggValueLevel, 0, EGG_VALUE_MAX_LEVEL)
	state.eggSellValue = PrototypeConfig.eggSellValue + state.eggValueLevel * PrototypeConfig.firstUpgrade.valueIncrease
	state.ducks = {}

	for _, savedDuck in savedData.ducks do
		local duck = createDuckFromSavedData(savedDuck, now)
		highestDuckId = math.max(highestDuckId, duck.id)
		table.insert(state.ducks, duck)
	end

	state.nextDuckId = math.max(savedData.nextDuckId, highestDuckId + 1)
	state.quests = savedData.quests or createQuestStates()

	if getDuckCount(state) <= 0 then
		addDuck(state)
	end

	local offlineEggs, offlineSeconds = computeOfflineProduction(state, savedData.lastSeenUtc or 0)

	state.pendingOfflineEggs = offlineEggs
	state.pendingOfflineSeconds = offlineSeconds
	state.availableEggs += offlineEggs

	-- Comeback Gift V0: long absences are welcomed, never punished, per the cozy promise.
	-- The away time uses the same server-derived timestamp as offline progress, but uncapped.
	local comebackConfig = PrototypeConfig.comebackGift
	local lastSeenUtc = savedData.lastSeenUtc or 0

	if lastSeenUtc > 0 and os.time() - lastSeenUtc >= comebackConfig.awayDaysThreshold * 86400 then
		local duckFeedId = PrototypeConfig.shop.duckFeed.id
		local duckTreatId = PrototypeConfig.shop.duckTreat.id

		state.inventory[duckFeedId] = (state.inventory[duckFeedId] or 0) + comebackConfig.duckFeedAmount
		state.inventory[duckTreatId] = (state.inventory[duckTreatId] or 0) + comebackConfig.duckTreatAmount
		grantEgg(state, comebackConfig.eggType, comebackConfig.eggAmount)
		state.pendingComebackGift = true
		queueNotice(state, {
			kind = RemoteProtocol.notices.comebackGift,
			duckFeed = comebackConfig.duckFeedAmount,
			duckTreat = comebackConfig.duckTreatAmount,
			eggType = comebackConfig.eggType,
			eggAmount = comebackConfig.eggAmount,
		})
	end

	state.nextCareRequestAt = now + PrototypeConfig.duckCare.firstRequestDelaySeconds
	state.nextEggAt = now + PrototypeConfig.eggProductionIntervalSeconds
	state.eggProductionCarry = 0
	state.eggCatchSession = nil
	state.nextEggCatchSessionId = 1
	state.weatherId = PrototypeConfig.weather.defaultId
	state.nextWeatherAt = now + PrototypeConfig.weather.cycleIntervalSeconds
	state.lastActionAt = {}
	state.renameError = ""
	state.renameErrorDuckIndex = 0
	state.freshProfileNeedsHungryFollowUp = false
	state.freshProfileHungryHandled = false
	state.pendingForcedCareRequestKind = ""
	state.visitorHelpEnabled = false
end

local function serializeSaveData(state: PlayerState)
	local ducks = {}

	for _, duck in state.ducks do
		table.insert(ducks, {
			id = duck.id,
			name = duck.name,
			level = duck.level,
			xp = duck.xp,
			family = duck.family,
			rarity = duck.rarity,
		})
	end

	return {
		schemaVersion = 13,
		coins = state.coins,
		eggs = state.eggs,
		duckFeed = getDuckFeedCount(state),
		premiumFeed = getPremiumFeedCount(state),
		duckTreat = getDuckTreatCount(state),
		pillow = getPillowCount(state),
		toy = getToyCount(state),
		availableEggs = state.availableEggs,
		eggValueLevel = state.eggValueLevel,
		nextDuckId = state.nextDuckId,
		ducks = ducks,
		quests = state.quests,
		lastDailyClaimDay = state.lastDailyClaimDay,
		lastSeenUtc = os.time(),
		streakDay = state.streakDay,
		dailyQuests = state.dailyQuests,
		unlockLadder = state.unlockLadder,
		collectionRewardsClaimed = state.collectionRewardsClaimed,
		starterChoiceCompleted = state.starterChoiceCompleted,
		mysteryDuckBoxes = state.mysteryDuckBoxes,
		funnelMilestones = state.funnelMilestones,
		eggInventory = state.eggInventory,
		incubatorSlots = state.incubatorSlots,
		hatchPity = state.hatchPity,
	}
end

local function updateCareRequest(state: PlayerState)
	local now = os.clock()

	for index = getVisibleCareDuckCount(state) + 1, getDuckCount(state) do
		state.ducks[index].hasCareRequest = false
	end

	if getCareRequestDuckIndex(state) > 0 or now < state.nextCareRequestAt then
		return
	end

	assignCareRequest(state, now)
end

local function serializeQuests(state: PlayerState)
	local quests = {}

	for _, questDefinition in getQuestDefinitions() do
		local quest = getQuestState(state, questDefinition.id)
		local level = if quest then quest.level else 1
		local progress = if quest then quest.progress else 0

		table.insert(quests, {
			id = questDefinition.id,
			displayName = questDefinition.displayName,
			level = level,
			progress = progress,
			target = getQuestTarget(questDefinition, level),
			rewardCoins = getQuestRewardCoins(questDefinition, level),
			rewardDuckFeed = getQuestRewardDuckFeed(questDefinition, level),
			rewardDuckTreat = getQuestRewardDuckTreat(questDefinition, level),
			rewardPillow = getQuestRewardPillow(questDefinition, level),
		})
	end

	return quests
end

-- Daily quests reuse the existing quest panel: they serialize in the same shape as
-- repeatable quests and sit at the top of the list, so no new UI surface is needed.
local function serializeDailyQuests(state: PlayerState)
	ensureDailyQuestsCurrent(state)

	local entries = {}

	for slotIndex = 1, PrototypeConfig.dailyQuests.questCount do
		local definition = getDailyQuestDefinition(slotIndex, state.dailyQuests.dayStamp)

		table.insert(entries, {
			id = "daily_slot_" .. tostring(slotIndex),
			displayName = definition.displayName,
			level = 1,
			progress = state.dailyQuests.progress[slotIndex],
			target = definition.target,
			rewardCoins = definition.rewardCoins,
			rewardDuckFeed = definition.rewardDuckFeedAmount,
			rewardDuckTreat = definition.rewardDuckTreatAmount,
			rewardPillow = 0,
		})
	end

	return entries
end

local function serializeAllQuests(state: PlayerState)
	local entries = serializeDailyQuests(state)

	for _, quest in serializeQuests(state) do
		table.insert(entries, quest)
	end

	return entries
end

local function serializeFarmVisits(viewer: Player)
	local visits = {}

	for _, player in Players:GetPlayers() do
		if player ~= viewer then
			local state = statesByPlayer[player]

			table.insert(visits, {
				userId = player.UserId,
				playerName = player.Name,
				displayName = getPlayerDisplayName(player),
				duckCount = if state then getDuckCount(state) else 0,
				isLoaded = state ~= nil and state.isLoaded,
				visitorHelpEnabled = state ~= nil and state.isLoaded and state.visitorHelpEnabled,
			})
		end
	end

	return visits
end

local function serializeDuck(duck: DuckState, index: number, now: number)
	local careCooldownSeconds = math.max(0, math.ceil(duck.lastCareAt + PrototypeConfig.duckCare.cooldownSeconds - now))
	local isCaredFor = duck.careUntil > now
	local requestKind = if duck.hasCareRequest and duck.careRequestKind ~= "" then duck.careRequestKind else ""
	local requestDefinition = getCareRequestDefinition(requestKind)

	return {
		id = duck.id,
		index = index,
		name = duck.name,
		level = duck.level,
		xp = duck.xp,
		xpToNextLevel = getDuckXpToNextLevel(duck),
		mood = if isCaredFor then PrototypeConfig.duckCare.caredMood else PrototypeConfig.duckCare.defaultMood,
		moodDetail = if duck.hasCareRequest
			then (
				if requestKind == HUNGRY_REQUEST_KIND
					then "This duck is hungry"
					elseif requestKind == SLEEPY_REQUEST_KIND then "This duck is sleepy"
					elseif requestKind == DIRTY_REQUEST_KIND then "This duck feels dirty"
					elseif requestKind == THIRSTY_REQUEST_KIND then "This duck is thirsty"
					elseif requestKind == BORED_REQUEST_KIND then "This duck is bored"
					else "This duck wants care"
			)
			elseif isCaredFor then "This duck feels cared for"
			else "This duck is relaxed",
		careCooldownSeconds = careCooldownSeconds,
		hasCareRequest = duck.hasCareRequest,
		careRequestKind = requestKind,
		careRequestText = if duck.hasCareRequest then requestDefinition.requestText else "",
		canCare = careCooldownSeconds <= 0,
		family = duck.family,
		rarity = duck.rarity,
	}
end

-- Replicates incubator slots with a computed countdown so the client never derives timing.
-- finishUtc is os.time-based (wall clock), so remaining time uses os.time, not os.clock.
local function serializeIncubatorSlots(state: PlayerState)
	local nowUtc = os.time()
	local slots = {}

	for slotIndex, slot in state.incubatorSlots do
		local displayName = slot.eggType

		for _, eggDef in PrototypeConfig.eggTypes do
			if eggDef.id == slot.eggType then
				displayName = eggDef.displayName
				break
			end
		end

		local secondsRemaining = math.max(0, slot.finishUtc - nowUtc)

		table.insert(slots, {
			slotIndex = slotIndex,
			eggType = slot.eggType,
			displayName = displayName,
			secondsRemaining = secondsRemaining,
			ready = secondsRemaining <= 0,
		})
	end

	return slots
end

local function serializeState(state: PlayerState)
	local now = os.clock()
	local duckCount = getDuckCount(state)
	local careRequestDuckIndex = getCareRequestDuckIndex(state)
	local careRequestKind = getCareRequestKind(state)
	local careRequestDefinition = getCareRequestDefinition(careRequestKind)
	local ducks = {}
	local canCareForDucks = false
	local shortestCooldown = 0
	local hasCaredDuck = false

	for index, duck in state.ducks do
		local serializedDuck = serializeDuck(duck, index, now)

		table.insert(ducks, serializedDuck)

		if serializedDuck.canCare then
			canCareForDucks = true
		elseif shortestCooldown == 0 or serializedDuck.careCooldownSeconds < shortestCooldown then
			shortestCooldown = serializedDuck.careCooldownSeconds
		end

		if serializedDuck.mood == PrototypeConfig.duckCare.caredMood then
			hasCaredDuck = true
		end
	end

	local upgradeCost = getEggValueUpgradeCost(state)
	local duckPurchaseCost = getDuckPurchaseCost(state)
	local duckFeed = PrototypeConfig.shop.duckFeed
	local duckFeedCount = getDuckFeedCount(state)
	local premiumFeed = PrototypeConfig.shop.premiumFeed
	local premiumFeedCount = getPremiumFeedCount(state)
	local duckTreat = PrototypeConfig.shop.duckTreat
	local duckTreatCount = getDuckTreatCount(state)
	local pillow = PrototypeConfig.shop.pillow
	local pillowCount = getPillowCount(state)
	local toy = PrototypeConfig.shop.toy
	local toyCount = getToyCount(state)
	local currentWeatherDefinition = getWeatherDefinition(state.weatherId)

	if careRequestDuckIndex > 0 and careRequestKind == HUNGRY_REQUEST_KIND and duckFeedCount + premiumFeedCount <= 0 then
		canCareForDucks = false
	end

	return {
		eggs = state.eggs,
		coins = state.coins,
		availableEggs = state.availableEggs,
		duckFeed = duckFeedCount,
		premiumFeed = premiumFeedCount,
		duckTreat = duckTreatCount,
		pillow = pillowCount,
		duckCount = duckCount,
		ducks = ducks,
		eggSellValue = state.eggSellValue,
		eggValueLevel = state.eggValueLevel,
		eggValueMaxLevel = EGG_VALUE_MAX_LEVEL,
		eggValueUpgradeCost = upgradeCost,
		duckPurchaseCost = duckPurchaseCost,
		duckFeedCost = duckFeed.cost,
		premiumFeedCost = premiumFeed.cost,
		duckTreatCost = duckTreat.cost,
		pillowCost = pillow.cost,
		toy = toyCount,
		toyCost = toy.cost,
		duckMood = if hasCaredDuck then PrototypeConfig.duckCare.caredMood else PrototypeConfig.duckCare.defaultMood,
		duckMoodDetail = if careRequestDuckIndex > 0
			then (
				if careRequestKind == HUNGRY_REQUEST_KIND
					then "A duck is hungry"
					elseif careRequestKind == SLEEPY_REQUEST_KIND then "A duck is sleepy"
					elseif careRequestKind == DIRTY_REQUEST_KIND then "A duck needs cleaning"
					elseif careRequestKind == THIRSTY_REQUEST_KIND then "A duck is thirsty"
					elseif careRequestKind == BORED_REQUEST_KIND then "A duck is bored"
					else "A duck wants care"
			)
			elseif hasCaredDuck then "Some ducks feel cared for"
			else "Ducks are relaxed",
		careRequestDuckIndex = careRequestDuckIndex,
		careRequestKind = careRequestKind,
		careRequestText = if careRequestDuckIndex > 0 then careRequestDefinition.requestText else "",
		careCooldownSeconds = shortestCooldown,
		secondsUntilNextEgg = math.max(0, math.ceil(state.nextEggAt - now)),
		canBuyEggValueUpgrade = upgradeCost > 0 and state.coins >= upgradeCost,
		canBuyDuck = state.coins >= duckPurchaseCost,
		canBuyDuckFeed = state.coins >= duckFeed.cost,
		canBuyPremiumFeed = state.coins >= premiumFeed.cost,
		canBuyDuckTreat = state.coins >= duckTreat.cost,
		canBuyPillow = state.coins >= pillow.cost,
		canBuyToy = state.coins >= toy.cost,
		canClaimDailyCheckIn = math.floor(os.time() / 86400) > state.lastDailyClaimDay,
		streakDay = state.streakDay,
		canCareForDucks = canCareForDucks,
		renameError = state.renameError,
		renameErrorDuckIndex = state.renameErrorDuckIndex,
		saveStatus = state.saveStatus,
		saveStatusText = state.saveStatusText,
		weatherId = currentWeatherDefinition.id,
		weatherDisplayName = currentWeatherDefinition.displayName,
		weatherDetail = currentWeatherDefinition.detailText,
		secondsUntilWeatherChange = math.max(0, math.ceil(state.nextWeatherAt - now)),
		isFreshProfile = state.isFreshProfile,
		quests = serializeAllQuests(state),
		collectionRewardsClaimed = state.collectionRewardsClaimed,
		starterChoiceCompleted = state.starterChoiceCompleted,
		mysteryDuckBoxes = state.mysteryDuckBoxes,
		pendingDuckBoxCandidates = state.pendingDuckBoxCandidates,
		eggInventory = state.eggInventory,
		incubatorSlots = serializeIncubatorSlots(state),
	}
end

local function getVisibleFarmOwner(viewer: Player): Player?
	local targetPlayer = farmViewTargetsByPlayer[viewer]

	if not targetPlayer or targetPlayer == viewer then
		farmViewTargetsByPlayer[viewer] = nil
		return nil
	end

	local targetState = statesByPlayer[targetPlayer]

	if not targetState or not targetState.isLoaded then
		farmViewTargetsByPlayer[viewer] = nil
		return nil
	end

	return targetPlayer
end

local function serializeStateForViewer(viewer: Player, homeState: PlayerState)
	local owner = getVisibleFarmOwner(viewer)
	local ownerState = homeState

	if owner then
		ownerState = statesByPlayer[owner] or homeState
	end

	local serializedState: {[string]: any} = serializeState(ownerState)
	local farmOwner = owner or viewer

	serializedState.isVisitingFarm = owner ~= nil
	serializedState.visitorHelpEnabled = ownerState.visitorHelpEnabled
	-- Unlock flags always reflect the viewer's own progress, never the visited owner's,
	-- so a fresh owner's locked features can never strand or restrict a visitor.
	serializedState.featureUnlocks = getFeatureUnlocks(homeState)
	serializedState.farmOwnerUserId = farmOwner.UserId
	serializedState.farmOwnerName = farmOwner.Name
	serializedState.farmOwnerDisplayName = getPlayerDisplayName(farmOwner)
	serializedState.farmVisits = serializeFarmVisits(viewer)

	return serializedState
end

-- Drains queued analytics events for the player who owns this state. sendState always pairs a
-- player with their own state (owner with ownerState, viewer with viewerState), so the Player
-- passed to the Roblox AnalyticsService is always the actor the events belong to.
local function flushAnalytics(player: Player, state: PlayerState)
	if #state.pendingAnalytics == 0 then
		return
	end

	for _, event in state.pendingAnalytics do
		if event.kind == "economy" then
			AnalyticsService.logEconomy(
				player,
				event.flow,
				event.currency,
				event.amount,
				event.endingBalance,
				event.transactionType,
				event.category
			)
		else
			AnalyticsService.logCustom(player, event.event)
		end
	end

	table.clear(state.pendingAnalytics)
end

local function sendState(player: Player, state: PlayerState)
	-- Join-time notices (streak claim, offline eggs, comeback gift) queue until the client
	-- proves its listener is connected by sending any action, otherwise they fire into the void.
	if state.clientReady and #state.pendingNotices > 0 then
		for _, noticePayload in state.pendingNotices do
			noticeEvent:FireClient(player, noticePayload)
		end

		table.clear(state.pendingNotices)
	end

	flushAnalytics(player, state)

	stateEvent:FireClient(player, serializeStateForViewer(player, state))
end

local function sendFarmStateToViewers(owner: Player, ownerState: PlayerState)
	sendState(owner, ownerState)

	for viewer, targetPlayer in farmViewTargetsByPlayer do
		if targetPlayer == owner then
			local viewerState = statesByPlayer[viewer]

			if viewerState then
				sendState(viewer, viewerState)
			end
		end
	end
end

local function sendNotice(player: Player, payload: {[string]: any})
	noticeEvent:FireClient(player, payload)
end

local function saveStateForUser(
	userId: number,
	playerName: string,
	state: PlayerState,
	statusText: string?,
	playerForClient: Player?
): boolean
	if state.saveInProgress then
		return false
	end

	state.saveInProgress = true
	state.lastSaveAttemptAt = os.clock()
	setSaveStatus(state, SAVE_STATUS_SAVING, statusText)
	local saveRevision = state.saveRevision
	local saveData = serializeSaveData(state)

	if playerForClient and statesByPlayer[playerForClient] == state then
		sendState(playerForClient, state)
	end

	local success, errorMessage = PlayerDataService.savePlayerData(userId, playerName, saveData)

	state.saveInProgress = false
	state.lastSaveAttemptAt = os.clock()

	if success then
		if state.saveRevision == saveRevision then
			state.saveDirty = false
			state.nextAutosaveAt = 0
			setSaveStatus(state, SAVE_STATUS_SAVED)
		else
			state.saveDirty = true
			state.nextAutosaveAt = os.clock() + AUTOSAVE_DELAY_SECONDS
			setSaveStatus(state, SAVE_STATUS_PENDING)
		end
	else
		state.saveDirty = true
		state.nextAutosaveAt = os.clock() + AUTOSAVE_RETRY_DELAY_SECONDS
		setSaveStatus(state, SAVE_STATUS_FAILED, getStudioSaveFailureText(errorMessage))
	end

	if playerForClient and statesByPlayer[playerForClient] == state then
		sendState(playerForClient, state)
	end

	return success
end

local function savePlayerState(player: Player, state: PlayerState, statusText: string?): boolean
	return saveStateForUser(player.UserId, player.Name, state, statusText, player)
end

local function saveEntryState(entry: SaveEntry, statusText: string?): boolean
	return saveStateForUser(entry.userId, entry.playerName, entry.state, statusText, nil)
end

local function requestSavePlayerState(player: Player, state: PlayerState, statusText: string?)
	if state.saveInProgress then
		return
	end

	task.spawn(function()
		if statesByPlayer[player] == state then
			savePlayerState(player, state, statusText)
		end
	end)
end

local function waitForActiveSave(state: PlayerState)
	local startedWaitingAt = os.clock()

	while state.saveInProgress and os.clock() - startedWaitingAt < SAVE_WAIT_TIMEOUT_SECONDS do
		task.wait(0.1)
	end
end

local function produceEggs(state: PlayerState)
	local interval = PrototypeConfig.eggProductionIntervalSeconds
	local now = os.clock()

	if now < state.nextEggAt then
		return
	end

	local cycles = math.floor((now - state.nextEggAt) / interval) + 1
	local totalProduction = state.eggProductionCarry + cycles * getEggProductionPerCycle(state)
	local producedEggs = math.floor(totalProduction)

	state.eggProductionCarry = totalProduction - producedEggs
	state.availableEggs += producedEggs
	state.nextEggAt += cycles * interval
	markSaveDirty(state)
end

local function isRateLimited(state: PlayerState, actionName: string): boolean
	local now = os.clock()
	local lastActionAt = state.lastActionAt[actionName]

	if lastActionAt and now - lastActionAt < ACTION_COOLDOWN_SECONDS then
		return true
	end

	state.lastActionAt[actionName] = now
	return false
end

local function collectEggs(state: PlayerState)
	if state.availableEggs <= 0 then
		return
	end

	local collectedEggs = state.availableEggs

	state.eggs += collectedEggs
	state.availableEggs = 0
	markFunnelMilestone(state, "funnel_first_collect")
	grantQuestProgress(state, QUEST_COLLECT_EGGS_ID, collectedEggs)
	grantDailyQuestProgress(state, "collect", collectedEggs)
	markSaveDirty(state)
end

local function sellEggs(state: PlayerState)
	if state.eggs <= 0 then
		return
	end

	local soldEggs = state.eggs
	local coinsGained = soldEggs * state.eggSellValue

	state.coins += coinsGained
	state.eggs = 0
	queueEconomyEvent(state, "source", coinsGained, "Gameplay", "egg_sale")
	markFunnelMilestone(state, "funnel_first_sell")
	grantQuestProgress(state, QUEST_SELL_EGGS_ID, soldEggs)
	grantDailyQuestProgress(state, "sell", soldEggs)
	markSaveDirty(state)
end

local function buyEggValueUpgrade(state: PlayerState)
	local upgradeCost = getEggValueUpgradeCost(state)

	if upgradeCost <= 0 or state.coins < upgradeCost then
		return
	end

	state.coins -= upgradeCost
	queueEconomyEvent(state, "sink", upgradeCost, "Shop", "egg_value_upgrade")
	state.eggValueLevel += 1
	state.eggSellValue += PrototypeConfig.firstUpgrade.valueIncrease
	grantQuestProgress(state, QUEST_SPEND_COINS_ID, upgradeCost)
	grantDailyQuestProgress(state, "spend", upgradeCost)
	markSaveDirty(state)
end

-- Forward declaration: buyDuck calls grantDuckWithFamily, whose full definition
-- lives further down with the other Phase 5 collection/duck-grant helpers.
local grantDuckWithFamily: (PlayerState, string, string) -> ()

local function buyDuck(state: PlayerState, payload: any)
	local duckPurchase = PrototypeConfig.duckPurchase
	local duckPurchaseCost: number
	local duckFamily = "classic_yellow"
	local duckRarity = "common"

	local requestedFamilyId: string? = nil

	if typeof(payload) == "table" then
		local pt = payload :: {[string]: any}

		if typeof(pt.familyId) == "string" then
			requestedFamilyId = pt.familyId
		end
	end

	if requestedFamilyId then
		local matched = false

		for _, familyDef in PrototypeConfig.families do
			if familyDef.id == requestedFamilyId then
				if familyDef.buyCost == nil then
					return
				end

				duckPurchaseCost = familyDef.buyCost
				duckFamily = familyDef.id
				duckRarity = familyDef.rarity
				matched = true
				break
			end
		end

		if not matched then
			return
		end
	else
		duckPurchaseCost = getDuckPurchaseCost(state)
	end

	if duckPurchaseCost <= 0 or state.coins < duckPurchaseCost then
		return
	end

	state.coins -= duckPurchaseCost
	queueEconomyEvent(state, "sink", duckPurchaseCost, "Shop", "duck_purchase")
	markFunnelMilestone(state, "funnel_first_buy_duck")

	for _ = 1, duckPurchase.duckIncrease do
		grantDuckWithFamily(state, duckFamily, duckRarity)
	end

	grantQuestProgress(state, QUEST_BUY_DUCKS_ID, duckPurchase.duckIncrease)
	grantQuestProgress(state, QUEST_SPEND_COINS_ID, duckPurchaseCost)
	grantDailyQuestProgress(state, "spend", duckPurchaseCost)
	markSaveDirty(state)
end

local function buyShopItem(state: PlayerState, payload: any)
	local itemId = nil

	if typeof(payload) == "string" then
		itemId = payload
	elseif typeof(payload) == "table" then
		local payloadTable = payload :: {[string]: any}

		if typeof(payloadTable.itemId) == "string" then
			itemId = payloadTable.itemId
		end
	end

	local duckFeed = PrototypeConfig.shop.duckFeed
	local premiumFeed = PrototypeConfig.shop.premiumFeed
	local duckTreat = PrototypeConfig.shop.duckTreat
	local pillow = PrototypeConfig.shop.pillow
	local toy = PrototypeConfig.shop.toy
	local itemDefinition = nil

	if itemId == duckFeed.id then
		itemDefinition = duckFeed
	elseif itemId == premiumFeed.id then
		itemDefinition = premiumFeed
	elseif itemId == duckTreat.id then
		itemDefinition = duckTreat
	elseif itemId == pillow.id then
		itemDefinition = pillow
	elseif itemId == toy.id then
		itemDefinition = toy
	end

	if not itemDefinition or itemDefinition.cost <= 0 or state.coins < itemDefinition.cost then
		return
	end

	state.coins -= itemDefinition.cost
	queueEconomyEvent(state, "sink", itemDefinition.cost, "Shop", "shop_" .. itemDefinition.id)
	markFunnelMilestone(state, "funnel_first_shop_purchase")
	state.inventory[itemDefinition.id] = (state.inventory[itemDefinition.id] or 0) + itemDefinition.purchaseAmount
	grantQuestProgress(state, QUEST_SPEND_COINS_ID, itemDefinition.cost)
	grantDailyQuestProgress(state, "buy_item", 1)
	grantDailyQuestProgress(state, "spend", itemDefinition.cost)
	markSaveDirty(state)
end

local function useTreatOnDuck(state: PlayerState, payload: any)
	local duck, _ = getDuckByPayloadIndex(state, payload)
	local duckTreat = PrototypeConfig.shop.duckTreat
	local duckTreatCount = getDuckTreatCount(state)
	local xpAmount = duckTreat.xpAmount or 0

	if not duck or duckTreatCount <= 0 or xpAmount <= 0 then
		return
	end

	if duck.level >= PrototypeConfig.duckLevel.maxLevel then
		return
	end

	state.inventory[duckTreat.id] = duckTreatCount - 1
	local levelsGained = addDuckXp(duck, xpAmount)
	grantQuestProgress(state, QUEST_USE_TREATS_ID, 1)
	grantDailyQuestProgress(state, "treat", 1)
	if levelsGained > 0 then
		grantQuestProgress(state, QUEST_LEVEL_UP_DUCKS_ID, levelsGained)
		grantDailyQuestProgress(state, "level", levelsGained)
	end
	markSaveDirty(state)
end

local function formatEggCatchRewardSummary(coins: number, duckFeed: number, duckTreat: number): string
	local parts = {}

	if coins > 0 then
		table.insert(parts, string.format("+%d coin%s", coins, if coins == 1 then "" else "s"))
	end

	if duckFeed > 0 then
		table.insert(parts, string.format("Feed x%d", duckFeed))
	end

	if duckTreat > 0 then
		table.insert(parts, string.format("Treat x%d", duckTreat))
	end

	if #parts <= 0 then
		return "No reward this round"
	end

	return table.concat(parts, "  |  ")
end

local function getEggCatchReward(score: number): (number, number, number)
	local rewardConfig = EGG_CATCH_CONFIG.reward
	local coins = math.min(rewardConfig.maxCoins, math.floor(score / rewardConfig.coinsPerScoreStep))
	local duckFeed = if score >= rewardConfig.duckFeedScoreThreshold then rewardConfig.duckFeedAmount else 0
	local duckTreat = if score >= rewardConfig.duckTreatScoreThreshold then rewardConfig.duckTreatAmount else 0

	return coins, duckFeed, duckTreat
end

local function getMaxPlausibleEggCatchScore(elapsedSeconds: number): number
	local rewardConfig = EGG_CATCH_CONFIG.reward
	local firstCatchAt = rewardConfig.firstDropDelaySeconds + rewardConfig.fastestDropTravelSeconds
	local minDropInterval = rewardConfig.minDropIntervalSeconds

	if elapsedSeconds < firstCatchAt or minDropInterval <= 0 then
		return 0
	end

	local catchesAfterFirst = math.floor((elapsedSeconds - firstCatchAt) / minDropInterval)

	return math.min(
		rewardConfig.maxSubmittedScore,
		1 + catchesAfterFirst + rewardConfig.scoreValidationSlack
	)
end

local function startEggCatchRound(state: PlayerState): number
	local sessionId = state.nextEggCatchSessionId

	state.nextEggCatchSessionId += 1
	state.eggCatchSession = {
		sessionId = sessionId,
		startedAt = os.clock(),
		claimed = false,
	}

	return sessionId
end

local function getEggCatchClaimPayload(payload: any): (number?, number?)
	if typeof(payload) ~= "table" then
		return nil, nil
	end

	local payloadTable = payload :: {[string]: any}
	local sessionId = if typeof(payloadTable.sessionId) == "number" then payloadTable.sessionId else nil
	local score = if typeof(payloadTable.score) == "number" then payloadTable.score else nil

	if not sessionId or not score then
		return nil, nil
	end

	if not isFiniteNumber(sessionId) or not isFiniteNumber(score) then
		return nil, nil
	end

	if sessionId % 1 ~= 0 or score % 1 ~= 0 then
		return nil, nil
	end

	if sessionId < 1 or score < 0 then
		return nil, nil
	end

	return sessionId, score
end

local function claimEggCatchReward(player: Player, state: PlayerState, payload: any)
	local sessionId, submittedScore = getEggCatchClaimPayload(payload)
	local session = state.eggCatchSession

	if not sessionId or submittedScore == nil or not session or session.sessionId ~= sessionId then
		sendNotice(player, {
			kind = RemoteProtocol.notices.eggCatchReward,
			success = false,
			sessionId = sessionId or 0,
			message = "Round expired",
		})
		return
	end

	if session.claimed then
		sendNotice(player, {
			kind = RemoteProtocol.notices.eggCatchReward,
			success = false,
			sessionId = sessionId,
			message = "Reward already claimed",
		})
		return
	end

	local elapsed = os.clock() - session.startedAt

	if elapsed < EGG_CATCH_CONFIG.roundSeconds - EGG_CATCH_CONFIG.reward.claimGraceSeconds then
		sendNotice(player, {
			kind = RemoteProtocol.notices.eggCatchReward,
			success = false,
			sessionId = sessionId,
			message = "Round still running",
		})
		return
	end

	local maxPlausibleScore = getMaxPlausibleEggCatchScore(elapsed)

	if submittedScore > maxPlausibleScore then
		sendNotice(player, {
			kind = RemoteProtocol.notices.eggCatchReward,
			success = false,
			sessionId = sessionId,
			message = "Score rejected",
		})
		return
	end

	local clampedScore = math.clamp(submittedScore, 0, EGG_CATCH_CONFIG.reward.maxSubmittedScore)
	local coins, duckFeed, duckTreat = getEggCatchReward(clampedScore)
	local rewardMessage = formatEggCatchRewardSummary(coins, duckFeed, duckTreat)
	local duckFeedId = PrototypeConfig.shop.duckFeed.id
	local duckTreatId = PrototypeConfig.shop.duckTreat.id

	session.claimed = true
	state.eggCatchSession = nil

	if coins > 0 then
		state.coins += coins
		queueEconomyEvent(state, "source", coins, "Gameplay", "minigame_egg_catch")
	end

	markFunnelMilestone(state, "funnel_first_minigame")

	if duckFeed > 0 then
		state.inventory[duckFeedId] = (state.inventory[duckFeedId] or 0) + duckFeed
	end

	if duckTreat > 0 then
		state.inventory[duckTreatId] = (state.inventory[duckTreatId] or 0) + duckTreat
	end

	if coins > 0 or duckFeed > 0 or duckTreat > 0 then
		markSaveDirty(state)
	end

	grantQuestProgress(state, QUEST_WIN_EGG_CATCH_ID, 1)
	grantDailyQuestProgress(state, "egg_catch", 1)
	markSaveDirty(state)

	sendNotice(player, {
		kind = RemoteProtocol.notices.eggCatchReward,
		success = true,
		sessionId = sessionId,
		score = clampedScore,
		coins = coins,
		duckFeed = duckFeed,
		duckTreat = duckTreat,
		message = rewardMessage,
	})
end

local function careForDuck(state: PlayerState, payload: any)
	local now = os.clock()
	local duck, duckIndex = getDuckByPayloadIndex(state, payload)
	local xpAmount = PrototypeConfig.duckLevel.xpPerCare

	if not duck then
		return
	end

	local careRequestDuckIndex = getCareRequestDuckIndex(state)

	if careRequestDuckIndex > 0 and careRequestDuckIndex ~= duckIndex then
		return
	end

	if not canDuckCare(duck, now) then
		return
	end

	if duck.hasCareRequest and duck.careRequestKind == HUNGRY_REQUEST_KIND then
		local duckFeed = PrototypeConfig.shop.duckFeed
		local duckFeedCount = getDuckFeedCount(state)
		local premiumFeed = PrototypeConfig.shop.premiumFeed
		local premiumFeedCount = getPremiumFeedCount(state)

		if premiumFeedCount > 0 then
			xpAmount = PrototypeConfig.duckLevel.xpPerPremiumFeed
			state.inventory[premiumFeed.id] = premiumFeedCount - 1
		elseif duckFeedCount > 0 then
			xpAmount = PrototypeConfig.duckLevel.xpPerFeed
			state.inventory[duckFeed.id] = duckFeedCount - 1
		else
			return
		end
		if state.isFreshProfile then
			state.freshProfileHungryHandled = true
			state.freshProfileNeedsHungryFollowUp = false
			state.pendingForcedCareRequestKind = ""
		end
	elseif duck.hasCareRequest and duck.careRequestKind == DIRTY_REQUEST_KIND then
		xpAmount = PrototypeConfig.duckLevel.xpPerClean
	elseif duck.hasCareRequest and duck.careRequestKind == SLEEPY_REQUEST_KIND then
		local pillow = PrototypeConfig.shop.pillow
		local pillowCount = getPillowCount(state)

		if pillowCount > 0 then
			xpAmount = PrototypeConfig.duckLevel.xpPerPillowRest
			state.inventory[pillow.id] = pillowCount - 1
		else
			xpAmount = PrototypeConfig.duckLevel.xpPerRest
		end
	elseif duck.hasCareRequest and duck.careRequestKind == THIRSTY_REQUEST_KIND then
		xpAmount = PrototypeConfig.duckLevel.xpPerDrink
	elseif duck.hasCareRequest and duck.careRequestKind == BORED_REQUEST_KIND then
		local toy = PrototypeConfig.shop.toy
		local toyCount = getToyCount(state)

		if toyCount > 0 then
			xpAmount = PrototypeConfig.duckLevel.xpPerToyPlay
			state.inventory[toy.id] = toyCount - 1
		else
			xpAmount = PrototypeConfig.duckLevel.xpPerPlay
		end
	end

	local levelsGained = addDuckXp(duck, xpAmount)
	markFunnelMilestone(state, "funnel_first_care")
	grantQuestProgress(state, QUEST_HELP_DUCKS_ID, 1)
	grantDailyQuestProgress(state, "help", 1)
	if levelsGained > 0 then
		grantQuestProgress(state, QUEST_LEVEL_UP_DUCKS_ID, levelsGained)
		grantDailyQuestProgress(state, "level", levelsGained)
	end
	duck.hasCareRequest = false
	duck.careRequestKind = ""
	duck.lastCareAt = now
	duck.careUntil = now + PrototypeConfig.duckCare.careDurationSeconds
	scheduleNextCareRequest(state, now)

	if
		state.isFreshProfile
		and state.freshProfileNeedsHungryFollowUp
		and not state.freshProfileHungryHandled
	then
		state.freshProfileNeedsHungryFollowUp = false
		state.pendingForcedCareRequestKind = HUNGRY_REQUEST_KIND
		state.nextCareRequestAt = now + PrototypeConfig.duckCare.freshProfileHungryFollowUpDelaySeconds
	end

	markSaveDirty(state)
end

local function getRenamePayload(payload: any): (number?, string?)
	if typeof(payload) ~= "table" then
		return nil, nil
	end

	local payloadTable = payload :: {[string]: any}
	local duckIndex = if typeof(payloadTable.duckIndex) == "number" then payloadTable.duckIndex else nil
	local name = if typeof(payloadTable.name) == "string" then payloadTable.name else nil

	return duckIndex, name
end

local function setRenameError(state: PlayerState, duckIndex: number, message: string)
	state.renameError = message
	state.renameErrorDuckIndex = duckIndex
end

local function filterDuckName(player: Player, requestedName: string): (string?, string?)
	local success, filteredName = pcall(function()
		local filterResult = TextService:FilterStringAsync(requestedName, player.UserId, Enum.TextFilterContext.PublicChat)
		return filterResult:GetNonChatStringForUserAsync(player.UserId)
	end)

	if not success or typeof(filteredName) ~= "string" then
		return nil, "Name could not be checked"
	end

	local trimmedName = trimText(filteredName)

	if trimmedName == "" or string.find(trimmedName, "#") then
		return nil, "Try another name"
	end

	return trimmedName, nil
end

local function renameDuck(player: Player, state: PlayerState, payload: any): boolean
	local payloadDuckIndex, requestedName = getRenamePayload(payload)

	if not payloadDuckIndex or not requestedName then
		setRenameError(state, 0, "Invalid name")
		return false
	end

	local duck, duckIndex = getDuckByPayloadIndex(state, payloadDuckIndex)

	if not duck then
		setRenameError(state, 0, "Duck not found")
		return false
	end

	local trimmedName = trimText(requestedName)
	local renameConfig = PrototypeConfig.duckRename
	local nameLength = getTextLength(trimmedName)

	if nameLength < renameConfig.minLength then
		setRenameError(state, duckIndex, "Name is too short")
		return false
	end

	if nameLength > renameConfig.maxLength then
		setRenameError(state, duckIndex, "Name is too long")
		return false
	end

	if isDuckNameUsed(state, trimmedName, duck) then
		setRenameError(state, duckIndex, "Name already used")
		return false
	end

	local filteredName, filterError = filterDuckName(player, trimmedName)

	if not filteredName then
		setRenameError(state, duckIndex, filterError or "Try another name")
		return false
	end

	if getTextLength(filteredName) > renameConfig.maxLength then
		setRenameError(state, duckIndex, "Name is too long")
		return false
	end

	if isDuckNameUsed(state, filteredName, duck) then
		setRenameError(state, duckIndex, "Name already used")
		return false
	end

	duck.name = filteredName
	state.renameError = ""
	state.renameErrorDuckIndex = 0
	markSaveDirty(state)
	return true
end

local function getVisitUserIdFromPayload(payload: any): number?
	local userId = nil

	if typeof(payload) == "number" then
		userId = payload
	elseif typeof(payload) == "table" then
		local payloadTable = payload :: {[string]: any}

		if typeof(payloadTable.userId) == "number" then
			userId = payloadTable.userId
		end
	end

	-- Studio multiplayer test clients can use negative UserIds; the live-player lookup below
	-- still prevents visiting anything except a real same-server Player instance.
	if not userId or not isFiniteNumber(userId) or userId % 1 ~= 0 or userId == 0 then
		return nil
	end

	return userId
end

local function getPlayerByUserId(userId: number): Player?
	for _, player in Players:GetPlayers() do
		if player.UserId == userId then
			return player
		end
	end

	return nil
end

local function visitFarm(player: Player, payload: any)
	local userId = getVisitUserIdFromPayload(payload)

	if not userId then
		return
	end

	if userId == player.UserId then
		farmViewTargetsByPlayer[player] = nil
		return
	end

	local targetPlayer = getPlayerByUserId(userId)
	local targetState: PlayerState? = nil

	if targetPlayer then
		targetState = statesByPlayer[targetPlayer]
	end

	if not targetPlayer or not targetState or not targetState.isLoaded then
		return
	end

	farmViewTargetsByPlayer[player] = targetPlayer

	local visitorState = statesByPlayer[player]

	if visitorState then
		markFunnelMilestone(visitorState, "social_first_visit")
	end
end

local function returnHomeFarm(player: Player)
	farmViewTargetsByPlayer[player] = nil
end

local function canVisitorHelpRequest(requestKind: string): boolean
	return requestKind == PET_REQUEST_KIND
		or requestKind == SLEEPY_REQUEST_KIND
		or requestKind == DIRTY_REQUEST_KIND
		or requestKind == THIRSTY_REQUEST_KIND
		or requestKind == BORED_REQUEST_KIND
end

local function toggleVisitorHelp(player: Player, state: PlayerState)
	state.visitorHelpEnabled = not state.visitorHelpEnabled
	sendFarmStateToViewers(player, state)
end

local function visitorHelpDuck(visitor: Player, payload: any)
	local owner = farmViewTargetsByPlayer[visitor]

	if not owner then
		return
	end

	local ownerState = statesByPlayer[owner]

	if not ownerState or not ownerState.isLoaded or not ownerState.visitorHelpEnabled then
		return
	end

	local duck, duckIndex = getDuckByPayloadIndex(ownerState, payload)
	local careRequestDuckIndex = getCareRequestDuckIndex(ownerState)

	if not duck or duckIndex ~= careRequestDuckIndex then
		return
	end

	local requestKind = if duck.careRequestKind ~= "" then duck.careRequestKind else PET_REQUEST_KIND

	if not duck.hasCareRequest or not canVisitorHelpRequest(requestKind) then
		return
	end

	local now = os.clock()

	duck.hasCareRequest = false
	duck.careRequestKind = ""
	duck.careUntil = now + PrototypeConfig.duckCare.careDurationSeconds
	scheduleNextCareRequest(ownerState, now)
	sendFarmStateToViewers(owner, ownerState)
end

-- Auto-grants any collection milestone rewards the player newly qualifies for.
-- Idempotent: already-claimed IDs in state.collectionRewardsClaimed are skipped.
local function checkCollectionMilestones(state: PlayerState)
	local ownedFamilies: {[string]: boolean} = {}

	for _, duck in state.ducks do
		if duck.family ~= "golden" then
			ownedFamilies[duck.family] = true
		end
	end

	local ownedCount = 0

	for _ in ownedFamilies do
		ownedCount += 1
	end

	for _, reward in PrototypeConfig.collectionRewards do
		if ownedCount < reward.familiesRequired then
			continue
		end

		local alreadyClaimed = false

		for _, claimedId in state.collectionRewardsClaimed do
			if claimedId == reward.id then
				alreadyClaimed = true
				break
			end
		end

		if alreadyClaimed then
			continue
		end

		table.insert(state.collectionRewardsClaimed, reward.id)
		state.coins += reward.rewardCoins
		queueEconomyEvent(state, "source", reward.rewardCoins, "Gameplay", "collection_reward")

		if reward.rewardTreat > 0 then
			local duckTreatId = PrototypeConfig.shop.duckTreat.id
			state.inventory[duckTreatId] = (state.inventory[duckTreatId] or 0) + reward.rewardTreat
		end

		if reward.rewardMysteryBox > 0 then
			state.mysteryDuckBoxes += reward.rewardMysteryBox
		end

		queueNotice(state, {
			kind = RemoteProtocol.notices.collectionRewardGranted,
			rewardId = reward.id,
			rewardCoins = reward.rewardCoins,
			rewardTreat = reward.rewardTreat,
			rewardMysteryBox = reward.rewardMysteryBox,
		})

		markSaveDirty(state)
	end
end

-- Assigns into the forward declaration above buyDuck (this is the real definition).
function grantDuckWithFamily(state: PlayerState, family: string, rarity: string)
	addDuck(state, family, rarity)
	checkCollectionMilestones(state)
	markSaveDirty(state)
end

local function pickMysteryBoxRarity(): string
	local config = PrototypeConfig.mysteryDuckBox
	local roll = math.random(1, 100)

	if roll <= config.epicChance then
		return "epic"
	elseif roll <= config.epicChance + config.rareChance then
		return "rare"
	end

	return "uncommon"
end

-- Maps a rolled rarity to a concrete family. The Mystery Duck Box only ever rolls uncommon
-- through epic; the common and legendary branches exist for Phase 6 egg hatching.
local function pickFamilyForRarity(rarity: string): string
	if rarity == "legendary" then
		return "golden"
	elseif rarity == "epic" then
		return "twilight_blue"
	elseif rarity == "rare" then
		return "blossom_pink"
	elseif rarity == "common" then
		return if math.random(1, 2) == 1 then "classic_yellow" else "mallard_green"
	end

	return if math.random(1, 2) == 1 then "choco_brown" else "snowy_white"
end

local function openMysteryDuckBox(player: Player, state: PlayerState)
	if state.mysteryDuckBoxes <= 0 or state.pendingDuckBoxCandidates ~= nil then
		return
	end

	state.mysteryDuckBoxes -= 1
	markSaveDirty(state)

	local candidates: {{family: string, rarity: string, displayName: string}} = {}

	for _ = 1, 3 do
		local rarity = pickMysteryBoxRarity()
		local familyId = pickFamilyForRarity(rarity)
		local displayName = familyId

		for _, familyDef in PrototypeConfig.families do
			if familyDef.id == familyId then
				displayName = familyDef.displayName
				break
			end
		end

		table.insert(candidates, { family = familyId, rarity = rarity, displayName = displayName })
	end

	state.pendingDuckBoxCandidates = candidates

	sendNotice(player, {
		kind = RemoteProtocol.notices.mysteryDuckBoxOpened,
		candidates = candidates,
	})
end

local function pickDuckBoxCandidate(player: Player, state: PlayerState, payload: any)
	local candidates = state.pendingDuckBoxCandidates

	if not candidates then
		return
	end

	local candidateIndex: number? = nil

	if typeof(payload) == "table" then
		local pt = payload :: {[string]: any}

		if typeof(pt.candidateIndex) == "number" then
			candidateIndex = pt.candidateIndex
		end
	end

	if
		not candidateIndex
		or not isFiniteNumber(candidateIndex)
		or candidateIndex % 1 ~= 0
		or candidateIndex < 1
		or candidateIndex > #candidates
	then
		return
	end

	local chosen = candidates[candidateIndex]

	state.pendingDuckBoxCandidates = nil
	grantDuckWithFamily(state, chosen.family, chosen.rarity)

	queueNotice(state, {
		kind = RemoteProtocol.notices.duckBoxCandidatePicked,
		family = chosen.family,
		rarity = chosen.rarity,
		displayName = chosen.displayName,
	})
end

local function pickStarterChoice(player: Player, state: PlayerState, payload: any)
	if state.starterChoiceCompleted then
		return
	end

	local familyId: string? = nil

	if typeof(payload) == "table" then
		local pt = payload :: {[string]: any}

		if typeof(pt.familyId) == "string" then
			familyId = pt.familyId
		end
	end

	if not familyId then
		return
	end

	local isValidChoice = false

	for _, allowedFamily in PrototypeConfig.starterChoiceFamilies do
		if allowedFamily == familyId then
			isValidChoice = true
			break
		end
	end

	if not isValidChoice then
		return
	end

	local rarity = "common"

	for _, familyDef in PrototypeConfig.families do
		if familyDef.id == familyId then
			rarity = familyDef.rarity
			break
		end
	end

	state.starterChoiceCompleted = true
	grantDuckWithFamily(state, familyId, rarity)
end

-- ── Phase 6: Hatching ─────────────────────────────────────────────────────────────────────
local RARITY_RANK: {[string]: number} = {
	common = 1,
	uncommon = 2,
	rare = 3,
	epic = 4,
	legendary = 5,
}

local function rarityAtLeast(rarity: string, floor: string): boolean
	return (RARITY_RANK[rarity] or 0) >= (RARITY_RANK[floor] or 0)
end

local function getEggDefinition(eggType: string): {[string]: any}?
	for _, eggDef in PrototypeConfig.eggTypes do
		if eggDef.id == eggType then
			return eggDef
		end
	end

	return nil
end

-- Weighted roll over the egg's odds table, iterated in fixed rarity-rank order so the result
-- is deterministic given the random draw. Odds for an egg must sum to 100.
local function rollEggRarity(eggDef: {[string]: any}): string
	local roll = math.random(1, 100)
	local cumulative = 0
	local lastDefined = "common"

	for _, rarity in { "common", "uncommon", "rare", "epic", "legendary" } do
		local chance = eggDef.odds[rarity]

		if typeof(chance) == "number" and chance > 0 then
			lastDefined = rarity
			cumulative += chance

			if roll <= cumulative then
				return rarity
			end
		end
	end

	-- Rounding slack: if the draw exceeds the summed odds, award the highest defined tier.
	return lastDefined
end

-- Resolves the hatch rarity including pity: a pity egg that has gone pityThreshold hatches
-- without reaching pityFloor is forced to the floor. The counter resets whenever a hatch meets
-- the floor (rolled or forced). Mutates state.hatchPity for the egg type.
local function resolveHatchRarity(state: PlayerState, eggDef: {[string]: any}): string
	local rarity = rollEggRarity(eggDef)

	if eggDef.pityThreshold == nil or eggDef.pityFloor == nil then
		return rarity
	end

	local pityKey = eggDef.id

	if rarityAtLeast(rarity, eggDef.pityFloor) then
		state.hatchPity[pityKey] = 0
		return rarity
	end

	local nextPity = (state.hatchPity[pityKey] or 0) + 1

	if nextPity >= eggDef.pityThreshold then
		state.hatchPity[pityKey] = 0
		return eggDef.pityFloor
	end

	state.hatchPity[pityKey] = nextPity
	return rarity
end

local function buyEgg(state: PlayerState, payload: any)
	if typeof(payload) ~= "table" then
		return
	end

	local eggType = (payload :: {[string]: any}).eggType

	if typeof(eggType) ~= "string" then
		return
	end

	local eggDef = getEggDefinition(eggType)

	if not eggDef or eggDef.buyCost <= 0 or state.coins < eggDef.buyCost then
		return
	end

	state.coins -= eggDef.buyCost
	queueEconomyEvent(state, "sink", eggDef.buyCost, "Shop", "egg_" .. eggDef.id)
	state.eggInventory[eggDef.id] = (state.eggInventory[eggDef.id] or 0) + 1
	markSaveDirty(state)
end

local function startIncubation(state: PlayerState, payload: any)
	if typeof(payload) ~= "table" then
		return
	end

	local eggType = (payload :: {[string]: any}).eggType

	if typeof(eggType) ~= "string" then
		return
	end

	local eggDef = getEggDefinition(eggType)

	if not eggDef then
		return
	end

	if (state.eggInventory[eggDef.id] or 0) <= 0 then
		return
	end

	if #state.incubatorSlots >= PrototypeConfig.incubator.slotCount then
		return
	end

	state.eggInventory[eggDef.id] -= 1
	table.insert(state.incubatorSlots, {
		eggType = eggDef.id,
		finishUtc = os.time() + eggDef.hatchSeconds,
	})
	markSaveDirty(state)
end

local function collectHatch(player: Player, state: PlayerState, payload: any)
	if typeof(payload) ~= "table" then
		return
	end

	local slotIndex = (payload :: {[string]: any}).slotIndex

	if typeof(slotIndex) ~= "number" or slotIndex % 1 ~= 0 then
		return
	end

	local slot = state.incubatorSlots[slotIndex]

	if not slot then
		return
	end

	if os.time() < slot.finishUtc then
		return
	end

	local eggDef = getEggDefinition(slot.eggType)

	if not eggDef then
		-- Unknown egg type (e.g. removed from config): drop the slot rather than stranding it.
		table.remove(state.incubatorSlots, slotIndex)
		markSaveDirty(state)
		return
	end

	local rarity = resolveHatchRarity(state, eggDef)
	local familyId = pickFamilyForRarity(rarity)
	local displayName = familyId

	for _, familyDef in PrototypeConfig.families do
		if familyDef.id == familyId then
			displayName = familyDef.displayName
			break
		end
	end

	table.remove(state.incubatorSlots, slotIndex)
	grantDuckWithFamily(state, familyId, rarity)
	markFunnelMilestone(state, "funnel_first_hatch")
	markSaveDirty(state)

	queueNotice(state, {
		kind = RemoteProtocol.notices.eggHatched,
		eggType = eggDef.id,
		family = familyId,
		rarity = rarity,
		displayName = displayName,
	})
end

local function claimDailyCheckIn(player: Player, state: PlayerState)
	local checkInConfig = PrototypeConfig.dailyCheckIn
	local currentDay = math.floor(os.time() / 86400)

	if currentDay <= state.lastDailyClaimDay then
		queueNotice(state, {
			kind = RemoteProtocol.notices.dailyCheckInRejected,
			message = "Daily already claimed",
		})
		return
	end

	-- Cozy streak rule: claiming the next day advances the streak, missing up to
	-- pauseGraceDays only pauses it in place, and longer absences restart at day 1.
	local gapDays = currentDay - state.lastDailyClaimDay
	local nextStreakDay = 1

	if
		state.streakDay > 0
		and state.lastDailyClaimDay > 0
		and gapDays <= 1 + checkInConfig.pauseGraceDays
	then
		nextStreakDay = (state.streakDay % 7) + 1
	end

	local rewardCoins = checkInConfig.streakRewards[nextStreakDay] or checkInConfig.rewardCoins
	local rewardTreat = if nextStreakDay >= 7 then checkInConfig.day7TreatAmount else 0
	local duckTreatId = PrototypeConfig.shop.duckTreat.id

	state.coins += rewardCoins
	queueEconomyEvent(state, "source", rewardCoins, "TimedReward", "daily_checkin")

	if rewardTreat > 0 then
		state.inventory[duckTreatId] = (state.inventory[duckTreatId] or 0) + rewardTreat
	end

	state.lastDailyClaimDay = currentDay
	state.streakDay = nextStreakDay
	markSaveDirty(state)

	queueNotice(state, {
		kind = RemoteProtocol.notices.dailyCheckInClaimed,
		rewardCoins = rewardCoins,
		rewardTreat = rewardTreat,
		streakDay = nextStreakDay,
	})
end

local function runTesterAction(player: Player, state: PlayerState, actionName: string)
	if not RunService:IsStudio() then
		return
	end

	if actionName == RemoteProtocol.actions.testAddCoins then
		state.coins += TESTER_COIN_GRANT
		markSaveDirty(state)
	elseif actionName == RemoteProtocol.actions.testReadyEggs then
		state.availableEggs += TESTER_READY_EGG_GRANT
		markSaveDirty(state)
	elseif actionName == RemoteProtocol.actions.testAddDuck then
		for _ = 1, PrototypeConfig.duckPurchase.duckIncrease do
			addDuck(state)
		end

		markSaveDirty(state)
	elseif
		actionName == RemoteProtocol.actions.testCareRequest
		or actionName == RemoteProtocol.actions.testHungryRequest
		or actionName == RemoteProtocol.actions.testSleepyRequest
		or actionName == RemoteProtocol.actions.testDirtyRequest
		or actionName == RemoteProtocol.actions.testThirstyRequest
		or actionName == RemoteProtocol.actions.testBoredRequest
	then
		local now = os.clock()

		for _, duck in state.ducks do
			duck.careUntil = 0
			duck.lastCareAt = now - PrototypeConfig.duckCare.cooldownSeconds - 1
		end

		local requestKind = if actionName == RemoteProtocol.actions.testHungryRequest
			then HUNGRY_REQUEST_KIND
			elseif actionName == RemoteProtocol.actions.testSleepyRequest then SLEEPY_REQUEST_KIND
			elseif actionName == RemoteProtocol.actions.testDirtyRequest then DIRTY_REQUEST_KIND
			elseif actionName == RemoteProtocol.actions.testThirstyRequest then THIRSTY_REQUEST_KIND
			elseif actionName == RemoteProtocol.actions.testBoredRequest then BORED_REQUEST_KIND
			else PET_REQUEST_KIND

		assignCareRequest(state, now, requestKind)
	elseif actionName == RemoteProtocol.actions.testToggleWeather then
		toggleWeather(state)
	elseif actionName == RemoteProtocol.actions.testReset then
		state = createPlayerState()
		state.isLoaded = true
		setSaveStatus(state, SAVE_STATUS_PENDING)
		markSaveDirty(state)
		statesByPlayer[player] = state
	end

	sendState(player, state)
end

local function onAction(player: Player, actionName: any, payload: any?)
	local state = statesByPlayer[player]

	if not state or typeof(actionName) ~= "string" or not validActions[actionName] then
		return
	end

	state.clientReady = true

	if actionName == RemoteProtocol.actions.requestState then
		sendState(player, state)
		return
	end

	if not state.isLoaded then
		sendState(player, state)
		return
	end

	if isRateLimited(state, actionName) then
		return
	end

	if actionName == RemoteProtocol.actions.visitFarm then
		if getFeatureUnlocks(state).visit then
			visitFarm(player, payload)
		end

		sendState(player, state)
		return
	elseif actionName == RemoteProtocol.actions.returnHomeFarm then
		returnHomeFarm(player)
		sendState(player, state)
		return
	elseif actionName == RemoteProtocol.actions.visitorHelpDuck then
		visitorHelpDuck(player, payload)
		sendState(player, state)
		return
	end

	if farmViewTargetsByPlayer[player] ~= nil then
		sendState(player, state)
		return
	end

	if testerActions[actionName] then
		runTesterAction(player, state, actionName)
		return
	end

	produceEggs(state)
	updateWeather(state)
	updateCareRequest(state)

	-- Ladder-locked features reject their actions server-side; hidden buttons are not the trust boundary.
	local featureUnlocks = getFeatureUnlocks(state)

	if
		(actionName == RemoteProtocol.actions.buyShopItem and not featureUnlocks.shop)
		or (actionName == RemoteProtocol.actions.buyEggValueUpgrade and not featureUnlocks.upgrades)
		or (
			(actionName == RemoteProtocol.actions.startEggCatchRound or actionName == RemoteProtocol.actions.claimEggCatchReward)
			and not featureUnlocks.minigames
		)
	then
		sendState(player, state)
		return
	end

	local badgeConfig = PrototypeConfig.badges

	if actionName == RemoteProtocol.actions.collectEggs then
		local beforeEggs = state.eggs
		collectEggs(state)
		local gained = state.eggs - beforeEggs
		if gained > 0 then
			local total = (sessionEggsCollectedByPlayer[player] or 0) + gained
			sessionEggsCollectedByPlayer[player] = total
			if total >= 100 then
				tryAwardBadge(player, badgeConfig.eggsCollected100)
			end
		end
	elseif actionName == RemoteProtocol.actions.sellEggs then
		sellEggs(state)
	elseif actionName == RemoteProtocol.actions.buyEggValueUpgrade then
		buyEggValueUpgrade(state)
	elseif actionName == RemoteProtocol.actions.buyDuck then
		buyDuck(state, payload)
		if #state.ducks >= 2 then
			tryAwardBadge(player, badgeConfig.firstDuck)
		end
	elseif actionName == RemoteProtocol.actions.buyShopItem then
		buyShopItem(state, payload)
	elseif actionName == RemoteProtocol.actions.useTreatOnDuck then
		useTreatOnDuck(state, payload)
		if hasDuckAtLevel(state, 5) then
			tryAwardBadge(player, badgeConfig.level5Duck)
		end
	elseif actionName == RemoteProtocol.actions.careForDucks then
		careForDuck(state, payload)
		if hasDuckAtLevel(state, 5) then
			tryAwardBadge(player, badgeConfig.level5Duck)
		end
	elseif actionName == RemoteProtocol.actions.renameDuck then
		local renameOk = renameDuck(player, state, payload)
		if renameOk then
			tryAwardBadge(player, badgeConfig.firstRename)
		end
	elseif actionName == RemoteProtocol.actions.toggleVisitorHelp then
		toggleVisitorHelp(player, state)
		return
	elseif actionName == RemoteProtocol.actions.startEggCatchRound then
		local sessionId = startEggCatchRound(state)
		sendNotice(player, {
			kind = RemoteProtocol.notices.eggCatchStarted,
			sessionId = sessionId,
		})
	elseif actionName == RemoteProtocol.actions.claimEggCatchReward then
		claimEggCatchReward(player, state, payload)
	elseif actionName == RemoteProtocol.actions.claimDailyCheckIn then
		claimDailyCheckIn(player, state)
		if state.streakDay == 7 then
			tryAwardBadge(player, badgeConfig.streak7)
		end
	elseif actionName == RemoteProtocol.actions.openMysteryDuckBox then
		openMysteryDuckBox(player, state)
	elseif actionName == RemoteProtocol.actions.pickDuckBoxCandidate then
		pickDuckBoxCandidate(player, state, payload)
	elseif actionName == RemoteProtocol.actions.pickStarterChoice then
		pickStarterChoice(player, state, payload)
	elseif actionName == RemoteProtocol.actions.claimCollectionReward then
		checkCollectionMilestones(state)
	elseif actionName == RemoteProtocol.actions.buyEgg then
		buyEgg(state, payload)
	elseif actionName == RemoteProtocol.actions.startIncubation then
		startIncubation(state, payload)
	elseif actionName == RemoteProtocol.actions.collectHatch then
		collectHatch(player, state, payload)
	end

	sendState(player, state)
end

local function onPlayerAdded(player: Player)
	sessionEggsCollectedByPlayer[player] = 0
	local state = createPlayerState()
	local saveEntry = {
		userId = player.UserId,
		playerName = player.Name,
		state = state,
	}

	statesByPlayer[player] = state
	recentSaveEntriesByUserId[player.UserId] = saveEntry
	sendState(player, state)

	local loadSuccess, savedData, errorMessage = PlayerDataService.loadPlayer(player)

	if statesByPlayer[player] ~= state then
		return
	end

	if savedData then
		applySavedData(state, savedData)
		state.saveDirty = false
		state.isFreshProfile = false
		setSaveStatus(state, SAVE_STATUS_SAVED)

		if state.pendingOfflineEggs > 0 or state.pendingComebackGift then
			markSaveDirty(state)
			state.pendingComebackGift = false
		end
	elseif loadSuccess then
		markSaveDirty(state)
		state.isFreshProfile = true
		state.freshProfileNeedsHungryFollowUp = true
		state.freshProfileHungryHandled = false
		state.pendingForcedCareRequestKind = ""
		setSaveStatus(state, SAVE_STATUS_PENDING)
	else
		state.saveDirty = false
		state.isFreshProfile = false
		state.freshProfileNeedsHungryFollowUp = false
		state.freshProfileHungryHandled = false
		state.pendingForcedCareRequestKind = ""
		setSaveStatus(state, SAVE_STATUS_FAILED, getStudioSaveFailureText(errorMessage))
		sendState(player, state)
		return
	end

	state.isLoaded = true

	if state.pendingOfflineEggs > 0 then
		queueNotice(state, {
			kind = RemoteProtocol.notices.offlineProgress,
			eggs = state.pendingOfflineEggs,
			awaySeconds = state.pendingOfflineSeconds,
		})
		state.pendingOfflineEggs = 0
		state.pendingOfflineSeconds = 0
	end

	local currentDay = math.floor(os.time() / 86400)

	if currentDay > state.lastDailyClaimDay then
		claimDailyCheckIn(player, state)
		if state.streakDay == 7 then
			tryAwardBadge(player, PrototypeConfig.badges.streak7)
		end
	end

	-- Queue Starter Choice for any profile that hasn't chosen yet (fresh or post-Phase-5 migration).
	-- Fresh profiles receive this notice and the client shows it after guide completion.
	-- Existing profiles show it immediately on receipt.
	if not state.starterChoiceCompleted then
		queueNotice(state, {
			kind = RemoteProtocol.notices.pendingStarterChoice,
			options = PrototypeConfig.starterChoiceFamilies,
		})
	end

	-- Auto-grant any collection milestones already met (e.g. after migration fills in family data).
	checkCollectionMilestones(state)

	sendState(player, state)
end

local function onPlayerRemoving(player: Player)
	local state = statesByPlayer[player]

	if state and state.isLoaded then
		local saveEntry = {
			userId = player.UserId,
			playerName = player.Name,
			state = state,
		}

		recentSaveEntriesByUserId[player.UserId] = saveEntry
		produceEggs(state)
		waitForActiveSave(state)

		if state.saveDirty and not state.saveInProgress then
			print(string.format("[Duck] Saving data for %s on leave.", player.Name))
			savePlayerState(player, state, "Saving")
		end

		task.delay(60, function()
			if recentSaveEntriesByUserId[player.UserId] == saveEntry then
				recentSaveEntriesByUserId[player.UserId] = nil
			end
		end)
	end

	statesByPlayer[player] = nil
	farmViewTargetsByPlayer[player] = nil
	sessionEggsCollectedByPlayer[player] = nil

	for viewer, targetPlayer in farmViewTargetsByPlayer do
		if targetPlayer == player then
			farmViewTargetsByPlayer[viewer] = nil
		end
	end
end

local function startProductionLoop()
	task.spawn(function()
		while started do
			for player, state in statesByPlayer do
				if state.isLoaded then
					produceEggs(state)
					updateWeather(state)
					updateCareRequest(state)

					if
						state.saveDirty
						and not state.saveInProgress
						and state.nextAutosaveAt > 0
						and os.clock() >= state.nextAutosaveAt
					then
						requestSavePlayerState(player, state, "Autosaving")
					end
				end

				sendState(player, state)
			end

			task.wait(UPDATE_INTERVAL_SECONDS)
		end
	end)
end

local function bindShutdownSave()
	game:BindToClose(function()
		local entriesToSave: {[number]: SaveEntry} = {}

		for player, state in statesByPlayer do
			if state.isLoaded then
				entriesToSave[player.UserId] = {
					userId = player.UserId,
					playerName = player.Name,
					state = state,
				}
			end
		end

		for userId, entry in recentSaveEntriesByUserId do
			if entry.state.isLoaded then
				entriesToSave[userId] = entry
			end
		end

		for _, entry in entriesToSave do
			produceEggs(entry.state)
			waitForActiveSave(entry.state)

			if entry.state.saveDirty and not entry.state.saveInProgress then
				print(string.format("[Duck] Saving data for %s during shutdown.", entry.playerName))
				saveEntryState(entry, "Saving")
			end
		end
	end)
end

function PlayerStateService.start()
	if started then
		return
	end

	started = true

	local remoteFolder = getOrCreateRemoteFolder()
	actionEvent = getOrCreateRemoteEvent(remoteFolder, RemoteProtocol.actionEventName)
	stateEvent = getOrCreateRemoteEvent(remoteFolder, RemoteProtocol.stateEventName)
	noticeEvent = getOrCreateRemoteEvent(remoteFolder, RemoteProtocol.noticeEventName)

	actionEvent.OnServerEvent:Connect(onAction)
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end

	startProductionLoop()
	bindShutdownSave()
end

return PlayerStateService
