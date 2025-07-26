-- // Services
local Players = game:GetService("Players")

-- // Utils
local DataUtil = require("@ServerUtility/DataUtil")
local PlotUtil = require("@ServerUtility/PlotUtil")

local HammerTool = require("@ServerClasses/HammerTool")

-- // Init
local PlayerService = {}

function PlayerService:Start()
	Players.PlayerAdded:Connect(function(Player: Player)
		task.spawn(DataUtil.New, Player)
		PlotUtil:AssignPlot(Player)

		task.delay(1, function()
			if Player.Character then
				self:_CharacterAdded(Player, Player.Character)
			end
			Player.CharacterAdded:Connect(function(Character: Model)
				self:_CharacterAdded(Player, Character)
			end)
		end)
	end)
end

function PlayerService:_CharacterAdded(Player: Player, _: Model)
	PlotUtil:TeleportPlayerToPlot(Player)

	HammerTool.new(Player)
end

return PlayerService
