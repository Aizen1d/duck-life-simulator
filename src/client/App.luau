--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))

local FarmScreen = require(script.Parent:WaitForChild("Screens"):WaitForChild("FarmScreen"))

local function App()
	return React.createElement(FarmScreen)
end

return App
