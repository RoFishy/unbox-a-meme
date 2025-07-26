local LabubuConfig = require("@Config/Labubus")

local Types = require("@Shared/Types")

local function GetLabubuInfo(Name: string): (Types.Rarity?, Types.LabubuInfo?)
	for Rarity, RarityInfo in pairs(LabubuConfig) do
		if RarityInfo.Labubus[Name] then
			return Rarity :: Types.Rarity, RarityInfo.Labubus[Name] :: Types.LabubuInfo
		end
	end

	return
end

return GetLabubuInfo
