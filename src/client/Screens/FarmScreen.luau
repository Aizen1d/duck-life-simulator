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
	progressionStackHeight: number,
	progressionGap: number,
	progressionAnchor: Vector2,
	progressionPosition: UDim2,
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
local TESTER_BUTTON_COUNT = 6
local DUCK_TARGET_RADIUS_X_SCALE = 0.4
local DUCK_TARGET_RADIUS_Y_SCALE = 0.34
local DUCK_TOUCH_TARGET_SCALE = 1.15
local SCREEN_MODE_FARM = "farm"
local SCREEN_MODE_SHOP = "shop"
local SCENE_FADE_STEPS = 8
local SCENE_FADE_STEP_SECONDS = 0.025
local DEFAULT_VIEWPORT_SIZE = Vector2.new(1280, 720)
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
	local progressionStackHeight = progressionCardHeight * 2 + progressionGap
	local progressionAnchor = if isNarrow then Vector2.new(0.5, 1) else Vector2.new(1, 1)
	local progressionPosition = if isNarrow
		then UDim2.new(0.5, 0, 1, -(actionBottom + actionButtonHeight + 20))
		else UDim2.new(1, -sideMargin, 1, -actionBottom)
	local profilePanelWidth = if isShortLandscape then math.min(200, math.max(180, math.floor(screenSize.X * 0.24)))
		elseif isCompact then 232
		else 268
	local profilePanelHeight = if isShortLandscape then 164 elseif isCompact then 176 else 190
	local profilePanelAnchor = if isNarrow then Vector2.new(0.5, 1) else Vector2.new(0, 1)
	local profilePanelPosition = if isNarrow
		then UDim2.new(0.5, 0, 1, -(actionBottom + actionButtonHeight + 12))
		else UDim2.new(0, sideMargin, 1, -(actionBottom + actionButtonHeight + 12))
	local testerHeight = if isShortLandscape then 32 elseif isCompact then 44 else 50
	local testerTop = if isShortLandscape then topY elseif isCompact then topY + counterHeight + 8 else topY
	local testerWidth = math.min(if isShortLandscape then 300 elseif isCompact then 340 else 430, math.max(280, screenSize.X - sideMargin * 2))
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
		progressionStackHeight = progressionStackHeight,
		progressionGap = progressionGap,
		progressionAnchor = progressionAnchor,
		progressionPosition = progressionPosition,
		profilePanelWidth = profilePanelWidth,
		profilePanelHeight = profilePanelHeight,
		profilePanelAnchor = profilePanelAnchor,
		profilePanelPosition = profilePanelPosition,
		testerTop = testerTop,
		testerWidth = testerWidth,
		testerHeight = testerHeight,
		testerTitleWidth = testerTitleWidth,
		testerButtonWidth = math.clamp(testerButtonWidth, 36, 86),
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
	end

	return PrototypeConfig.duckCare.requestKinds.pet
end

local function isHungryRequest(requestKind: string): boolean
	return requestKind == PrototypeConfig.duckCare.requestKinds.hungry.id
end

local function trimText(text: string): string
	return text:match("^%s*(.-)%s*$") or ""
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
			or ((item.kind == "care" or item.kind == "level") and item.duckIndex == duckIndex)

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
			Size = UDim2.fromScale(1, 0.34),
			ZIndex = Theme.zIndex.background + 1,
		}),
		Awning = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Theme.colors.coral,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.12),
			Size = UDim2.fromScale(0.72, 0.12),
			ZIndex = Theme.zIndex.background + 2,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.corner,
			}),
		}),
		Counter = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 219, 96),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.68),
			Size = UDim2.fromScale(0.66, 0.18),
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

local function createShopScreen(
	farmState: FarmState,
	layout: LayoutMetrics,
	screenSize: Vector2,
	isTransitioning: boolean,
	onBack: () -> (),
	onBuyDuckFeed: () -> ()
)
	local duckFeed = PrototypeConfig.shop.duckFeed
	local panelWidth = math.min(if layout.isShortLandscape then 360 else 440, math.max(300, screenSize.X - layout.sideMargin * 2))
	local panelHeight = if layout.isShortLandscape then 154 else 194
	local topButtonWidth = if layout.isShortLandscape then 76 else 94
	local feedCounterWidth = if layout.isShortLandscape then 120 else 154

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
			Position = UDim2.new(0.5, 0, 0, layout.topY + 2),
			Size = UDim2.fromOffset(220, 36),
			Text = "Duck Shop",
			TextColor3 = Theme.colors.text,
			TextSize = if layout.isShortLandscape then 20 else 26,
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
				value = tostring(farmState.coins),
				accentColor = Theme.colors.coin,
				image = AssetIds.coinIcon,
				width = layout.counterWidth,
				height = layout.counterHeight,
			}),
		}),
		FeedCounter = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Theme.colors.panel,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -layout.sideMargin, 0, layout.topY + layout.counterHeight + 8),
			Size = UDim2.fromOffset(feedCounterWidth, if layout.isShortLandscape then 36 else 44),
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
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.new(1, -20, 1, 0),
				Text = string.format("Feed x%d", farmState.duckFeed),
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 12 else 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
		}),
		ItemCard = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.colors.panel,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, if layout.isShortLandscape then 0.56 else 0.55),
			Size = UDim2.fromOffset(panelWidth, panelHeight),
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
				Position = UDim2.fromOffset(18, if layout.isShortLandscape then 10 else 16),
				Size = UDim2.new(1, -36, 0, 26),
				Text = duckFeed.displayName,
				TextColor3 = Theme.colors.text,
				TextSize = if layout.isShortLandscape then 18 else 22,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Description = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromOffset(18, if layout.isShortLandscape then 40 else 54),
				Size = UDim2.new(1, -36, 0, if layout.isShortLandscape then 42 else 50),
				Text = string.format("Cost: %d coins\nOwned: %d\nUse for hungry ducks", duckFeed.cost, farmState.duckFeed),
				TextColor3 = Theme.colors.mutedText,
				TextSize = if layout.isShortLandscape then 12 else 14,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = Theme.zIndex.ui + 3,
			}),
			Buy = e("TextButton", {
				Active = farmState.canBuyDuckFeed and not isTransitioning,
				AutoButtonColor = farmState.canBuyDuckFeed and not isTransitioning,
				BackgroundColor3 = if farmState.canBuyDuckFeed
					then Theme.colors.coral
					else Color3.fromRGB(185, 176, 164),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0, 18, 1, if layout.isShortLandscape then -42 else -50),
				Size = UDim2.new(1, -36, 0, if layout.isShortLandscape then 28 else 34),
				Text = if farmState.canBuyDuckFeed then "Buy" else "Need coins",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = if layout.isShortLandscape then 13 else 15,
				ZIndex = Theme.zIndex.ui + 3,
				[React.Event.Activated] = if farmState.canBuyDuckFeed and not isTransitioning then onBuyDuckFeed else nil,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.corner,
				}),
			}),
		}),
	})
end

local function createDefaultFarmState()
	return {
		eggs = PrototypeConfig.startingEggs,
		coins = PrototypeConfig.startingCoins,
		availableEggs = 0,
		duckFeed = 0,
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
		canCareForDucks = true,
		renameError = "",
		renameErrorDuckIndex = 0,
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
	local hasRequiredFeed = not needsFeed or farmState.duckFeed > 0
	local canUseCare = selectedDuck ~= nil and selectedDuck.canCare and (not hasCareRequest or isRequestedDuck) and hasRequiredFeed
	local duckName = if selectedDuck and selectedDuck.name ~= "" then selectedDuck.name else "Duck " .. tostring(selectedDuckIndex)
	local requestText = if isRequestedDuck
		then (if farmState.careRequestText ~= "" then farmState.careRequestText else PrototypeConfig.duckCare.requestText)
		else ""
	local buttonText = if canUseCare
		then (if isRequestedDuck then requestDefinition.actionText else PrototypeConfig.duckCare.displayName)
		elseif hasCareRequest and not isRequestedDuck then "Later"
		elseif needsFeed and farmState.duckFeed <= 0 then requestDefinition.missingText
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
		ZIndex = Theme.zIndex.ui + 6,
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
			ZIndex = Theme.zIndex.ui + 7,
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
			ZIndex = Theme.zIndex.ui + 7,
		}),
		LevelBarBack = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(221, 213, 195),
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(10, barTop),
			Size = UDim2.new(1, -20, 0, barHeight),
			ZIndex = Theme.zIndex.ui + 7,
		}, {
			Corner = e("UICorner", {
				CornerRadius = Theme.round,
			}),
			Fill = e("Frame", {
				BackgroundColor3 = Theme.colors.duckHighlight,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(progressRatio, 1),
				ZIndex = Theme.zIndex.ui + 8,
			}, {
				Corner = e("UICorner", {
					CornerRadius = Theme.round,
				}),
			}),
		}),
		ActionButton = e("TextButton", {
			Active = canUseCare,
			AutoButtonColor = canUseCare,
			BackgroundColor3 = if canUseCare then Theme.colors.coral else Color3.fromRGB(185, 176, 164),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0, 8, 1, -(buttonHeight + 6)),
			Size = UDim2.fromOffset(actionButtonWidth, buttonHeight),
			Text = buttonText,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = if layout.isShortLandscape then 10 else 11,
			ZIndex = Theme.zIndex.ui + 7,
			[React.Event.Activated] = if canUseCare then function()
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
			ZIndex = Theme.zIndex.ui + 7,
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
			ZIndex = Theme.zIndex.ui + 6,
		}),
	})
end

local function createProfileLine(label: string, value: string, yOffset: number, isShort: boolean)
	local textSize = if isShort then 10 else 12
	local rowHeight = if isShort then 18 else 20
	local labelWidth = if isShort then 44 else 52

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

local function createDuckProfilePanel(
	selectedDuckIndex: number?,
	farmState: FarmState,
	animationTime: number,
	feedbackItems: {FeedbackItem},
	screenSize: Vector2,
	layout: LayoutMetrics,
	renamingDuckIndex: number?,
	renameText: string,
	onStartRename: (number, string) -> (),
	onRenameTextChanged: (string) -> (),
	onSubmitRename: (number) -> (),
	onCancelRename: () -> ()
)
	local selectedDuck = getDuckState(farmState, selectedDuckIndex)

	if not selectedDuck or not selectedDuckIndex then
		return nil
	end

	local isShort = layout.isShortLandscape
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
	local footerTop = math.max(firstLineTop + lineGap * 2 + lineRowHeight + 6, height - (if isShort then 28 else 32))
	local footerButtonTop = footerTop
	local footerButtonHeight = if isShort then 19 else 22
	local isRenaming = renamingDuckIndex == selectedDuckIndex
	local trimmedRenameText = trimText(renameText)
	local canSubmitRename = trimmedRenameText ~= "" and trimmedRenameText ~= duckName
	local renameError = if farmState.renameErrorDuckIndex == selectedDuckIndex then farmState.renameError else ""
	local footerReservedWidth = if isRenaming then 140 else 92

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
				Size = UDim2.new(1, -contentLeft * 2, 0, if isShort then 17 else 20),
				Text = duckName,
				TextColor3 = Theme.colors.text,
				TextSize = if isShort then 13 else 17,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = Theme.zIndex.ui + 4,
			}),
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
		Footer = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromOffset(contentLeft, footerTop),
			Size = UDim2.new(1, -(contentLeft * 2 + footerReservedWidth), 0, footerButtonHeight),
			Text = if renameError ~= "" then renameError else "Session-only duck",
			TextColor3 = if renameError ~= "" then Theme.colors.coralDark else Theme.colors.mutedText,
			TextSize = if isShort then 9 else 11,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 4,
		}),
		Rename = if not isRenaming
			then e("TextButton", {
				Active = true,
				AutoButtonColor = true,
				BackgroundColor3 = Theme.colors.duckHighlight,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(1, -(contentLeft + 82), 0, footerButtonTop),
				Size = UDim2.fromOffset(82, footerButtonHeight),
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

local function formatDuckCount(duckCount: number): string
	if duckCount == 1 then
		return "1 duck"
	end

	return string.format("%d ducks", duckCount)
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

local function createEggStatusCard(farmState: FarmState, layout: LayoutMetrics, isStudio: boolean)
	local isSmallStatus = layout.eggStatusHeight < 50
	local interval = PrototypeConfig.eggProductionIntervalSeconds
	local progress = if farmState.availableEggs > 0
		then 1
		else 1 - math.clamp(farmState.secondsUntilNextEgg / interval, 0, 1)
	local title = if farmState.availableEggs > 0 then "Ready to collect" else "Next egg"
	local detail = if farmState.availableEggs > 0
		then string.format("%d ready", farmState.availableEggs)
		else string.format("%ds left with %s", farmState.secondsUntilNextEgg, formatDuckCount(farmState.duckCount))

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
			Position = UDim2.fromOffset(12, if isSmallStatus then 4 else 6),
			Size = UDim2.new(1, -24, 0, if isSmallStatus then 16 else 18),
			Text = title,
			TextColor3 = Theme.colors.text,
			TextSize = if isSmallStatus then 13 else 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 1,
		}),
		Detail = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.fromOffset(12, if isSmallStatus then 19 else 24),
			Size = UDim2.new(1, -24, 0, if isSmallStatus then 14 else 16),
			Text = detail,
			TextColor3 = Theme.colors.mutedText,
			TextSize = if isSmallStatus then 11 else 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 1,
		}),
		BarTrack = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(231, 224, 207),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.new(0, 12, 1, if isSmallStatus then -7 else -9),
			Size = UDim2.new(1, -24, 0, 4),
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
				string.format("+%d feed", nextState.duckFeed - previousState.duckFeed),
				Theme.colors.grassDark,
				0.5,
				0.28
			)
		)
	end

	if nextState.careRequestDuckIndex > 0 and previousState.careRequestDuckIndex <= 0 then
		local requestText = if isHungryRequest(nextState.careRequestKind) then "Hungry duck" else "Duck needs care"

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
		local feedbackText = if previousDuck and isHungryRequest(previousDuck.careRequestKind) then "Fed duck" else "Happy duck"

		table.insert(
			feedback,
			createFeedbackItem(nextFeedbackId(), "care", feedbackText, Theme.colors.duck, 0.5, 0.36, caredDuckIndex)
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

local function createTesterButton(label: string, actionName: string, layoutOrder: number, layout: LayoutMetrics)
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
		[React.Event.Activated] = function()
			actionEvent:FireServer(actionName)
		end,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
	})
end

local function createTesterPanel(layout: LayoutMetrics, isExpanded: boolean, onToggle: () -> ())
	if layout.isShortLandscape and not isExpanded then
		return e("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0),
			AutoButtonColor = true,
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
			[React.Event.Activated] = onToggle,
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
			AutoButtonColor = true,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(layout.testerTitleWidth + 12, layout.testerHeight),
			Text = "",
			TextColor3 = Color3.fromRGB(230, 238, 234),
			TextSize = 11,
			ZIndex = Theme.zIndex.ui + 3,
			[React.Event.Activated] = onToggle,
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
			Coins = createTesterButton(if layout.isCompact then "+100" else "+100 Coins", RemoteProtocol.actions.testAddCoins, 1, layout),
			Eggs = createTesterButton(if layout.isCompact then "+10" else "+10 Ready", RemoteProtocol.actions.testReadyEggs, 2, layout),
			Duck = createTesterButton(if layout.isCompact then "+Duck" else "+1 Duck", RemoteProtocol.actions.testAddDuck, 3, layout),
			Need = createTesterButton("Need", RemoteProtocol.actions.testCareRequest, 4, layout),
			Hungry = createTesterButton("Hungry", RemoteProtocol.actions.testHungryRequest, 5, layout),
			Reset = createTesterButton("Reset", RemoteProtocol.actions.testReset, 6, layout),
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
	local selectedDuckIndex, setSelectedDuckIndex = React.useState(nil :: number?)
	local profileDuckIndex, setProfileDuckIndex = React.useState(nil :: number?)
	local renamingDuckIndex, setRenamingDuckIndex = React.useState(nil :: number?)
	local renameText, setRenameText = React.useState("")
	local screenMode, setScreenMode = React.useState(SCREEN_MODE_FARM)
	local transitionAlpha, setTransitionAlpha = React.useState(0)
	local isTransitioning, setIsTransitioning = React.useState(false)
	local previousStateRef = React.useRef(nil :: FarmState?)
	local feedbackIdRef = React.useRef(0)
	local scenePointerHandlerRef = React.useRef(nil :: ((Vector2, number?) -> ())?)
	local layout = createLayoutMetrics(screenSize, displaySize)
	local children = if screenMode == SCREEN_MODE_SHOP then createShopBackground() else createBackground(hasImage(AssetIds.farmBackground))
	local function runSceneTransition(nextMode: string)
		if isTransitioning or screenMode == nextMode then
			return
		end

		setIsTransitioning(true)
		setSelectedDuckIndex(nil)
		setProfileDuckIndex(nil)
		setRenamingDuckIndex(nil)

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
		actionEvent:FireServer(RemoteProtocol.actions.buyShopItem, {
			itemId = PrototypeConfig.shop.duckFeed.id,
		})
	end
	local function requestCare(duckIndex: number)
		actionEvent:FireServer(RemoteProtocol.actions.careForDucks, {
			duckIndex = duckIndex,
		})
		setSelectedDuckIndex(nil)
		setProfileDuckIndex(nil)
		setRenamingDuckIndex(nil)
	end
	local function openProfile(duckIndex: number)
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

		local targetDuckIndex = findDuckAtPosition(
			screenSize,
			farmState.duckCount,
			animationTime,
			feedbackItems,
			pointerPosition,
			targetScale
		)

		if targetDuckIndex then
			selectDuck(targetDuckIndex)
		elseif selectedDuckIndex ~= nil then
			setSelectedDuckIndex(nil)
			setProfileDuckIndex(nil)
			setRenamingDuckIndex(nil)
		end
	end
	local function startRename(duckIndex: number, currentName: string)
		setProfileDuckIndex(duckIndex)
		setRenamingDuckIndex(duckIndex)
		setRenameText(currentName)
	end
	local function submitRename(duckIndex: number)
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
	scenePointerHandlerRef.current = handleScenePointer
	React.useEffect(function()
		local connection = stateEvent.OnClientEvent:Connect(function(nextState)
			if type(nextState) == "table" then
				local previousState = previousStateRef.current
				local typedState = nextState :: FarmState

				if previousState then
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
			startRename,
			setRenameText,
			submitRename,
			cancelRename
		)

		if IS_STUDIO then
			children.TesterPanel = createTesterPanel(layout, testerExpanded, function()
				setTesterExpanded(function(current)
					return not current
				end)
			end)
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
					value = tostring(farmState.coins),
					accentColor = Theme.colors.coin,
					image = AssetIds.coinIcon,
					width = layout.counterWidth,
					height = layout.counterHeight,
				}),
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
				disabled = farmState.availableEggs <= 0,
				layoutOrder = 1,
				width = layout.actionButtonWidth,
				height = layout.actionButtonHeight,
				onActivated = function()
					actionEvent:FireServer(RemoteProtocol.actions.collectEggs)
				end,
			}),
			Sell = e(ActionButton, {
				label = "Sell",
				subtitle = formatSellSubtitle(farmState.eggs, farmState.eggSellValue),
				disabled = farmState.eggs <= 0,
				layoutOrder = 2,
				width = layout.actionButtonWidth,
				height = layout.actionButtonHeight,
				onActivated = function()
					actionEvent:FireServer(RemoteProtocol.actions.sellEggs)
				end,
			}),
			Shop = e(ActionButton, {
				label = "Shop",
				subtitle = string.format("Feed x%d", farmState.duckFeed),
				disabled = isTransitioning,
				layoutOrder = 3,
				width = layout.actionButtonWidth,
				height = layout.actionButtonHeight,
				onActivated = function()
					runSceneTransition(SCREEN_MODE_SHOP)
				end,
			}),
		})

		children.ProgressionStack = e("Frame", {
			AnchorPoint = layout.progressionAnchor,
			BackgroundTransparency = 1,
			Position = layout.progressionPosition,
			Size = UDim2.fromOffset(layout.progressionCardWidth, layout.progressionStackHeight),
			ZIndex = Theme.zIndex.ui,
		}, {
			Layout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
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
				canActivate = farmState.canBuyEggValueUpgrade,
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
				canActivate = farmState.canBuyDuck,
				layoutOrder = 2,
				width = layout.progressionCardWidth,
				height = layout.progressionCardHeight,
				onActivated = function()
					actionEvent:FireServer(RemoteProtocol.actions.buyDuck)
				end,
			}),
		})
	else
		children.ShopScreen = createShopScreen(farmState, layout, screenSize, isTransitioning, function()
			runSceneTransition(SCREEN_MODE_FARM)
		end, buyDuckFeed)
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
