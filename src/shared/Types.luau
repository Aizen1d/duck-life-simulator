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

export type FarmState = {
	eggs: number,
	coins: number,
	availableEggs: number,
	duckFeed: number,
	duckCount: number,
	ducks: {DuckState},
	eggSellValue: number,
	eggValueLevel: number,
	eggValueMaxLevel: number,
	eggValueUpgradeCost: number,
	duckPurchaseCost: number,
	duckFeedCost: number,
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
	canCareForDucks: boolean,
	renameError: string,
	renameErrorDuckIndex: number,
}

export type UpgradeDefinition = {
	id: string,
	displayName: string,
	startingLevel: number,
	firstCost: number,
	valueIncrease: number,
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
}

export type ShopDefinition = {
	duckFeed: ShopItemDefinition,
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
	},
	hungryRequestChance: number,
	firstRequestDelaySeconds: number,
	requestIntervalSeconds: number,
	requestVisibleDuckCap: number,
}

export type DuckLevelDefinition = {
	startingLevel: number,
	startingXp: number,
	xpPerCare: number,
	xpPerFeed: number,
	xpPerLevel: number,
	maxLevel: number,
}

export type DuckRenameDefinition = {
	minLength: number,
	maxLength: number,
}

export type PrototypeConfig = {
	gameName: string,
	playerMode: string,
	usesSaveData: boolean,
	startingDucks: number,
	startingEggs: number,
	startingCoins: number,
	duckNames: {string},
	eggProductionIntervalSeconds: number,
	eggSellValue: number,
	firstUpgrade: UpgradeDefinition,
	duckPurchase: DuckPurchaseDefinition,
	shop: ShopDefinition,
	duckCare: DuckCareDefinition,
	duckLevel: DuckLevelDefinition,
	duckRename: DuckRenameDefinition,
}

return {}
