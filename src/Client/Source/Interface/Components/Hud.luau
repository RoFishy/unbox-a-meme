-- // Services
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Modules/Utils
local Button = require("@ClientUtility/Button")

-- // UI Shit
local MainUI = PlayerGui:WaitForChild("UI") :: ScreenGui
local Hud = MainUI:WaitForChild("Hud") :: Frame

-- hud
local LeftButtons = Hud:WaitForChild("Left") :: Frame
local RightButtons = Hud:WaitForChild("Right") :: Frame
local TopButtons = Hud:WaitForChild("Top") :: Frame

local StarterPack = Hud:WaitForChild("StarterPack") :: TextButton

-- // Start
return function(props: {
	OpenFrame: (FrameName: string) -> (),
})
	for _, Instance in LeftButtons:GetChildren() do
		if Instance:IsA("TextButton") or Instance:IsA("ImageButton") then
			local button: TextButton | ImageButton = Instance

			Button(button, function()
				props.OpenFrame(button.Name)
			end)
		end
	end

	for _, Instance in RightButtons:GetChildren() do
		if Instance:IsA("TextButton") or Instance:IsA("ImageButton") then
			local button: TextButton | ImageButton = Instance

			Button(button, function()
				props.OpenFrame(button.Name)
			end)
		end
	end

	for _, Instance in TopButtons:GetChildren() do
		if Instance:IsA("TextButton") or Instance:IsA("ImageButton") then
			local button: TextButton | ImageButton = Instance

			Button(button)
		end
	end

	Button(StarterPack)
end
