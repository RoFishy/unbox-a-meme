local function GetDictionaryLength(Dictionary: {}): number
	local counter = 0
	for _, _ in pairs(Dictionary) do
		counter = counter + 1
	end
	return counter
end

return GetDictionaryLength
