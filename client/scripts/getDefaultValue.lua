local classDefaultValueList = {}

---@param className string
---@param propertyName string
---@return any propertyValue
return function(className, propertyName)
	local defaultValue
	if classDefaultValueList[className] then
		classDefaultValueList[className] = {}
	end

	if classDefaultValueList[className][propertyName] then
		defaultValue = classDefaultValueList[className][propertyName]
	else
		local object = core.construct(className, { parent = core.interface })
		defaultValue = object[propertyName]
		classDefaultValueList[className][propertyName] = defaultValue
		object:destroy()
	end

	return defaultValue
end
