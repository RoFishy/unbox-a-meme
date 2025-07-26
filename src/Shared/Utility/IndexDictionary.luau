local function IndexDictionary(Dictionary: {}, Index: number): (any?, any?)
	local i = 0
	for index, value in pairs(Dictionary) do
		i = i + 1
		if i == Index then
			return index, value
		end
	end

	return
end

return IndexDictionary
