-- // Services
local Players = game:GetService("Players")

-- // Utils
local DataUtil = require("@ServerUtility/DataUtil")
local PlotUtil = require("@ServerUtility/PlotUtil")

-- // Init
local PlayerService = {}

function PlayerService:Start()
	Players.PlayerAdded:Connect(function(Player: Player)
		task.spawn(DataUtil.New, Player)
		PlotUtil:AssignPlot(Player)
	end)
end

return PlayerService
