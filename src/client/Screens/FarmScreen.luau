--!strict

local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local AssetIds = require(Shared:WaitForChild("AssetIds"))
local PrototypeConfig = require(Shared:WaitForChild("PrototypeConfig"))
local RemoteProtocol = require(Shared:WaitForChild("RemoteProtocol"))

local ActionButton = require(script.Parent.Parent:WaitForChild("Components"):WaitForChild("ActionButton"))
local ResourceCounter = require(script.Parent.Parent:WaitForChild("Components"):WaitForChild("ResourceCounter"))
local Theme = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("Theme"))

local e = React.createElement
local remoteFolder = ReplicatedStorage:WaitForChild(RemoteProtocol.folderName)
local actionEvent = remoteFolder:WaitForChild(RemoteProtocol.actionEventName) :: RemoteEvent
local stateEvent = remoteFolder:WaitForChild(RemoteProtocol.stateEventName) :: RemoteEvent
local noticeEvent = remoteFolder:WaitForChild(RemoteProtocol.noticeEventName) :: RemoteEvent
local IS_STUDIO = RunService:IsStudio()

type DuckState = {
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

type QuestState = {
	id: string,
	displayName: string,
	level: number,
	progress: number,
	target: number,
	rewardCoins: number,
	rewardDuckFeed: number,
	rewardDuckTreat: number,
}

type FarmVisitSummary = {
	userId: number,
	playerName: string,
	displayName: string,
	duckCount: number,
	isLoaded: boolean,
	visitorHelpEnabled: boolean,
}

type FarmState = {
	eggs: number,
	coins: number,
	availableEggs: number,
	duckCount: number,
	ducks: {DuckState},
	eggSellValue: number,
	eggValueLevel: number,
	eggValueMaxLevel: number,
	eggValueUpgradeCost: number,
	duckPurchaseCost: number,
	duckFeed: number,
	premiumFeed: number,
	duckFeedCost: number,
	premiumFeedCost: number,
	duckTreat: number,
	duckTreatCost: number,
	pillow: number,
	pillowCost: number,
	toy: number,
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

type FeedbackItem = {
	id: number,
	kind: string,
	text: string,
	color: Color3,
	createdAt: number,
	xScale: number,
	yScale: number,
	duckIndex: number?,
}

type LayoutMetrics = {
	isCompact: boolean,
	isNarrow: boolean,
	isShortLandscape: boolean,
	showReadyBadge: boolean,
	showEggStatus: boolean,
	topY: number,
	sideMargin: number,
	counterWidth: number,
	counterHeight: number,
	actionButtonWidth: number,
	actionButtonHeight: number,
	actionGap: number,
	actionBarWidth: number,
	actionBottom: number,
	progressionCardWidth: number,
	progressionCardHeight: number,
	progressionStackWidth: number,
	progressionStackHeight: number,
	progressionGap: number,
	progressionAnchor: Vector2,
	progressionPosition: UDim2,
	progressionDirection: Enum.FillDirection,
	profilePanelWidth: number,
	profilePanelHeight: number,
	profilePanelAnchor: Vector2,
	profilePanelPosition: UDim2,
	testerTop: number,
	testerWidth: number,
	testerHeight: number,
	testerTitleWidth: number,
	testerButtonWidth: number,
	testerButtonGap: number,
	eggStatusWidth: number,
	eggStatusHeight: number,
}

type EggCatchDrop = {
	id: number,
	xScale: number,
	yScale: number,
	speed: number,
}

type EggCatchState = {
	score: number,
	missed: number,
	streak: number,
	bestStreak: number,
	timeLeft: number,
	basketXScale: number,
	drops: {EggCatchDrop},
	nextDropId: number,
	spawnTimer: number,
}

type EggCatchResult = {
	score: number,
	missed: number,
	bestStreak: number,
}

type EggCatchReward = {
	sessionId: number,
	score: number,
	coins: number,
	duckFeed: number,
	duckTreat: number,
	message: string,
}

type TutorialStep = {
	id: string,
	title: string,
	body: string,
}

type TutorialSpotlight = {
	x: number,
	y: number,
	width: number,
	height: number,
}
type DuckPresentation = {
	position: UDim2,
	size: number,
	rotation: number,
	facingDirection: number,
}

local ANIMATION_STEP_SECONDS = 1 / 30
local COLLECT_PULSE_SECONDS = 0.45
local FEEDBACK_DURATION_SECONDS = 1.25
local MAX_FEEDBACK_ITEMS = 5
local MAX_VISIBLE_NEST_EGGS = 8
local MAX_VISIBLE_DUCKS = 10
local TESTER_BUTTON_COUNT = 12
local DUCK_TARGET_RADIUS_X_SCALE = 0.4
local DUCK_TARGET_RADIUS_Y_SCALE = 0.34
local DUCK_TOUCH_TARGET_SCALE = 1.15
local SCREEN_MODE_FARM = "farm"
local SCREEN_MODE_SHOP = "shop"
local SCREEN_MODE_MINIGAMES = "minigames"
local SCREEN_MODE_EGG_CATCH = "egg_catch"
local SCREEN_MODE_EGG_CATCH_RESULTS = "egg_catch_results"
local WEATHER_RAINY_ID = PrototypeConfig.weather.states.rainy.id
local WEATHER_CLOUDY_ID = PrototypeConfig.weather.states.cloudy.id
local WEATHER_SUNNY_ID = PrototypeConfig.weather.states.sunny.id
local WEATHER_STORMY_ID = PrototypeConfig.weather.states.stormy.id
local SCENE_FADE_STEPS = 8
local SCENE_FADE_STEP_SECONDS = 0.025
local DEFAULT_VIEWPORT_SIZE = Vector2.new(1280, 720)
local EGG_CATCH_ROUND_SECONDS = PrototypeConfig.minigames.eggCatch.roundSeconds
local EGG_CATCH_BASKET_STEP = 0.09
local EGG_CATCH_BASKET_MIN_X = 0.12
local EGG_CATCH_BASKET_MAX_X = 0.88
local EGG_CATCH_BASKET_Y = 0.84
local EGG_CATCH_CATCH_RADIUS = 0.115
local EGG_CATCH_DROP_INTERVAL_MIN = 0.48
local EGG_CATCH_DROP_INTERVAL_MAX = 0.86
local EGG_CATCH_DROP_SPEED_MIN = 0.46
local EGG_CATCH_DROP_SPEED_MAX = 0.68
local TUTORIAL_STEPS: {TutorialStep} = {
	{
		id = "collect",
		title = "Collect eggs",
		body = "Tap Collect when the nest is ready. This moves ready eggs into your egg counter.",
	},
	{
		id = "sell",
		title = "Sell for coins",
		body = "Sell turns held eggs into coins so you can buy upgrades, ducks, and shop items.",
	},
	{
		id = "buy_duck",
		title = "Buy more ducks",
		body = "Buy Duck is in the right stack. More ducks make eggs faster over time.",
	},
	{
		id = "shop",
		title = "Visit the shop",
		body = "Shop buys Duck Feed, Premium Feed, and Treat. Feed helps hungry ducks, Premium Feed gives more hungry-duck XP, and Treat gives XP to one duck.",
	},
	{
		id = "care",
		title = "Help ducks",
		body = "When a duck asks for help with Pet me?, Hungry?, Sleepy?, or Dirty?, tap that duck and use its action.",
	},
}
local DUCK_SLOTS = {
	{ -24, -18, 1 },
	{ -86, 2, -1 },
	{ 38, 4, 1 },
	{ -136, 28, 1 },
	{ 88, 30, -1 },
	{ -34, 42, -1 },
	{ 26, 48, 1 },
	{ -112, -22, 1 },
	{ 78, -20, -1 },
	{ 136, 4, 1 },
}
local eggCatchRandom = Random.new()

local function getViewportSize(): Vector2
	local camera = workspace.CurrentCamera

	if camera then
		return camera.ViewportSize
	end

	return DEFAULT_VIEWPORT_SIZE
end

local function getDisplaySize(): EnumItem
	return GuiService.ViewportDisplaySize
end

local function createLayoutMetrics(screenSize: Vector2, displaySize: EnumItem): LayoutMetrics
	local isSmallDisplay = displaySize == Enum.DisplaySize.Small
	local isShortLandscape = screenSize.X >= 700 and screenSize.Y <= 430
	local isCompact = isSmallDisplay or isShortLandscape or screenSize.X < 900 or screenSize.Y < 560
	local isNarrow = screenSize.X < 560
	local sideMargin = if isShortLandscape then 12 elseif isCompact then 14 else 24
	local topY = if isShortLandscape then 72 elseif isCompact then 74 else 84
	local counterWidth = if isShortLandscape then 132 elseif isCompact then 156 else 176
	local counterHeight = if isShortLandscape then 46 elseif isCompact then 58 else 64
	local actionButtonWidth = if isNarrow then 112 elseif isShortLandscape then 132 elseif isCompact then 150 else 176
	local actionButtonHeight = if isShortLandscape then 50 elseif isCompact then 58 else 64
	local actionGap = if isShortLandscape then 10 elseif isCompact then 12 else 16
	local actionBottom = if isShortLandscape then 10 elseif isCompact then 18 else 32
	local progressionCardWidth = if isShortLandscape then 160 elseif isCompact then 178 else 210
	local progressionCardHeight = if isShortLandscape then 76 elseif isCompact then 104 else 116
	local progressionGap = if isShortLandscape then 6 else 12
	local progressionStackWidth = if isShortLandscape
		then progressionCardWidth * 2 + progressionGap
		else progressionCardWidth
	local progressionStackHeight = if isShortLandscape
		then progressionCardHeight
		else progressionCardHeight * 2 + progressionGap
	local progressionAnchor = if isNarrow then Vector2.new(0.5, 1) else Vector2.new(1, 1)
	local progressionPosition = if isNarrow
		then UDim2.new(0.5, 0, 1, -(actionBottom + actionButtonHeight + 20))
		elseif isShortLandscape
		then UDim2.new(1, -sideMargin, 1, -(actionBottom + actionButtonHeight + 8))
		else UDim2.new(1, -sideMargin, 1, -actionBottom)
	local progressionDirection = if isShortLandscape then Enum.FillDirection.Horizontal else Enum.FillDirection.Vertical
	local profilePanelWidth = if isShortLandscape then math.min(200, math.max(180, math.floor(screenSize.X * 0.24)))
		elseif isCompact then 232
		else 268
	local profilePanelHeight = if isShortLandscape then 204 elseif isCompact then 214 else 226
	local profilePanelAnchor = if isNarrow then Vector2.new(0.5, 1) else Vector2.new(0, 1)
	local profilePanelPosition = if isNarrow
		then UDim2.new(0.5, 0, 1, -(actionBottom + actionButtonHeight + 12))
		else UDim2.new(0, sideMargin, 1, -(actionBottom + actionButtonHeight + 12))
	local testerHeight = if isShortLandscape then 32 elseif isCompact then 44 else 50
	local testerTop = if isShortLandscape then topY elseif isCompact then topY + counterHeight + 8 else topY
	local testerWidth = math.min(if isShortLandscape then 400 elseif isCompact then 440 else 560, math.max(300, screenSize.X - sideMargin * 2))
	local testerTitleWidth = if isShortLandscape then 40 elseif isCompact then 50 else 76
	local testerButtonGap = if isShortLandscape then 4 elseif isCompact then 5 else 8
	local testerButtonArea = testerWidth - testerTitleWidth - 24
	local testerButtonWidth = math.floor((testerButtonArea - testerButtonGap * (TESTER_BUTTON_COUNT - 1)) / TESTER_BUTTON_COUNT)

	return {
		isCompact = isCompact,
		isNarrow = isNarrow,
		isShortLandscape = isShortLandscape,
		showReadyBadge = not isShortLandscape,
		showEggStatus = not isShortLandscape,
		topY = topY,
		sideMargin = sideMargin,
		counterWidth = counterWidth,
		counterHeight = counterHeight,
		actionButtonWidth = actionButtonWidth,
		actionButtonHeight = actionButtonHeight,
		actionGap = actionGap,
		actionBarWidth = actionButtonWidth * 3 + actionGap * 2,
		actionBottom = actionBottom,
		progressionCardWidth = progressionCardWidth,
		progressionCardHeight = progressionCardHeight,
		progressionStackWidth = progressionStackWidth,
		progressionStackHeight = progressionStackHeight,
		progressionGap = progressionGap,
		progressionAnchor = progressionAnchor,
		progressionPosition = progressionPosition,
		progressionDirection = progressionDirection,
		profilePanelWidth = profilePanelWidth,
		profilePanelHeight = profilePanelHeight,
		profilePanelAnchor = profilePanelAnchor,
		profilePanelPosition = profilePanelPosition,
		testerTop = testerTop,
		testerWidth = testerWidth,
		testerHeight = testerHeight,
		testerTitleWidth = testerTitleWidth,
		testerButtonWidth = math.clamp(testerButtonWidth, 30, 86),
		testerButtonGap = testerButtonGap,
		eggStatusWidth = if isCompact then math.min(220, math.max(180, screenSize.X - sideMargin * 2)) else 236,
		eggStatusHeight = if isShortLandscape then 42 elseif isCompact then 50 else 54,
	}
end

local function hasImage(image: string?): boolean
	return type(image) == "string" and image ~= ""
end

local function getThumbnailRectSize(image: string): Vector2?
	local widthText = image:match("[?&]w=(%d+)")
	local heightText = image:match("[?&]h=(%d+)")

	if not widthText or not heightText then
		return nil
	end

	local width = tonumber(widthText)
	local height = tonumber(heightText)

	if not width or not height then
		return nil
	end

	return Vector2.new(width, height)
end

local function getDuckState(farmState: FarmState, duckIndex: number?): DuckState?
	if not duckIndex or duckIndex < 1 or duckIndex > #farmState.ducks then
		return nil
	end

	return farmState.ducks[duckIndex]
end

local function getCareRequestDefinition(requestKind: string)
	if requestKind == PrototypeConfig.duckCare.requestKinds.hungry.id then
		return PrototypeConfig.duckCare.requestKinds.hungry
	elseif requestKind == PrototypeConfig.duckCare.requestKinds.sleepy.id then
		return PrototypeConfig.duckCare.requestKinds.sleepy
	elseif requestKind == PrototypeConfig.duckCare.requestKinds.clean.id then
		return PrototypeConfig.duckCare.requestKinds.clean
	elseif requestKind == PrototypeConfig.duckCare.requestKinds.thirsty.id then
		return PrototypeConfig.duckCare.requestKinds.thirsty
	elseif requestKind == PrototypeConfig.duckCare.requestKinds.bored.id then
		return PrototypeConfig.duckCare.requestKinds.bored
	end

	return PrototypeConfig.duckCare.requestKinds.pet
end

local function isHungryRequest(requestKind: string): boolean
	return requestKind == PrototypeConfig.duckCare.requestKinds.hungry.id
end

local function isSleepyRequest(requestKind: string): boolean
	return requestKind == PrototypeConfig.duckCare.requestKinds.sleepy.id
end

local function isDirtyRequest(requestKind: string): boolean
	return requestKind == PrototypeConfig.duckCare.requestKinds.clean.id
end

local function isThirstyRequest(requestKind: string): boolean
	return requestKind == PrototypeConfig.duckCare.requestKinds.thirsty.id
end

local function isBoredRequest(requestKind: string): boolean
	return requestKind == PrototypeConfig.duckCare.requestKinds.bored.id
end

local function canVisitorHelpRequest(requestKind: string): boolean
	return requestKind == PrototypeConfig.duckCare.requestKinds.pet.id
		or isSleepyRequest(requestKind)
		or isDirtyRequest(requestKind)
		or isThirstyRequest(requestKind)
		or isBoredRequest(requestKind)
end

local function trimText(text: string): string
	return text:match("^%s*(.-)%s*$") or ""
end

local function formatCoinCount(count: number): string
	if count < 1000 then
		return tostring(count)
	elseif count < 1000000 then
		local thousands = count / 1000
		if thousands >= 100 then
			return string.format("%dk", math.floor(thousands))
		end
		return string.format("%.1fk", thousands)
	end

	local millions = count / 1000000
	if millions >= 100 then
		return string.format("%dM", math.floor(millions))
	end
	return string.format("%.1fM", millions)
end

local function createFallbackDuck(
	position: UDim2,
	size: UDim2,
	rotation: number,
	isEmphasized: boolean,
	zIndex: number
)
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = zIndex,
	}, {
		Body = e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = if isEmphasized then Theme.colors.duckHighlight else Theme.colors.duck,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = position,
		Rotation = rotation,
		Size = size,
		ZIndex = zIndex,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.5, 0),
		}),
		Wing = e("Frame", {
			BackgroundColor3 = if isEmphasized then Theme.colors.duck else Theme.colors.duckWing,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(26, 42),
			Size = UDim2.fromOffset(50, 28),
			ZIndex = zIndex + 1,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			}),
		}),
		Eye = e("Frame", {
			BackgroundColor3 = Theme.colors.text,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(88, 23),
			Size = UDim2.fromOffset(9, 9),
			ZIndex = zIndex + 1,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.round,
			}),
		}),
		Beak = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(247, 142, 56),
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(102, 38),
			Size = UDim2.fromOffset(34, 18),
			ZIndex = zIndex + 1,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			}),
		}),
		}),
	})
end

local function getCollectPulse(feedbackItems: {FeedbackItem}, animationTime: number, duckIndex: number): number
	local pulse = 0

	for _, item in feedbackItems do
		local shouldPulse = item.kind == "egg"
			or ((item.kind == "care" or item.kind == "level" or item.kind == "treat") and item.duckIndex == duckIndex)

		if shouldPulse then
			local age = animationTime - item.createdAt

			if age >= 0 and age <= COLLECT_PULSE_SECONDS then
				pulse = math.max(pulse, 1 - age / COLLECT_PULSE_SECONDS)
			end
		end
	end

	return pulse
end

local function getDuckPresentation(animationTime: number, feedbackItems: {FeedbackItem}, index: number): DuckPresentation
	local slot = DUCK_SLOTS[index] or DUCK_SLOTS[1]
	local slotX = slot[1]
	local slotY = slot[2]
	local slotDirection = slot[3]
	local timeOffset = animationTime + index * 1.37
	local wanderWave = animationTime * 0.45 + index * 0.85
	local wanderX = math.sin(wanderWave) * 16 + slotX
	local wanderY = math.sin(timeOffset * 1.7) * 4 + math.sin(timeOffset * 0.55) * 5 + slotY
	local bobY = math.sin(timeOffset * 3.2) * 3
	local rotation = math.sin(timeOffset * 1.15) * 2
	local collectPulse = getCollectPulse(feedbackItems, animationTime, index)
	local baseSize = if index <= 3 then 112 else 96
	local size = baseSize + collectPulse * 8
	local position = UDim2.new(0.48, wanderX, 0.5, wanderY + bobY - collectPulse * 8)
	local facingDirection = if math.cos(wanderWave) * slotDirection >= 0 then 1 else -1

	return {
		position = position,
		size = size,
		rotation = rotation,
		facingDirection = facingDirection,
	}
end

local function getDuckCenterPixels(screenSize: Vector2, presentation: DuckPresentation): Vector2
	return Vector2.new(
		screenSize.X * presentation.position.X.Scale + presentation.position.X.Offset,
		screenSize.Y * presentation.position.Y.Scale + presentation.position.Y.Offset
	)
end

local function findDuckAtPosition(
	screenSize: Vector2,
	duckCount: number,
	animationTime: number,
	feedbackItems: {FeedbackItem},
	position: Vector2,
	targetScale: number?
): number?
	local visibleDuckCount = math.min(duckCount, MAX_VISIBLE_DUCKS)
	local bestDuckIndex = nil :: number?
	local bestScore = math.huge
	local scale = targetScale or 1

	for index = 1, visibleDuckCount do
		local presentation = getDuckPresentation(animationTime, feedbackItems, index)
		local center = getDuckCenterPixels(screenSize, presentation)
		local radiusX = math.max(24, presentation.size * DUCK_TARGET_RADIUS_X_SCALE * scale)
		local radiusY = math.max(24, presentation.size * DUCK_TARGET_RADIUS_Y_SCALE * scale)
		local deltaX = (position.X - center.X) / radiusX
		local deltaY = (position.Y - center.Y) / radiusY
		local score = deltaX * deltaX + deltaY * deltaY

		if score <= 1 and score < bestScore then
			bestScore = score
			bestDuckIndex = index
		end
	end

	return bestDuckIndex
end

local function isDuckPointerInput(inputObject: InputObject): boolean
	return inputObject.UserInputType == Enum.UserInputType.MouseButton1
end

local function getPointerPosition(inputObject: InputObject): Vector2
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService.MouseEnabled then
		return UserInputService:GetMouseLocation()
	end

	local inputPosition = inputObject.Position

	return Vector2.new(inputPosition.X, inputPosition.Y)
end

local function getTouchPosition(touchPosition: Vector2): Vector2
	local topLeftInset = GuiService:GetGuiInset()

	return touchPosition + topLeftInset
end

local function createDuck(
	animationTime: number,
	feedbackItems: {FeedbackItem},
	index: number,
	selectedDuckIndex: number?,
	duckState: DuckState?
)
	local presentation = getDuckPresentation(animationTime, feedbackItems, index)
	local isSelected = selectedDuckIndex == index
	local isRequested = duckState ~= nil and duckState.hasCareRequest == true
	local isEmphasized = isSelected or isRequested
	local rightDuckImage = if hasImage(AssetIds.duckRight) then AssetIds.duckRight else AssetIds.duck
	local leftDuckImage = AssetIds.duckLeft
	local duckImage = if presentation.facingDirection < 0 and hasImage(leftDuckImage) then leftDuckImage else rightDuckImage
	local zIndexBoost = if isRequested then 40 elseif isSelected then 24 else 0
	local zIndex = Theme.zIndex.scene + 2 + index + zIndexBoost

	if hasImage(duckImage) then
		local imageProps = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = duckImage,
			ImageColor3 = if isEmphasized then Theme.colors.duckHighlight else Color3.fromRGB(255, 255, 255),
			ImageRectOffset = nil :: Vector2?,
			ImageRectSize = nil :: Vector2?,
			Position = presentation.position,
			Rotation = presentation.rotation,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(presentation.size, presentation.size),
			ZIndex = zIndex,
		}

		if presentation.facingDirection < 0 and not hasImage(leftDuckImage) then
			local rectSize = getThumbnailRectSize(duckImage)

			if rectSize then
				imageProps.ImageRectOffset = Vector2.new(rectSize.X, 0)
				imageProps.ImageRectSize = Vector2.new(-rectSize.X, rectSize.Y)
			end
		end

		return e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = zIndex,
		}, {
			Image = e("ImageLabel", imageProps),
		})
	end

	return createFallbackDuck(
		presentation.position,
		UDim2.fromOffset(128, 92),
		presentation.rotation,
		isEmphasized,
		zIndex
	)
end

local function createDuckGroundHighlight(
	duckIndex: number?,
	duckCount: number,
	animationTime: number,
	feedbackItems: {FeedbackItem},
	transparency: number,
	zIndex: number
)
	local visibleDuckCount = math.min(duckCount, MAX_VISIBLE_DUCKS)

	if not duckIndex or duckIndex < 1 or duckIndex > visibleDuckCount then
		return nil
	end

	local presentation = getDuckPresentation(animationTime, feedbackItems, duckIndex)
	local pulse = 0.5 + math.sin(animationTime * 4) * 0.5
	local width = presentation.size * (0.7 + pulse * 0.04)
	local height = presentation.size * 0.16

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.colors.duckHighlight,
		BackgroundTransparency = transparency,
		BorderSizePixel = 0,
		Position = UDim2.new(
			presentation.position.X.Scale,
			presentation.position.X.Offset,
			presentation.position.Y.Scale,
			presentation.position.Y.Offset + presentation.size * 0.34
		),
		Size = UDim2.fromOffset(width, height),
		ZIndex = zIndex,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.round,
		}),
	})
end

local function createDuckCareRequestPrompt(
	farmState: FarmState,
	selectedDuckIndex: number?,
	animationTime: number,
	feedbackItems: {FeedbackItem},
	layout: LayoutMetrics
)
	local requestDuckIndex = farmState.careRequestDuckIndex
	local visibleDuckCount = math.min(farmState.duckCount, MAX_VISIBLE_DUCKS)

	if requestDuckIndex <= 0 or requestDuckIndex > visibleDuckCount or selectedDuckIndex == requestDuckIndex then
		return nil
	end

	local presentation = getDuckPresentation(animationTime, feedbackItems, requestDuckIndex)
	local promptText = if farmState.careRequestText ~= "" then farmState.careRequestText else PrototypeConfig.duckCare.requestText
	local promptWidth = if layout.isShortLandscape then 78 else 96
	local promptHeight = if layout.isShortLandscape then 28 else 32
	local yOffset = -(presentation.size / 2 + promptHeight / 2 + 4)

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.colors.panelSoft,
		BorderSizePixel = 0,
		Position = UDim2.new(
			presentation.position.X.Scale,
			presentation.position.X.Offset,
			presentation.position.Y.Scale,
			presentation.position.Y.Offset + yOffset
		),
		Size = UDim2.fromOffset(promptWidth, promptHeight),
		ZIndex = Theme.zIndex.ui + 4,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Stroke = e("UIStroke", {
			Color = Theme.colors.duckHighlight,
			Thickness = 2,
			Transparency = 0.08,
		}),
		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.fromScale(1, 1),
			Text = promptText,
			TextColor3 = Theme.colors.text,
			TextSize = if layout.isShortLandscape then 11 else 13,
			ZIndex = Theme.zIndex.ui + 5,
		}),
	})
end

type RectBounds = {
	left: number,
	top: number,
	right: number,
	bottom: number,
}

local function getDuckInteractionBubbleBounds(
	selectedDuckIndex: number?,
	duckCount: number,
	screenSize: Vector2,
	animationTime: number,
	feedbackItems: {FeedbackItem},
	layout: LayoutMetrics
): RectBounds?
	local visibleDuckCount = math.min(duckCount, MAX_VISIBLE_DUCKS)

	if not selectedDuckIndex or selectedDuckIndex < 1 or selectedDuckIndex > visibleDuckCount then
		return nil
	end

	local presentation = getDuckPresentation(animationTime, feedbackItems, selectedDuckIndex)
	local bubbleWidth = if layout.isShortLandscape then 148 else 166
	local bubbleHeight = if layout.isShortLandscape then 64 else 76
	local yOffset = -(presentation.size / 2 + bubbleHeight / 2 + 8)
	local center = Vector2.new(
		screenSize.X * presentation.position.X.Scale + presentation.position.X.Offset,
		screenSize.Y * presentation.position.Y.Scale + presentation.position.Y.Offset + yOffset
	)

	return {
		left = center.X - bubbleWidth / 2,
		top = center.Y - bubbleHeight / 2,
		right = center.X + bubbleWidth / 2,
		bottom = center.Y + bubbleHeight / 2,
	}
end

local function isPointInsideDuckInteractionBubble(
	position: Vector2,
	selectedDuckIndex: number?,
	duckCount: number,
	screenSize: Vector2,
	layout: LayoutMetrics,
	animationTime: number,
	feedbackItems: {FeedbackItem}
): boolean
	local bounds = getDuckInteractionBubbleBounds(
		selectedDuckIndex,
		duckCount,
		screenSize,
		animationTime,
		feedbackItems,
		layout
	)

	if not bounds then
		return false
	end

	return position.X >= bounds.left and position.X <= bounds.right and position.Y >= bounds.top and position.Y <= bounds.bottom
end

local function createDuckGroup(
	duckCount: number,
	animationTime: number,
	feedbackItems: {FeedbackItem},
	selectedDuckIndex: number?,
	farmState: FarmState
)
	local visibleDuckCount = math.min(duckCount, MAX_VISIBLE_DUCKS)
	local children: {[string]: any} = {}

	children.RequestHighlight = createDuckGroundHighlight(
		farmState.careRequestDuckIndex,
		duckCount,
		animationTime,
		feedbackItems,
		0.22,
		Theme.zIndex.scene + 3
	)
	children.SelectedHighlight = createDuckGroundHighlight(
		selectedDuckIndex,
		duckCount,
		animationTime,
		feedbackItems,
		0.34,
		Theme.zIndex.scene + 2
	)

	for index = 1, visibleDuckCount do
		local duckState = getDuckState(farmState, index)

		children["Duck" .. tostring(index)] =
			createDuck(animationTime, feedbackItems, index, selectedDuckIndex, duckState)
	end

	if duckCount > MAX_VISIBLE_DUCKS then
		children.CountBadge = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.colors.panel,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.6, 0.34),
			Size = UDim2.fromOffset(58, 32),
			ZIndex = Theme.zIndex.scene + 8,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(231, 224, 207),
				Thickness = 1,
			}),
			Label = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Size = UDim2.fromScale(1, 1),
				Text = "x" .. tostring(duckCount),
				TextColor3 = Theme.colors.text,
				TextSize = 15,
				ZIndex = Theme.zIndex.scene + 9,
			}),
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.zIndex.scene + 2,
	}, children)
end

local function createBackground(hasBackgroundImage: boolean)
	if hasBackgroundImage then
		return {
			BackgroundImage = e("ImageLabel", {
				BackgroundTransparency = 1,
				Image = AssetIds.farmBackground,
				ScaleType = Enum.ScaleType.Crop,
				Size = UDim2.fromScale(1, 1),
				ZIndex = Theme.zIndex.background,
			}),
		}
	end

	return {
		Grass = e("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Theme.colors.grass,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 0.72),
			ZIndex = Theme.zIndex.background,
		}),
		Pond = e("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Theme.colors.pond,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.97, 0.5),
			Size = UDim2.fromScale(0.34, 0.78),
			ZIndex = Theme.zIndex.background,
		}, {
			SizeConstraint = e("UISizeConstraint", {
				MaxSize = Vector2.new(620, 720),
				MinSize = Vector2.new(320, 260),
			}),
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0.45, 0),
			}),
			Stroke = e("UIStroke", {
				Color = Theme.colors.pondDark,
				Thickness = 5,
				Transparency = 0.25,
			}),
		}),
		Nest = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(218, 173, 91),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.37, 0.59),
			Size = UDim2.fromOffset(150, 54),
			ZIndex = Theme.zIndex.scene,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0.45, 0),
			}),
		}),
	}
end

local function createWeatherOverlay(farmState: FarmState, animationTime: number)
	local isRainy = farmState.weatherId == WEATHER_RAINY_ID
	local isStormy = farmState.weatherId == WEATHER_STORMY_ID

	if not isRainy and not isStormy then
		return nil
	end

	local tintColor = if isStormy then Color3.fromRGB(54, 73, 96) else Color3.fromRGB(87, 133, 166)
	local tintTransparency = if isStormy then 0.7 else 0.82
	local dropCount = if isStormy then 18 else 12

	local children = {
		Tint = e("Frame", {
			Active = false,
			BackgroundColor3 = tintColor,
			BackgroundTransparency = tintTransparency,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = Theme.zIndex.background + 1,
		}),
	}

	for index = 1, dropCount do
		local xScale = (index * 0.083 + animationTime * 0.055) % 1
		local yScale = (index * 0.173 + animationTime * 0.32) % 1

		children["Rain" .. tostring(index)] = e("Frame", {
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(225, 245, 255),
			BackgroundTransparency = 0.42,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(xScale, yScale),
			Rotation = 14,
			Size = UDim2.fromOffset(2, if index % 3 == 0 then 26 else 18),
			ZIndex = Theme.zIndex.scene + 1,
		})
	end

	return e("Frame", {
		Active = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.zIndex.background + 1,
	}, children)
end

local function createWeatherBadge(farmState: FarmState, layout: LayoutMetrics)
	local width = if layout.isShortLandscape then 118 else 152
	local height = if layout.isShortLandscape then 28 else 34
	local y = layout.topY + layout.counterHeight + (if layout.isShortLandscape then 54 else 42)
	local isRainy = farmState.weatherId == WEATHER_RAINY_ID
	local isStormy = farmState.weatherId == WEATHER_STORMY_ID
	local isCloudy = farmState.weatherId == WEATHER_CLOUDY_ID
	local badgeBackground = if isStormy
		then Color3.fromRGB(200, 213, 227)
		elseif isRainy then Color3.fromRGB(235, 247, 255)
		elseif isCloudy then Color3.fromRGB(238, 240, 244)
		else Theme.colors.panelSoft
	local badgeStroke = if isStormy
		then Color3.fromRGB(78, 102, 128)
		elseif isRainy then Color3.fromRGB(118, 173, 198)
		elseif isCloudy then Color3.fromRGB(168, 178, 196)
		else Color3.fromRGB(231, 224, 207)
	local badgeIconText = if isStormy
		then "Stm"
		elseif isRainy then "Rain"
		elseif isCloudy then "Cld"
		else "Sun"
	local badgeIconColor = if isStormy
		then Color3.fromRGB(54, 73, 96)
		elseif isRainy then Color3.fromRGB(54, 112, 145)
		elseif isCloudy then Color3.fromRGB(78, 95, 122)
		else Theme.colors.coin

	return e("Frame", {
		BackgroundColor3 = badgeBackground,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(layout.sideMargin, y),
		Size = UDim2.fromOffset(width, height),
		ZIndex = Theme.zIndex.ui + 1,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Stroke = e("UIStroke", {
			Color = badgeStroke,
			Thickness = 1,
		}),
		Icon = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.fromOffset(24, height),
			Text = badgeIconText,
			TextColor3 = badgeIconColor,
			TextSize = if layout.isShortLandscape then 10 else 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 2,
		}),
		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(34, 3),
			Size = UDim2.new(1, -42, 0, if layout.isShortLandscape then 11 else 14),
			Text = farmState.weatherDisplayName,
			TextColor3 = Theme.colors.text,
			TextSize = if layout.isShortLandscape then 10 else 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 2,
		}),
		Detail = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.fromOffset(34, if layout.isShortLandscape then 15 else 18),
			Size = UDim2.new(1, -42, 0, if layout.isShortLandscape then 10 else 12),
			Text = if layout.isShortLandscape then string.format("%ds", farmState.secondsUntilWeatherChange) else farmState.weatherDetail,
			TextColor3 = Theme.colors.mutedText,
			TextSize = if layout.isShortLandscape then 9 else 10,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 2,
		}),
	})
end

local function formatQuestRewardSummary(quest: QuestState, isShort: boolean): string
	local parts = { "+" .. tostring(quest.rewardCoins) }
	local rewardDuckFeed = quest.rewardDuckFeed or 0
	local rewardDuckTreat = quest.rewardDuckTreat or 0

	if rewardDuckFeed > 0 then
		table.insert(parts, if isShort then "F" .. tostring(rewardDuckFeed) else "Feed " .. tostring(rewardDuckFeed))
	end
	if rewardDuckTreat > 0 then
		table.insert(parts, if isShort then "T" .. tostring(rewardDuckTreat) else "Treat " .. tostring(rewardDuckTreat))
	end

	return table.concat(parts, if isShort then " " else "  ")
end

local function formatQuestCompleteFeedback(quest: QuestState): string
	local rewardSummary = formatQuestRewardSummary(quest, true)

	return "Quest " .. rewardSummary
end

local function createQuestPanel(farmState: FarmState, layout: LayoutMetrics, isExpanded: boolean, onActivated: () -> ())
	if #farmState.quests <= 0 then
		return nil
	end

	local quest = farmState.quests[1]
	local progress = math.clamp(quest.progress / math.max(1, quest.target), 0, 1)
	local width = if layout.isShortLandscape then 150 elseif layout.isCompact then 168 else 190
	local rowHeight = if layout.isShortLandscape then 24 else 32
	-- The expanded list caps at a few visible rows and scrolls, so dailies plus the growing
	-- repeatable quest set never turn the panel into a full-screen wall.
	local visibleRowCount = math.min(#farmState.quests, if layout.isShortLandscape then 4 else 6)
	local headerHeight = if layout.isShortLandscape then 18 else 24
	local height = if isExpanded
		then headerHeight + rowHeight * visibleRowCount + 8
		else (if layout.isShortLandscape then 42 else 50)
	local weatherHeight = if layout.isShortLandscape then 28 else 34
	local weatherOffset = if layout.isShortLandscape then 54 else 42
	local y = layout.topY + layout.counterHeight + weatherOffset + weatherHeight + 8
	local children = {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(231, 224, 207),
			Thickness = 1,
		}),
		Title = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(10, if layout.isShortLandscape then 5 else 7),
			Size = UDim2.new(1, -20, 0, if layout.isShortLandscape then 12 else 15),
			Text = "Quests",
			TextColor3 = Theme.colors.text,
			TextSize = if layout.isShortLandscape then 10 else 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 2,
		}),
		Toggle = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(1, -24, 0, if layout.isShortLandscape then 5 else 7),
			Size = UDim2.fromOffset(14, if layout.isShortLandscape then 12 else 15),
			Text = if isExpanded then "-" else "+",
			TextColor3 = Theme.colors.mutedText,
			TextSize = if layout.isShortLandscape then 12 else 14,
			ZIndex = Theme.zIndex.ui + 2,
		}),
	}

	if isExpanded then
		local rowChildren = {}

		for index, expandedQuest in farmState.quests do
			local expandedProgress = math.clamp(expandedQuest.progress / math.max(1, expandedQuest.target), 0, 1)
			local rowY = (index - 1) * rowHeight
			local rewardWidth = if layout.isShortLandscape then 58 else 78
			-- Daily slots have no quest level, so their rows show the goal name alone.
			local isDailyQuest = string.sub(expandedQuest.id, 1, 10) == "daily_slot"

			rowChildren["Quest" .. tostring(index)] = e("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, rowY),
				Size = UDim2.new(1, -6, 0, rowHeight),
				ZIndex = Theme.zIndex.ui + 2,
			}, {
				Label = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.fromOffset(0, 0),
					Size = UDim2.new(1, -rewardWidth - 2, 0, if layout.isShortLandscape then 10 else 13),
					Text = if isDailyQuest
						then expandedQuest.displayName
						else string.format("%s %d", expandedQuest.displayName, expandedQuest.level),
					TextColor3 = Theme.colors.text,
					TextSize = if layout.isShortLandscape then 9 else 11,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = Theme.zIndex.ui + 3,
				}),
				Reward = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.new(1, -rewardWidth, 0, 0),
					Size = UDim2.fromOffset(rewardWidth, if layout.isShortLandscape then 10 else 13),
					Text = formatQuestRewardSummary(expandedQuest, layout.isShortLandscape),
					TextColor3 = Theme.colors.coin,
					TextSize = if layout.isShortLandscape then 8 else 10,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = Theme.zIndex.ui + 3,
				}),
				ProgressText = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Position = UDim2.fromOffset(0, if layout.isShortLandscape then 10 else 14),
					Size = UDim2.new(1, 0, 0, if layout.isShortLandscape then 9 else 12),
					Text = string.format("%d / %d", expandedQuest.progress, expandedQuest.target),
					TextColor3 = Theme.colors.mutedText,
					TextSize = if layout.isShortLandscape then 8 else 10,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = Theme.zIndex.ui + 3,
				}),
				BarTrack = e("Frame", {
					BackgroundColor3 = Color3.fromRGB(231, 224, 207),
					BorderSizePixel = 0,
					ClipsDescendants = true,
					Position = UDim2.new(0, 0, 1, -5),
					Size = UDim2.new(1, 0, 0, 4),
					ZIndex = Theme.zIndex.ui + 3,
				}, {
					Corner = e("UICorner", {
						CornerRadius = Theme.round,
					}),
					Fill = e("Frame", {
						BackgroundColor3 = Theme.colors.coral,
						BorderSizePixel = 0,
						Size = UDim2.fromScale(expandedProgress, 1),
						ZIndex = Theme.zIndex.ui + 4,
					}, {
						Corner = e("UICorner", {
							CornerRadius = Theme.round,
						}),
					}),
				}),
			})
		end

		children.Rows = e("ScrollingFrame", {
			Active = true,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.fromOffset(0, rowHeight * #farmState.quests),
			Position = UDim2.fromOffset(10, headerHeight),
			ScrollBarThickness = 3,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Size = UDim2.new(1, -20, 0, rowHeight * visibleRowCount),
			ZIndex = Theme.zIndex.ui + 2,
		}, rowChildren)
	else
		children.Summary = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.fromOffset(10, if layout.isShortLandscape then 18 else 23),
			Size = UDim2.new(1, -20, 0, if layout.isShortLandscape then 10 else 13),
			Text = string.format("%s %d / %d", quest.displayName, quest.progress, quest.target),
			TextColor3 = Theme.colors.mutedText,
			TextSize = if layout.isShortLandscape then 8 else 10,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 2,
		})
		children.BarTrack = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(231, 224, 207),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.new(0, 10, 1, -8),
			Size = UDim2.new(1, -20, 0, 4),
			ZIndex = Theme.zIndex.ui + 2,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.round,
			}),
			Fill = e("Frame", {
				BackgroundColor3 = Theme.colors.coral,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(progress, 1),
				ZIndex = Theme.zIndex.ui + 3,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.round,
				}),
			}),
		})
	end

	return e("TextButton", {
		AutoButtonColor = true,
		BackgroundColor3 = Theme.colors.panel,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(layout.sideMargin, y),
		Size = UDim2.fromOffset(width, height),
		Text = "",
		ZIndex = Theme.zIndex.ui + 1,
		[React.Event.Activated] = onActivated,
	}, children)
end

local function createShopBackground()
	return {
		ShopWall = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(139, 218, 204),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = Theme.zIndex.background,
		}),
		ShopFloor = e("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(92, 175, 103),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 0.28),
			ZIndex = Theme.zIndex.background + 1,
		}),
		Counter = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 219, 96),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.78),
			Size = UDim2.fromScale(0.56, 0.1),
			ZIndex = Theme.zIndex.background + 2,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(177, 134, 48),
				Thickness = 3,
				Transparency = 0.15,
			}),
		}),
	}
end

local function createFadeOverlay(alpha: number)
	if alpha <= 0 then
		return nil
	end

	return e("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1 - math.clamp(alpha, 0, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.zIndex.ui + 100,
	})
end

local function createShopPill(
	layout: LayoutMetrics,
	xOffset: number,
	yOffset: number,
	width: number,
	text: string,
	backgroundColor: Color3,
	textColor: Color3
)
	local isShort = layout.isShortLandscape

	return e("Frame", {
		BackgroundColor3 = backgroundColor,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(xOffset, yOffset),
		Size = UDim2.fromOffset(width, if isShort then 18 else 22),
		ZIndex = Theme.zIndex.ui + 3,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.fromScale(1, 1),
			Text = text,
			TextColor3 = textColor,
			TextSize = if isShort then 9 else 11,
			ZIndex = Theme.zIndex.ui + 4,
		}),
	})
end

local function createShopItemCard(props: {
	layout: LayoutMetrics,
	position: UDim2,
	width: number,
	height: number,
	title: string,
	description: string,
	purposeText: string,
	purposeColor: Color3,
	ownedCount: number,
	cost: number,
	buttonText: string,
	canBuy: boolean,
	isTransitioning: boolean,
	onActivated: () -> (),
})
	local layout = props.layout
	local isShort = layout.isShortLandscape
	local contentLeft = if isShort then 14 else 18
	local buttonHeight = if isShort then 18 else 32
	local purposeWidth = if isShort then 58 else 64
	local costWidth = if isShort then 66 else 78
	local ownedWidth = if isShort then 68 else 82
	local pillTop = if isShort then 26 else 46
	local descriptionTop = if isShort then 61 else 74
	local descriptionHeight = if isShort then 14 else 18

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.colors.panel,
		BorderSizePixel = 0,
		Position = props.position,
		Size = UDim2.fromOffset(props.width, props.height),
		ZIndex = Theme.zIndex.ui + 2,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(231, 224, 207),
			Thickness = 2,
		}),
		Name = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(contentLeft, if isShort then 6 else 14),
			Size = UDim2.new(1, -(contentLeft * 2), 0, if isShort then 18 else 26),
			Text = props.title,
			TextColor3 = Theme.colors.text,
			TextSize = if isShort then 15 else 22,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 3,
		}),
		Purpose = createShopPill(
			layout,
			contentLeft,
			pillTop,
			purposeWidth,
			props.purposeText,
			props.purposeColor,
			Color3.fromRGB(255, 255, 255)
		),
		Cost = createShopPill(
			layout,
			contentLeft + purposeWidth + 6,
			pillTop,
			costWidth,
			string.format("%d coins", props.cost),
			Color3.fromRGB(246, 236, 196),
			Theme.colors.text
		),
		Owned = createShopPill(
			layout,
			contentLeft + purposeWidth + costWidth + 12,
			pillTop,
			ownedWidth,
			string.format("Owned %d", props.ownedCount),
			Color3.fromRGB(225, 238, 226),
			Theme.colors.text
		),
		Description = if isShort then nil else e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.fromOffset(contentLeft, descriptionTop),
			Size = UDim2.new(1, -(contentLeft * 2), 0, descriptionHeight),
			Text = props.description,
			TextColor3 = Theme.colors.mutedText,
			TextSize = if isShort then 12 else 14,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrapped = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = Theme.zIndex.ui + 3,
		}),
		Buy = e("TextButton", {
			Active = props.canBuy and not props.isTransitioning,
			AutoButtonColor = props.canBuy and not props.isTransitioning,
			BackgroundColor3 = if props.canBuy then Theme.colors.coral else Color3.fromRGB(185, 176, 164),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0, contentLeft, 1, -(buttonHeight + if isShort then 8 else 12)),
			Size = UDim2.new(1, -(contentLeft * 2), 0, buttonHeight),
			Text = props.buttonText,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = if isShort then 11 else 15,
			ZIndex = Theme.zIndex.ui + 3,
			[React.Event.Activated] = if props.canBuy and not props.isTransitioning then props.onActivated else nil,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
		}),
	})
end

local function createShopScreen(
	farmState: FarmState,
	layout: LayoutMetrics,
	screenSize: Vector2,
	isTransitioning: boolean,
	onBack: () -> (),
	onBuyDuckFeed: () -> (),
	onBuyPremiumFeed: () -> (),
	onBuyDuckTreat: () -> (),
	onBuyPillow: () -> (),
	onBuyToy: () -> ()
)
	local duckFeed = PrototypeConfig.shop.duckFeed
	local premiumFeed = PrototypeConfig.shop.premiumFeed
	local duckTreat = PrototypeConfig.shop.duckTreat
	local pillow = PrototypeConfig.shop.pillow
	local toy = PrototypeConfig.shop.toy
	local cardWidth = math.min(if layout.isShortLandscape then 348 else 440, math.max(300, screenSize.X - layout.sideMargin * 2))
	local cardGap = if layout.isShortLandscape then 3 else 8
	local shortStackTop = layout.topY + layout.counterHeight + 6
	local shortAvailableHeight = math.max(0, screenSize.Y - shortStackTop - 12 - cardGap * 4)
	local cardHeight = if layout.isShortLandscape then math.clamp(math.floor(shortAvailableHeight / 5), 50, 70) else 104
	local stackCenterScaleY = if layout.isShortLandscape then 0 else 0.55
	local stackCenterOffsetY = if layout.isShortLandscape then shortStackTop + cardHeight * 2 + cardGap * 2 + math.floor(cardHeight / 2) else 0
	local topButtonWidth = if layout.isShortLandscape then 76 else 94
	local inventoryWidth = if layout.isShortLandscape then 148 else 174
	local inventoryHeight = if layout.isShortLandscape then 124 else 144
	local stackOffset = cardHeight + cardGap
	local firstCardOffset = -stackOffset * 2
	local secondCardOffset = -stackOffset
	local thirdCardOffset = 0
	local fourthCardOffset = stackOffset
	local fifthCardOffset = stackOffset * 2

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.zIndex.ui,
	}, {
		Back = e("TextButton", {
			AutoButtonColor = not isTransitioning,
			BackgroundColor3 = Color3.fromRGB(43, 52, 49),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(layout.sideMargin, layout.topY),
			Size = UDim2.fromOffset(topButtonWidth, if layout.isShortLandscape then 36 else 44),
			Text = "Back",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = if layout.isShortLandscape then 12 else 14,
			ZIndex = Theme.zIndex.ui + 2,
			[React.Event.Activated] = if isTransitioning then nil else onBack,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
		}),
		Title = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0.5, 0, 0, layout.topY + if layout.isShortLandscape then 4 else 0),
			Size = UDim2.fromOffset(220, 36),
			Text = "Duck Shop",
			TextColor3 = Theme.colors.text,
			TextSize = if layout.isShortLandscape then 18 else 26,
			ZIndex = Theme.zIndex.ui + 2,
		}),
		Subtitle = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.new(0.5, 0, 0, layout.topY + if layout.isShortLandscape then 24 else 30),
			Size = UDim2.fromOffset(if layout.isShortLandscape then 250 else 320, if layout.isShortLandscape then 18 else 20),
			Text = "Food and boosts for your ducks",
			TextColor3 = Theme.colors.mutedText,
			TextSize = if layout.isShortLandscape then 10 else 13,
			ZIndex = Theme.zIndex.ui + 2,
		}),
		Coins = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -layout.sideMargin, 0, layout.topY),
			Size = UDim2.fromOffset(layout.counterWidth, layout.counterHeight),
			ZIndex = Theme.zIndex.ui + 2,
		}, {
			Counter = e(ResourceCounter, {
				title = "Coins",
				value = formatCoinCount(farmState.coins),
				accentColor = Theme.colors.coin,
				image = AssetIds.coinIcon,
				width = layout.counterWidth,
				height = layout.counterHeight,
			}),
		}),
		Inventory = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Theme.colors.panel,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -layout.sideMargin, 0, layout.topY + layout.counterHeight + 8),
			Size = UDim2.fromOffset(inventoryWidth, inventoryHeight),
			ZIndex = Theme.zIndex.ui + 2,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(231, 224, 207),
				Thickness = 2,
			}),
			Title = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(10, if layout.isShortLandscape then 6 else 8),
				Size = UDim2.new(1, -20, 0, if layout.isShortLandscape then 14 else 16),
				Text = "Bag",
				TextColor3 = Theme.colors.mutedText,
				TextSize = if layout.isShortLandscape then 10 else 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Feed = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(10, if layout.isShortLandscape then 24 else 30),
				Size = UDim2.new(1, -20, 0, if layout.isShortLandscape then 16 else 18),
				Text = string.format("Feed x%d", farmState.duckFeed),
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 11 else 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Premium = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(10, if layout.isShortLandscape then 44 else 54),
				Size = UDim2.new(1, -20, 0, if layout.isShortLandscape then 16 else 18),
				Text = string.format("Premium x%d", farmState.premiumFeed),
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 11 else 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Treat = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(10, if layout.isShortLandscape then 64 else 78),
				Size = UDim2.new(1, -20, 0, if layout.isShortLandscape then 16 else 18),
				Text = string.format("Treat x%d", farmState.duckTreat),
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 11 else 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Pillow = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(10, if layout.isShortLandscape then 82 else 98),
				Size = UDim2.new(1, -20, 0, if layout.isShortLandscape then 16 else 18),
				Text = string.format("Pillow x%d", farmState.pillow),
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 11 else 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Toy = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(10, if layout.isShortLandscape then 100 else 118),
				Size = UDim2.new(1, -20, 0, if layout.isShortLandscape then 16 else 18),
				Text = string.format("Toy x%d", farmState.toy),
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 11 else 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
		}),
		FeedCard = e(createShopItemCard, {
			layout = layout,
			position = UDim2.new(0.5, 0, stackCenterScaleY, stackCenterOffsetY + firstCardOffset),
			width = cardWidth,
			height = cardHeight,
			title = duckFeed.displayName,
			description = "Use one when a duck asks for food.",
			purposeText = "Care",
			purposeColor = Color3.fromRGB(180, 223, 143),
			ownedCount = farmState.duckFeed,
			cost = duckFeed.cost,
			buttonText = if farmState.canBuyDuckFeed then "Buy Feed" else string.format("Need %d coins", duckFeed.cost),
			canBuy = farmState.canBuyDuckFeed,
			isTransitioning = isTransitioning,
			onActivated = onBuyDuckFeed,
		}),
		PremiumFeedCard = e(createShopItemCard, {
			layout = layout,
			position = UDim2.new(0.5, 0, stackCenterScaleY, stackCenterOffsetY + secondCardOffset),
			width = cardWidth,
			height = cardHeight,
			title = premiumFeed.displayName,
			description = string.format("Use this first for hungry ducks and gain +%d XP.", PrototypeConfig.duckLevel.xpPerPremiumFeed),
			purposeText = "Boost",
			purposeColor = Color3.fromRGB(255, 196, 111),
			ownedCount = farmState.premiumFeed,
			cost = premiumFeed.cost,
			buttonText = if farmState.canBuyPremiumFeed then "Buy Premium" else string.format("Need %d coins", premiumFeed.cost),
			canBuy = farmState.canBuyPremiumFeed,
			isTransitioning = isTransitioning,
			onActivated = onBuyPremiumFeed,
		}),
		TreatCard = e(createShopItemCard, {
			layout = layout,
			position = UDim2.new(0.5, 0, stackCenterScaleY, stackCenterOffsetY + thirdCardOffset),
			width = cardWidth,
			height = cardHeight,
			title = duckTreat.displayName,
			description = string.format("Give one duck +%d XP right away.", duckTreat.xpAmount or 0),
			purposeText = "Level",
			purposeColor = Color3.fromRGB(255, 221, 119),
			ownedCount = farmState.duckTreat,
			cost = duckTreat.cost,
			buttonText = if farmState.canBuyDuckTreat then "Buy Treat" else string.format("Need %d coins", duckTreat.cost),
			canBuy = farmState.canBuyDuckTreat,
			isTransitioning = isTransitioning,
			onActivated = onBuyDuckTreat,
		}),
		PillowCard = e(createShopItemCard, {
			layout = layout,
			position = UDim2.new(0.5, 0, stackCenterScaleY, stackCenterOffsetY + fourthCardOffset),
			width = cardWidth,
			height = cardHeight,
			title = pillow.displayName,
			description = string.format("Use one when a duck asks to rest and gain +%d XP.", PrototypeConfig.duckLevel.xpPerPillowRest),
			purposeText = "Rest",
			purposeColor = Color3.fromRGB(178, 198, 224),
			ownedCount = farmState.pillow,
			cost = pillow.cost,
			buttonText = if farmState.canBuyPillow then "Buy Pillow" else string.format("Need %d coins", pillow.cost),
			canBuy = farmState.canBuyPillow,
			isTransitioning = isTransitioning,
			onActivated = onBuyPillow,
		}),
		ToyCard = e(createShopItemCard, {
			layout = layout,
			position = UDim2.new(0.5, 0, stackCenterScaleY, stackCenterOffsetY + fifthCardOffset),
			width = cardWidth,
			height = cardHeight,
			title = toy.displayName,
			description = string.format("Use one when a duck is bored and gain +%d XP.", PrototypeConfig.duckLevel.xpPerToyPlay),
			purposeText = "Play",
			purposeColor = Theme.colors.coral,
			ownedCount = farmState.toy,
			cost = toy.cost,
			buttonText = if farmState.canBuyToy then "Buy Toy" else string.format("Need %d coins", toy.cost),
			canBuy = farmState.canBuyToy,
			isTransitioning = isTransitioning,
			onActivated = onBuyToy,
		}),
	})
end

local function createMinigameBackground(animationTime: number)
	local children = {
		Sky = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(184, 233, 255),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = Theme.zIndex.background,
		}),
		Grass = e("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(143, 220, 105),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 0.28),
			ZIndex = Theme.zIndex.background + 1,
		}),
	}

	for index = 1, 3 do
		local xScale = 0.18 + (index - 1) * 0.29 + math.sin(animationTime * 0.2 + index) * 0.01
		local yScale = 0.13 + (index % 2) * 0.09

		children["Cloud" .. tostring(index)] = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(xScale, yScale),
			Size = UDim2.fromOffset(96, 34),
			ZIndex = Theme.zIndex.background + 2,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
		})
	end

	return children
end

local function createMinigameMenuScreen(
	layout: LayoutMetrics,
	screenSize: Vector2,
	isTransitioning: boolean,
	onBack: () -> (),
	onPlayEggCatch: () -> ()
)
	local cardWidth = math.min(if layout.isShortLandscape then 360 else 430, math.max(280, screenSize.X - layout.sideMargin * 2))
	local cardHeight = if layout.isShortLandscape then 150 else 176
	local titleWidth = if layout.isShortLandscape then 220 else 300

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.zIndex.ui,
	}, {
		Back = e("TextButton", {
			AutoButtonColor = not isTransitioning,
			BackgroundColor3 = Color3.fromRGB(43, 52, 49),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(layout.sideMargin, layout.topY),
			Size = UDim2.fromOffset(if layout.isShortLandscape then 76 else 92, if layout.isShortLandscape then 36 else 44),
			Text = "Back",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = if layout.isShortLandscape then 12 else 14,
			ZIndex = Theme.zIndex.ui + 2,
			[React.Event.Activated] = if isTransitioning then nil else onBack,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
		}),
		Title = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0.5, 0, 0, layout.topY),
			Size = UDim2.fromOffset(titleWidth, 36),
			Text = "Minigames",
			TextColor3 = Theme.colors.text,
			TextSize = if layout.isShortLandscape then 22 else 28,
			ZIndex = Theme.zIndex.ui + 2,
		}),
		Subtitle = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.new(0.5, 0, 0, layout.topY + if layout.isShortLandscape then 28 else 38),
			Size = UDim2.fromOffset(math.min(cardWidth, 420), if layout.isShortLandscape then 18 else 22),
			Text = "Short side activities in the same place",
			TextColor3 = Theme.colors.mutedText,
			TextSize = if layout.isShortLandscape then 11 else 13,
			ZIndex = Theme.zIndex.ui + 2,
		}),
		EggCatchCard = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.colors.panel,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, if layout.isShortLandscape then 0.58 else 0.54),
			Size = UDim2.fromOffset(cardWidth, cardHeight),
			ZIndex = Theme.zIndex.ui + 2,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(231, 224, 207),
				Thickness = 2,
			}),
			Name = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(18, if layout.isShortLandscape then 14 else 18),
				Size = UDim2.new(1, -36, 0, if layout.isShortLandscape then 22 else 28),
				Text = "Egg Catch",
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 20 else 24,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Description = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromOffset(18, if layout.isShortLandscape then 42 else 54),
				Size = UDim2.new(1, -36, 0, if layout.isShortLandscape then 50 else 62),
				Text = "Catch falling eggs for 20 seconds. Better scores earn coins, and strong rounds can also grant Duck Feed or Treat.",
				TextColor3 = Theme.colors.mutedText,
				TextSize = if layout.isShortLandscape then 12 else 14,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Play = e("TextButton", {
				Active = not isTransitioning,
				AutoButtonColor = not isTransitioning,
				BackgroundColor3 = Theme.colors.coral,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0, 18, 1, -(if layout.isShortLandscape then 40 else 48)),
				Size = UDim2.new(1, -36, 0, if layout.isShortLandscape then 28 else 34),
				Text = "Play",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = if layout.isShortLandscape then 13 else 15,
				ZIndex = Theme.zIndex.ui + 3,
				[React.Event.Activated] = if isTransitioning then nil else onPlayEggCatch,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.corner,
				}),
			}),
		}),
	})
end

local function createEggCatchDropVisual(drop: EggCatchDrop)
	if hasImage(AssetIds.eggIcon) then
		return e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = AssetIds.eggIcon,
			Position = UDim2.fromScale(drop.xScale, drop.yScale),
			Rotation = math.sin(drop.id) * 8,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(28, 34),
			ZIndex = Theme.zIndex.ui + 5,
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.colors.egg,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(drop.xScale, drop.yScale),
		Rotation = math.sin(drop.id) * 8,
		Size = UDim2.fromOffset(24, 30),
		ZIndex = Theme.zIndex.ui + 5,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.5, 0),
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(201, 170, 112),
			Thickness = 2,
		}),
	})
end

local function createEggCatchScreen(
	layout: LayoutMetrics,
	screenSize: Vector2,
	isTransitioning: boolean,
	eggCatchState: EggCatchState,
	onBack: () -> (),
	onMoveLeft: () -> (),
	onMoveRight: () -> ()
)
	local hudTop = layout.topY + if layout.isShortLandscape then 44 else 54
	local timerWidth = if layout.isShortLandscape then 98 else 122
	local hudHeight = if layout.isShortLandscape then 46 else 58
	local controlsHeight = if UserInputService.TouchEnabled then (if layout.isShortLandscape then 44 else 52) else 0
	local controlsBottom = if UserInputService.TouchEnabled then layout.actionBottom + 6 else 0
	local controlWidth = math.max(96, math.floor((math.max(280, screenSize.X - layout.sideMargin * 2) - 12) / 2))
	local playfieldChildren = {
		CatcherShadow = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(177, 134, 48),
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(eggCatchState.basketXScale, EGG_CATCH_BASKET_Y + 0.055),
			Size = UDim2.fromOffset(84, 18),
			ZIndex = Theme.zIndex.ui + 3,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
		}),
		Catcher = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(218, 173, 91),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(eggCatchState.basketXScale, EGG_CATCH_BASKET_Y),
			Size = UDim2.fromOffset(92, 34),
			ZIndex = Theme.zIndex.ui + 4,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0.45, 0),
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(177, 134, 48),
				Thickness = 3,
				Transparency = 0.08,
			}),
		}),
	}

	for _, drop in eggCatchState.drops do
		playfieldChildren["Drop" .. tostring(drop.id)] = createEggCatchDropVisual(drop)
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.zIndex.ui,
	}, {
		Back = e("TextButton", {
			AutoButtonColor = not isTransitioning,
			BackgroundColor3 = Color3.fromRGB(43, 52, 49),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(layout.sideMargin, layout.topY),
			Size = UDim2.fromOffset(if layout.isShortLandscape then 76 else 92, if layout.isShortLandscape then 36 else 44),
			Text = "Menu",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = if layout.isShortLandscape then 12 else 14,
			ZIndex = Theme.zIndex.ui + 2,
			[React.Event.Activated] = if isTransitioning then nil else onBack,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
		}),
		Title = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0.5, 0, 0, layout.topY),
			Size = UDim2.fromOffset(220, 36),
			Text = "Egg Catch",
			TextColor3 = Theme.colors.text,
			TextSize = if layout.isShortLandscape then 22 else 28,
			ZIndex = Theme.zIndex.ui + 2,
		}),
		Timer = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Theme.colors.panel,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -layout.sideMargin, 0, layout.topY),
			Size = UDim2.fromOffset(timerWidth, hudHeight),
			ZIndex = Theme.zIndex.ui + 2,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(231, 224, 207),
				Thickness = 2,
			}),
			Label = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(10, if layout.isShortLandscape then 7 else 8),
				Size = UDim2.new(1, -20, 0, if layout.isShortLandscape then 14 else 18),
				Text = "Time",
				TextColor3 = Theme.colors.mutedText,
				TextSize = if layout.isShortLandscape then 10 else 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Value = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(10, if layout.isShortLandscape then 20 else 24),
				Size = UDim2.new(1, -20, 0, if layout.isShortLandscape then 16 else 22),
				Text = string.format("%ds", math.ceil(eggCatchState.timeLeft)),
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 16 else 20,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
		}),
		Playfield = e("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromScale(1, 1),
			ZIndex = Theme.zIndex.ui + 2,
		}, {
			Score = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(layout.sideMargin, hudTop),
				Size = UDim2.new(1, -(layout.sideMargin * 2 + timerWidth + 18), 0, 18),
				Text = string.format("Caught %d  |  Missed %d  |  Best streak %d", eggCatchState.score, eggCatchState.missed, eggCatchState.bestStreak),
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 10 else 12,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Hint = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromOffset(layout.sideMargin, hudTop + if layout.isShortLandscape then 14 else 18),
				Size = UDim2.new(1, -(layout.sideMargin * 2), 0, 16),
				Text = if UserInputService.TouchEnabled
					then "Drag on the screen or tap Left/Right"
					else "Move the mouse or use A/D / arrow keys",
				TextColor3 = Theme.colors.mutedText,
				TextSize = if layout.isShortLandscape then 9 else 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Scene = e("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Position = UDim2.fromOffset(0, 0),
				Size = UDim2.new(1, 0, 1, -(controlsHeight + controlsBottom)),
				ZIndex = Theme.zIndex.ui + 3,
			}, {
				Ground = e("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundColor3 = Color3.fromRGB(149, 220, 100),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.fromScale(1, 0.19),
					ZIndex = Theme.zIndex.ui + 3,
				}),
				Drops = e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					ZIndex = Theme.zIndex.ui + 4,
				}, playfieldChildren),
			}),
		}),
		Controls = if UserInputService.TouchEnabled then e("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 1, -(layout.actionBottom + 6)),
			Size = UDim2.fromOffset(math.max(280, screenSize.X - layout.sideMargin * 2), if layout.isShortLandscape then 44 else 52),
			ZIndex = Theme.zIndex.ui + 2,
		}, {
			Layout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 12),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Left = e(ActionButton, {
				label = "Left",
				subtitle = "A / <-",
				disabled = isTransitioning,
				layoutOrder = 1,
				width = controlWidth,
				height = if layout.isShortLandscape then 44 else 52,
				onActivated = onMoveLeft,
			}),
			Right = e(ActionButton, {
				label = "Right",
				subtitle = "D / ->",
				disabled = isTransitioning,
				layoutOrder = 2,
				width = controlWidth,
				height = if layout.isShortLandscape then 44 else 52,
				onActivated = onMoveRight,
			}),
		}) else nil,
	})
end

local function formatEggCatchAccuracy(score: number, missed: number): string
	local total = score + missed

	if total <= 0 then
		return "0%"
	end

	return string.format("%d%%", math.round((score / total) * 100))
end

local function getEggCatchRewardStatusText(claimStatus: string, claimMessage: string, reward: EggCatchReward?): string
	if claimStatus == "claimed" and reward then
		return reward.message
	end

	if claimMessage ~= "" then
		return claimMessage
	end

	if claimStatus == "claiming" then
		return "Claiming reward..."
	elseif claimStatus == "awaiting_session" then
		return "Preparing reward..."
	elseif claimStatus == "failed" then
		return "Reward not claimed"
	end

	return "Round complete"
end

local function createEggCatchResultsScreen(
	layout: LayoutMetrics,
	screenSize: Vector2,
	isTransitioning: boolean,
	eggCatchResult: EggCatchResult?,
	eggCatchClaimStatus: string,
	eggCatchClaimMessage: string,
	eggCatchReward: EggCatchReward?,
	onRetryClaim: () -> (),
	onPlayAgain: () -> (),
	onBackToMenu: () -> (),
	onBackToFarm: () -> ()
)
	local result = eggCatchResult or {
		score = 0,
		missed = 0,
		bestStreak = 0,
	}
	local cardWidth = math.min(if layout.isShortLandscape then 360 else 430, math.max(280, screenSize.X - layout.sideMargin * 2))
	local cardHeight = if layout.isShortLandscape then 236 else 286
	local rewardText = getEggCatchRewardStatusText(eggCatchClaimStatus, eggCatchClaimMessage, eggCatchReward)
	local isClaimPending = eggCatchClaimStatus == "awaiting_session" or eggCatchClaimStatus == "claiming"
	local primaryIsRetry = eggCatchClaimStatus == "failed"
	local canNavigate = not isTransitioning and not isClaimPending
	local primaryLabel = if primaryIsRetry then "Retry Reward" elseif isClaimPending then "Claiming..." else "Play Again"
	local primaryActivated = if primaryIsRetry then onRetryClaim elseif canNavigate then onPlayAgain else nil

	return e("Frame", {
		Active = true,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.zIndex.ui,
	}, {
		Backdrop = e("Frame", {
			Active = true,
			BackgroundColor3 = Color3.fromRGB(235, 249, 255),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = Theme.zIndex.ui + 1,
		}, {
			TopBand = e("Frame", {
				BackgroundColor3 = Color3.fromRGB(194, 236, 255),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 0.74),
				ZIndex = Theme.zIndex.ui + 1,
			}),
			Ground = e("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = Color3.fromRGB(149, 220, 100),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 0.2),
				ZIndex = Theme.zIndex.ui + 1,
			}),
			Tint = e("Frame", {
				BackgroundColor3 = Theme.colors.panelSoft,
				BackgroundTransparency = 0.18,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				ZIndex = Theme.zIndex.ui + 2,
			}),
		}),
		Title = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0.5, 0, 0, layout.topY),
			Size = UDim2.fromOffset(240, 36),
			Text = "Egg Catch Results",
			TextColor3 = Theme.colors.text,
			TextSize = if layout.isShortLandscape then 22 else 28,
			ZIndex = Theme.zIndex.ui + 2,
		}),
		ResultCard = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.colors.panel,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.52),
			Size = UDim2.fromOffset(cardWidth, cardHeight),
			ZIndex = Theme.zIndex.ui + 2,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(231, 224, 207),
				Thickness = 2,
			}),
			Score = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(18, 18),
				Size = UDim2.new(1, -36, 0, 22),
				Text = string.format("Caught: %d", result.score),
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 18 else 22,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Missed = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromOffset(18, if layout.isShortLandscape then 52 else 60),
				Size = UDim2.new(1, -36, 0, 20),
				Text = string.format("Missed: %d", result.missed),
				TextColor3 = Theme.colors.mutedText,
				TextSize = if layout.isShortLandscape then 13 else 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Accuracy = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromOffset(18, if layout.isShortLandscape then 76 else 90),
				Size = UDim2.new(1, -36, 0, 20),
				Text = string.format("Accuracy: %s", formatEggCatchAccuracy(result.score, result.missed)),
				TextColor3 = Theme.colors.mutedText,
				TextSize = if layout.isShortLandscape then 13 else 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			BestStreak = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromOffset(18, if layout.isShortLandscape then 100 else 120),
				Size = UDim2.new(1, -36, 0, 20),
				Text = string.format("Best streak: %d", result.bestStreak),
				TextColor3 = Theme.colors.mutedText,
				TextSize = if layout.isShortLandscape then 13 else 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			RewardTitle = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(18, if layout.isShortLandscape then 126 else 150),
				Size = UDim2.new(1, -36, 0, if layout.isShortLandscape then 12 else 16),
				Text = "Reward",
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 11 else 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Reward = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromOffset(18, if layout.isShortLandscape then 142 else 170),
				Size = UDim2.new(1, -36, 0, if layout.isShortLandscape then 38 else 46),
				Text = rewardText,
				TextColor3 = if eggCatchClaimStatus == "failed" then Color3.fromRGB(166, 82, 74) else Theme.colors.mutedText,
				TextSize = if layout.isShortLandscape then 11 else 13,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			PlayAgain = e("TextButton", {
				Active = primaryActivated ~= nil,
				AutoButtonColor = primaryActivated ~= nil,
				BackgroundColor3 = Theme.colors.coral,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(18, cardHeight - if layout.isShortLandscape then 42 else 50),
				Size = UDim2.new(1, -36, 0, if layout.isShortLandscape then 28 else 34),
				Text = primaryLabel,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = if layout.isShortLandscape then 13 else 15,
				ZIndex = Theme.zIndex.ui + 3,
				[React.Event.Activated] = primaryActivated,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.corner,
				}),
			}),
		}),
		Menu = e("TextButton", {
			AnchorPoint = Vector2.new(0.5, 1),
			AutoButtonColor = canNavigate,
			BackgroundColor3 = Color3.fromRGB(43, 52, 49),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, -70, 1, -layout.actionBottom),
			Size = UDim2.fromOffset(124, if layout.isShortLandscape then 34 else 40),
			Text = "Minigames",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = if layout.isShortLandscape then 12 else 14,
			ZIndex = Theme.zIndex.ui + 2,
			[React.Event.Activated] = if canNavigate then onBackToMenu else nil,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
		}),
		Farm = e("TextButton", {
			AnchorPoint = Vector2.new(0.5, 1),
			AutoButtonColor = canNavigate,
			BackgroundColor3 = Color3.fromRGB(185, 176, 164),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 70, 1, -layout.actionBottom),
			Size = UDim2.fromOffset(124, if layout.isShortLandscape then 34 else 40),
			Text = "Farm",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = if layout.isShortLandscape then 12 else 14,
			ZIndex = Theme.zIndex.ui + 2,
			[React.Event.Activated] = if canNavigate then onBackToFarm else nil,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
		}),
	})
end

local function createDefaultQuestStates(): {QuestState}
	local quests = {}

	for _, questDefinition in {
		PrototypeConfig.quests.collectEggs,
		PrototypeConfig.quests.sellEggs,
		PrototypeConfig.quests.helpDucks,
	} do
		table.insert(quests, {
			id = questDefinition.id,
			displayName = questDefinition.displayName,
			level = 1,
			progress = 0,
			target = questDefinition.baseTarget,
			rewardCoins = questDefinition.baseRewardCoins,
			rewardDuckFeed = 0,
			rewardDuckTreat = 0,
		})
	end

	return quests
end

local function createDefaultFarmState()
	return {
		eggs = PrototypeConfig.startingEggs,
		coins = PrototypeConfig.startingCoins,
		availableEggs = 0,
		duckFeed = 0,
		premiumFeed = 0,
		duckTreat = 0,
		pillow = 0,
		toy = 0,
		duckCount = PrototypeConfig.startingDucks,
		ducks = {
			{
				id = 1,
				index = 1,
				name = PrototypeConfig.duckNames[1] or "Duck 1",
				level = PrototypeConfig.duckLevel.startingLevel,
				xp = PrototypeConfig.duckLevel.startingXp,
				xpToNextLevel = PrototypeConfig.duckLevel.xpPerLevel,
				mood = PrototypeConfig.duckCare.defaultMood,
				moodDetail = "This duck is relaxed",
				careCooldownSeconds = 0,
				hasCareRequest = false,
				careRequestKind = "",
				careRequestText = "",
				canCare = true,
			},
		},
		eggSellValue = PrototypeConfig.eggSellValue,
		eggValueLevel = PrototypeConfig.firstUpgrade.startingLevel,
		eggValueMaxLevel = 1,
		eggValueUpgradeCost = PrototypeConfig.firstUpgrade.firstCost,
		duckPurchaseCost = PrototypeConfig.duckPurchase.baseCost * PrototypeConfig.startingDucks,
		duckFeedCost = PrototypeConfig.shop.duckFeed.cost,
		premiumFeedCost = PrototypeConfig.shop.premiumFeed.cost,
		duckTreatCost = PrototypeConfig.shop.duckTreat.cost,
		pillowCost = PrototypeConfig.shop.pillow.cost,
		toyCost = PrototypeConfig.shop.toy.cost,
		duckMood = PrototypeConfig.duckCare.defaultMood,
		duckMoodDetail = "Ducks are relaxed",
		careRequestDuckIndex = 0,
		careRequestKind = "",
		careRequestText = "",
		careCooldownSeconds = 0,
		secondsUntilNextEgg = PrototypeConfig.eggProductionIntervalSeconds,
		canBuyEggValueUpgrade = false,
		canBuyDuck = false,
		canBuyDuckFeed = false,
		canBuyPremiumFeed = false,
		canBuyDuckTreat = false,
		canBuyPillow = false,
		canBuyToy = false,
		canClaimDailyCheckIn = false,
		canCareForDucks = true,
		renameError = "",
		renameErrorDuckIndex = 0,
		saveStatus = "loading",
		saveStatusText = "Loading",
		weatherId = PrototypeConfig.weather.defaultId,
		weatherDisplayName = PrototypeConfig.weather.states.sunny.displayName,
		weatherDetail = PrototypeConfig.weather.states.sunny.detailText,
		secondsUntilWeatherChange = PrototypeConfig.weather.cycleIntervalSeconds,
		isFreshProfile = false,
		quests = createDefaultQuestStates(),
		isVisitingFarm = false,
		visitorHelpEnabled = false,
		farmOwnerUserId = 0,
		farmOwnerName = "",
		farmOwnerDisplayName = "",
		farmVisits = {},
	}
end

local function createFeedbackItem(
	id: number,
	kind: string,
	text: string,
	color: Color3,
	xScale: number,
	yScale: number,
	duckIndex: number?
): FeedbackItem
	return {
		id = id,
		kind = kind,
		text = text,
		color = color,
		createdAt = os.clock(),
		xScale = xScale,
		yScale = yScale,
		duckIndex = duckIndex,
	}
end

local function formatCollectSubtitle(availableEggs: number, secondsUntilNextEgg: number): string
	if availableEggs > 0 then
		return string.format("%d ready", availableEggs)
	end

	return string.format("%ds", secondsUntilNextEgg)
end

local function formatSellSubtitle(eggs: number, eggSellValue: number): string
	if eggs <= 0 then
		return "No eggs"
	end

	return string.format("%d coin each", eggSellValue)
end

local function formatCareSubtitle(farmState: FarmState, duckIndex: number?): string
	local duck = getDuckState(farmState, duckIndex)

	if duck then
		if duck.careCooldownSeconds > 0 then
			return string.format("%ds", duck.careCooldownSeconds)
		end

		return duck.mood
	end

	if farmState.careCooldownSeconds > 0 and not farmState.canCareForDucks then
		return string.format("%ds", farmState.careCooldownSeconds)
	end

	return if farmState.canCareForDucks then "Ready" else farmState.duckMood
end

local function createDuckInteractionBubble(
	selectedDuckIndex: number?,
	duckCount: number,
	farmState: FarmState,
	animationTime: number,
	feedbackItems: {FeedbackItem},
	layout: LayoutMetrics,
	isTutorialCareStepActive: boolean,
	isReadOnly: boolean,
	canUseVisitorHelp: boolean,
	onCare: (number) -> (),
	onOpenProfile: (number) -> ()
)
	local visibleDuckCount = math.min(duckCount, MAX_VISIBLE_DUCKS)

	if not selectedDuckIndex or selectedDuckIndex < 1 or selectedDuckIndex > visibleDuckCount then
		return nil
	end

	local presentation = getDuckPresentation(animationTime, feedbackItems, selectedDuckIndex)
	local bubbleWidth = if layout.isShortLandscape then 148 else 166
	local bubbleHeight = if layout.isShortLandscape then 64 else 76
	local buttonHeight = if layout.isShortLandscape then 20 else 24
	local buttonGap = if layout.isShortLandscape then 5 else 6
	local innerButtonWidth = bubbleWidth - 16
	local actionButtonWidth = math.floor(innerButtonWidth * 0.58)
	local profileButtonWidth = innerButtonWidth - actionButtonWidth - buttonGap
	local yOffset = -(presentation.size / 2 + bubbleHeight / 2 + 8)
	local isRequestedDuck = farmState.careRequestDuckIndex == selectedDuckIndex
	local hasCareRequest = farmState.careRequestDuckIndex > 0

	local selectedDuck = getDuckState(farmState, selectedDuckIndex)
	local requestKind = if selectedDuck and selectedDuck.careRequestKind ~= ""
		then selectedDuck.careRequestKind
		else farmState.careRequestKind
	local requestDefinition = getCareRequestDefinition(requestKind)
	local needsFeed = isRequestedDuck and isHungryRequest(requestKind)
	local hasPremiumFeed = needsFeed and farmState.premiumFeed > 0
	local hasRequiredFeed = not needsFeed or farmState.duckFeed > 0 or farmState.premiumFeed > 0
	local canVisitorHelp = isReadOnly
		and canUseVisitorHelp
		and selectedDuck ~= nil
		and isRequestedDuck
		and canVisitorHelpRequest(requestKind)
	local canUseCare = not isReadOnly
		and selectedDuck ~= nil
		and selectedDuck.canCare
		and (not hasCareRequest or isRequestedDuck)
		and hasRequiredFeed
	local duckName = if selectedDuck and selectedDuck.name ~= "" then selectedDuck.name else "Duck " .. tostring(selectedDuckIndex)
	local requestText = if isRequestedDuck
		then (if farmState.careRequestText ~= "" then farmState.careRequestText else PrototypeConfig.duckCare.requestText)
		else ""
	local buttonText = if canUseCare
		then (
			if isRequestedDuck and hasPremiumFeed
				then "Premium Feed"
				elseif isRequestedDuck then requestDefinition.actionText
				else PrototypeConfig.duckCare.displayName
		)
		elseif canVisitorHelp then "Help"
		elseif hasCareRequest and not isRequestedDuck then "Later"
		elseif needsFeed and farmState.duckFeed <= 0 and farmState.premiumFeed <= 0 then requestDefinition.missingText
		elseif isReadOnly and isRequestedDuck and isHungryRequest(requestKind) and canUseVisitorHelp then "Needs feed"
		elseif isReadOnly then "Viewing"
		else formatCareSubtitle(farmState, selectedDuckIndex)
	local duckLevel = if selectedDuck then selectedDuck.level else PrototypeConfig.duckLevel.startingLevel
	local duckXp = if selectedDuck then selectedDuck.xp else PrototypeConfig.duckLevel.startingXp
	local duckXpToNextLevel = if selectedDuck then selectedDuck.xpToNextLevel else PrototypeConfig.duckLevel.xpPerLevel
	local isMaxLevel = duckXpToNextLevel <= 0
	local progressRatio = if isMaxLevel then 1 else math.clamp(duckXp / math.max(1, duckXpToNextLevel), 0, 1)
	local baseLevelText = if isMaxLevel then string.format("Lv. %d Max", duckLevel) else string.format("Lv. %d", duckLevel)
	local levelText = if requestText ~= "" then string.format("%s - %s", baseLevelText, requestText) else baseLevelText
	local titleHeight = if layout.isShortLandscape then 14 else 18
	local levelTop = if layout.isShortLandscape then 19 else 24
	local levelHeight = if layout.isShortLandscape then 12 else 14
	local barTop = if layout.isShortLandscape then 33 else 39
	local barHeight = if layout.isShortLandscape then 5 else 6
	local bubbleZIndex = if isTutorialCareStepActive then Theme.zIndex.ui + 25 else Theme.zIndex.ui + 6
	local contentZIndex = bubbleZIndex + 1
	local fillZIndex = bubbleZIndex + 2

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.colors.panel,
		BorderSizePixel = 0,
		Position = UDim2.new(
			presentation.position.X.Scale,
			presentation.position.X.Offset,
			presentation.position.Y.Scale,
			presentation.position.Y.Offset + yOffset
		),
		Size = UDim2.fromOffset(bubbleWidth, bubbleHeight),
		ZIndex = bubbleZIndex,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(231, 224, 207),
			Thickness = 1,
		}),
		Title = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(8, 4),
			Size = UDim2.new(1, -16, 0, titleHeight),
			Text = duckName,
			TextColor3 = Theme.colors.text,
			TextSize = if layout.isShortLandscape then 12 else 13,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = contentZIndex,
		}),
		Level = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(8, levelTop),
			Size = UDim2.new(1, -16, 0, levelHeight),
			Text = levelText,
			TextColor3 = Theme.colors.mutedText,
			TextSize = if layout.isShortLandscape then 10 else 11,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = contentZIndex,
		}),
		LevelBarBack = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(221, 213, 195),
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(10, barTop),
			Size = UDim2.new(1, -20, 0, barHeight),
			ZIndex = contentZIndex,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.round,
			}),
			Fill = e("Frame", {
				BackgroundColor3 = Theme.colors.duckHighlight,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(progressRatio, 1),
				ZIndex = fillZIndex,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.round,
				}),
			}),
		}),
		ActionButton = e("TextButton", {
			Active = canUseCare or canVisitorHelp,
			AutoButtonColor = canUseCare or canVisitorHelp,
			BackgroundColor3 = if canUseCare
				then Theme.colors.coral
				elseif canVisitorHelp then Theme.colors.pondDark
				else Color3.fromRGB(185, 176, 164),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0, 8, 1, -(buttonHeight + 6)),
			Size = UDim2.fromOffset(actionButtonWidth, buttonHeight),
			Text = buttonText,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = if layout.isShortLandscape then 10 else 11,
			ZIndex = contentZIndex,
			[React.Event.Activated] = if canUseCare or canVisitorHelp then function()
				onCare(selectedDuckIndex)
			end else nil,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
		}),
		ProfileButton = e("TextButton", {
			Active = true,
			AutoButtonColor = true,
			BackgroundColor3 = Theme.colors.duckHighlight,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0, 8 + actionButtonWidth + buttonGap, 1, -(buttonHeight + 6)),
			Size = UDim2.fromOffset(profileButtonWidth, buttonHeight),
			Text = "Profile",
			TextColor3 = Theme.colors.text,
			TextSize = if layout.isShortLandscape then 10 else 11,
			ZIndex = contentZIndex,
			[React.Event.Activated] = function()
				onOpenProfile(selectedDuckIndex)
			end,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
		}),
		Pointer = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.colors.panel,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 1, 2),
			Rotation = 45,
			Size = UDim2.fromOffset(10, 10),
			ZIndex = bubbleZIndex,
		}),
	})
end

local function createProfileLine(label: string, value: string, yOffset: number, isShort: boolean)
	local textSize = if isShort then 10 else 12
	local rowHeight = if isShort then 18 else 20
	local labelWidth = if isShort then 56 else 68

	return e("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, yOffset),
		Size = UDim2.new(1, -24, 0, rowHeight),
		ZIndex = Theme.zIndex.ui + 4,
	}, {
		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(labelWidth, rowHeight),
			Text = label,
			TextColor3 = Theme.colors.mutedText,
			TextSize = textSize,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 4,
		}),
		Value = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromOffset(labelWidth + 6, 0),
			Size = UDim2.new(1, -(labelWidth + 6), 0, rowHeight),
			Text = value,
			TextColor3 = Theme.colors.mutedText,
			TextSize = textSize,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 4,
		}),
	})
end

local function getDuckEggOutputMultiplier(duckState: DuckState): number
	local levelOffset = math.max(0, duckState.level - PrototypeConfig.duckLevel.startingLevel)

	return 1 + levelOffset * PrototypeConfig.duckLevel.eggProductionBonusPerLevel
end

local function getFarmEggOutputPerCycle(farmState: FarmState): number
	local totalOutput = 0

	for _, duck in farmState.ducks do
		totalOutput += getDuckEggOutputMultiplier(duck)
	end

	return totalOutput
end

local function formatEggOutput(value: number): string
	local roundedValue = math.round(value * 10) / 10

	if math.abs(roundedValue - math.round(roundedValue)) < 0.001 then
		return tostring(math.round(roundedValue))
	end

	return string.format("%.1f", roundedValue)
end

local function createDefaultEggCatchState(): EggCatchState
	return {
		score = 0,
		missed = 0,
		streak = 0,
		bestStreak = 0,
		timeLeft = EGG_CATCH_ROUND_SECONDS,
		basketXScale = 0.5,
		drops = {},
		nextDropId = 0,
		spawnTimer = 0.35,
	}
end

local function moveEggCatchBasket(currentState: EggCatchState, direction: number): EggCatchState
	if direction == 0 then
		return currentState
	end

	local nextState = table.clone(currentState)
	nextState.basketXScale = math.clamp(
		currentState.basketXScale + direction * EGG_CATCH_BASKET_STEP,
		EGG_CATCH_BASKET_MIN_X,
		EGG_CATCH_BASKET_MAX_X
	)

	return nextState
end

local function setEggCatchBasketFromPointer(currentState: EggCatchState, pointerPosition: Vector2, screenSize: Vector2): EggCatchState
	local width = math.max(1, screenSize.X)
	local nextState = table.clone(currentState)
	local xScale = pointerPosition.X / width

	nextState.basketXScale = math.clamp(xScale, EGG_CATCH_BASKET_MIN_X, EGG_CATCH_BASKET_MAX_X)

	return nextState
end

local function stepEggCatchState(currentState: EggCatchState, deltaTime: number): EggCatchState
	if currentState.timeLeft <= 0 then
		return currentState
	end

	local nextState = table.clone(currentState)
	local nextDrops = {}
	local basketXScale = currentState.basketXScale
	local nextTimeLeft = math.max(0, currentState.timeLeft - deltaTime)
	local nextSpawnTimer = currentState.spawnTimer - deltaTime
	local score = currentState.score
	local missed = currentState.missed
	local streak = currentState.streak
	local bestStreak = currentState.bestStreak
	local nextDropId = currentState.nextDropId

	while nextSpawnTimer <= 0 and nextTimeLeft > 0 do
		nextDropId += 1
		table.insert(nextDrops, {
			id = nextDropId,
			xScale = eggCatchRandom:NextNumber(0.12, 0.88),
			yScale = -0.08,
			speed = eggCatchRandom:NextNumber(EGG_CATCH_DROP_SPEED_MIN, EGG_CATCH_DROP_SPEED_MAX),
		})
		nextSpawnTimer += eggCatchRandom:NextNumber(EGG_CATCH_DROP_INTERVAL_MIN, EGG_CATCH_DROP_INTERVAL_MAX)
	end

	for _, drop in currentState.drops do
		local updatedDrop = table.clone(drop)
		updatedDrop.yScale += updatedDrop.speed * deltaTime

		if updatedDrop.yScale >= EGG_CATCH_BASKET_Y and math.abs(updatedDrop.xScale - basketXScale) <= EGG_CATCH_CATCH_RADIUS then
			score += 1
			streak += 1
			bestStreak = math.max(bestStreak, streak)
		elseif updatedDrop.yScale > 1.08 then
			missed += 1
			streak = 0
		else
			table.insert(nextDrops, updatedDrop)
		end
	end

	nextState.score = score
	nextState.missed = missed
	nextState.streak = streak
	nextState.bestStreak = bestStreak
	nextState.timeLeft = nextTimeLeft
	nextState.drops = nextDrops
	nextState.nextDropId = nextDropId
	nextState.spawnTimer = nextSpawnTimer

	return nextState
end

type ProfilePanelPlacement = {
	width: number,
	height: number,
	anchor: Vector2,
	position: UDim2,
}

local function getDuckProfilePanelPlacement(
	selectedDuckIndex: number,
	screenSize: Vector2,
	layout: LayoutMetrics,
	animationTime: number,
	feedbackItems: {FeedbackItem}
): ProfilePanelPlacement
	local width = layout.profilePanelWidth
	local height = layout.profilePanelHeight
	local panelPosition = layout.profilePanelPosition
	local panelAnchor = layout.profilePanelAnchor

	if not layout.isCompact then
		local presentation = getDuckPresentation(animationTime, feedbackItems, selectedDuckIndex)
		local center = getDuckCenterPixels(screenSize, presentation)
		local sideGap = 22
		local topPadding = layout.topY + layout.counterHeight + 12
		local bottomPadding = layout.actionBottom + layout.actionButtonHeight + 16
		local xOffset = sideGap
		local anchorX = 0

		if center.X + presentation.size / 2 + sideGap + width > screenSize.X - layout.sideMargin then
			xOffset = -(presentation.size / 2 + sideGap)
			anchorX = 1
		else
			xOffset = presentation.size / 2 + sideGap
		end

		local clampedY = math.clamp(
			center.Y - height / 2,
			topPadding,
			math.max(topPadding, screenSize.Y - bottomPadding - height)
		)

		panelAnchor = Vector2.new(anchorX, 0)
		panelPosition = UDim2.fromOffset(center.X + xOffset, clampedY)
	end

	return {
		width = width,
		height = height,
		anchor = panelAnchor,
		position = panelPosition,
	}
end

local function isPointInsideProfilePanel(
	point: Vector2,
	selectedDuckIndex: number?,
	screenSize: Vector2,
	layout: LayoutMetrics,
	animationTime: number,
	feedbackItems: {FeedbackItem}
): boolean
	if not selectedDuckIndex then
		return false
	end

	local placement = getDuckProfilePanelPlacement(selectedDuckIndex, screenSize, layout, animationTime, feedbackItems)
	local left = math.floor(screenSize.X * placement.position.X.Scale + placement.position.X.Offset - placement.anchor.X * placement.width)
	local top = math.floor(screenSize.Y * placement.position.Y.Scale + placement.position.Y.Offset - placement.anchor.Y * placement.height)

	return point.X >= left
		and point.X <= left + placement.width
		and point.Y >= top
		and point.Y <= top + placement.height
end

local function createDuckProfilePanel(
	selectedDuckIndex: number?,
	farmState: FarmState,
	animationTime: number,
	feedbackItems: {FeedbackItem},
	screenSize: Vector2,
	layout: LayoutMetrics,
	renamingDuckIndex: number?,
	renameText: string,
	isReadOnly: boolean,
	onStartRename: (number, string) -> (),
	onRenameTextChanged: (string) -> (),
	onSubmitRename: (number) -> (),
	onCancelRename: () -> (),
	onUseTreat: (number) -> ()
)
	local selectedDuck = getDuckState(farmState, selectedDuckIndex)

	if not selectedDuck or not selectedDuckIndex then
		return nil
	end

	local isShort = layout.isShortLandscape
	local placement = getDuckProfilePanelPlacement(selectedDuckIndex, screenSize, layout, animationTime, feedbackItems)
	local width = placement.width
	local height = placement.height
	local panelPosition = placement.position
	local panelAnchor = placement.anchor

	local contentLeft = 12
	local duckName = if selectedDuck.name ~= "" then selectedDuck.name else "Duck " .. tostring(selectedDuckIndex)
	local isRequestedDuck = farmState.careRequestDuckIndex == selectedDuckIndex
	local requestText = if isRequestedDuck
		then (if farmState.careRequestText ~= "" then farmState.careRequestText else PrototypeConfig.duckCare.requestText)
		else "None"
	local careText = if farmState.careRequestDuckIndex > 0 and not isRequestedDuck
		then "Later"
		elseif selectedDuck.careCooldownSeconds > 0 then string.format("%ds", selectedDuck.careCooldownSeconds)
		else "Ready"
	local isMaxLevel = selectedDuck.xpToNextLevel <= 0
	local progressRatio = if isMaxLevel then 1 else math.clamp(selectedDuck.xp / math.max(1, selectedDuck.xpToNextLevel), 0, 1)
	local eggOutputMultiplier = getDuckEggOutputMultiplier(selectedDuck)
	local levelBonus = math.max(0, eggOutputMultiplier - 1)
	local eggBoostText = if levelBonus <= 0 then "None" else string.format("+%d%%", math.round(levelBonus * 100))
	local nextLevelText = if isMaxLevel
		then "Maxed"
		else string.format("%d XP left", math.max(0, selectedDuck.xpToNextLevel - selectedDuck.xp))
	local levelText = if isMaxLevel
		then string.format("Lv. %d Max", selectedDuck.level)
		else string.format("Lv. %d  %d/%d XP", selectedDuck.level, selectedDuck.xp, selectedDuck.xpToNextLevel)
	local titleTop = if isShort then 8 else 10
	local subtitleTop = if isShort then 27 else 32
	local barTop = if isShort then 46 else 54
	local barHeight = if isShort then 6 else 7
	local firstLineTop = if isShort then 66 else 78
	local lineGap = if isShort then 22 else 25
	local lineRowHeight = if isShort then 18 else 20
	local infoLineCount = 5
	local footerTop = math.max(
		firstLineTop + lineGap * (infoLineCount - 1) + lineRowHeight + 6,
		height - (if isShort then 28 else 32)
	)
	local footerButtonTop = footerTop
	local footerButtonHeight = if isShort then 19 else 22
	local headerButtonTop = if isShort then titleTop - 1 else titleTop
	local headerButtonHeight = if isShort then 19 else 22
	local renameButtonWidth = if isShort then 62 else 72
	local headerButtonGap = 6
	local treatButtonWidth = if isShort then 72 else 82
	local isRenaming = not isReadOnly and renamingDuckIndex == selectedDuckIndex
	local trimmedRenameText = trimText(renameText)
	local canSubmitRename = trimmedRenameText ~= "" and trimmedRenameText ~= duckName
	local renameError = if farmState.renameErrorDuckIndex == selectedDuckIndex then farmState.renameError else ""
	local canUseTreat = not isReadOnly and not isMaxLevel and farmState.duckTreat > 0
	local footerText = if renameError ~= ""
		then renameError
		elseif isReadOnly then (if farmState.visitorHelpEnabled then "Help from bubble" else "Viewing only")
		elseif isRenaming then ""
		else string.format("Treats: %d", farmState.duckTreat)
	local footerReservedWidth = if isRenaming then 140 else treatButtonWidth + 8
	local titleRightInset = if isRenaming then contentLeft * 2 else contentLeft * 2 + renameButtonWidth + headerButtonGap

	return e("Frame", {
		AnchorPoint = panelAnchor,
		BackgroundColor3 = Theme.colors.panel,
		BorderSizePixel = 0,
		Position = panelPosition,
		Size = UDim2.fromOffset(width, height),
		ZIndex = Theme.zIndex.ui + 3,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(231, 224, 207),
			Thickness = 1,
		}),
		Title = if isRenaming
			then e("TextBox", {
				BackgroundColor3 = Theme.colors.panelSoft,
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				Font = Enum.Font.GothamBold,
				PlaceholderText = "Duck name",
				Position = UDim2.fromOffset(contentLeft, titleTop),
				Size = UDim2.new(1, -contentLeft * 2, 0, if isShort then 20 else 24),
				Text = renameText,
				TextColor3 = Theme.colors.text,
				TextSize = if isShort then 12 else 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 4,
				[React.Change.Text] = function(textBox)
					onRenameTextChanged(textBox.Text)
				end,
				[React.Event.FocusLost] = function(_, enterPressed)
					if enterPressed and canSubmitRename then
						onSubmitRename(selectedDuckIndex)
					end
				end,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.corner,
				}),
				Padding = e("UIPadding", {
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
				}),
			})
			else e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(contentLeft, titleTop),
				Size = UDim2.new(1, -titleRightInset, 0, if isShort then 17 else 20),
				Text = duckName,
				TextColor3 = Theme.colors.text,
				TextSize = if isShort then 13 else 17,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 4,
		}),
		Rename = if not isRenaming and not isReadOnly
			then e("TextButton", {
				Active = true,
				AutoButtonColor = true,
				BackgroundColor3 = Theme.colors.duckHighlight,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(1, -(contentLeft + renameButtonWidth), 0, headerButtonTop),
				Size = UDim2.fromOffset(renameButtonWidth, headerButtonHeight),
				Text = "Rename",
				TextColor3 = Theme.colors.text,
				TextSize = if isShort then 10 else 11,
				ZIndex = Theme.zIndex.ui + 4,
				[React.Event.Activated] = function()
					onStartRename(selectedDuckIndex, duckName)
				end,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.corner,
				}),
			})
			else nil,
		Subtitle = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(contentLeft, subtitleTop),
			Size = UDim2.new(1, -contentLeft * 2, 0, if isShort then 14 else 16),
			Text = levelText,
			TextColor3 = Theme.colors.mutedText,
			TextSize = if isShort then 10 else 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 4,
		}),
		LevelBarBack = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(221, 213, 195),
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(contentLeft, barTop),
			Size = UDim2.new(1, -contentLeft * 2, 0, barHeight),
			ZIndex = Theme.zIndex.ui + 4,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.round,
			}),
			Fill = e("Frame", {
				BackgroundColor3 = Theme.colors.duckHighlight,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(progressRatio, 1),
				ZIndex = Theme.zIndex.ui + 5,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.round,
				}),
			}),
		}),
		Mood = createProfileLine("Mood", selectedDuck.mood, firstLineTop, isShort),
		Need = createProfileLine("Need", requestText, firstLineTop + lineGap, isShort),
		Care = createProfileLine("Care", careText, firstLineTop + lineGap * 2, isShort),
		EggBoost = createProfileLine("Egg Boost", eggBoostText, firstLineTop + lineGap * 3, isShort),
		LevelUp = createProfileLine("Level Up", nextLevelText, firstLineTop + lineGap * 4, isShort),
		Footer = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromOffset(contentLeft, footerTop),
			Size = UDim2.new(1, -(contentLeft * 2 + footerReservedWidth), 0, footerButtonHeight),
			Text = footerText,
			TextColor3 = if renameError ~= "" then Theme.colors.coralDark else Theme.colors.mutedText,
			TextSize = if isShort then 9 else 11,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 4,
		}),
		Treat = if not isRenaming and not isReadOnly
			then e("TextButton", {
				Active = canUseTreat,
				AutoButtonColor = canUseTreat,
				BackgroundColor3 = if canUseTreat then Theme.colors.duckHighlight else Color3.fromRGB(185, 176, 164),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(1, -(contentLeft + treatButtonWidth), 0, footerButtonTop),
				Size = UDim2.fromOffset(treatButtonWidth, footerButtonHeight),
				Text = if isMaxLevel then "Maxed" elseif farmState.duckTreat <= 0 then "No Treats" else "Give Treat",
				TextColor3 = if canUseTreat then Theme.colors.text else Color3.fromRGB(255, 255, 255),
				TextSize = if isShort then 10 else 11,
				ZIndex = Theme.zIndex.ui + 4,
				[React.Event.Activated] = if canUseTreat then function()
					onUseTreat(selectedDuckIndex)
				end else nil,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.corner,
				}),
			})
			else nil,
		Save = if isRenaming
			then e("TextButton", {
				Active = canSubmitRename,
				AutoButtonColor = canSubmitRename,
				BackgroundColor3 = if canSubmitRename then Theme.colors.coral else Color3.fromRGB(185, 176, 164),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(1, -(contentLeft + 132), 0, footerButtonTop),
				Size = UDim2.fromOffset(62, footerButtonHeight),
				Text = "Save",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = if isShort then 10 else 11,
				ZIndex = Theme.zIndex.ui + 4,
				[React.Event.Activated] = if canSubmitRename then function()
					onSubmitRename(selectedDuckIndex)
				end else nil,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.corner,
				}),
			})
			else nil,
		Cancel = if isRenaming
			then e("TextButton", {
				Active = true,
				AutoButtonColor = true,
				BackgroundColor3 = Color3.fromRGB(185, 176, 164),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(1, -(contentLeft + 64), 0, footerButtonTop),
				Size = UDim2.fromOffset(64, footerButtonHeight),
				Text = "Cancel",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = if isShort then 10 else 11,
				ZIndex = Theme.zIndex.ui + 4,
				[React.Event.Activated] = onCancelRename,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.corner,
				}),
			})
			else nil,
	})
end

local function formatCompactCount(value: number): string
	if value < 1000 then
		return tostring(value)
	end

	if value < 1000000 then
		local reduced = value / 1000
		local rounded = if reduced >= 100 then math.round(reduced) else math.round(reduced * 10) / 10

		if math.abs(rounded - math.round(rounded)) < 0.001 then
			return string.format("%dK", math.round(rounded))
		end

		return string.format("%.1fK", rounded)
	end

	local reduced = value / 1000000
	local rounded = if reduced >= 100 then math.round(reduced) else math.round(reduced * 10) / 10

	if math.abs(rounded - math.round(rounded)) < 0.001 then
		return string.format("%dM", math.round(rounded))
	end

	return string.format("%.1fM", rounded)
end

local function formatCostLine(cost: number, coins: number, isShort: boolean): string
	if coins >= cost then
		return if isShort then string.format("Cost %d coins", cost) else string.format("Cost: %d coins", cost)
	end

	return if isShort then string.format("Need %d coins", cost - coins) else string.format("Need %d more coins", cost - coins)
end

local function getEggStatusPosition(layout: LayoutMetrics, isStudio: boolean): UDim2
	if layout.isShortLandscape then
		return UDim2.new(0.5, 0, 0, layout.topY + layout.counterHeight + 8)
	end

	if layout.isCompact then
		local testerOffset = if isStudio then layout.testerHeight + 8 else 0

		return UDim2.new(0.5, 0, 0, layout.topY + layout.counterHeight + testerOffset + 8)
	end

	if isStudio then
		return UDim2.new(0.5, 0, 0, layout.testerTop + layout.testerHeight + 8)
	end

	return UDim2.new(0.5, 0, 0, layout.topY)
end

local function getMinigamesButtonPosition(layout: LayoutMetrics, isStudio: boolean): UDim2
	if layout.isShortLandscape then
		return UDim2.new(1, -(layout.sideMargin + 42), 0, layout.topY + layout.counterHeight + 8)
	end

	return UDim2.new(1, -(layout.sideMargin + 46), 0, layout.topY + layout.counterHeight + 10)
end

local function createFarmVisitPanel(
	farmState: FarmState,
	layout: LayoutMetrics,
	isOpen: boolean,
	canInteract: boolean,
	onToggle: () -> (),
	onVisitFarm: (number) -> (),
	onReturnHome: () -> (),
	onToggleVisitorHelp: () -> ()
)
	local buttonWidth = if layout.isShortLandscape then 84 else 96
	local buttonHeight = if layout.isShortLandscape then 32 else 36
	local panelWidth = if layout.isShortLandscape then 206 else 238
	local usesVisitDrawer = not farmState.isVisitingFarm
	local rowHeight = if layout.isShortLandscape then 42 else 48
	local buttonCenterOffset = if layout.isShortLandscape then 134 else 154
	local buttonRightInset = layout.sideMargin + buttonCenterOffset - buttonWidth / 2
	local buttonTop = layout.topY + layout.counterHeight + 10
	local buttonPosition = UDim2.new(1, -buttonRightInset, 0, buttonTop)
	local panelTop = layout.topY + layout.counterHeight + (if layout.isShortLandscape then 46 else 54)
	local panelPosition = UDim2.new(1, -buttonRightInset, 0, panelTop)
	local rowGap = 6
	local rowsTopOffset = if usesVisitDrawer then (if layout.isShortLandscape then 36 else 40) else (if layout.isShortLandscape then 30 else 34)
	local visitorHelpHeight = if layout.isShortLandscape then 20 else 24
	local visitorHelpGap = if layout.isShortLandscape then 7 else 8
	local visitorHelpBottom = if layout.isShortLandscape then 8 else 8
	local farmVisitRowCount = math.max(1, #farmState.farmVisits)
	local farmVisitRowsHeight = rowHeight * farmVisitRowCount + rowGap * math.max(0, farmVisitRowCount - 1)
	local bannerHeight = if layout.isShortLandscape then 52 else 60
	local drawerBottomInset = layout.actionBottom + layout.actionButtonHeight + 12
	local drawerWidth = math.min(math.max(layout.actionBarWidth, panelWidth), 420)
	local panelMaxHeight = if usesVisitDrawer
		then (if layout.isShortLandscape then 170 elseif layout.isCompact then 250 else 260)
		else (if layout.isShortLandscape then 188 else 238)
	local panelHeight = if farmState.isVisitingFarm
		then bannerHeight
		else math.min(
			rowsTopOffset + farmVisitRowsHeight + visitorHelpGap + visitorHelpHeight + visitorHelpBottom,
			panelMaxHeight
		)
	local visitZIndex = Theme.zIndex.ui + 12
	local buttonText = if farmState.isVisitingFarm then "Home" else "Visit"
	local buttonSubtitle = if farmState.isVisitingFarm
		then "Return"
		else string.format("%d online", #farmState.farmVisits)
	local children: {[string]: any} = {
		Button = e("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			AutoButtonColor = canInteract,
			BackgroundColor3 = if farmState.isVisitingFarm then Theme.colors.pondDark else Color3.fromRGB(43, 52, 49),
			BorderSizePixel = 0,
			Position = buttonPosition,
			Size = UDim2.fromOffset(buttonWidth, buttonHeight),
			Text = "",
			ZIndex = visitZIndex + 3,
			[React.Event.Activated] = if canInteract then (
				if farmState.isVisitingFarm then onReturnHome else onToggle
			) else nil,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Label = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(8, if layout.isShortLandscape then 4 else 5),
				Size = UDim2.new(1, -16, 0, if layout.isShortLandscape then 13 else 15),
				Text = buttonText,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = if layout.isShortLandscape then 11 else 12,
				ZIndex = visitZIndex + 4,
			}),
			Subtitle = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromOffset(8, if layout.isShortLandscape then 17 else 20),
				Size = UDim2.new(1, -16, 0, if layout.isShortLandscape then 11 else 12),
				Text = buttonSubtitle,
				TextColor3 = Color3.fromRGB(222, 231, 227),
				TextSize = if layout.isShortLandscape then 9 else 10,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = visitZIndex + 4,
			}),
		}),
	}

	if isOpen and not farmState.isVisitingFarm then
		local rowsTop = panelTop + rowsTopOffset
		local rowsFrameHeight = math.max(rowHeight, panelHeight - rowsTopOffset - visitorHelpGap - visitorHelpHeight - visitorHelpBottom)
		local rowHitPositionXOffset = -(buttonRightInset + panelWidth - 10)
		local rowHitWidth = panelWidth - 20
		local drawerPanelPosition = if layout.isCompact
			then UDim2.new(0, layout.sideMargin, 1, -drawerBottomInset)
			else UDim2.new(0.5, 0, 1, -drawerBottomInset)
		local drawerPanelSize = if layout.isCompact
			then UDim2.new(1, -(layout.sideMargin * 2), 0, panelHeight)
			else UDim2.fromOffset(drawerWidth, panelHeight)
		local rowChildren: {[string]: any} = {
			Layout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, rowGap),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}

		if #farmState.farmVisits <= 0 then
			rowChildren.Empty = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, rowHeight),
				ZIndex = visitZIndex + 5,
			}, {
				Title = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.fromOffset(0, if layout.isShortLandscape then 3 else 5),
					Size = UDim2.new(1, 0, 0, if layout.isShortLandscape then 14 else 16),
					Text = "No farms online",
					TextColor3 = Theme.colors.text,
					TextSize = if layout.isShortLandscape then 11 else 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = visitZIndex + 5,
				}),
				Subtitle = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Position = UDim2.fromOffset(0, if layout.isShortLandscape then 20 else 24),
					Size = UDim2.new(1, 0, 0, if layout.isShortLandscape then 11 else 13),
					Text = "Same-server visits only",
					TextColor3 = Theme.colors.mutedText,
					TextSize = if layout.isShortLandscape then 9 else 10,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = visitZIndex + 5,
				}),
			})
		else
			for index, visit in farmState.farmVisits do
				local canVisit = canInteract and visit.isLoaded
				local displayName = if visit.displayName ~= "" then visit.displayName else visit.playerName
				local subtitle = if visit.isLoaded
					then string.format(
						"Same server | %d duck%s%s",
						visit.duckCount,
						if visit.duckCount == 1 then "" else "s",
						if visit.visitorHelpEnabled then " | Help on" else ""
					)
					else "Loading"
				local badgeText = if visit.isLoaded then (if visit.visitorHelpEnabled then "Help" else "View") else "Wait"
				local badgeWidth = if layout.isShortLandscape then 42 else 48
				local rowTextRightInset = badgeWidth + 24
				local rowOffset = (index - 1) * (rowHeight + rowGap)
				local rowTop = rowsTop + rowOffset
				local rowHitAnchorPoint = if usesVisitDrawer and not layout.isCompact
					then Vector2.new(0.5, 0)
					else Vector2.new(0, 0)
				local rowHitPosition = if usesVisitDrawer
					then (
						if layout.isCompact
							then UDim2.new(0, layout.sideMargin + 10, 1, -(drawerBottomInset + panelHeight - rowsTopOffset - rowOffset))
							else UDim2.new(0.5, 0, 1, -(drawerBottomInset + panelHeight - rowsTopOffset - rowOffset))
					)
					else UDim2.new(1, rowHitPositionXOffset, 0, rowTop)
				local rowHitSize = if usesVisitDrawer
					then (
						if layout.isCompact
							then UDim2.new(1, -((layout.sideMargin + 10) * 2), 0, rowHeight)
							else UDim2.fromOffset(drawerWidth - 20, rowHeight)
					)
					else UDim2.fromOffset(rowHitWidth, rowHeight)

				rowChildren["Farm" .. tostring(visit.userId)] = e("TextButton", {
					AutoButtonColor = canVisit,
					BackgroundColor3 = if canVisit then Theme.colors.panelSoft else Color3.fromRGB(226, 220, 210),
					BorderSizePixel = 0,
					LayoutOrder = index,
					Size = UDim2.new(1, 0, 0, rowHeight),
					Text = "",
					ZIndex = visitZIndex + 5,
					[React.Event.Activated] = if canVisit then function()
						onVisitFarm(visit.userId)
					end else nil,
				}, {
					Corner = e("UICorner", {
						CornerRadius = Theme.corner,
					}),
					Name = e("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						Position = UDim2.fromOffset(10, if layout.isShortLandscape then 4 else 5),
						Size = UDim2.new(1, -rowTextRightInset, 0, if layout.isShortLandscape then 13 else 16),
						Text = displayName,
						TextColor3 = Theme.colors.text,
						TextSize = if layout.isShortLandscape then 11 else 13,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = visitZIndex + 6,
					}),
					Subtitle = e("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamSemibold,
						Position = UDim2.fromOffset(10, if layout.isShortLandscape then 18 else 23),
						Size = UDim2.new(1, -rowTextRightInset, 0, if layout.isShortLandscape then 11 else 12),
						Text = subtitle,
						TextColor3 = Theme.colors.mutedText,
						TextSize = if layout.isShortLandscape then 9 else 10,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = visitZIndex + 6,
					}),
					Badge = e("Frame", {
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = if canVisit then Theme.colors.pondDark else Color3.fromRGB(185, 176, 164),
						BorderSizePixel = 0,
						Position = UDim2.new(1, -10, 0.5, 0),
						Size = UDim2.fromOffset(badgeWidth, if layout.isShortLandscape then 20 else 22),
						ZIndex = visitZIndex + 6,
					}, {
						Corner = e("UICorner", {
							CornerRadius = Theme.corner,
						}),
						Label = e("TextLabel", {
							BackgroundTransparency = 1,
							Font = Enum.Font.GothamBold,
							Size = UDim2.fromScale(1, 1),
							Text = badgeText,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = if layout.isShortLandscape then 9 else 10,
							ZIndex = visitZIndex + 7,
						}),
					}),
					ClickLayer = e("TextButton", {
						Active = canVisit,
						AutoButtonColor = false,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Font = Enum.Font.Gotham,
						Size = UDim2.fromScale(1, 1),
						Text = "",
						ZIndex = visitZIndex + 8,
						[React.Event.Activated] = if canVisit then function()
							onVisitFarm(visit.userId)
						end else nil,
					}),
				})

				if rowOffset + rowHeight <= rowsFrameHeight then
					children["FarmHit" .. tostring(visit.userId)] = e("TextButton", {
						Active = canVisit,
						AnchorPoint = rowHitAnchorPoint,
						AutoButtonColor = false,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = rowHitPosition,
						Size = rowHitSize,
						Text = "",
						ZIndex = visitZIndex + 10,
						[React.Event.Activated] = if canVisit then function()
							onVisitFarm(visit.userId)
						end else nil,
					})
				end
			end
		end

		children.Panel = e("Frame", {
			AnchorPoint = if usesVisitDrawer
				then (if layout.isCompact then Vector2.new(0, 1) else Vector2.new(0.5, 1))
				else Vector2.new(1, 0),
			BackgroundColor3 = Theme.colors.panel,
			BorderSizePixel = 0,
			Position = if usesVisitDrawer then drawerPanelPosition else panelPosition,
			Size = if usesVisitDrawer then drawerPanelSize else UDim2.fromOffset(panelWidth, panelHeight),
			ZIndex = visitZIndex + 4,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(231, 224, 207),
				Thickness = 1,
			}),
			Handle = if usesVisitDrawer then e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(210, 202, 187),
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0, 7),
				Size = UDim2.fromOffset(38, 3),
				ZIndex = visitZIndex + 5,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			}) else nil,
			Title = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(10, if usesVisitDrawer then 14 else 8),
				Size = UDim2.new(1, -20, 0, 18),
				Text = "Same-Server Farms",
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 12 else 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = visitZIndex + 5,
			}),
			Rows = e("Frame", {
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				Position = UDim2.fromOffset(10, rowsTopOffset),
				Size = UDim2.new(1, -20, 0, rowsFrameHeight),
				ZIndex = visitZIndex + 5,
			}, rowChildren),
			VisitorHelp = e("TextButton", {
				Active = canInteract,
				AutoButtonColor = canInteract,
				BackgroundColor3 = if farmState.visitorHelpEnabled then Theme.colors.pondDark else Color3.fromRGB(185, 176, 164),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0, 10, 1, -(visitorHelpHeight + visitorHelpBottom)),
				Size = UDim2.new(1, -20, 0, visitorHelpHeight),
				Text = if farmState.visitorHelpEnabled then "Visitor Help: On" else "Visitor Help: Off",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = if layout.isShortLandscape then 9 else 10,
				ZIndex = visitZIndex + 5,
				[React.Event.Activated] = if canInteract then onToggleVisitorHelp else nil,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.corner,
				}),
			}),
		})
	elseif farmState.isVisitingFarm then
		children.Banner = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(235, 247, 255),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -buttonRightInset, 0, buttonTop + buttonHeight + 8),
			Size = UDim2.fromOffset(panelWidth, bannerHeight),
			ZIndex = visitZIndex + 4,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(118, 173, 198),
				Thickness = 1,
			}),
			Title = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(10, if layout.isShortLandscape then 5 else 7),
				Size = UDim2.new(1, -82, 0, if layout.isShortLandscape then 13 else 15),
				Text = "Viewing Farm",
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 11 else 12,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = visitZIndex + 5,
			}),
			Badge = e("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Theme.colors.pondDark,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -10, 0, if layout.isShortLandscape then 5 else 7),
				Size = UDim2.fromOffset(
					if farmState.visitorHelpEnabled
						then (if layout.isShortLandscape then 70 else 78)
						else (if layout.isShortLandscape then 62 else 68),
					if layout.isShortLandscape then 18 else 20
				),
				ZIndex = visitZIndex + 5,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.corner,
				}),
				Label = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Size = UDim2.fromScale(1, 1),
					Text = if farmState.visitorHelpEnabled then "Help allowed" else "Read only",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = if layout.isShortLandscape then 7 else 8,
					ZIndex = visitZIndex + 6,
				}),
			}),
			Owner = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromOffset(10, if layout.isShortLandscape then 22 else 28),
				Size = UDim2.new(1, -20, 0, if layout.isShortLandscape then 12 else 14),
				Text = farmState.farmOwnerDisplayName,
				TextColor3 = Theme.colors.mutedText,
				TextSize = if layout.isShortLandscape then 10 else 11,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = visitZIndex + 5,
			}),
			Help = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromOffset(10, if layout.isShortLandscape then 36 else 44),
				Size = UDim2.new(1, -20, 0, if layout.isShortLandscape then 10 else 12),
				Text = if farmState.visitorHelpEnabled then "Help simple duck needs" else "Home returns to your farm",
				TextColor3 = Color3.fromRGB(54, 112, 145),
				TextSize = if layout.isShortLandscape then 8 else 9,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = visitZIndex + 5,
			}),
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(1, 1),
		ZIndex = visitZIndex,
	}, children)
end

local function resolveScreenOffset(axisSize: number, scale: number, offset: number): number
	return math.floor(axisSize * scale + offset)
end

local function clampTutorialSpotlight(spotlight: TutorialSpotlight, screenSize: Vector2): TutorialSpotlight
	local width = math.max(72, math.min(spotlight.width, screenSize.X - 16))
	local height = math.max(40, math.min(spotlight.height, screenSize.Y - 16))
	local x = math.clamp(spotlight.x, 8, math.max(8, screenSize.X - width - 8))
	local y = math.clamp(spotlight.y, 8, math.max(8, screenSize.Y - height - 8))

	return {
		x = x,
		y = y,
		width = width,
		height = height,
	}
end

local function getTutorialSpotlight(
	stepId: string,
	screenMode: string,
	layout: LayoutMetrics,
	screenSize: Vector2,
	isStudio: boolean,
	farmState: FarmState,
	animationTime: number,
	feedbackItems: {FeedbackItem},
	selectedDuckIndex: number?
): TutorialSpotlight?
	if stepId == "shop" and screenMode == SCREEN_MODE_SHOP then
		local width = if layout.isShortLandscape then 76 else 94
		local height = if layout.isShortLandscape then 36 else 44

		return clampTutorialSpotlight({
			x = layout.sideMargin,
			y = layout.topY,
			width = width,
			height = height,
		}, screenSize)
	elseif stepId == "collect" or stepId == "sell" or stepId == "shop" then
		local actionBarLeft = math.floor(screenSize.X / 2 - layout.actionBarWidth / 2)
		local actionTop = screenSize.Y - layout.actionBottom - layout.actionButtonHeight
		local buttonIndex = if stepId == "collect" then 0 elseif stepId == "sell" then 1 else 2
		local x = actionBarLeft + buttonIndex * (layout.actionButtonWidth + layout.actionGap)

		return clampTutorialSpotlight({
			x = x,
			y = actionTop,
			width = layout.actionButtonWidth,
			height = layout.actionButtonHeight,
		}, screenSize)
	elseif stepId == "buy_duck" then
		local stackLeft = resolveScreenOffset(screenSize.X, layout.progressionPosition.X.Scale, layout.progressionPosition.X.Offset)
			- math.floor(layout.progressionAnchor.X * layout.progressionStackWidth)
		local stackTop = resolveScreenOffset(screenSize.Y, layout.progressionPosition.Y.Scale, layout.progressionPosition.Y.Offset)
			- math.floor(layout.progressionAnchor.Y * layout.progressionStackHeight)
		local buyDuckOffsetX = if layout.progressionDirection == Enum.FillDirection.Horizontal
			then layout.progressionCardWidth + layout.progressionGap
			else 0
		local buyDuckOffsetY = if layout.progressionDirection == Enum.FillDirection.Horizontal
			then 0
			else layout.progressionCardHeight + layout.progressionGap

		return clampTutorialSpotlight({
			x = stackLeft + buyDuckOffsetX,
			y = stackTop + buyDuckOffsetY,
			width = layout.progressionCardWidth,
			height = layout.progressionCardHeight,
		}, screenSize)
	elseif stepId == "care" then
		local duckIndex = if farmState.careRequestDuckIndex > 0
			then farmState.careRequestDuckIndex
			else (if selectedDuckIndex then selectedDuckIndex else 1)
		local visibleDuckCount = math.min(farmState.duckCount, MAX_VISIBLE_DUCKS)

		if duckIndex < 1 or duckIndex > visibleDuckCount then
			return nil
		end

		local presentation = getDuckPresentation(animationTime, feedbackItems, duckIndex)
		local center = getDuckCenterPixels(screenSize, presentation)
		local width = math.max(78, math.floor(presentation.size * 0.78))
		local height = math.max(72, math.floor(presentation.size * 0.86))

		return clampTutorialSpotlight({
			x = math.floor(center.X - width / 2),
			y = math.floor(center.Y - height / 2),
			width = width,
			height = height,
		}, screenSize)
	end

	return nil
end

local function createTutorialOverlay(
	layout: LayoutMetrics,
	screenSize: Vector2,
	stepIndex: number,
	screenMode: string,
	isStudio: boolean,
	farmState: FarmState,
	animationTime: number,
	feedbackItems: {FeedbackItem},
	selectedDuckIndex: number?
)
	local clampedIndex = math.clamp(stepIndex, 1, #TUTORIAL_STEPS)
	local step = TUTORIAL_STEPS[clampedIndex]
	local spotlight = getTutorialSpotlight(step.id, screenMode, layout, screenSize, isStudio, farmState, animationTime, feedbackItems, selectedDuckIndex)
	local cardWidth = math.min(
		if layout.isShortLandscape then 270 elseif layout.isCompact then 304 else 360,
		math.max(236, screenSize.X - layout.sideMargin * 2)
	)
	local cardHeight = if layout.isShortLandscape then 146 elseif layout.isCompact then 156 else 168
	local spotlightMidY = if spotlight then spotlight.y + spotlight.height / 2 else screenSize.Y / 2
	local preferredCardTop = if spotlightMidY > screenSize.Y * 0.48
		then layout.topY + (if layout.isShortLandscape then 38 else 8)
		else screenSize.Y - layout.actionBottom - cardHeight - 12
	local cardTop = math.clamp(math.floor(preferredCardTop), 12, math.max(12, screenSize.Y - cardHeight - 12))
	local cardLeft = math.floor((screenSize.X - cardWidth) / 2)
	local buyDuckNeedsCoins = step.id == "buy_duck" and not farmState.canBuyDuck
	local footerText = if step.id == "shop" and screenMode == SCREEN_MODE_SHOP
			then "Tap Back to return to the farm."
		elseif step.id == "shop"
			then "Open Shop to continue."
		elseif buyDuckNeedsCoins
			then "Use Collect and Sell until Buy Duck is ready."
		elseif step.id == "care" and farmState.careRequestDuckIndex <= 0
			then "Wait for one duck to ask for help."
			else "Complete the highlighted task to continue."
	local function createTutorialDim(position: UDim2, size: UDim2)
		local commonProps = {
			BackgroundColor3 = Color3.fromRGB(39, 47, 44),
			BackgroundTransparency = 0.34,
			BorderSizePixel = 0,
			Position = position,
			Size = size,
			ZIndex = Theme.zIndex.ui + 21,
		}

		if step.id == "care" or buyDuckNeedsCoins then
			return e("Frame", commonProps)
		end

		local buttonProps = table.clone(commonProps)
		buttonProps.Active = true
		buttonProps.AutoButtonColor = false
		buttonProps.Text = ""

		return e("TextButton", buttonProps)
	end

	return e("Frame", {
		Active = true,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.zIndex.ui + 20,
	}, {
		DimFull = if spotlight == nil then createTutorialDim(UDim2.fromScale(0, 0), UDim2.fromScale(1, 1)) else nil,
		DimTop = if spotlight then createTutorialDim(UDim2.fromOffset(0, 0), UDim2.fromOffset(screenSize.X, spotlight.y)) else nil,
		DimBottom = if spotlight
			then createTutorialDim(
				UDim2.fromOffset(0, spotlight.y + spotlight.height),
				UDim2.fromOffset(screenSize.X, math.max(0, screenSize.Y - spotlight.y - spotlight.height))
			)
			else nil,
		DimLeft = if spotlight
			then createTutorialDim(UDim2.fromOffset(0, spotlight.y), UDim2.fromOffset(spotlight.x, spotlight.height))
			else nil,
		DimRight = if spotlight
			then createTutorialDim(
				UDim2.fromOffset(spotlight.x + spotlight.width, spotlight.y),
				UDim2.fromOffset(math.max(0, screenSize.X - spotlight.x - spotlight.width), spotlight.height)
			)
			else nil,
		Spotlight = spotlight and e("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(spotlight.x, spotlight.y),
			Size = UDim2.fromOffset(spotlight.width, spotlight.height),
			ZIndex = Theme.zIndex.ui + 22,
		}, {
			Corner = e("UICorner", {
				CornerRadius = if step.id == "care" then UDim.new(1, 0) else Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Theme.colors.duckHighlight,
				Thickness = 3,
			}),
		}) or nil,
		DuckHint = if step.id == "care" and spotlight then e("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Theme.colors.panel,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(
				math.floor(spotlight.x + spotlight.width / 2),
				math.max(36, spotlight.y - 10)
			),
			Size = UDim2.fromOffset(96, 30),
			ZIndex = Theme.zIndex.ui + 23,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Theme.colors.duckHighlight,
				Thickness = 2,
			}),
			Label = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Size = UDim2.fromScale(1, 1),
				Text = "This duck",
				TextColor3 = Theme.colors.text,
				TextSize = 12,
				ZIndex = Theme.zIndex.ui + 24,
			}),
			Pointer = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Theme.colors.panel,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 1, -1),
				Rotation = 45,
				Size = UDim2.fromOffset(12, 12),
				ZIndex = Theme.zIndex.ui + 22,
			}, {
				Stroke = e("UIStroke", {
					Color = Theme.colors.duckHighlight,
					Thickness = 2,
				}),
			}),
		}) else nil,
		Card = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Theme.colors.panel,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(cardLeft + math.floor(cardWidth / 2), cardTop),
			Size = UDim2.fromOffset(cardWidth, cardHeight),
			ZIndex = Theme.zIndex.ui + 23,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(231, 224, 207),
				Thickness = 2,
			}),
			Step = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(16, 12),
				Size = UDim2.new(1, -32, 0, 14),
				Text = string.format("Guide %d/%d", clampedIndex, #TUTORIAL_STEPS),
				TextColor3 = Theme.colors.mutedText,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 24,
			}),
			Title = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(16, 30),
				Size = UDim2.new(1, -32, 0, if layout.isShortLandscape then 20 else 24),
				Text = step.title,
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 16 else 18,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 24,
			}),
			Body = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromOffset(16, if layout.isShortLandscape then 56 else 62),
				Size = UDim2.new(1, -32, 0, if layout.isShortLandscape then 50 else 58),
				Text = step.body,
				TextColor3 = Theme.colors.mutedText,
				TextSize = if layout.isShortLandscape then 11 else 12,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = Theme.zIndex.ui + 24,
			}),
			Footer = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(16, cardHeight - 34),
				Size = UDim2.new(1, -32, 0, 18),
				Text = footerText,
				TextColor3 = Theme.colors.coralDark,
				TextSize = if layout.isShortLandscape then 10 else 11,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = Theme.zIndex.ui + 24,
			}),
		}),
	})
end
local function createEggStatusCard(farmState: FarmState, layout: LayoutMetrics, isStudio: boolean)
	local isSmallStatus = layout.eggStatusHeight < 50
	local interval = PrototypeConfig.eggProductionIntervalSeconds
	local eggOutputPerCycle = getFarmEggOutputPerCycle(farmState)
	local progress = if farmState.availableEggs > 0
		then 1
		else 1 - math.clamp(farmState.secondsUntilNextEgg / interval, 0, 1)
	local title = if farmState.availableEggs > 0 then "Ready to collect" else "Next egg"
	local summaryText = if farmState.availableEggs > 0
		then string.format("%s ready | %s eggs/%ds", formatCompactCount(farmState.availableEggs), formatEggOutput(eggOutputPerCycle), interval)
		else string.format("%ds left | %s eggs/%ds", farmState.secondsUntilNextEgg, formatEggOutput(eggOutputPerCycle), interval)
	local titleY = if isSmallStatus then 5 else 6
	local titleHeight = if isSmallStatus then 13 else 16
	local summaryY = titleY + titleHeight + (if isSmallStatus then 1 else 3)
	local barHeight = 4
	local barBottomPadding = if isSmallStatus then 7 else 9
	local barTop = layout.eggStatusHeight - barBottomPadding - barHeight
	local summaryHeight = math.max(if isSmallStatus then 10 else 12, barTop - summaryY - 2)

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.colors.panel,
		BorderSizePixel = 0,
		Position = getEggStatusPosition(layout, isStudio),
		Size = UDim2.fromOffset(layout.eggStatusWidth, layout.eggStatusHeight),
		ZIndex = Theme.zIndex.ui,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(231, 224, 207),
			Thickness = 1,
		}),
		Title = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(12, titleY),
			Size = UDim2.new(1, -24, 0, titleHeight),
			Text = title,
			TextColor3 = Theme.colors.text,
			TextSize = if isSmallStatus then 12 else 13,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 1,
		}),
		Summary = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.fromOffset(12, summaryY),
			Size = UDim2.new(1, -24, 0, summaryHeight),
			Text = summaryText,
			TextColor3 = Theme.colors.mutedText,
			TextSize = if isSmallStatus then 9 else 10,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = Theme.zIndex.ui + 1,
		}),
		BarTrack = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(231, 224, 207),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.fromOffset(12, barTop),
			Size = UDim2.new(1, -24, 0, barHeight),
			ZIndex = Theme.zIndex.ui + 1,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.round,
			}),
			Fill = e("Frame", {
				BackgroundColor3 = if farmState.availableEggs > 0 then Theme.colors.coral else Theme.colors.coin,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(progress, 1),
				ZIndex = Theme.zIndex.ui + 2,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.round,
				}),
			}),
		}),
	})
end

local function createReadyBadge(availableEggs: number)
	if availableEggs <= 0 then
		return nil
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.colors.panel,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.27, 0.48),
		Size = UDim2.fromOffset(132, 38),
		ZIndex = Theme.zIndex.scene + 4,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(231, 224, 207),
			Thickness = 2,
		}),
		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.fromScale(1, 1),
			Text = if availableEggs == 1 then "1 egg ready" else string.format("%d eggs ready", availableEggs),
			TextColor3 = Theme.colors.text,
			TextSize = 15,
			ZIndex = Theme.zIndex.scene + 5,
		}),
	})
end

local function createEggVisual(xOffset: number, yOffset: number, rotation: number)
	local size = Vector2.new(34, 42)

	if hasImage(AssetIds.eggIcon) then
		return e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = AssetIds.eggIcon,
			Position = UDim2.new(0.5, xOffset, 0.5, yOffset),
			Rotation = rotation,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(size.X, size.Y),
			ZIndex = Theme.zIndex.scene + 3,
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.colors.egg,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, xOffset, 0.5, yOffset),
		Rotation = rotation,
		Size = UDim2.fromOffset(size.X, size.Y),
		ZIndex = Theme.zIndex.scene + 3,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.5, 0),
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(201, 170, 112),
			Thickness = 2,
		}),
	})
end

local function createEggPile(availableEggs: number)
	if availableEggs <= 0 then
		return nil
	end

	local eggCount = math.min(availableEggs, MAX_VISIBLE_NEST_EGGS)
	local positions = {
		{ -42, 18, -12 },
		{ -18, 17, 9 },
		{ 8, 18, -4 },
		{ 34, 17, 12 },
		{ -30, -3, 7 },
		{ -4, -4, -10 },
		{ 22, -3, 5 },
		{ -4, -24, 0 },
	}
	local children: {[string]: any} = {}

	for index = 1, eggCount do
		local placement = positions[index]
		children["Egg" .. tostring(index)] = createEggVisual(placement[1], placement[2], placement[3])
	end

	if availableEggs > MAX_VISIBLE_NEST_EGGS then
		children.More = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.colors.panel,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 72, 0.5, -18),
			Size = UDim2.fromOffset(54, 30),
			ZIndex = Theme.zIndex.scene + 5,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(231, 224, 207),
				Thickness = 1,
			}),
			Label = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Size = UDim2.fromScale(1, 1),
				Text = "x" .. tostring(availableEggs),
				TextColor3 = Theme.colors.text,
				TextSize = 14,
				ZIndex = Theme.zIndex.scene + 6,
			}),
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.25, 0.58),
		Size = UDim2.fromOffset(170, 76),
		ZIndex = Theme.zIndex.scene + 3,
	}, children)
end

local function createFeedbackLayer(feedbackItems: {FeedbackItem}, animationTime: number)
	local children: {[string]: any} = {}

	for _, item in feedbackItems do
		local age = animationTime - item.createdAt

		if age >= 0 and age <= FEEDBACK_DURATION_SECONDS then
			local progress = math.clamp(age / FEEDBACK_DURATION_SECONDS, 0, 1)
			local yOffset = -math.floor(progress * 54)
			local key = "Feedback" .. tostring(item.id)

			children[key] = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Theme.colors.panel,
				BackgroundTransparency = 0.12 + progress * 0.78,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(item.xScale, 0, item.yScale, yOffset),
				Size = UDim2.fromOffset(118, 32),
				Text = item.text,
				TextColor3 = item.color,
				TextSize = 18,
				TextStrokeColor3 = Theme.colors.panel,
				TextStrokeTransparency = 0.55 + progress * 0.4,
				TextTransparency = progress,
				ZIndex = Theme.zIndex.ui + 5,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.corner,
				}),
			})
		end
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.zIndex.ui + 5,
	}, children)
end

local function appendFeedbackItems(currentFeedback: {FeedbackItem}, newFeedback: {FeedbackItem}): {FeedbackItem}
	local merged = {}
	local now = os.clock()

	for _, item in currentFeedback do
		if now - item.createdAt <= FEEDBACK_DURATION_SECONDS then
			table.insert(merged, item)
		end
	end

	for _, item in newFeedback do
		table.insert(merged, item)
	end

	while #merged > MAX_FEEDBACK_ITEMS do
		table.remove(merged, 1)
	end

	return merged
end

local function findNewCaredDuckIndex(previousState: FarmState, nextState: FarmState): number?
	for index, nextDuck in nextState.ducks do
		local previousDuck = previousState.ducks[index]

		if nextDuck.mood == PrototypeConfig.duckCare.caredMood then
			if not previousDuck or previousDuck.id ~= nextDuck.id then
				return index
			end

			if previousDuck.mood ~= PrototypeConfig.duckCare.caredMood then
				return index
			end

			if nextDuck.careCooldownSeconds > previousDuck.careCooldownSeconds then
				return index
			end
		end
	end

	return nil
end

local function findLeveledDuckIndex(previousState: FarmState, nextState: FarmState): number?
	for index, nextDuck in nextState.ducks do
		local previousDuck = previousState.ducks[index]

		if previousDuck and previousDuck.id == nextDuck.id and nextDuck.level > previousDuck.level then
			return index
		end
	end

	return nil
end

local function findXpIncreasedDuckIndex(previousState: FarmState, nextState: FarmState): number?
	for index, nextDuck in nextState.ducks do
		local previousDuck = previousState.ducks[index]

		if previousDuck and previousDuck.id == nextDuck.id then
			if nextDuck.level > previousDuck.level or nextDuck.xp > previousDuck.xp then
				return index
			end
		end
	end

	return nil
end

local function findAdvancedQuest(previousState: FarmState, nextState: FarmState): QuestState?
	for _, nextQuest in nextState.quests do
		for _, previousQuest in previousState.quests do
			if previousQuest.id == nextQuest.id and nextQuest.level > previousQuest.level then
				return previousQuest
			end
		end
	end

	return nil
end

local function getCareFeedbackText(previousState: FarmState, nextState: FarmState, requestKind: string): string
	local caredDuckIndex = findNewCaredDuckIndex(previousState, nextState)

	if caredDuckIndex then
		local previousDuck = previousState.ducks[caredDuckIndex]
		local nextDuck = nextState.ducks[caredDuckIndex]

		if previousDuck and nextDuck and nextDuck.careCooldownSeconds <= previousDuck.careCooldownSeconds then
			return "Visitor helped"
		end
	end

	if isHungryRequest(requestKind) then
		if nextState.premiumFeed < previousState.premiumFeed then
			return string.format("Premium +%d XP", PrototypeConfig.duckLevel.xpPerPremiumFeed)
		end

		return string.format("Feed +%d XP", PrototypeConfig.duckLevel.xpPerFeed)
	elseif isSleepyRequest(requestKind) then
		if nextState.pillow < previousState.pillow then
			return string.format("Pillow +%d XP", PrototypeConfig.duckLevel.xpPerPillowRest)
		end

		return string.format("Rest +%d XP", PrototypeConfig.duckLevel.xpPerRest)
	elseif isDirtyRequest(requestKind) then
		return string.format("Clean +%d XP", PrototypeConfig.duckLevel.xpPerClean)
	elseif isThirstyRequest(requestKind) then
		return string.format("Drink +%d XP", PrototypeConfig.duckLevel.xpPerDrink)
	elseif isBoredRequest(requestKind) then
		if nextState.toy < previousState.toy then
			return string.format("Toy +%d XP", PrototypeConfig.duckLevel.xpPerToyPlay)
		end

		return string.format("Play +%d XP", PrototypeConfig.duckLevel.xpPerPlay)
	end

	return string.format("Care +%d XP", PrototypeConfig.duckLevel.xpPerCare)
end

local function createFeedbackForStateChange(
	previousState: FarmState,
	nextState: FarmState,
	nextFeedbackId: () -> number
): {FeedbackItem}
	local feedback = {}

	if nextState.availableEggs > 0 and previousState.availableEggs <= 0 then
		table.insert(
			feedback,
			createFeedbackItem(nextFeedbackId(), "ready", "Egg ready", Theme.colors.text, 0.3, 0.42)
		)
	end

	if nextState.weatherId ~= previousState.weatherId then
		local weatherText = if nextState.weatherId == WEATHER_RAINY_ID
			then "Rain started"
			elseif nextState.weatherId == WEATHER_CLOUDY_ID then "Clouds rolled in"
			elseif nextState.weatherId == WEATHER_STORMY_ID then "Storm rolled in"
			else "Sunny again"
		local weatherColor = if nextState.weatherId == WEATHER_RAINY_ID
			then Theme.colors.pondDark
			elseif nextState.weatherId == WEATHER_CLOUDY_ID then Theme.colors.mutedText
			elseif nextState.weatherId == WEATHER_STORMY_ID then Theme.colors.shadow
			else Theme.colors.coin

		table.insert(
			feedback,
			createFeedbackItem(nextFeedbackId(), "weather", weatherText, weatherColor, 0.5, 0.24)
		)
	end
	if nextState.eggs > previousState.eggs then
		table.insert(
			feedback,
			createFeedbackItem(
				nextFeedbackId(),
				"egg",
				string.format("+%d egg", nextState.eggs - previousState.eggs),
				Theme.colors.text,
				0.48,
				0.42
			)
		)
	end

	if nextState.coins > previousState.coins then
		table.insert(
			feedback,
			createFeedbackItem(
				nextFeedbackId(),
				"coin",
				string.format("+%d coin", nextState.coins - previousState.coins),
				Theme.colors.coin,
				0.88,
				0.22
			)
		)
	end

	local advancedQuest = findAdvancedQuest(previousState, nextState)

	if advancedQuest then
		table.insert(
			feedback,
			createFeedbackItem(nextFeedbackId(), "quest", formatQuestCompleteFeedback(advancedQuest), Theme.colors.coin, 0.5, 0.2)
		)
	end
	if nextState.eggValueLevel > previousState.eggValueLevel then
		table.insert(
			feedback,
			createFeedbackItem(nextFeedbackId(), "upgrade", "Value up", Theme.colors.coral, 0.88, 0.72)
		)
	end

	if nextState.duckCount > previousState.duckCount then
		table.insert(
			feedback,
			createFeedbackItem(nextFeedbackId(), "duck", "Duck joined", Theme.colors.duck, 0.52, 0.38)
		)
	end

	if nextState.duckFeed > previousState.duckFeed then
		table.insert(
			feedback,
			createFeedbackItem(
				nextFeedbackId(),
				"feed",
				string.format("Feed x%d", nextState.duckFeed - previousState.duckFeed),
				Theme.colors.grassDark,
				0.5,
				0.28
			)
		)
	end

	if nextState.premiumFeed > previousState.premiumFeed then
		table.insert(
			feedback,
			createFeedbackItem(
				nextFeedbackId(),
				"premium_feed",
				string.format("Premium x%d", nextState.premiumFeed - previousState.premiumFeed),
				Theme.colors.coin,
				0.5,
				0.28
			)
		)
	end

	if nextState.duckTreat > previousState.duckTreat then
		table.insert(
			feedback,
			createFeedbackItem(
				nextFeedbackId(),
				"treat",
				string.format("Treat x%d", nextState.duckTreat - previousState.duckTreat),
				Theme.colors.duckHighlight,
				0.5,
				0.28
			)
		)
	end

	if nextState.pillow > previousState.pillow then
		table.insert(
			feedback,
			createFeedbackItem(
				nextFeedbackId(),
				"pillow",
				string.format("Pillow x%d", nextState.pillow - previousState.pillow),
				Theme.colors.pondDark,
				0.5,
				0.28
			)
		)
	end

	if nextState.toy > previousState.toy then
		table.insert(
			feedback,
			createFeedbackItem(
				nextFeedbackId(),
				"toy",
				string.format("Toy x%d", nextState.toy - previousState.toy),
				Theme.colors.coral,
				0.5,
				0.28
			)
		)
	end

	if nextState.careRequestDuckIndex > 0 and previousState.careRequestDuckIndex <= 0 then
		local requestText = if isHungryRequest(nextState.careRequestKind)
			then "Hungry duck"
			elseif isSleepyRequest(nextState.careRequestKind) then "Sleepy duck"
			elseif isDirtyRequest(nextState.careRequestKind) then "Dirty duck"
			elseif isThirstyRequest(nextState.careRequestKind) then "Thirsty duck"
			elseif isBoredRequest(nextState.careRequestKind) then "Bored duck"
			else "Duck needs care"

		table.insert(
			feedback,
			createFeedbackItem(nextFeedbackId(), "care_request", requestText, Theme.colors.duckHighlight, 0.5, 0.34)
		)
	end

	local leveledDuckIndex = findLeveledDuckIndex(previousState, nextState)

	if leveledDuckIndex then
		table.insert(
			feedback,
			createFeedbackItem(nextFeedbackId(), "level", "Level up", Theme.colors.duckHighlight, 0.5, 0.34, leveledDuckIndex)
		)
	end

	local caredDuckIndex = findNewCaredDuckIndex(previousState, nextState)

	if caredDuckIndex then
		local previousDuck = previousState.ducks[caredDuckIndex]
		local requestKind = if previousDuck then previousDuck.careRequestKind else ""
		local feedbackText = getCareFeedbackText(previousState, nextState, requestKind)

		table.insert(
			feedback,
			createFeedbackItem(nextFeedbackId(), "care", feedbackText, Theme.colors.duck, 0.5, 0.36, caredDuckIndex)
		)
	end

	if nextState.duckTreat < previousState.duckTreat then
		local treatedDuckIndex = findXpIncreasedDuckIndex(previousState, nextState)
		local treatXpAmount = PrototypeConfig.shop.duckTreat.xpAmount or 0
		local treatFeedbackText = if treatXpAmount > 0 then string.format("Treat +%d XP", treatXpAmount) else "Treat"

		table.insert(
			feedback,
			createFeedbackItem(
				nextFeedbackId(),
				"treat",
				treatFeedbackText,
				Theme.colors.duckHighlight,
				0.5,
				0.34,
				treatedDuckIndex
			)
		)
	end

	return feedback
end

local function createProgressionCard(props: {
	title: string,
	lineOne: string,
	lineTwo: string,
	buttonText: string,
	canActivate: boolean,
	layoutOrder: number,
	width: number?,
	height: number?,
	onActivated: (() -> ())?,
})
	local width = props.width or 210
	local height = props.height or 116
	local isTiny = height <= 80
	local isSmall = height < 100
	local buttonHeight = if isTiny then 18 elseif isSmall then 22 else 24

	return e("Frame", {
		BackgroundColor3 = Theme.colors.panel,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromOffset(width, height),
		ZIndex = Theme.zIndex.ui,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(231, 224, 207),
			Thickness = 2,
		}),
		Title = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(14, if isTiny then 6 elseif isSmall then 7 else 10),
			Size = UDim2.new(1, -28, 0, if isTiny then 16 elseif isSmall then 18 else 23),
			Text = props.title,
			TextColor3 = Theme.colors.text,
			TextSize = if isTiny then 14 elseif isSmall then 16 else 18,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 1,
		}),
		LineOne = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.fromOffset(14, if isTiny then 24 elseif isSmall then 28 else 37),
			Size = UDim2.new(1, -28, 0, if isTiny then 12 elseif isSmall then 14 else 19),
			Text = props.lineOne,
			TextColor3 = Theme.colors.mutedText,
			TextSize = if isTiny then 11 elseif isSmall then 12 else 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 1,
		}),
		LineTwo = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.fromOffset(14, if isTiny then 38 elseif isSmall then 43 else 58),
			Size = UDim2.new(1, -28, 0, if isTiny then 12 elseif isSmall then 14 else 19),
			Text = props.lineTwo,
			TextColor3 = Theme.colors.mutedText,
			TextSize = if isTiny then 11 elseif isSmall then 12 else 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 1,
		}),
		Button = e("TextButton", {
			Active = props.canActivate,
			AutoButtonColor = props.canActivate,
			BackgroundColor3 = if props.canActivate then Theme.colors.coral else Color3.fromRGB(185, 176, 164),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(14, height - buttonHeight - 6),
			Size = UDim2.new(1, -28, 0, buttonHeight),
			Text = props.buttonText,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = if isTiny then 11 elseif isSmall then 12 else 13,
			ZIndex = Theme.zIndex.ui + 1,
			[React.Event.Activated] = if props.canActivate then props.onActivated else nil,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
		}),
	})
end

local function createTesterButton(
	label: string,
	layoutOrder: number,
	layout: LayoutMetrics,
	onActivated: () -> ()
)
	return e("TextButton", {
		AutoButtonColor = true,
		BackgroundColor3 = Color3.fromRGB(79, 94, 88),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		LayoutOrder = layoutOrder,
		Size = UDim2.fromOffset(layout.testerButtonWidth, 28),
		Text = label,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 11,
		ZIndex = Theme.zIndex.ui + 2,
		[React.Event.Activated] = onActivated,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
	})
end

local function createTesterPanel(
	layout: LayoutMetrics,
	isExpanded: boolean,
	onToggle: () -> (),
	farmState: FarmState,
	onOpenGuide: () -> (),
	allowInteractions: boolean
)
	if layout.isShortLandscape and not isExpanded then
		return e("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0),
			AutoButtonColor = allowInteractions,
			BackgroundColor3 = Color3.fromRGB(43, 52, 49),
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0.5, 0, 0, layout.testerTop),
			Size = UDim2.fromOffset(74, layout.testerHeight),
			Text = "TEST",
			TextColor3 = Color3.fromRGB(230, 238, 234),
			TextSize = 11,
			ZIndex = Theme.zIndex.ui + 1,
			[React.Event.Activated] = if allowInteractions then onToggle else nil,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(101, 119, 111),
				Thickness = 1,
			}),
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(43, 52, 49),
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, layout.testerTop),
		Size = UDim2.fromOffset(layout.testerWidth, layout.testerHeight),
		ZIndex = Theme.zIndex.ui + 1,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(101, 119, 111),
			Thickness = 1,
		}),
		Title = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.fromOffset(layout.testerTitleWidth, layout.testerHeight),
			Text = if layout.isCompact then "TEST" else "TESTER",
			TextColor3 = Color3.fromRGB(230, 238, 234),
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 2,
		}),
		Collapse = layout.isShortLandscape and e("TextButton", {
			AutoButtonColor = allowInteractions,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(layout.testerTitleWidth + 12, layout.testerHeight),
			Text = "",
			TextColor3 = Color3.fromRGB(230, 238, 234),
			TextSize = 11,
			ZIndex = Theme.zIndex.ui + 3,
			[React.Event.Activated] = if allowInteractions then onToggle else nil,
		}) or nil,
		Buttons = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12 + layout.testerTitleWidth, (layout.testerHeight - 28) / 2),
			Size = UDim2.new(1, -(layout.testerTitleWidth + 24), 0, 28),
			ZIndex = Theme.zIndex.ui + 2,
		}, {
			Layout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, layout.testerButtonGap),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Coins = createTesterButton(
				if layout.isCompact then "+100" else "+100 Coins",
				1,
				layout,
				if allowInteractions then function()
					actionEvent:FireServer(RemoteProtocol.actions.testAddCoins)
				end else nil
			),
			Eggs = createTesterButton(
				if layout.isCompact then "+10" else "+10 Ready",
				2,
				layout,
				if allowInteractions then function()
					actionEvent:FireServer(RemoteProtocol.actions.testReadyEggs)
				end else nil
			),
			Duck = createTesterButton(
				if layout.isCompact then "+Duck" else "+1 Duck",
				3,
				layout,
				if allowInteractions then function()
					actionEvent:FireServer(RemoteProtocol.actions.testAddDuck)
				end else nil
			),
			Need = createTesterButton(
				"Need",
				4,
				layout,
				if allowInteractions then function()
					actionEvent:FireServer(RemoteProtocol.actions.testCareRequest)
				end else nil
			),
			Hungry = createTesterButton(
				if layout.isShortLandscape then "Hun" else "Hungry",
				5,
				layout,
				if allowInteractions then function()
					actionEvent:FireServer(RemoteProtocol.actions.testHungryRequest)
				end else nil
			),
			Sleepy = createTesterButton(
				if layout.isShortLandscape then "Slp" else "Sleepy",
				6,
				layout,
				if allowInteractions then function()
					actionEvent:FireServer(RemoteProtocol.actions.testSleepyRequest)
				end else nil
			),
			Dirty = createTesterButton(
				if layout.isShortLandscape then "Dty" else "Dirty",
				7,
				layout,
				if allowInteractions then function()
					actionEvent:FireServer(RemoteProtocol.actions.testDirtyRequest)
				end else nil
			),
			Thirsty = createTesterButton(
				if layout.isShortLandscape then "Thr" else "Thirsty",
				8,
				layout,
				if allowInteractions then function()
					actionEvent:FireServer(RemoteProtocol.actions.testThirstyRequest)
				end else nil
			),
			Bored = createTesterButton(
				if layout.isShortLandscape then "Brd" else "Bored",
				9,
				layout,
				if allowInteractions then function()
					actionEvent:FireServer(RemoteProtocol.actions.testBoredRequest)
				end else nil
			),
			Guide = createTesterButton(
				if layout.isShortLandscape then "Gde" else "Guide",
				10,
				layout,
				if allowInteractions then onOpenGuide else nil
			),
			Weather = createTesterButton(
				if farmState.weatherId == WEATHER_SUNNY_ID
					then "Cld"
					elseif farmState.weatherId == WEATHER_CLOUDY_ID then "Rain"
					elseif farmState.weatherId == WEATHER_RAINY_ID then "Stm"
					else "Sun",
				11,
				layout,
				if allowInteractions then function()
					actionEvent:FireServer(RemoteProtocol.actions.testToggleWeather)
				end else nil
			),
			Reset = createTesterButton(
				if layout.isShortLandscape then "Rst" else "Reset",
				12,
				layout,
				if allowInteractions then function()
					actionEvent:FireServer(RemoteProtocol.actions.testReset)
				end else nil
			),
		}),
	})
end

local function FarmScreen()
	local upgrade = PrototypeConfig.firstUpgrade
	local farmState, setFarmState = React.useState(createDefaultFarmState() :: FarmState)
	local animationTime, setAnimationTime = React.useState(os.clock())
	local feedbackItems, setFeedbackItems = React.useState({} :: {FeedbackItem})
	local screenSize, setScreenSize = React.useState(getViewportSize())
	local displaySize, setDisplaySize = React.useState(getDisplaySize())
	local testerExpanded, setTesterExpanded = React.useState(false)
	local upgradesOpen, setUpgradesOpen = React.useState(false)
	local questPanelExpanded, setQuestPanelExpanded = React.useState(false)
	local visitPanelOpen, setVisitPanelOpen = React.useState(false)
	local tutorialVisible, setTutorialVisible = React.useState(false)
	local tutorialStepIndex, setTutorialStepIndex = React.useState(1)
	local selectedDuckIndex, setSelectedDuckIndex = React.useState(nil :: number?)
	local profileDuckIndex, setProfileDuckIndex = React.useState(nil :: number?)
	local renamingDuckIndex, setRenamingDuckIndex = React.useState(nil :: number?)
	local renameText, setRenameText = React.useState("")
	local screenMode, setScreenMode = React.useState(SCREEN_MODE_FARM)
	local transitionAlpha, setTransitionAlpha = React.useState(0)
	local isTransitioning, setIsTransitioning = React.useState(false)
	local eggCatchState, setEggCatchState = React.useState(createDefaultEggCatchState() :: EggCatchState)
	local eggCatchResult, setEggCatchResult = React.useState(nil :: EggCatchResult?)
	local eggCatchSessionId, setEggCatchSessionId = React.useState(nil :: number?)
	local eggCatchReward, setEggCatchReward = React.useState(nil :: EggCatchReward?)
	local eggCatchClaimStatus, setEggCatchClaimStatus = React.useState("idle")
	local eggCatchClaimMessage, setEggCatchClaimMessage = React.useState("")
	local previousStateRef = React.useRef(nil :: FarmState?)
	local feedbackIdRef = React.useRef(0)
	local scenePointerHandlerRef = React.useRef(nil :: ((Vector2, number?) -> ())?)
	local eggCatchFinishedRef = React.useRef(false)
	local eggCatchClaimRequestedSessionIdRef = React.useRef(0)
	local eggCatchSessionIdRef = React.useRef(nil :: number?)
	local tutorialAutoShownRef = React.useRef(false)
	local previousCareRequestDuckIndexRef = React.useRef(0)
	local freshProfileStarterFeedbackShownRef = React.useRef(false)
	local layout = createLayoutMetrics(screenSize, displaySize)
	eggCatchSessionIdRef.current = eggCatchSessionId
	local activeTutorialStepId = if tutorialVisible
		then TUTORIAL_STEPS[math.clamp(tutorialStepIndex, 1, #TUTORIAL_STEPS)].id
		else nil
	local isTutorialCareStepActive = tutorialVisible and activeTutorialStepId == "care"
	local isViewingOtherFarm = farmState.isVisitingFarm == true
	local function isTutorialActionAllowed(stepId: string): boolean
		return activeTutorialStepId == nil or activeTutorialStepId == stepId
	end
	local function isTutorialCareDuckAllowed(duckIndex: number?): boolean
		if activeTutorialStepId ~= "care" or duckIndex == nil then
			return false
		end

		return farmState.careRequestDuckIndex > 0 and duckIndex == farmState.careRequestDuckIndex
	end
	local isMinigameMode = screenMode == SCREEN_MODE_MINIGAMES
		or screenMode == SCREEN_MODE_EGG_CATCH
		or screenMode == SCREEN_MODE_EGG_CATCH_RESULTS
	local children = if screenMode == SCREEN_MODE_SHOP
		then createShopBackground()
		elseif isMinigameMode then createMinigameBackground(animationTime)
		else createBackground(hasImage(AssetIds.farmBackground))
	local function runSceneTransition(nextMode: string)
		if isTransitioning or screenMode == nextMode then
			return
		end

		setIsTransitioning(true)
		setSelectedDuckIndex(nil)
		setProfileDuckIndex(nil)
		setRenamingDuckIndex(nil)
		setQuestPanelExpanded(false)
		setVisitPanelOpen(false)

		task.spawn(function()
			for step = 1, SCENE_FADE_STEPS do
				setTransitionAlpha(step / SCENE_FADE_STEPS)
				task.wait(SCENE_FADE_STEP_SECONDS)
			end

			setScreenMode(nextMode)

			for step = SCENE_FADE_STEPS - 1, 0, -1 do
				setTransitionAlpha(step / SCENE_FADE_STEPS)
				task.wait(SCENE_FADE_STEP_SECONDS)
			end

			setTransitionAlpha(0)
			setIsTransitioning(false)
		end)
	end
	local function buyDuckFeed()
		if tutorialVisible then
			return
		end

		actionEvent:FireServer(RemoteProtocol.actions.buyShopItem, {
			itemId = PrototypeConfig.shop.duckFeed.id,
		})
	end
	local function buyPremiumFeed()
		if tutorialVisible then
			return
		end

		actionEvent:FireServer(RemoteProtocol.actions.buyShopItem, {
			itemId = PrototypeConfig.shop.premiumFeed.id,
		})
	end
	local function buyDuckTreat()
		if tutorialVisible then
			return
		end

		actionEvent:FireServer(RemoteProtocol.actions.buyShopItem, {
			itemId = PrototypeConfig.shop.duckTreat.id,
		})
	end
	local function buyPillow()
		if tutorialVisible then
			return
		end

		actionEvent:FireServer(RemoteProtocol.actions.buyShopItem, {
			itemId = PrototypeConfig.shop.pillow.id,
		})
	end
	local function buyToy()
		if tutorialVisible then
			return
		end

		actionEvent:FireServer(RemoteProtocol.actions.buyShopItem, {
			itemId = PrototypeConfig.shop.toy.id,
		})
	end
	local function resetEggCatch()
		setEggCatchState(createDefaultEggCatchState())
	end
	local function resetEggCatchRewardState()
		setEggCatchSessionId(nil)
		setEggCatchReward(nil)
		setEggCatchClaimStatus("idle")
		setEggCatchClaimMessage("")
		eggCatchClaimRequestedSessionIdRef.current = 0
	end
	local function openMinigamesMenu()
		setEggCatchResult(nil)
		resetEggCatch()
		resetEggCatchRewardState()
		runSceneTransition(SCREEN_MODE_MINIGAMES)
	end
	local function startEggCatchRound()
		setEggCatchResult(nil)
		resetEggCatch()
		resetEggCatchRewardState()
		actionEvent:FireServer(RemoteProtocol.actions.startEggCatchRound)
		runSceneTransition(SCREEN_MODE_EGG_CATCH)
	end
	local function finishEggCatchRound(finalState: EggCatchState)
		setEggCatchResult({
			score = finalState.score,
			missed = finalState.missed,
			bestStreak = finalState.bestStreak,
		})
		setEggCatchReward(nil)
		setEggCatchClaimMessage("")
		setEggCatchClaimStatus(if eggCatchSessionId then "idle" else "awaiting_session")
		runSceneTransition(SCREEN_MODE_EGG_CATCH_RESULTS)
	end
	local function claimEggCatchReward()
		if not eggCatchSessionId or not eggCatchResult then
			setEggCatchClaimStatus("awaiting_session")
			setEggCatchClaimMessage("Preparing reward...")
			return
		end

		eggCatchClaimRequestedSessionIdRef.current = eggCatchSessionId
		setEggCatchClaimStatus("claiming")
		setEggCatchClaimMessage("Claiming reward...")
		actionEvent:FireServer(RemoteProtocol.actions.claimEggCatchReward, {
			sessionId = eggCatchSessionId,
			score = eggCatchResult.score,
		})
	end
	local function retryEggCatchReward()
		eggCatchClaimRequestedSessionIdRef.current = 0
		claimEggCatchReward()
	end
	local function moveEggCatch(direction: number)
		if screenMode ~= SCREEN_MODE_EGG_CATCH or isTransitioning then
			return
		end

		setEggCatchState(function(currentState)
			return moveEggCatchBasket(currentState, direction)
		end)
	end
	local function moveEggCatchToPointer(pointerPosition: Vector2)
		if screenMode ~= SCREEN_MODE_EGG_CATCH or isTransitioning then
			return
		end

		setEggCatchState(function(currentState)
			return setEggCatchBasketFromPointer(currentState, pointerPosition, screenSize)
		end)
	end
	local function returnToFarm()
		setEggCatchResult(nil)
		resetEggCatch()
		resetEggCatchRewardState()
		runSceneTransition(SCREEN_MODE_FARM)
	end
	local function visitFarm(userId: number)
		if tutorialVisible or isTransitioning then
			return
		end

		setVisitPanelOpen(false)
		setSelectedDuckIndex(nil)
		setProfileDuckIndex(nil)
		setRenamingDuckIndex(nil)
		actionEvent:FireServer(RemoteProtocol.actions.visitFarm, {
			userId = userId,
		})
	end
	local function returnHomeFarm()
		setVisitPanelOpen(false)
		setSelectedDuckIndex(nil)
		setProfileDuckIndex(nil)
		setRenamingDuckIndex(nil)
		actionEvent:FireServer(RemoteProtocol.actions.returnHomeFarm)
	end
	local function requestCare(duckIndex: number)
		if isViewingOtherFarm then
			actionEvent:FireServer(RemoteProtocol.actions.visitorHelpDuck, {
				duckIndex = duckIndex,
			})
			setSelectedDuckIndex(nil)
			setProfileDuckIndex(nil)
			setRenamingDuckIndex(nil)
			return
		end

		if tutorialVisible and not isTutorialCareDuckAllowed(duckIndex) then
			return
		end

		actionEvent:FireServer(RemoteProtocol.actions.careForDucks, {
			duckIndex = duckIndex,
		})
		setSelectedDuckIndex(nil)
		setProfileDuckIndex(nil)
		setRenamingDuckIndex(nil)
	end
	local function openProfile(duckIndex: number)
		if tutorialVisible then
			return
		end

		setProfileDuckIndex(duckIndex)
		setRenamingDuckIndex(nil)
	end
	local function selectDuck(index: number)
		setProfileDuckIndex(nil)
		setRenamingDuckIndex(nil)
		setSelectedDuckIndex(function(currentIndex)
			if currentIndex == index then
				return nil
			end

			return index
		end)
	end
	local function handleScenePointer(pointerPosition: Vector2, targetScale: number?)
		if screenMode ~= SCREEN_MODE_FARM or isTransitioning then
			return
		end

		if tutorialVisible and activeTutorialStepId ~= "care" then
			return
		end

		if isPointInsideProfilePanel(pointerPosition, profileDuckIndex, screenSize, layout, animationTime, feedbackItems) then
			return
		end

		if
			isPointInsideDuckInteractionBubble(
				pointerPosition,
				selectedDuckIndex,
				farmState.duckCount,
				screenSize,
				layout,
				animationTime,
				feedbackItems
			)
		then
			return
		end

		local targetDuckIndex = findDuckAtPosition(
			screenSize,
			farmState.duckCount,
			animationTime,
			feedbackItems,
			pointerPosition,
			targetScale
		)

		if tutorialVisible then
			if isTutorialCareDuckAllowed(targetDuckIndex) then
				selectDuck(targetDuckIndex :: number)
			end

			return
		end

		if targetDuckIndex then
			selectDuck(targetDuckIndex)
		elseif selectedDuckIndex ~= nil then
			setSelectedDuckIndex(nil)
			setProfileDuckIndex(nil)
			setRenamingDuckIndex(nil)
		end
	end
	local function startRename(duckIndex: number, currentName: string)
		if isViewingOtherFarm then
			return
		end

		setProfileDuckIndex(duckIndex)
		setRenamingDuckIndex(duckIndex)
		setRenameText(currentName)
	end
	local function submitRename(duckIndex: number)
		if isViewingOtherFarm then
			return
		end

		actionEvent:FireServer(RemoteProtocol.actions.renameDuck, {
			duckIndex = duckIndex,
			name = renameText,
		})
		setRenamingDuckIndex(nil)
	end
	local function cancelRename()
		setRenamingDuckIndex(nil)
		setRenameText("")
	end
	local function useTreatOnDuck(duckIndex: number)
		if isViewingOtherFarm then
			return
		end

		actionEvent:FireServer(RemoteProtocol.actions.useTreatOnDuck, {
			duckIndex = duckIndex,
		})
	end
	local function closeTutorial()
		setTutorialVisible(false)
	end
	local function advanceTutorial(expectedStepId: string)
		if not tutorialVisible or activeTutorialStepId ~= expectedStepId then
			return
		end

		if tutorialStepIndex >= #TUTORIAL_STEPS then
			closeTutorial()
			return
		end

		setTutorialStepIndex(tutorialStepIndex + 1)
	end
	local function openTutorialFromStart()
		setSelectedDuckIndex(nil)
		setProfileDuckIndex(nil)
		setRenamingDuckIndex(nil)
		setTutorialStepIndex(1)
		setTutorialVisible(true)
	end
	scenePointerHandlerRef.current = handleScenePointer
	React.useEffect(function()
		local connection = stateEvent.OnClientEvent:Connect(function(nextState)
			if type(nextState) == "table" then
				local previousState = previousStateRef.current
				local typedState = nextState :: FarmState

				if previousState and previousState.farmOwnerUserId == typedState.farmOwnerUserId then
					local function nextFeedbackId(): number
						feedbackIdRef.current += 1
						return feedbackIdRef.current
					end

					local newFeedback = createFeedbackForStateChange(previousState, typedState, nextFeedbackId)

					if #newFeedback > 0 then
						setFeedbackItems(function(currentFeedback)
							return appendFeedbackItems(currentFeedback, newFeedback)
						end)
					end
				elseif previousState then
					setSelectedDuckIndex(nil)
					setProfileDuckIndex(nil)
					setRenamingDuckIndex(nil)
					setFeedbackItems({})
				end

				previousStateRef.current = typedState
				setFarmState(typedState)
			end
		end)

		actionEvent:FireServer(RemoteProtocol.actions.requestState)

		return function()
			connection:Disconnect()
		end
	end, {})

	React.useEffect(function()
		if tutorialAutoShownRef.current or screenMode ~= SCREEN_MODE_FARM or farmState.saveStatus == "loading" then
			return
		end

		tutorialAutoShownRef.current = true

		if not farmState.isFreshProfile then
			return
		end

		setSelectedDuckIndex(nil)
		setProfileDuckIndex(nil)
		setRenamingDuckIndex(nil)
		setTutorialStepIndex(1)
		setTutorialVisible(true)
	end, {screenMode, farmState.saveStatus, farmState.isFreshProfile})

	React.useEffect(function()
		if freshProfileStarterFeedbackShownRef.current or not farmState.isFreshProfile or farmState.saveStatus == "loading" then
			return
		end

		local starterFeedAmount = PrototypeConfig.startingDuckFeed

		if starterFeedAmount <= 0 or farmState.duckFeed < starterFeedAmount then
			return
		end

		freshProfileStarterFeedbackShownRef.current = true
		feedbackIdRef.current += 1

		setFeedbackItems(function(currentFeedback)
			return appendFeedbackItems(currentFeedback, {
				createFeedbackItem(
					feedbackIdRef.current,
					"starter_feed",
					string.format("Starter Feed x%d", starterFeedAmount),
					Theme.colors.grassDark,
					0.5,
					0.28
				),
			})
		end)
	end, { farmState.isFreshProfile, farmState.saveStatus, farmState.duckFeed })

	React.useEffect(function()
		if not isTutorialCareStepActive or screenMode ~= SCREEN_MODE_FARM then
			return
		end

		local requestDuckIndex = farmState.careRequestDuckIndex

		if requestDuckIndex > 0 and selectedDuckIndex ~= requestDuckIndex then
			setSelectedDuckIndex(requestDuckIndex)
			setProfileDuckIndex(nil)
			setRenamingDuckIndex(nil)
		end
	end, { isTutorialCareStepActive, screenMode, farmState.careRequestDuckIndex, selectedDuckIndex })

	React.useEffect(function()
		local previousRequestDuckIndex = previousCareRequestDuckIndexRef.current
		local currentRequestDuckIndex = farmState.careRequestDuckIndex

		if isTutorialCareStepActive
			and screenMode == SCREEN_MODE_FARM
			and previousRequestDuckIndex > 0
			and currentRequestDuckIndex <= 0 then
			advanceTutorial("care")
		end

		previousCareRequestDuckIndexRef.current = currentRequestDuckIndex
	end, { isTutorialCareStepActive, screenMode, farmState.careRequestDuckIndex })

	React.useEffect(function()
		local connection = noticeEvent.OnClientEvent:Connect(function(noticePayload)
			if typeof(noticePayload) ~= "table" then
				return
			end

			local notice = noticePayload :: {[string]: any}
			local kind = if typeof(notice.kind) == "string" then notice.kind else ""

			if kind == RemoteProtocol.notices.eggCatchStarted then
				local sessionId = if typeof(notice.sessionId) == "number" then notice.sessionId else nil

				if sessionId and sessionId % 1 == 0 then
					setEggCatchSessionId(sessionId)
				end
			elseif kind == RemoteProtocol.notices.dailyCheckInClaimed then
				local rewardCoins = if typeof(notice.rewardCoins) == "number" then notice.rewardCoins else 0
				local rewardTreat = if typeof(notice.rewardTreat) == "number" then notice.rewardTreat else 0
				local streakDay = if typeof(notice.streakDay) == "number" then notice.streakDay else 0

				if rewardCoins > 0 then
					local dailyText = if streakDay > 0
						then string.format("Day %d streak! +%d coins", streakDay, rewardCoins)
						else string.format("Daily +%d coins", rewardCoins)

					if rewardTreat > 0 then
						dailyText ..= string.format(" + Treat x%d", rewardTreat)
					end

					feedbackIdRef.current += 1
					setFeedbackItems(function(items: {FeedbackItem})
						local nextItems = table.clone(items)
						table.insert(nextItems, createFeedbackItem(
							feedbackIdRef.current,
							"daily",
							dailyText,
							Theme.colors.coin,
							0.5,
							0.18
						))
						return nextItems
					end)
				end
			elseif kind == RemoteProtocol.notices.dailyQuestCompleted then
				local rewardCoins = if typeof(notice.rewardCoins) == "number" then notice.rewardCoins else 0
				local displayName = if typeof(notice.displayName) == "string" then notice.displayName else "Daily goal"
				local rewardDuckFeed = if typeof(notice.rewardDuckFeed) == "number" then notice.rewardDuckFeed else 0
				local rewardDuckTreat = if typeof(notice.rewardDuckTreat) == "number" then notice.rewardDuckTreat else 0

				if rewardCoins > 0 then
					local dailyQuestText = string.format("%s done! +%d coins", displayName, rewardCoins)

					if rewardDuckFeed > 0 then
						dailyQuestText ..= string.format(" + Feed x%d", rewardDuckFeed)
					end

					if rewardDuckTreat > 0 then
						dailyQuestText ..= string.format(" + Treat x%d", rewardDuckTreat)
					end

					feedbackIdRef.current += 1
					setFeedbackItems(function(items: {FeedbackItem})
						local nextItems = table.clone(items)
						table.insert(nextItems, createFeedbackItem(
							feedbackIdRef.current,
							"daily_quest",
							dailyQuestText,
							Theme.colors.coin,
							0.5,
							0.21
						))
						return nextItems
					end)
				end
			elseif kind == RemoteProtocol.notices.dailyQuestBonus then
				local bonusCoins = if typeof(notice.bonusCoins) == "number" then notice.bonusCoins else 0

				if bonusCoins > 0 then
					feedbackIdRef.current += 1
					setFeedbackItems(function(items: {FeedbackItem})
						local nextItems = table.clone(items)
						table.insert(nextItems, createFeedbackItem(
							feedbackIdRef.current,
							"daily_bonus",
							string.format("All daily goals done! +%d bonus coins", bonusCoins),
							Theme.colors.coral,
							0.5,
							0.24
						))
						return nextItems
					end)
				end
			elseif kind == RemoteProtocol.notices.comebackGift then
				local giftFeed = if typeof(notice.duckFeed) == "number" then notice.duckFeed else 0
				local giftTreat = if typeof(notice.duckTreat) == "number" then notice.duckTreat else 0

				if giftFeed > 0 or giftTreat > 0 then
					local giftParts = {}

					if giftFeed > 0 then
						table.insert(giftParts, string.format("Feed x%d", giftFeed))
					end

					if giftTreat > 0 then
						table.insert(giftParts, string.format("Treat x%d", giftTreat))
					end

					feedbackIdRef.current += 1
					setFeedbackItems(function(items: {FeedbackItem})
						local nextItems = table.clone(items)
						table.insert(nextItems, createFeedbackItem(
							feedbackIdRef.current,
							"comeback",
							string.format("Your ducks missed you! Gift: %s", table.concat(giftParts, " + ")),
							Theme.colors.coral,
							0.5,
							0.27
						))
						return nextItems
					end)
				end
			elseif kind == RemoteProtocol.notices.offlineProgress then
				local offlineEggs = if typeof(notice.eggs) == "number" then notice.eggs else 0
				local awaySeconds = if typeof(notice.awaySeconds) == "number" then notice.awaySeconds else 0

				if offlineEggs > 0 then
					local awayMinutes = math.max(1, math.floor(awaySeconds / 60))
					feedbackIdRef.current += 1
					setFeedbackItems(function(items: {FeedbackItem})
						local nextItems = table.clone(items)
						table.insert(nextItems, createFeedbackItem(
							feedbackIdRef.current,
							"offline",
							string.format(
								"Welcome back! Your ducks laid %d egg%s while you were away (%dm)",
								offlineEggs,
								if offlineEggs == 1 then "" else "s",
								awayMinutes
							),
							Theme.colors.grassDark,
							0.5,
							0.24
						))
						return nextItems
					end)
				end
			elseif kind == RemoteProtocol.notices.eggCatchReward then
				local sessionId = if typeof(notice.sessionId) == "number" then notice.sessionId else nil
				local success = notice.success == true
				local message = if typeof(notice.message) == "string" then notice.message else ""
				local currentSessionId = eggCatchSessionIdRef.current
				local requestedSessionId = eggCatchClaimRequestedSessionIdRef.current

				if not sessionId or sessionId % 1 ~= 0 then
					return
				end

				if requestedSessionId > 0 and sessionId ~= requestedSessionId then
					return
				end

				if requestedSessionId <= 0 and currentSessionId == nil then
					return
				end

				if requestedSessionId <= 0 and currentSessionId and sessionId ~= currentSessionId then
					return
				end

				if success then
					setEggCatchReward({
						sessionId = sessionId,
						score = if typeof(notice.score) == "number" then notice.score else 0,
						coins = if typeof(notice.coins) == "number" then notice.coins else 0,
						duckFeed = if typeof(notice.duckFeed) == "number" then notice.duckFeed else 0,
						duckTreat = if typeof(notice.duckTreat) == "number" then notice.duckTreat else 0,
						message = message,
					})
					setEggCatchClaimStatus("claimed")
					setEggCatchClaimMessage(message)
				else
					setEggCatchClaimStatus("failed")
					setEggCatchClaimMessage(if message ~= "" then message else "Reward not claimed")
				end
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	React.useEffect(function()
		local inputEndedConnection = UserInputService.InputEnded:Connect(function(inputObject, gameProcessedEvent)
			if gameProcessedEvent or not isDuckPointerInput(inputObject) then
				return
			end

			local handler = scenePointerHandlerRef.current

			if handler then
				handler(getPointerPosition(inputObject), nil)
			end
		end)
		local touchTapConnection = UserInputService.TouchTap:Connect(function(touchPositions)
			local handler = scenePointerHandlerRef.current
			local touchPosition = touchPositions[1]

			if handler and touchPosition then
				handler(getTouchPosition(touchPosition), DUCK_TOUCH_TARGET_SCALE)
			end
		end)

		return function()
			inputEndedConnection:Disconnect()
			touchTapConnection:Disconnect()
		end
	end, {})

	React.useEffect(function()
		local inputBeganConnection = UserInputService.InputBegan:Connect(function(inputObject, gameProcessedEvent)
			if gameProcessedEvent or screenMode ~= SCREEN_MODE_EGG_CATCH or isTransitioning then
				return
			end

			if inputObject.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end

			if inputObject.KeyCode == Enum.KeyCode.A or inputObject.KeyCode == Enum.KeyCode.Left then
				moveEggCatch(-1)
			elseif inputObject.KeyCode == Enum.KeyCode.D or inputObject.KeyCode == Enum.KeyCode.Right then
				moveEggCatch(1)
			end
		end)

		return function()
			inputBeganConnection:Disconnect()
		end
	end, {screenMode, isTransitioning})

	React.useEffect(function()
		local inputChangedConnection = UserInputService.InputChanged:Connect(function(inputObject, gameProcessedEvent)
			if gameProcessedEvent or screenMode ~= SCREEN_MODE_EGG_CATCH or isTransitioning then
				return
			end

			if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
				moveEggCatchToPointer(getPointerPosition(inputObject))
			elseif inputObject.UserInputType == Enum.UserInputType.Touch then
				moveEggCatchToPointer(getTouchPosition(inputObject.Position))
			end
		end)

		return function()
			inputChangedConnection:Disconnect()
		end
	end, {screenMode, isTransitioning, screenSize})

	React.useEffect(function()
		local isMounted = true

		task.spawn(function()
			while isMounted do
				setAnimationTime(os.clock())
				task.wait(ANIMATION_STEP_SECONDS)
			end
		end)

		return function()
			isMounted = false
		end
	end, {})

	React.useEffect(function()
		if screenMode ~= SCREEN_MODE_EGG_CATCH or isTransitioning then
			return
		end

		local isMounted = true

		task.spawn(function()
			while isMounted do
				setEggCatchState(function(currentState)
					return stepEggCatchState(currentState, ANIMATION_STEP_SECONDS)
				end)
				task.wait(ANIMATION_STEP_SECONDS)
			end
		end)

		return function()
			isMounted = false
		end
	end, {screenMode, isTransitioning})

	React.useEffect(function()
		if screenMode ~= SCREEN_MODE_EGG_CATCH then
			eggCatchFinishedRef.current = false
			return
		end

		if eggCatchState.timeLeft <= 0 and not eggCatchFinishedRef.current then
			eggCatchFinishedRef.current = true
			finishEggCatchRound(eggCatchState)
		end
	end, {
		screenMode,
		eggCatchState.timeLeft,
		eggCatchState.score,
		eggCatchState.missed,
		eggCatchState.bestStreak,
	})

	React.useEffect(function()
		if screenMode ~= SCREEN_MODE_EGG_CATCH_RESULTS or isTransitioning or not eggCatchResult then
			return
		end

		if eggCatchClaimStatus == "claimed" or eggCatchClaimStatus == "claiming" then
			return
		end

		if not eggCatchSessionId then
			if eggCatchClaimStatus ~= "awaiting_session" then
				setEggCatchClaimStatus("awaiting_session")
				setEggCatchClaimMessage("Preparing reward...")
			end
			return
		end

		if eggCatchClaimRequestedSessionIdRef.current == eggCatchSessionId then
			return
		end

		claimEggCatchReward()
	end, { screenMode, isTransitioning, eggCatchResult, eggCatchSessionId, eggCatchClaimStatus })

	React.useEffect(function()
		if eggCatchClaimStatus ~= "awaiting_session" and eggCatchClaimStatus ~= "claiming" then
			return
		end

		local active = true
		local expectedStatus = eggCatchClaimStatus

		task.delay(2, function()
			if not active then
				return
			end

			setEggCatchClaimStatus(function(currentStatus)
				if currentStatus ~= expectedStatus then
					return currentStatus
				end

				return "failed"
			end)
			setEggCatchClaimMessage(function(currentMessage)
				if expectedStatus == "awaiting_session" then
					return "Reward session missing"
				elseif expectedStatus == "claiming" and currentMessage == "Claiming reward..." then
					return "Reward claim timed out"
				end

				return currentMessage
			end)
		end)

		return function()
			active = false
		end
	end, { eggCatchClaimStatus })

	React.useEffect(function()
		local camera = workspace.CurrentCamera
		local connections = {}

		if camera then
			table.insert(
				connections,
				camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
					setScreenSize(camera.ViewportSize)
				end)
			)
			setScreenSize(camera.ViewportSize)
		end

		table.insert(
			connections,
			GuiService:GetPropertyChangedSignal("ViewportDisplaySize"):Connect(function()
				setDisplaySize(GuiService.ViewportDisplaySize)
			end)
		)
		setDisplaySize(GuiService.ViewportDisplaySize)

		return function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end
	end, {})

	if screenMode == SCREEN_MODE_FARM then
		children.WeatherOverlay = createWeatherOverlay(farmState, animationTime)
		children.WeatherBadge = createWeatherBadge(farmState, layout)
		children.QuestPanel = createQuestPanel(farmState, layout, questPanelExpanded, function()
			setQuestPanelExpanded(function(current)
				return not current
			end)
		end)
		children.Ducks = createDuckGroup(
			farmState.duckCount,
			animationTime,
			feedbackItems,
			selectedDuckIndex,
			farmState
		)
		children.CareRequestPrompt = createDuckCareRequestPrompt(farmState, selectedDuckIndex, animationTime, feedbackItems, layout)
		children.EggPile = createEggPile(farmState.availableEggs)
		children.ReadyBadge = if layout.showReadyBadge then createReadyBadge(farmState.availableEggs) else nil
		children.EggStatus = if layout.showEggStatus then createEggStatusCard(farmState, layout, IS_STUDIO) else nil
		children.DuckInteractionBubble = createDuckInteractionBubble(
			selectedDuckIndex,
			farmState.duckCount,
			farmState,
			animationTime,
			feedbackItems,
			layout,
			isTutorialCareStepActive,
			isViewingOtherFarm,
			farmState.visitorHelpEnabled,
			requestCare,
			openProfile
		)
		children.DuckProfile = createDuckProfilePanel(
			profileDuckIndex,
			farmState,
			animationTime,
			feedbackItems,
			screenSize,
			layout,
			renamingDuckIndex,
			renameText,
			isViewingOtherFarm,
			startRename,
			setRenameText,
			submitRename,
			cancelRename,
			useTreatOnDuck
		)

		if IS_STUDIO then
			children.TesterPanel = createTesterPanel(layout, testerExpanded, function()
				setTesterExpanded(function(current)
					return not current
				end)
			end, farmState, openTutorialFromStart, not tutorialVisible and not isViewingOtherFarm)
		end

		children.TopBar = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(layout.sideMargin, layout.topY),
			Size = UDim2.new(1, -layout.sideMargin * 2, 0, layout.counterHeight),
			ZIndex = Theme.zIndex.ui,
		}, {
			Eggs = e(ResourceCounter, {
				title = "Eggs",
				value = tostring(farmState.eggs),
				accentColor = Theme.colors.egg,
				image = AssetIds.eggIcon,
				width = layout.counterWidth,
				height = layout.counterHeight,
			}),
			Coins = e("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromOffset(layout.counterWidth, layout.counterHeight),
				ZIndex = Theme.zIndex.ui,
			}, {
				Counter = e(ResourceCounter, {
					title = "Coins",
					value = formatCoinCount(farmState.coins),
					accentColor = Theme.colors.coin,
					image = AssetIds.coinIcon,
					width = layout.counterWidth,
					height = layout.counterHeight,
				}),
			}),
		})

		local canOpenMinigames = not isViewingOtherFarm and not isTransitioning and not tutorialVisible
		local buyDuckNeedsCoins = activeTutorialStepId == "buy_duck" and not farmState.canBuyDuck
		local canCollectEggs = not isViewingOtherFarm
			and farmState.availableEggs > 0
			and (isTutorialActionAllowed("collect") or buyDuckNeedsCoins)
		local canSellEggs = not isViewingOtherFarm
			and farmState.eggs > 0
			and (isTutorialActionAllowed("sell") or buyDuckNeedsCoins)
		local canOpenShop = not isViewingOtherFarm and not isTransitioning and isTutorialActionAllowed("shop")
		local canBuyEggValue = not isViewingOtherFarm and farmState.canBuyEggValueUpgrade and not tutorialVisible
		local canBuyDuck = not isViewingOtherFarm and farmState.canBuyDuck and isTutorialActionAllowed("buy_duck")
		local canUseFarmVisit = not isTransitioning and not tutorialVisible
		local upgradesVisible = upgradesOpen or activeTutorialStepId == "buy_duck"
		local upgradesButtonWidth = if layout.isShortLandscape then 96 else 116
		local upgradesButtonHeight = if layout.isShortLandscape then 32 else 36
		local upgradesButtonPosition = if layout.isShortLandscape and upgradesVisible
			then UDim2.new(
				1,
				-layout.sideMargin,
				1,
				-(layout.actionBottom + layout.actionButtonHeight + 8 + layout.progressionStackHeight + 8)
			)
			else UDim2.new(1, -layout.sideMargin, 1, -(layout.actionBottom + layout.actionButtonHeight + 10))

		children.MinigamesButton = e("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0),
			AutoButtonColor = canOpenMinigames,
			BackgroundColor3 = Color3.fromRGB(43, 52, 49),
			BorderSizePixel = 0,
			Position = getMinigamesButtonPosition(layout, IS_STUDIO),
			Size = UDim2.fromOffset(if layout.isShortLandscape then 84 else 92, if layout.isShortLandscape then 32 else 36),
			Text = "",
			ZIndex = Theme.zIndex.ui + 1,
			[React.Event.Activated] = if canOpenMinigames then openMinigamesMenu else nil,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
			Label = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromOffset(8, if layout.isShortLandscape then 4 else 5),
				Size = UDim2.new(1, -16, 0, if layout.isShortLandscape then 13 else 15),
				Text = "Games",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = if layout.isShortLandscape then 11 else 12,
				ZIndex = Theme.zIndex.ui + 2,
			}),
			Subtitle = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromOffset(8, if layout.isShortLandscape then 17 else 20),
				Size = UDim2.new(1, -16, 0, if layout.isShortLandscape then 11 else 12),
				Text = "Egg Catch",
				TextColor3 = Color3.fromRGB(222, 231, 227),
				TextSize = if layout.isShortLandscape then 9 else 10,
				ZIndex = Theme.zIndex.ui + 2,
			}),
		})

		children.FarmVisitPanel = createFarmVisitPanel(farmState, layout, visitPanelOpen, canUseFarmVisit, function()
			setVisitPanelOpen(function(current)
				return not current
			end)
		end, visitFarm, returnHomeFarm, function()
			actionEvent:FireServer(RemoteProtocol.actions.toggleVisitorHelp)
		end)

		children.UpgradesButton = e("TextButton", {
			AnchorPoint = Vector2.new(1, 1),
			AutoButtonColor = not tutorialVisible and not isViewingOtherFarm,
			BackgroundColor3 = Color3.fromRGB(43, 52, 49),
			BorderSizePixel = 0,
			Position = upgradesButtonPosition,
			Size = UDim2.fromOffset(upgradesButtonWidth, upgradesButtonHeight),
			Text = if upgradesVisible then "Upgrades" else "Upgrades",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = if layout.isShortLandscape then 11 else 13,
			Font = Enum.Font.GothamBold,
			ZIndex = Theme.zIndex.ui + 1,
			[React.Event.Activated] = if not tutorialVisible and not isViewingOtherFarm then function()
				setUpgradesOpen(function(current)
					return not current
				end)
			end else nil,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
		})

		children.Actions = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 1, -layout.actionBottom),
			Size = UDim2.fromOffset(layout.actionBarWidth, layout.actionButtonHeight),
			ZIndex = Theme.zIndex.ui,
		}, {
			Layout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, layout.actionGap),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Collect = e(ActionButton, {
				label = "Collect",
				subtitle = formatCollectSubtitle(farmState.availableEggs, farmState.secondsUntilNextEgg),
				disabled = not canCollectEggs,
				layoutOrder = 1,
				width = layout.actionButtonWidth,
				height = layout.actionButtonHeight,
				onActivated = function()
					actionEvent:FireServer(RemoteProtocol.actions.collectEggs)
					advanceTutorial("collect")
				end,
			}),
			Sell = e(ActionButton, {
				label = "Sell",
				subtitle = formatSellSubtitle(farmState.eggs, farmState.eggSellValue),
				disabled = not canSellEggs,
				layoutOrder = 2,
				width = layout.actionButtonWidth,
				height = layout.actionButtonHeight,
				onActivated = function()
					actionEvent:FireServer(RemoteProtocol.actions.sellEggs)
					advanceTutorial("sell")
				end,
			}),
			Shop = e(ActionButton, {
				label = "Shop",
				subtitle = string.format("Feed x%d", farmState.duckFeed),
				disabled = not canOpenShop,
				layoutOrder = 3,
				width = layout.actionButtonWidth,
				height = layout.actionButtonHeight,
				onActivated = function()
					runSceneTransition(SCREEN_MODE_SHOP)
				end,
			}),
		})

		if upgradesVisible then
			children.ProgressionStack = e("Frame", {
				AnchorPoint = layout.progressionAnchor,
				BackgroundTransparency = 1,
				Position = layout.progressionPosition,
				Size = UDim2.fromOffset(layout.progressionStackWidth, layout.progressionStackHeight),
				ZIndex = Theme.zIndex.ui + 2,
			}, {
				Layout = e("UIListLayout", {
					FillDirection = layout.progressionDirection,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, layout.progressionGap),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Bottom,
				}),
				EggValue = e(createProgressionCard, {
					title = upgrade.displayName,
					lineOne = if farmState.eggValueLevel >= farmState.eggValueMaxLevel
						then "Maxed"
						else formatCostLine(farmState.eggValueUpgradeCost, farmState.coins, layout.isShortLandscape),
					lineTwo = string.format("Value: %d coin/egg", farmState.eggSellValue),
					buttonText = if farmState.eggValueLevel >= farmState.eggValueMaxLevel then "Maxed" else "Upgrade",
					canActivate = canBuyEggValue,
					layoutOrder = 1,
					width = layout.progressionCardWidth,
					height = layout.progressionCardHeight,
					onActivated = function()
						actionEvent:FireServer(RemoteProtocol.actions.buyEggValueUpgrade)
					end,
				}),
				BuyDuck = e(createProgressionCard, {
					title = PrototypeConfig.duckPurchase.displayName,
					lineOne = formatCostLine(farmState.duckPurchaseCost, farmState.coins, layout.isShortLandscape),
					lineTwo = string.format("Ducks: %d (+1)", farmState.duckCount),
					buttonText = "Buy",
					canActivate = canBuyDuck,
					layoutOrder = 2,
					width = layout.progressionCardWidth,
					height = layout.progressionCardHeight,
					onActivated = function()
						actionEvent:FireServer(RemoteProtocol.actions.buyDuck)
						advanceTutorial("buy_duck")
					end,
				}),
			})
		end
		children.TutorialOverlay = if tutorialVisible
			then createTutorialOverlay(
				layout,
				screenSize,
				tutorialStepIndex,
				screenMode,
				IS_STUDIO,
				farmState,
				animationTime,
				feedbackItems,
				selectedDuckIndex
			)
			else nil
	elseif screenMode == SCREEN_MODE_SHOP then
		children.ShopScreen = createShopScreen(farmState, layout, screenSize, isTransitioning, function()
			advanceTutorial("shop")
			runSceneTransition(SCREEN_MODE_FARM)
		end, buyDuckFeed, buyPremiumFeed, buyDuckTreat, buyPillow, buyToy)
		children.TutorialOverlay = if tutorialVisible and activeTutorialStepId == "shop"
			then createTutorialOverlay(
				layout,
				screenSize,
				tutorialStepIndex,
				screenMode,
				IS_STUDIO,
				farmState,
				animationTime,
				feedbackItems,
				selectedDuckIndex
			)
			else nil
	elseif screenMode == SCREEN_MODE_MINIGAMES then
		children.MinigameMenu = createMinigameMenuScreen(layout, screenSize, isTransitioning, returnToFarm, startEggCatchRound)
	elseif screenMode == SCREEN_MODE_EGG_CATCH then
		children.EggCatchScreen = createEggCatchScreen(
			layout,
			screenSize,
			isTransitioning,
			eggCatchState,
			openMinigamesMenu,
			function()
				moveEggCatch(-1)
			end,
			function()
				moveEggCatch(1)
			end
		)
	elseif screenMode == SCREEN_MODE_EGG_CATCH_RESULTS then
		children.EggCatchResults = createEggCatchResultsScreen(
			layout,
			screenSize,
			isTransitioning,
			eggCatchResult,
			eggCatchClaimStatus,
			eggCatchClaimMessage,
			eggCatchReward,
			retryEggCatchReward,
			startEggCatchRound,
			openMinigamesMenu,
			returnToFarm
		)
	end

	children.Feedback = createFeedbackLayer(feedbackItems, animationTime)
	children.FadeOverlay = createFadeOverlay(transitionAlpha)


	return e("Frame", {
		BackgroundColor3 = Theme.colors.sky,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Theme.zIndex.background,
	}, children)
end

return FarmScreen
