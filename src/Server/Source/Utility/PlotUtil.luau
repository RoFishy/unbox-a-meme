-- // Objects
local Plots = workspace.Plots :: Folder

-- // Modules
local Types = require("@Shared/Types")

local Crate = require("@ServerClasses/Crate")

type PlotUtil = {
	Plots: { [string]: Types.PlotData },

	Setup: (self: PlotUtil) -> (),
	GetEmptyPlot: (self: PlotUtil) -> string?,
	GetPlayerPlot: (self: PlotUtil, Player: Player) -> string?,
	AssignPlot: (self: PlotUtil, Player: Player) -> (),
	ResetPlot: (self: PlotUtil, Plot: string) -> (),
	TeleportPlayerToPlot: (self: PlotUtil, Player: Player, Plot: string?) -> (),
	SetupSpawner: (self: PlotUtil, Plot: string) -> (),
}

type PlotModel = Model & {
	Components: Folder & {
		Teleport: Part,
		CrateSpawn: Part,
	},
}

-- // Module
local PlotUtil = {
	Plots = {} :: { [string]: Types.PlotData },
} :: PlotUtil

function PlotUtil.Setup(self: PlotUtil)
	for _, PlotModel in Plots:GetChildren() do
		self.Plots[PlotModel.Name] = {
			Owner = nil,
		}
		self:ResetPlot(PlotModel.Name)
	end
end

function PlotUtil.GetEmptyPlot(self: PlotUtil): string?
	for Name, PlotData: Types.PlotData in self.Plots do
		if PlotData.Owner == nil then
			return Name
		end
	end
	return nil
end

function PlotUtil.GetPlayerPlot(self: PlotUtil, Player: Player): string?
	for Name, PlotData: Types.PlotData in self.Plots do
		if PlotData.Owner == Player then
			return Name
		end
	end
	return nil
end

function PlotUtil.TeleportPlayerToPlot(self: PlotUtil, Player: Player, Plot: string?)
	local PlayerPlot = Plot or self:GetPlayerPlot(Player)
	if PlayerPlot then
		local PlotModel = Plots:FindFirstChild(PlayerPlot) :: PlotModel

		if PlotModel then
			local Components = PlotModel.Components

			local Character = Player.Character or Player.CharacterAdded:Wait()
			Character:PivotTo(Components.Teleport:GetPivot())
		end
	end
end

function PlotUtil.SetupSpawner(self: PlotUtil, Plot: string)
	local PlotModel = Plots:FindFirstChild(Plot) :: PlotModel
	if PlotModel then
		local Owner = self.Plots[Plot].Owner
		if Owner then
			self.Plots[Plot].Spawner = task.spawn(function()
				while true do
					local _Crate = Crate.new("Crate", PlotModel.Components.CrateSpawn.Position, Owner)
					self.Plots[Plot].CurrentCrate = _Crate
					_Crate.Destroying:Wait()
				end
			end)
		end
	end
end

function PlotUtil.AssignPlot(self: PlotUtil, Player: Player)
	local PlotName = self:GetEmptyPlot()
	if PlotName then
		self.Plots[PlotName].Owner = Player

		local PlotModel = Plots:FindFirstChild(PlotName) :: PlotModel
		if PlotModel then
			PlotModel:SetAttribute("Owner", Player.Name)
		end

		self:TeleportPlayerToPlot(Player)
		self:SetupSpawner(PlotName)
	end
end

function PlotUtil.ResetPlot(self: PlotUtil, Plot: string)
	local PlotData: Types.PlotData = self.Plots[Plot]

	if PlotData then
		if PlotData.Owner then
			local PlotModel = Plots:FindFirstChild(Plot) :: PlotModel
			if PlotModel then
				PlotModel:SetAttribute("Owner", nil)
			end
		end
		PlotData.Owner = nil
	end

	if self.Plots[Plot].Spawner then
		task.cancel(self.Plots[Plot].Spawner :: thread)
		self.Plots[Plot].Spawner = nil

		if self.Plots[Plot].CurrentCrate then
			local CurrentCrate = self.Plots[Plot].CurrentCrate :: Crate.Crate
			CurrentCrate:Destroy()

			self.Plots[Plot].CurrentCrate = nil
		end
	end
end

return PlotUtil
