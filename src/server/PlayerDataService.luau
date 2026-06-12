--!strict

local DataStoreService = game:GetService("DataStoreService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local PrototypeConfig = require(Shared:WaitForChild("PrototypeConfig"))

export type SavedQuestData = {
	level: number,
	progress: number,
}

export type SavedDuckData = {
	id: number,
	name: string,
	level: number,
	xp: number,
}

export type SavedDailyQuests = {
	dayStamp: number,
	progress: {number},
	bonusGranted: boolean,
}

export type SavedPlayerData = {
	schemaVersion: number,
	coins: number,
	eggs: number,
	duckFeed: number,
	premiumFeed: number,
	duckTreat: number,
	pillow: number,
	toy: number,
	availableEggs: number,
	eggValueLevel: number,
	nextDuckId: number,
	ducks: {SavedDuckData},
	quests: {[string]: SavedQuestData},
	lastDailyClaimDay: number,
	lastSeenUtc: number,
	streakDay: number,
	dailyQuests: SavedDailyQuests,
	unlockLadder: boolean,
}

local PlayerDataService = {}

local STORE_NAME = "DuckPlayerDataV1"
local SCHEMA_VERSION = 10

local playerStore = DataStoreService:GetDataStore(STORE_NAME)

local function getPlayerKey(userId: number): string
	return "player_" .. tostring(userId)
end

local function countSavedDucks(data: SavedPlayerData?): number
	if not data then
		return 0
	end

	return #data.ducks
end

local function countSavedQuestLevels(data: SavedPlayerData?): number
	if not data then
		return 0
	end

	local totalLevels = 0

	for _, quest in data.quests do
		totalLevels += quest.level
	end

	return totalLevels
end

local function trimText(text: string): string
	return text:match("^%s*(.-)%s*$") or ""
end

local function normalizeText(text: string): string
	return string.lower(text)
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

local function readInteger(value: any, fallback: number, minimum: number, maximum: number?): number
	if typeof(value) ~= "number" or not isFiniteNumber(value) then
		return fallback
	end

	local integer = math.floor(value)
	integer = math.max(minimum, integer)

	if maximum then
		integer = math.min(maximum, integer)
	end

	return integer
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

local function getQuestTarget(questDefinition: {[string]: any}, level: number): number
	return math.max(1, questDefinition.baseTarget * level)
end

local function sanitizeQuests(rawQuests: any): {[string]: SavedQuestData}
	local quests = {}
	local rawQuestTable = if typeof(rawQuests) == "table" then rawQuests :: {[string]: any} else {}

	for _, questDefinition in getQuestDefinitions() do
		local rawQuest = rawQuestTable[questDefinition.id]
		local rawQuestData = if typeof(rawQuest) == "table" then rawQuest :: {[string]: any} else {}
		local level = readInteger(rawQuestData.level, 1, 1, nil)
		local target = getQuestTarget(questDefinition, level)
		local progress = readInteger(rawQuestData.progress, 0, 0, target - 1)

		quests[questDefinition.id] = {
			level = level,
			progress = progress,
		}
	end

	return quests
end

local function sanitizeDailyQuests(rawDailyQuests: any): SavedDailyQuests
	local rawTable = if typeof(rawDailyQuests) == "table" then rawDailyQuests :: {[string]: any} else {}
	local rawProgress = if typeof(rawTable.progress) == "table" then rawTable.progress :: {any} else {}
	local progress = {}

	for slotIndex = 1, PrototypeConfig.dailyQuests.questCount do
		progress[slotIndex] = readInteger(rawProgress[slotIndex], 0, 0, 100000)
	end

	-- A stale or forged dayStamp is harmless: any mismatch with the current UTC day resets the slots.
	return {
		dayStamp = readInteger(rawTable.dayStamp, 0, 0, nil),
		progress = progress,
		bonusGranted = rawTable.bonusGranted == true,
	}
end

local function getUniqueDuckName(rawName: any, duckId: number, usedNames: {[string]: boolean}): string
	local renameConfig = PrototypeConfig.duckRename
	local fallbackName = "Duck " .. tostring(duckId)
	local name = if typeof(rawName) == "string" then trimText(rawName) else fallbackName

	if name == ""
		or getTextLength(name) < renameConfig.minLength
		or getTextLength(name) > renameConfig.maxLength
		or string.find(name, "#")
	then
		name = fallbackName
	end

	if getTextLength(name) > renameConfig.maxLength then
		name = "Duck"
	end

	local candidate = name
	local suffix = 2

	while usedNames[normalizeText(candidate)] do
		candidate = "Duck " .. tostring(suffix)
		suffix += 1
	end

	usedNames[normalizeText(candidate)] = true
	return candidate
end

local function sanitizeDucks(rawDucks: any): ({SavedDuckData}, number)
	local ducks = {}
	local usedIds: {[number]: boolean} = {}
	local usedNames: {[string]: boolean} = {}
	local highestDuckId = 0

	if typeof(rawDucks) ~= "table" then
		return ducks, highestDuckId
	end

	for _, rawDuck in rawDucks do
		if typeof(rawDuck) == "table" then
			local rawDuckTable = rawDuck :: {[string]: any}
			local duckId = readInteger(rawDuckTable.id, highestDuckId + 1, 1, nil)

			while usedIds[duckId] do
				duckId += 1
			end

			usedIds[duckId] = true
			highestDuckId = math.max(highestDuckId, duckId)

			local level = readInteger(
				rawDuckTable.level,
				PrototypeConfig.duckLevel.startingLevel,
				PrototypeConfig.duckLevel.startingLevel,
				PrototypeConfig.duckLevel.maxLevel
			)
			local xp = readInteger(rawDuckTable.xp, PrototypeConfig.duckLevel.startingXp, 0, nil)

			if level >= PrototypeConfig.duckLevel.maxLevel then
				xp = 0
			else
				xp = math.min(xp, PrototypeConfig.duckLevel.xpPerLevel - 1)
			end

			table.insert(ducks, {
				id = duckId,
				name = getUniqueDuckName(rawDuckTable.name, duckId, usedNames),
				level = level,
				xp = xp,
			})
		end
	end

	return ducks, highestDuckId
end

function PlayerDataService.sanitize(rawData: any): SavedPlayerData?
	if typeof(rawData) ~= "table" then
		return nil
	end

	local rawTable = rawData :: {[string]: any}
	local ducks, highestDuckId = sanitizeDucks(rawTable.ducks)
	local nextDuckId = readInteger(rawTable.nextDuckId, highestDuckId + 1, highestDuckId + 1, nil)

	return {
		schemaVersion = SCHEMA_VERSION,
		coins = readInteger(rawTable.coins, PrototypeConfig.startingCoins, 0, nil),
		eggs = readInteger(rawTable.eggs, PrototypeConfig.startingEggs, 0, nil),
		duckFeed = readInteger(rawTable.duckFeed, 0, 0, nil),
		premiumFeed = readInteger(rawTable.premiumFeed, 0, 0, nil),
		duckTreat = readInteger(rawTable.duckTreat, 0, 0, nil),
		pillow = readInteger(rawTable.pillow, 0, 0, nil),
		toy = readInteger(rawTable.toy, 0, 0, nil),
		availableEggs = readInteger(rawTable.availableEggs, 0, 0, nil),
		eggValueLevel = readInteger(rawTable.eggValueLevel, PrototypeConfig.firstUpgrade.startingLevel, 0, PrototypeConfig.firstUpgrade.maxLevel),
		nextDuckId = nextDuckId,
		ducks = ducks,
		quests = sanitizeQuests(rawTable.quests),
		lastDailyClaimDay = readInteger(rawTable.lastDailyClaimDay, 0, 0, nil),
		-- Forged or future-dated timestamps clamp to now so offline elapsed time can never go negative or inflate.
		lastSeenUtc = readInteger(rawTable.lastSeenUtc, 0, 0, os.time()),
		streakDay = readInteger(rawTable.streakDay, 0, 0, 7),
		dailyQuests = sanitizeDailyQuests(rawTable.dailyQuests),
		-- Profiles saved before the Feature Unlock Ladder shipped stay fully unlocked.
		unlockLadder = rawTable.unlockLadder == true,
	}
end

function PlayerDataService.loadPlayer(player: Player): (boolean, SavedPlayerData?, string?)
	local success, result = pcall(function()
		return playerStore:GetAsync(getPlayerKey(player.UserId))
	end)

	if not success then
		local message = tostring(result)
		warn(string.format("[Duck] Failed to load save data for %s: %s", player.Name, message))
		return false, nil, message
	end

	local sanitizedData = PlayerDataService.sanitize(result)

	if sanitizedData then
		print(
			string.format(
				"[Duck] Loaded save data for %s: %d coins, %d eggs, %d ready, %d ducks, %d quest levels.",
				player.Name,
				sanitizedData.coins,
				sanitizedData.eggs,
				sanitizedData.availableEggs,
				countSavedDucks(sanitizedData),
				countSavedQuestLevels(sanitizedData)
			)
		)
	else
		print(string.format("[Duck] No save data found for %s; using a fresh profile.", player.Name))
	end

	return true, sanitizedData, nil
end

function PlayerDataService.savePlayerData(userId: number, playerName: string, data: SavedPlayerData): (boolean, string?)
	local sanitizedData = PlayerDataService.sanitize(data)

	if not sanitizedData then
		return false, "Invalid save data"
	end

	local success, result = pcall(function()
		playerStore:UpdateAsync(getPlayerKey(userId), function()
			return sanitizedData
		end)
	end)

	if not success then
		local message = tostring(result)
		warn(string.format("[Duck] Failed to save data for %s: %s", playerName, message))
		return false, message
	end

	print(
		string.format(
			"[Duck] Saved data for %s: %d coins, %d eggs, %d ready, %d ducks, %d quest levels.",
			playerName,
			sanitizedData.coins,
			sanitizedData.eggs,
			sanitizedData.availableEggs,
			countSavedDucks(sanitizedData),
			countSavedQuestLevels(sanitizedData)
		)
	)

	return true, nil
end

function PlayerDataService.savePlayer(player: Player, data: SavedPlayerData): (boolean, string?)
	return PlayerDataService.savePlayerData(player.UserId, player.Name, data)
end

function PlayerDataService.clearPlayer(player: Player): (boolean, string?)
	local success, result = pcall(function()
		playerStore:RemoveAsync(getPlayerKey(player.UserId))
	end)

	if not success then
		local message = tostring(result)
		warn(string.format("[Duck] Failed to clear save data for %s: %s", player.Name, message))
		return false, message
	end

	print(string.format("[Duck] Cleared save data for %s.", player.Name))

	return true, nil
end

return PlayerDataService

