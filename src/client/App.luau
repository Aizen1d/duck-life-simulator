--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

local FarmScreen = require(script.Parent:WaitForChild("Screens"):WaitForChild("FarmScreen"))

local e = React.createElement
local AppErrorBoundary = React.Component:extend("AppErrorBoundary")

function AppErrorBoundary:init()
	self.state = {
		hasError = false,
		errorText = nil,
	}
end

function AppErrorBoundary.getDerivedStateFromError(errorValue: any)
	return {
		hasError = true,
		errorText = tostring(errorValue),
	}
end

function AppErrorBoundary:componentDidCatch(errorValue: any)
	warn(string.format("[Duck] Client UI error: %s", tostring(errorValue)))
end

function AppErrorBoundary:render()
	local state = self.state :: {
		hasError: boolean,
		errorText: string?,
	}

	if state.hasError then
		return e("Frame", {
			BackgroundColor3 = Color3.fromRGB(234, 249, 255),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
		}, {
			Panel = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(420, 180),
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				Stroke = e("UIStroke", {
					Color = Color3.fromRGB(231, 224, 207),
					Thickness = 2,
				}),
				Title = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.fromOffset(20, 18),
					Size = UDim2.new(1, -40, 0, 28),
					Text = "Duck UI needs a reset",
					TextColor3 = Color3.fromRGB(75, 56, 42),
					TextSize = 24,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				Message = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Position = UDim2.fromOffset(20, 56),
					Size = UDim2.new(1, -40, 0, 48),
					Text = "The client UI hit an error and was kept on-screen instead of dropping back to the Roblox world.",
					TextColor3 = Color3.fromRGB(117, 98, 78),
					TextSize = 15,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
				}),
				Detail = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Position = UDim2.fromOffset(20, 114),
					Size = UDim2.new(1, -40, 0, 44),
					Text = "Check Studio Output for the logged client error, then retry the flow.",
					TextColor3 = Color3.fromRGB(117, 98, 78),
					TextSize = 13,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
				}),
				ErrorText = if state.errorText and state.errorText ~= "" then e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.Code,
					Position = UDim2.fromOffset(20, 146),
					Size = UDim2.new(1, -40, 0, 18),
					Text = state.errorText,
					TextColor3 = Color3.fromRGB(145, 84, 74),
					TextSize = 11,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left,
				}) else nil,
			}),
		})
	end

	return self.props.children
end

local function App()
	return e(AppErrorBoundary, nil, e(FarmScreen))
end

return App
