-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Obj
local CratesFolder: Folder = ReplicatedStorage.Crates

-- // packages
local Signal = require("@Packages/Signal")

-- // Utils
local Log = require("@Utility/Log")
local TweenModel = require("@Utility/TweenModel")

local Types = require("@Shared/Types")

local CrateConfig = require("@Config/Crates")
local ToolConfig = require("@Config/Tools")

-- // Const
local SCALE_VALUES = {
	Up = {
		[1] = 1.15,
		[2] = 1.1,
		[3] = 1.05,
		[4] = 1.2,
	},
	Down = {
		[1] = 0.9,
		[2] = 0.85,
		[3] = 0.77,
		[4] = 0.95,
	},
}

-- // Init
local Crate = {}
Crate.__index = Crate

type CrateData = {
	Name: string,
	Owner: Player,
	Config: Types.CrateConfig,
	Model: Model,
	Primary: Part,
	Destroying: typeof(Signal.new()),

	_junk: { RBXScriptConnection },
}
export type Crate = typeof(setmetatable({} :: CrateData, Crate))

function Crate.new(Name: string, SpawnLocation: Vector3, Owner: Player): Crate
	local self = setmetatable({}, Crate) :: Crate
	self.Name = Name
	self.Owner = Owner
	self.Destroying = Signal.new()
	self._junk = {}

	if CrateConfig[Name] then
		self.Config = table.clone(CrateConfig[Name]) :: Types.CrateConfig
	else
		Log.Error(`No configuration found for crate: {Name}`)
	end

	local Model = CratesFolder:FindFirstChild(Name) :: Model
	if Model then
		self.Model = Model
		if self.Model.PrimaryPart then
			self.Primary = self.Model.PrimaryPart :: Part
		else
			Log.Error(`No primary part found for crate {Model:GetFullName()}`)
		end
	else
		Log.Error(`No crate with name {Name} was found within CratesFolder.`)
	end

	self:Init(SpawnLocation)

	return self
end

function Crate.Init(self: Crate, SpawnLocation: Vector3)
	self:Spawn(SpawnLocation)
end

function Crate.TakeDamage(self: Crate, Amount: number)
	self.Config.Health -= Amount

	-- Do the model tween
	do
		local EndScale: number

		local RandomNumber = math.random(1, 2)
		if RandomNumber == 1 then -- scale up
			local UpValues = SCALE_VALUES.Up
			EndScale = UpValues[math.random(1, #UpValues)]
			--EndScale = 1.15
		else -- scale down
			local DownValues = SCALE_VALUES.Down
			EndScale = DownValues[math.random(1, #DownValues)]
			--EndScale = 0.85
		end

		local Info = TweenInfo.new(0.07, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		TweenModel.Scale(self.Model, 1, EndScale, Info, function()
			TweenModel.Scale(self.Model, EndScale, 1, Info, function()
				-- kill myself if im at 0 health
				if self.Config.Health <= 0 then
					print("well fuck me im cooked")

					TweenModel.Scale(self.Model, 1, 0.00001, TweenInfo.new(1.25), function()
						self:Destroy()
					end)
				end
			end)
		end)
	end
end

function Crate.SetupConnections(self: Crate)
	table.insert(
		self._junk,
		self.Primary.Touched:Connect(function(Hit: BasePart)
			if Hit.Parent and Hit.Parent:IsA("Tool") then
				local Character = Hit.Parent.Parent :: Model?
				if Character then
					if Character.Name == self.Owner.Name then
						local Tool = Hit.Parent :: Tool
						-- only have it do dmg if its attack lmfao
						if Tool:GetAttribute("Attacking") then
							-- get the configuration for the tools
							local ToolInfo: Types.ToolInfo = ToolConfig[Tool.Name]
							if ToolInfo then
								ToolInfo = table.freeze(ToolInfo)
								self:TakeDamage(ToolInfo.Damage)
							end
						end
					end
				end
			end
		end)
	)
end

function Crate.Spawn(self: Crate, Location: Vector3)
	self.Model.Parent = workspace
	self.Primary.Anchored = false
	self.Model:PivotTo(CFrame.new(Location + Vector3.new(0, 5, 0)))

	task.delay(1, function()
		self.Primary.Anchored = true
	end)
end

function Crate.Destroy(self: Crate)
	for _, v in self._junk do
		if v.Connected then
			v:Disconnect()
		end
	end
	self.Destroying:Fire()
	table.clear(self._junk)
	self.Model:Destroy()
end

return Crate
