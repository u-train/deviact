return function(element, props)
	local elementType
	if type(element) == "string" then
		if element == ".fragment" then
			elementType = "fragment"
		elseif element == ".portal" then
			elementType = "portal"
		else
			elementType = "tevObject"
		end
	elseif type(element) == "function" then
		elementType = "functional"
	else
		error("Not valid element type: " .. type(element), 2)
	end

	if props.children == nil then
		props.children = {}
	end

	return { type = elementType, element = element, props = props }
end
