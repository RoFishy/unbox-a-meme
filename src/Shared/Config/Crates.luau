local Types = require("@Shared/Types")

return {
	["Crate"] = {
		Health = 100,

		Chances = {
			["Common"] = 50, -- 50% chance
			["Rare"] = 50, -- 50% chance
		},
	},
} :: { [string]: Types.CrateConfig }
