-- // Services
local Players = game:GetService("Players")

-- // Packages
local ProfileStore = require("@ServerPackages/ProfileStore")

-- // Modules
local DataTemplate = require(script.Template)
local Types = require("@Shared/Types")

-- // Store
local PlayerStore = ProfileStore.New("PlayerStore", DataTemplate)

-- // Module
type DataUtilType = {
	Profiles: { [Player]: any },
	New: (Player) -> (),
	InitializePlayer: (self: DataUtilType, Player: Player) -> (),
	_SetupLeaderstats: (self: DataUtilType, Player: Player) -> (),
	_UpdateLeaderstats: (self: DataUtilType, Player: Player) -> (),
	GetData: (self: DataUtilType, Player: Player) -> Types.UserData?,
	SetData: (self: DataUtilType, Player: Player, Data: Types.UserData) -> (),
	CleanupProfile: (self: DataUtilType, Player: Player) -> (),
}
local DataUtil = {
	Profiles = {} :: { [Player]: any },
} :: DataUtilType

function DataUtil.New(Player: Player)
	local Profile = PlayerStore:StartSessionAsync(`{Player.UserId}`, {
		Cancel = function()
			return Player.Parent ~= Players
		end,
	})

	if Profile ~= nil then
		Profile:AddUserId(Player.UserId)
		Profile:Reconcile()

		Profile.OnSessionEnd:Connect(function()
			DataUtil.Profiles[Player] = nil
			Player:Kick("Profile session end - Please Rejoin")
		end)

		if Player.Parent == Players then
			DataUtil.Profiles[Player] = Profile
			DataUtil:InitializePlayer(Player)
		else
			Profile:EndSession()
		end
	else
		Player:Kick(`Profile load fail - Please Rejoin`)
	end
end

function DataUtil:InitializePlayer(Player: Player)
	self:_SetupLeaderstats(Player)
end

function DataUtil:_SetupLeaderstats(Player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

	local Cash = Instance.new("IntValue")
	Cash.Name = "Cash"
	Cash.Parent = leaderstats

	local Data = self:GetData(Player)
	if Data then
		Cash.Value = Data.Cash
	end
end

function DataUtil:SetData(Player: Player, Data: Types.UserData)
	local Profile = self.Profiles[Player]
	if Profile then
		Profile.Data = Data

		self:_UpdateLeaderstats(Player)
	end
end

function DataUtil:_UpdateLeaderstats(Player: Player)
	local leaderstats = Player:FindFirstChild("leaderstats")
	if leaderstats then
		local Cash = leaderstats:FindFirstChild("Cash") :: IntValue
		if Cash then
			local Data = self:GetData(Player)
			if Data then
				Cash.Value = Data.Cash
			end
		end
	end
end

function DataUtil:GetData(Player: Player): Types.UserData?
	local Profile = self.Profiles[Player]
	if Profile then
		return Profile.Data
	else
		return nil
	end
end

function DataUtil:CleanupProfile(Player: Player)
	if self.Profiles[Player] then
		self.Profiles[Player]:EndSession()
	end
end

return DataUtil
