--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

local Theme = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("Theme"))

export type Props = {
	label: string,
	subtitle: string?,
	layoutOrder: number?,
	disabled: boolean?,
	width: number?,
	height: number?,
	onActivated: (() -> ())?,
}

local e = React.createElement

local function ActionButton(props: Props)
	local disabled = props.disabled == true
	local width = props.width or 176
	local height = props.height or 64
	local isSmall = height <= 50
	local labelY = if isSmall then 5 elseif height < 64 then 6 else 8
	local subtitleY = if isSmall then 30 elseif height < 64 then 34 else 38
	local labelSize = if isSmall then 18 elseif height < 64 then 20 else 22
	local subtitleSize = if isSmall then 11 else 13

	return e("TextButton", {
		Active = not disabled,
		AutoButtonColor = not disabled,
		BackgroundColor3 = if disabled then Color3.fromRGB(185, 176, 164) else Theme.colors.coral,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder or 0,
		Size = UDim2.fromOffset(width, height),
		Text = "",
		ZIndex = Theme.zIndex.ui,
		[React.Event.Activated] = if disabled then nil else props.onActivated,
	}, {
		Corner = e("UICorner", {
			CornerRadius = Theme.corner,
		}),
		Stroke = e("UIStroke", {
			Color = if disabled then Color3.fromRGB(145, 134, 122) else Theme.colors.coralDark,
			Thickness = 3,
		}),
		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(10, labelY),
			Size = UDim2.new(1, -20, 0, 28),
			Text = props.label,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextTransparency = if disabled then 0.15 else 0,
			TextSize = labelSize,
			ZIndex = Theme.zIndex.ui + 1,
		}),
		Subtitle = props.subtitle and e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.fromOffset(10, subtitleY),
			Size = UDim2.new(1, -20, 0, 18),
			Text = props.subtitle,
			TextColor3 = Color3.fromRGB(255, 237, 226),
			TextTransparency = if disabled then 0.15 else 0,
			TextSize = subtitleSize,
			ZIndex = Theme.zIndex.ui + 1,
		}) or nil,
	})
end

return ActionButton
