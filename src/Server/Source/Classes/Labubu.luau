-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- //  Objects
local LabubuFolder = ReplicatedStorage.Labubus :: Folder
local PlotsFolder = workspace.Plots :: Folder
local NameGradients = ReplicatedStorage.Gradients

-- // Packages
local t = require("@Packages/t")

-- // Utils/Modules/shit
local Types = require("@Shared/Types")

local GetLabubuInfo = require("@Utility/GetLabubuInfo")
local Log = require("@Utility/Log")
local TweenModel = require("@Utility/TweenModel")

-- // local functions
local function GetPlayerPlot(Player: Player): Instance?
	for _, Plot in PlotsFolder:GetChildren() do
		if Plot:GetAttribute("Owner") and Plot:GetAttribute("Owner") == Player.Name then
			return Plot
		end
	end

	return
end

local function GetNextOpenSlot(Slots: Folder): string?
	for i = 1, #Slots:GetChildren() do
		local CurrentSlot = Slots:FindFirstChild("Slot" .. i)
		if CurrentSlot then
			if CurrentSlot:GetAttribute("Labubu") == nil then
				return CurrentSlot.Name
			end
		end
	end

	return
end

-- // Init
local Labubu = {}
Labubu.__index = Labubu

type LabubuData = {
	Name: string,
	Owner: Player,
	Config: Types.LabubuInfo,
	Slot: string,
	Rarity: Types.Rarity,
	RootPart: Part,
	Model: Model,
}

export type Labubu = typeof(setmetatable({} :: LabubuData, Labubu))

local labubuCheck = t.tuple(t.string, t.Instance, t.optional(t.string))
function Labubu.new(Name: string, Owner: Player, Slot: string?): Labubu
	assert(labubuCheck(Name, Owner, Slot))

	local self = setmetatable({}, Labubu) :: Labubu
	self.Name = Name
	self.Owner = Owner

	if Slot then
		self.Slot = Slot
	end

	local Rarity, Info = GetLabubuInfo(Name)
	if Rarity and Info then
		self.Config = Info :: Types.LabubuInfo
		self.Rarity = Rarity :: Types.Rarity
	else
		Log.Error(`No configuration found for labubu: {Name}`)
	end

	local LabubuModel = LabubuFolder:FindFirstChild(Name) :: Model
	if LabubuModel then
		self.Model = LabubuModel:Clone()
		self.Model.Parent = workspace
		local HumanoidRootPart = self.Model:FindFirstChild("HumanoidRootPart") :: Part
		if HumanoidRootPart then
			self.RootPart = HumanoidRootPart
		else
			if typeof(self.Model.PrimaryPart) == "Part" then
				self.RootPart = self.Model.PrimaryPart
			end
		end
	else
		Log.Error(`No model found for labubu: {Name}`)
	end

	self:SetupDisplayInfo()

	return self :: Labubu
end

function Labubu.SetupDisplayInfo(self: Labubu)
	local Attachment = self.RootPart:FindFirstChild("Attachment") :: Attachment
	if not Attachment then
		return
	end

	local Billboard = Attachment:WaitForChild("Billboard")
	local Main = Billboard:WaitForChild("Main")

	local NameText = Main:WaitForChild("Name") :: TextLabel
	local RarityText = Main:WaitForChild("Rarity") :: TextLabel

	NameText.Text = self.Name
	RarityText.Text = self.Rarity

	local OldGradient = RarityText:FindFirstChildOfClass("UIGradient")
	if OldGradient then
		OldGradient:Destroy()
	end

	local NewGradient = NameGradients:FindFirstChild(self.Rarity)
	if NewGradient then
		local NewClone = NewGradient:Clone()
		NewClone.Parent = RarityText
	end
end

function Labubu.Spawn(self: Labubu)
	local Plot = GetPlayerPlot(self.Owner) :: Model
	if not Plot then
		return
	end

	local Components = Plot:FindFirstChild("Components") :: Folder
	if not Components then
		return
	end

	local CrateSpawn = Components:FindFirstChild("CrateSpawn") :: Part
	if not CrateSpawn then
		return
	end

	self.Model:PivotTo(CrateSpawn.CFrame * CFrame.new(0, -5, 0) * CFrame.Angles(0, math.rad(180), 0))

	TweenModel.Position(self.Model, CrateSpawn.CFrame * CFrame.new(0, 2, 0), TweenInfo.new(1.5), function()
		local Slots = Components:WaitForChild("Slots") :: Folder
		local OpenSlotName = GetNextOpenSlot(Slots)

		if OpenSlotName then
			local OpenSlot = Slots:WaitForChild(OpenSlotName)
			local Stand = OpenSlot:WaitForChild("Stand") :: Part
			self.Slot = OpenSlotName
			TweenModel.Position(
				self.Model,
				Stand.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, math.rad(-90), 0),
				TweenInfo.new(1.5),
				function()
					self:AddToSlot(OpenSlotName)
				end
			)
		end
	end)
end

function Labubu.AddToSlot(self: Labubu, Slot: string)
	local Plot = GetPlayerPlot(self.Owner) :: Model
	if not Plot then
		return
	end

	local Components = Plot:FindFirstChild("Components") :: Folder
	if not Components then
		return
	end

	local Slots = Components:WaitForChild("Slots") :: Folder

	local SlotInstance = Slots:FindFirstChild(Slot) :: Folder
	if SlotInstance then
		SlotInstance:SetAttribute("Labubu", self.Name)
	end
end

return Labubu
