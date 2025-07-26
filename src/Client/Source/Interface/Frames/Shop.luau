-- // Services
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Util
local Button = require("@ClientUtility/Button")

-- // Module
local InterfaceController = require("@Controllers/InterfaceController")

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")

local ShopFrame = MainUI:WaitForChild("Frames"):WaitForChild("Shop")

local CloseButton = ShopFrame:WaitForChild("Close")

-- // Init
local Shop = {}

function Shop.Init()
	Shop.Junk = {} :: { RBXScriptConnection | () -> () }
end

function Shop:Start()
	table.insert(
		self.Junk,
		Button(CloseButton, function()
			InterfaceController:CloseAllFrames()
		end)
	)
end

function Shop:Stop()
	for _, v in self.Junk do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
		elseif typeof(v) == "function" then
			v()
		else
			v:Destroy()
		end
	end

	table.clear(self.Junk)
end

return Shop
