--!strict

export type ResourceState = {
	eggs: number,
	coins: number,
}

export type DuckState = {
	id: number,
	index: number,
	name: string,
	level: number,
	xp: number,
	xpToNextLevel: number,
	mood: string,
	moodDetail: string,
	careCooldownSeconds: number,
	hasCareRequest: boolean,
	careRequestKind: string,
	careRequestText: string,
	canCare: boolean,
}

export type QuestState = {
	id: string,
	displayName: string,
	level: number,
	progress: number,
	target: number,
	rewardCoins: number,
	rewardDuckFeed: number,
	rewardDuckTreat: number,
	rewardPillow: number,
}

export type FarmVisitSummary = {
	userId: number,
	playerName: string,
	displayName: string,
	duckCount: number,
	isLoaded: boolean,
	visitorHelpEnabled: boolean,
}

export type FarmState = {
	eggs: number,
	coins: number,
	availableEggs: number,
	duckFeed: number,
	premiumFeed: number,
	duckTreat: number,
	pillow: number,
	toy: number,
	duckCount: number,
	ducks: {DuckState},
	eggSellValue: number,
	eggValueLevel: number,
	eggValueMaxLevel: number,
	eggValueUpgradeCost: number,
	duckPurchaseCost: number,
	duckFeedCost: number,
	premiumFeedCost: number,
	duckTreatCost: number,
	pillowCost: number,
	toyCost: number,
	duckMood: string,
	duckMoodDetail: string,
	careRequestDuckIndex: number,
	careRequestKind: string,
	careRequestText: string,
	careCooldownSeconds: number,
	secondsUntilNextEgg: number,
	canBuyEggValueUpgrade: boolean,
	canBuyDuck: boolean,
	canBuyDuckFeed: boolean,
	canBuyPremiumFeed: boolean,
	canBuyDuckTreat: boolean,
	canBuyPillow: boolean,
	canBuyToy: boolean,
	canClaimDailyCheckIn: boolean,
	streakDay: number,
	featureUnlocks: {[string]: boolean},
	canCareForDucks: boolean,
	renameError: string,
	renameErrorDuckIndex: number,
	saveStatus: string,
	saveStatusText: string,
	weatherId: string,
	weatherDisplayName: string,
	weatherDetail: string,
	secondsUntilWeatherChange: number,
	isFreshProfile: boolean,
	quests: {QuestState},
	isVisitingFarm: boolean,
	visitorHelpEnabled: boolean,
	farmOwnerUserId: number,
	farmOwnerName: string,
	farmOwnerDisplayName: string,
	farmVisits: {FarmVisitSummary},
}

export type UpgradeDefinition = {
	id: string,
	displayName: string,
	startingLevel: number,
	firstCost: number,
	valueIncrease: number,
	maxLevel: number,
	costs: {number},
}

export type DuckPurchaseDefinition = {
	id: string,
	displayName: string,
	baseCost: number,
	duckIncrease: number,
}

export type ShopItemDefinition = {
	id: string,
	displayName: string,
	cost: number,
	purchaseAmount: number,
	xpAmount: number?,
}

export type ShopDefinition = {
	duckFeed: ShopItemDefinition,
	premiumFeed: ShopItemDefinition,
	duckTreat: ShopItemDefinition,
	pillow: ShopItemDefinition,
	toy: ShopItemDefinition,
}

export type QuestDefinition = {
	id: string,
	displayName: string,
	baseTarget: number,
	baseRewardCoins: number,
	rewardDuckFeedEveryLevels: number?,
	rewardDuckFeedAmount: number?,
	rewardDuckTreatEveryLevels: number?,
	rewardDuckTreatAmount: number?,
	rewardPillowEveryLevels: number?,
	rewardPillowAmount: number?,
}

export type QuestsDefinition = {
	order: {string},
	collectEggs: QuestDefinition,
	sellEggs: QuestDefinition,
	helpDucks: QuestDefinition,
	useTreats: QuestDefinition,
	buyDucks: QuestDefinition,
	spendCoins: QuestDefinition,
	winEggCatch: QuestDefinition,
	levelUpDucks: QuestDefinition,
}

export type DuckCareDefinition = {
	id: string,
	displayName: string,
	defaultMood: string,
	caredMood: string,
	careDurationSeconds: number,
	cooldownSeconds: number,
	requestText: string,
	requestKinds: {
		pet: {
			id: string,
			requestText: string,
			actionText: string,
			missingText: string,
		},
		hungry: {
			id: string,
			requestText: string,
			actionText: string,
			missingText: string,
		},
		sleepy: {
			id: string,
			requestText: string,
			actionText: string,
			missingText: string,
		},
		clean: {
			id: string,
			requestText: string,
			actionText: string,
			missingText: string,
		},
		thirsty: {
			id: string,
			requestText: string,
			actionText: string,
			missingText: string,
		},
		bored: {
			id: string,
			requestText: string,
			actionText: string,
			missingText: string,
		},
	},
	hungryRequestChance: number,
	sleepyRequestChance: number,
	dirtyRequestChance: number,
	thirstyRequestChance: number,
	boredRequestChance: number,
	firstRequestDelaySeconds: number,
	requestIntervalSeconds: number,
	freshProfileHungryFollowUpDelaySeconds: number,
	requestVisibleDuckCap: number,
}

export type DuckLevelDefinition = {
	startingLevel: number,
	startingXp: number,
	xpPerCare: number,
	xpPerFeed: number,
	xpPerPremiumFeed: number,
	xpPerClean: number,
	xpPerDrink: number,
	xpPerPlay: number,
	xpPerToyPlay: number,
	xpPerRest: number,
	xpPerPillowRest: number,
	xpPerLevel: number,
	maxLevel: number,
	eggProductionBonusPerLevel: number,
}

export type DuckRenameDefinition = {
	minLength: number,
	maxLength: number,
}

export type WeatherStateDefinition = {
	id: string,
	displayName: string,
	detailText: string,
	sleepyRequestChanceBonus: number,
	dirtyRequestChanceBonus: number,
}

export type WeatherDefinition = {
	defaultId: string,
	cycleIntervalSeconds: number,
	rainyChance: number,
	cloudyChance: number,
	stormyChance: number,
	states: {
		sunny: WeatherStateDefinition,
		cloudy: WeatherStateDefinition,
		rainy: WeatherStateDefinition,
		stormy: WeatherStateDefinition,
	},
}

export type DailyCheckInDefinition = {
	id: string,
	displayName: string,
	rewardCoins: number,
	streakRewards: {number},
	day7TreatAmount: number,
	pauseGraceDays: number,
}

export type OfflineProgressDefinition = {
	rate: number,
	capSeconds: number,
}

export type ComebackGiftDefinition = {
	awayDaysThreshold: number,
	duckFeedAmount: number,
	duckTreatAmount: number,
}

export type DailyQuestPoolEntry = {
	id: string,
	displayName: string,
	action: string,
	target: number,
	rewardCoins: number,
	rewardDuckFeedAmount: number,
	rewardDuckTreatAmount: number,
}

export type DailyQuestsDefinition = {
	questCount: number,
	slotOffsets: {number},
	allCompleteBonusCoins: number,
	pool: {DailyQuestPoolEntry},
}

export type MinigameRewardDefinition = {
	coinsPerScoreStep: number,
	maxCoins: number,
	duckFeedScoreThreshold: number,
	duckFeedAmount: number,
	duckTreatScoreThreshold: number,
	duckTreatAmount: number,
	maxSubmittedScore: number,
	firstDropDelaySeconds: number,
	minDropIntervalSeconds: number,
	fastestDropTravelSeconds: number,
	scoreValidationSlack: number,
	claimGraceSeconds: number,
}

export type EggCatchDefinition = {
	id: string,
	displayName: string,
	roundSeconds: number,
	reward: MinigameRewardDefinition,
}

export type MinigamesDefinition = {
	eggCatch: EggCatchDefinition,
}

export type PrototypeConfig = {
	gameName: string,
	playerMode: string,
	usesSaveData: boolean,
	startingDucks: number,
	startingEggs: number,
	startingCoins: number,
	startingDuckFeed: number,
	startingPremiumFeed: number,
	duckNames: {string},
	eggProductionIntervalSeconds: number,
	eggSellValue: number,
	firstUpgrade: UpgradeDefinition,
	duckPurchase: DuckPurchaseDefinition,
	shop: ShopDefinition,
	quests: QuestsDefinition,
	weather: WeatherDefinition,
	duckCare: DuckCareDefinition,
	duckLevel: DuckLevelDefinition,
	duckRename: DuckRenameDefinition,
	dailyCheckIn: DailyCheckInDefinition,
	offlineProgress: OfflineProgressDefinition,
	comebackGift: ComebackGiftDefinition,
	dailyQuests: DailyQuestsDefinition,
	minigames: MinigamesDefinition,
}

return {}
