--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PrototypeConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PrototypeConfig"))
local PlayerStateService = require(script.Parent:WaitForChild("PlayerStateService"))

local GameServer = {}

local started = false

function GameServer.start()
	if started then
		return
	end

	started = true
	PlayerStateService.start()

	print(
		string.format(
			"[Duck] Server ready: %d duck, egg interval %ds, egg value %d coin.",
			PrototypeConfig.startingDucks,
			PrototypeConfig.eggProductionIntervalSeconds,
			PrototypeConfig.eggSellValue
		)
	)
end

return GameServer
