local GetDictionaryLength = require("@Utility/GetDictionaryLength")
local IndexDictionary = require("@Utility/IndexDictionary")

local function GetRandomDictionaryIndex(Dictionary: {})
	return IndexDictionary(Dictionary, math.random(1, GetDictionaryLength(Dictionary)))
end

return GetRandomDictionaryIndex
