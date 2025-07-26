-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- // Obj
local ToolsFolder = ReplicatedStorage.Tools :: Folder & { Tool }

-- // Modules
local Log = require("@Utility/Log")
local ToolConfig = require("@Config/Tools")
local Types = require("@Shared/Types")
local t = require("@Packages/t")

local DataUtil = require("@ServerUtility/DataUtil")

-- // init
local HammerTool = {}
HammerTool.__index = HammerTool

type HammerToolData = {
	Name: number,
	Player: Player,
	Object: Tool,
	Config: Types.ToolInfo,

	_junk: { RBXScriptConnection },
}

export type HammerToolClass = typeof(setmetatable({} :: HammerToolData, HammerTool))

local toolCheck = t.tuple(t.Instance, t.optional(t.number))
function HammerTool.new(Player: Player, Name: number?): HammerToolClass?
	assert(toolCheck(Player, Name))
	if not Name then
		local PlayerData = DataUtil:GetData(Player)
		if PlayerData and PlayerData.Tool then
			Name = PlayerData.Tool
		end
	end

	if not Name then
		return nil
	end

	local self = setmetatable({
		Name = Name,
		Player = Player,
	}, HammerTool) :: HammerToolClass

	self._junk = {}

	if ToolConfig[Name] then
		self.Config = ToolConfig[Name]
	else
		Log.Error(`No config found for tool:  {Name}`)
	end

	local ToolObject = ToolsFolder:FindFirstChild(tostring(Name)) :: Tool
	if ToolObject then
		self.Object = ToolObject:Clone() :: Tool
	else
		Log.Error(`No object found for tool: {Name}`)
	end

	self.Object.Parent = Player.Backpack
	self.Object:SetAttribute("Hammer", true)

	self:SetupConnections()

	self.Object.Destroying:Connect(function()
		self:Destroy()
	end)

	self.Object:GetPropertyChangedSignal("Parent"):Connect(function()
		if self.Object.Parent == nil then
			self:Destroy()
		end
	end)

	return self :: HammerToolClass
end

function HammerTool:SetupConnections()
	local CurrentAttack: "Left" | "Right" = "Left"
	local Debounce = false
	table.insert(
		self._junk,
		self.Object.Activated:Connect(function()
			if Debounce == true then
				return
			end
			Debounce = true
			--self.Object:SetAttribute("Attacking", true)

			self.Player:SetAttribute("Animation", `Swing_{CurrentAttack}`)
			if CurrentAttack == "Left" then
				CurrentAttack = "Right"
			else
				CurrentAttack = "Left"
			end

			local SwingSound = SoundService:WaitForChild("Swing"):Clone() :: Sound
			SwingSound.Parent = self.Object:WaitForChild("Handle")
			SwingSound:Play()

			SwingSound.Ended:Connect(function()
				SwingSound:Destroy()
			end)

			task.delay(0.2, function()
				self.Object:SetAttribute("Attacking", true)
			end)

			task.delay(0.75, function()
				Debounce = false
				self.Object:SetAttribute("Attacking", nil)
			end)
		end)
	)
end

function HammerTool:Destroy()
	if self.Object then
		self.Object:Destroy()
	end

	for _, v in self._junk do
		if v.Connected then
			v:Disconnect()
		end
	end
	table.clear(self._junk)
end

return HammerTool
