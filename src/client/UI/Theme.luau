--!strict

local Theme = {
	colors = {
		sky = Color3.fromRGB(164, 224, 255),
		grass = Color3.fromRGB(126, 214, 86),
		grassDark = Color3.fromRGB(82, 171, 83),
		pond = Color3.fromRGB(34, 184, 190),
		pondDark = Color3.fromRGB(23, 143, 158),
		panel = Color3.fromRGB(255, 255, 255),
		panelSoft = Color3.fromRGB(255, 250, 237),
		text = Color3.fromRGB(75, 56, 42),
		mutedText = Color3.fromRGB(117, 98, 78),
		coral = Color3.fromRGB(255, 111, 82),
		coralDark = Color3.fromRGB(224, 82, 62),
		duck = Color3.fromRGB(255, 222, 86),
		duckHighlight = Color3.fromRGB(255, 236, 52),
		duckWing = Color3.fromRGB(245, 192, 64),
		egg = Color3.fromRGB(255, 247, 229),
		coin = Color3.fromRGB(247, 195, 58),
		shadow = Color3.fromRGB(49, 101, 79),
	},
	corner = UDim.new(0, 8),
	round = UDim.new(1, 0),
	zIndex = {
		background = 1,
		scene = 2,
		ui = 10,
	},
}

return Theme
