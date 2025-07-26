export type CrateConfig = {
	Health: number,

	Chances: { [Rarity]: number },
}

export type ToolInfo = {
	Damage: number,
}

export type UserData = {
	Cash: number,
	Tool: number,
}

export type Rarity = "Uncommon" | "Common" | "Rare" | "Epic" | "Legendary" | "Divine" | "Secret"

export type LabubuInfo = {
	Income: number,
	SellPrice: number,
}

export type LabubuRarityInfo = {
	Color: Color3?,
	Labubus: { [string]: LabubuInfo },
}

export type PlotData = {
	Owner: Player?,
	Spawner: unknown?,
	CurrentCrate: unknown?,
}

return {}
