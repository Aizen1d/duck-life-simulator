--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

local Theme = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("Theme"))

export type Props = {
	title: string,
	value: string,
	accentColor: Color3,
	image: string?,
	width: number?,
	height: number?,
}

local e = React.createElement

local function hasImage(image: string?): boolean
	return type(image) == "string" and image ~= ""
end

local function ResourceCounter(props: Props)
	local image = props.image
	local width = props.width or 176
	local height = props.height or 64
	local isSmall = height <= 46
	local iconSize = if isSmall then 24 elseif height < 64 then 30 else 34
	local iconX = if isSmall then 10 elseif height < 64 then 12 else 14
	local textX = if isSmall then 42 elseif height < 64 then 52 else 58
	local titleY = if isSmall then 5 else 8
	local valueY = if isSmall then 19 else 26
	local titleSize = if isSmall then 12 else 14
	local valueSize = if isSmall then 20 else 24
	local iconChildren = {
		Corner = e("UICorner", {
			CornerRadius = Theme.round,
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(201, 170, 112),
			Thickness = 1,
		}),
	}

	if hasImage(image) then
		iconChildren.IconImage = e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = image,
			Position = UDim2.fromOffset(1, 1),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.new(1, -2, 1, -2),
			ZIndex = Theme.zIndex.ui + 2,
		})
	end

	return e("Frame", {
		BackgroundColor3 = Theme.colors.panel,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width, height),
		ZIndex = Theme.zIndex.ui,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(231, 224, 207),
			Thickness = 1,
		}),
		Icon = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = props.accentColor,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(iconX, height / 2),
			Size = UDim2.fromOffset(iconSize, iconSize),
			ZIndex = Theme.zIndex.ui + 1,
		}, iconChildren),
		Title = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.fromOffset(textX, titleY),
			Size = UDim2.new(1, -(textX + 10), 0, 18),
			Text = props.title,
			TextColor3 = Theme.colors.mutedText,
			TextSize = titleSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 1,
		}),
		Value = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(textX, valueY),
			Size = UDim2.new(1, -(textX + 10), 0, 26),
			Text = props.value,
			TextColor3 = Theme.colors.text,
			TextSize = valueSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Theme.zIndex.ui + 1,
		}),
	})
end

return ResourceCounter
