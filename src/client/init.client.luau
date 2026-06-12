--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages:WaitForChild("React"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))

local App = require(script:WaitForChild("App"))

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local existingGui = playerGui:FindFirstChild("DuckApp")

if existingGui then
	existingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DuckApp"
screenGui.DisplayOrder = 10
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local root = ReactRoblox.createRoot(screenGui)
root:render(React.createElement(App))

script.Destroying:Connect(function()
	root:unmount()
end)
