--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PrototypeConfig = require(Shared:WaitForChild("PrototypeConfig"))
local RemoteProtocol = require(Shared:WaitForChild("RemoteProtocol"))

type DuckState = {
	id: number,
	name: string,
	level: number,
	xp: number,
	careUntil: number,
	lastCareAt: number,
	hasCareRequest: boolean,
	careRequestKind: string,
}

type PlayerState = {
	eggs: number,
	coins: number,
	availableEggs: number,
	inventory: {[string]: number},
	ducks: {DuckState},
	nextDuckId: number,
	eggSellValue: number,
	eggValueLevel: number,
	nextCareRequestAt: number,
	nextEggAt: number,
	lastActionAt: {[string]: number},
	renameError: string,
	renameErrorDuckIndex: number,
}

local PlayerStateService = {}

local ACTION_COOLDOWN_SECONDS = 0.15
local EGG_VALUE_MAX_LEVEL = 1
local UPDATE_INTERVAL_SECONDS = 1
local TESTER_COIN_GRANT = 100
local TESTER_READY_EGG_GRANT = 10
local PET_REQUEST_KIND = PrototypeConfig.duckCare.requestKinds.pet.id
local HUNGRY_REQUEST_KIND = PrototypeConfig.duckCare.requestKinds.hungry.id

local started = false
local statesByPlayer: {[Player]: PlayerState} = {}
local actionEvent: RemoteEvent
local stateEvent: RemoteEvent

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

local function getDuckCount(state: PlayerState): number
	return #state.ducks
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

local function addDuck(state: PlayerState)
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
	})
	state.nextDuckId += 1
end

local function getEggValueUpgradeCost(state: PlayerState): number
	if state.eggValueLevel >= EGG_VALUE_MAX_LEVEL then
		return 0
	end

	return PrototypeConfig.firstUpgrade.firstCost
end

local function getDuckPurchaseCost(state: PlayerState): number
	return PrototypeConfig.duckPurchase.baseCost * math.max(1, getDuckCount(state))
end

local function getDuckFeedCount(state: PlayerState): number
	return state.inventory[PrototypeConfig.shop.duckFeed.id] or 0
end

local function getVisibleCareDuckCount(state: PlayerState): number
	return math.min(getDuckCount(state), PrototypeConfig.duckCare.requestVisibleDuckCap)
end

local function scheduleNextCareRequest(state: PlayerState, now: number)
	state.nextCareRequestAt = now + PrototypeConfig.duckCare.requestIntervalSeconds
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
	end

	return PrototypeConfig.duckCare.requestKinds.pet
end

local function chooseCareRequestKind(): string
	if math.random() <= PrototypeConfig.duckCare.hungryRequestChance then
		return HUNGRY_REQUEST_KIND
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

	if not duckIndex or duckIndex % 1 ~= 0 or duckIndex < 1 or duckIndex > getDuckCount(state) then
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

local function addDuckXp(duck: DuckState, amount: number)
	local levelConfig = PrototypeConfig.duckLevel

	if amount <= 0 then
		return
	end

	if duck.level >= levelConfig.maxLevel then
		duck.level = levelConfig.maxLevel
		duck.xp = 0
		return
	end

	duck.xp += amount

	while duck.xp >= levelConfig.xpPerLevel and duck.level < levelConfig.maxLevel do
		duck.xp -= levelConfig.xpPerLevel
		duck.level += 1
	end

	if duck.level >= levelConfig.maxLevel then
		duck.level = levelConfig.maxLevel
		duck.xp = 0
	end
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
	state.ducks[requestDuckIndex].hasCareRequest = true
	state.ducks[requestDuckIndex].careRequestKind = forcedKind or chooseCareRequestKind()
	scheduleNextCareRequest(state, now)
end

local function createPlayerState(): PlayerState
	local now = os.clock()
	local state: PlayerState = {
		eggs = PrototypeConfig.startingEggs,
		coins = PrototypeConfig.startingCoins,
		availableEggs = 0,
		inventory = {},
		ducks = {},
		nextDuckId = 1,
		eggSellValue = PrototypeConfig.eggSellValue,
		eggValueLevel = PrototypeConfig.firstUpgrade.startingLevel,
		nextCareRequestAt = now + PrototypeConfig.duckCare.firstRequestDelaySeconds,
		nextEggAt = now + PrototypeConfig.eggProductionIntervalSeconds,
		lastActionAt = {},
		renameError = "",
		renameErrorDuckIndex = 0,
	}

	for _ = 1, PrototypeConfig.startingDucks do
		addDuck(state)
	end

	return state
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
			then (if requestKind == HUNGRY_REQUEST_KIND then "This duck is hungry" else "This duck wants care")
			elseif isCaredFor then "This duck feels cared for"
			else "This duck is relaxed",
		careCooldownSeconds = careCooldownSeconds,
		hasCareRequest = duck.hasCareRequest,
		careRequestKind = requestKind,
		careRequestText = if duck.hasCareRequest then requestDefinition.requestText else "",
		canCare = careCooldownSeconds <= 0,
	}
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

	if careRequestDuckIndex > 0 and careRequestKind == HUNGRY_REQUEST_KIND and duckFeedCount <= 0 then
		canCareForDucks = false
	end

	return {
		eggs = state.eggs,
		coins = state.coins,
		availableEggs = state.availableEggs,
		duckFeed = duckFeedCount,
		duckCount = duckCount,
		ducks = ducks,
		eggSellValue = state.eggSellValue,
		eggValueLevel = state.eggValueLevel,
		eggValueMaxLevel = EGG_VALUE_MAX_LEVEL,
		eggValueUpgradeCost = upgradeCost,
		duckPurchaseCost = duckPurchaseCost,
		duckMood = if hasCaredDuck then PrototypeConfig.duckCare.caredMood else PrototypeConfig.duckCare.defaultMood,
		duckMoodDetail = if careRequestDuckIndex > 0
			then (if careRequestKind == HUNGRY_REQUEST_KIND then "A duck is hungry" else "A duck wants care")
			elseif hasCaredDuck then "Some ducks feel cared for"
			else "Ducks are relaxed",
		careRequestDuckIndex = careRequestDuckIndex,
		careRequestKind = careRequestKind,
		careRequestText = if careRequestDuckIndex > 0 then careRequestDefinition.requestText else "",
		careCooldownSeconds = shortestCooldown,
		secondsUntilNextEgg = math.max(0, math.ceil(state.nextEggAt - now)),
		canBuyEggValueUpgrade = upgradeCost > 0 and state.coins >= upgradeCost,
		canBuyDuck = state.coins >= duckPurchaseCost,
		duckFeedCost = duckFeed.cost,
		canBuyDuckFeed = state.coins >= duckFeed.cost,
		canCareForDucks = canCareForDucks,
		renameError = state.renameError,
		renameErrorDuckIndex = state.renameErrorDuckIndex,
	}
end

local function sendState(player: Player, state: PlayerState)
	stateEvent:FireClient(player, serializeState(state))
end

local function produceEggs(state: PlayerState)
	local interval = PrototypeConfig.eggProductionIntervalSeconds
	local now = os.clock()

	if now < state.nextEggAt then
		return
	end

	local cycles = math.floor((now - state.nextEggAt) / interval) + 1
	state.availableEggs += cycles * getDuckCount(state)
	state.nextEggAt += cycles * interval
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

	state.eggs += state.availableEggs
	state.availableEggs = 0
end

local function sellEggs(state: PlayerState)
	if state.eggs <= 0 then
		return
	end

	state.coins += state.eggs * state.eggSellValue
	state.eggs = 0
end

local function buyEggValueUpgrade(state: PlayerState)
	local upgradeCost = getEggValueUpgradeCost(state)

	if upgradeCost <= 0 or state.coins < upgradeCost then
		return
	end

	state.coins -= upgradeCost
	state.eggValueLevel += 1
	state.eggSellValue += PrototypeConfig.firstUpgrade.valueIncrease
end

local function buyDuck(state: PlayerState)
	local duckPurchase = PrototypeConfig.duckPurchase
	local duckPurchaseCost = getDuckPurchaseCost(state)

	if duckPurchaseCost <= 0 or state.coins < duckPurchaseCost then
		return
	end

	state.coins -= duckPurchaseCost

	for _ = 1, duckPurchase.duckIncrease do
		addDuck(state)
	end
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

	if itemId ~= duckFeed.id or duckFeed.cost <= 0 or state.coins < duckFeed.cost then
		return
	end

	state.coins -= duckFeed.cost
	state.inventory[duckFeed.id] = getDuckFeedCount(state) + duckFeed.purchaseAmount
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
		xpAmount = PrototypeConfig.duckLevel.xpPerFeed

		if duckFeedCount <= 0 then
			return
		end

		state.inventory[duckFeed.id] = duckFeedCount - 1
	end

	addDuckXp(duck, xpAmount)
	duck.hasCareRequest = false
	duck.careRequestKind = ""
	duck.lastCareAt = now
	duck.careUntil = now + PrototypeConfig.duckCare.careDurationSeconds
	scheduleNextCareRequest(state, now)
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

local function renameDuck(player: Player, state: PlayerState, payload: any)
	local payloadDuckIndex, requestedName = getRenamePayload(payload)

	if not payloadDuckIndex or not requestedName then
		setRenameError(state, 0, "Invalid name")
		return
	end

	local duck, duckIndex = getDuckByPayloadIndex(state, payloadDuckIndex)

	if not duck then
		setRenameError(state, 0, "Duck not found")
		return
	end

	local trimmedName = trimText(requestedName)
	local renameConfig = PrototypeConfig.duckRename
	local nameLength = getTextLength(trimmedName)

	if nameLength < renameConfig.minLength then
		setRenameError(state, duckIndex, "Name is too short")
		return
	end

	if nameLength > renameConfig.maxLength then
		setRenameError(state, duckIndex, "Name is too long")
		return
	end

	if isDuckNameUsed(state, trimmedName, duck) then
		setRenameError(state, duckIndex, "Name already used")
		return
	end

	local filteredName, filterError = filterDuckName(player, trimmedName)

	if not filteredName then
		setRenameError(state, duckIndex, filterError or "Try another name")
		return
	end

	if getTextLength(filteredName) > renameConfig.maxLength then
		setRenameError(state, duckIndex, "Name is too long")
		return
	end

	if isDuckNameUsed(state, filteredName, duck) then
		setRenameError(state, duckIndex, "Name already used")
		return
	end

	duck.name = filteredName
	state.renameError = ""
	state.renameErrorDuckIndex = 0
end

local function runTesterAction(player: Player, state: PlayerState, actionName: string)
	if not RunService:IsStudio() then
		return
	end

	if actionName == RemoteProtocol.actions.testAddCoins then
		state.coins += TESTER_COIN_GRANT
	elseif actionName == RemoteProtocol.actions.testReadyEggs then
		state.availableEggs += TESTER_READY_EGG_GRANT
	elseif actionName == RemoteProtocol.actions.testAddDuck then
		for _ = 1, PrototypeConfig.duckPurchase.duckIncrease do
			addDuck(state)
		end
	elseif actionName == RemoteProtocol.actions.testCareRequest or actionName == RemoteProtocol.actions.testHungryRequest then
		local now = os.clock()

		for _, duck in state.ducks do
			duck.careUntil = 0
			duck.lastCareAt = now - PrototypeConfig.duckCare.cooldownSeconds - 1
		end

		local requestKind = if actionName == RemoteProtocol.actions.testHungryRequest then HUNGRY_REQUEST_KIND else PET_REQUEST_KIND

		assignCareRequest(state, now, requestKind)
	elseif actionName == RemoteProtocol.actions.testReset then
		state = createPlayerState()
		statesByPlayer[player] = state
	end

	sendState(player, state)
end

local function onAction(player: Player, actionName: any, payload: any?)
	local state = statesByPlayer[player]

	if not state or typeof(actionName) ~= "string" or not validActions[actionName] then
		return
	end

	if isRateLimited(state, actionName) then
		return
	end

	if testerActions[actionName] then
		runTesterAction(player, state, actionName)
		return
	end

	produceEggs(state)
	updateCareRequest(state)

	if actionName == RemoteProtocol.actions.collectEggs then
		collectEggs(state)
	elseif actionName == RemoteProtocol.actions.sellEggs then
		sellEggs(state)
	elseif actionName == RemoteProtocol.actions.buyEggValueUpgrade then
		buyEggValueUpgrade(state)
	elseif actionName == RemoteProtocol.actions.buyDuck then
		buyDuck(state)
	elseif actionName == RemoteProtocol.actions.buyShopItem then
		buyShopItem(state, payload)
	elseif actionName == RemoteProtocol.actions.careForDucks then
		careForDuck(state, payload)
	elseif actionName == RemoteProtocol.actions.renameDuck then
		renameDuck(player, state, payload)
	end

	sendState(player, state)
end

local function onPlayerAdded(player: Player)
	local state = createPlayerState()
	statesByPlayer[player] = state
	sendState(player, state)
end

local function onPlayerRemoving(player: Player)
	statesByPlayer[player] = nil
end

local function startProductionLoop()
	task.spawn(function()
		while started do
			for player, state in statesByPlayer do
				produceEggs(state)
				updateCareRequest(state)
				sendState(player, state)
			end

			task.wait(UPDATE_INTERVAL_SECONDS)
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

	actionEvent.OnServerEvent:Connect(onAction)
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end

	startProductionLoop()
end

return PlayerStateService
