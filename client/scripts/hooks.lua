--[[
	useState
	useEffect
]]
return function(renderer, node)
	local useCount = 0

	local captureUseCount = function()
		useCount = useCount + 1
		return useCount
	end

	return {
		hasRan = function()
			return useCount > 0
		end,
		useState = function(startingState)
			local capturedUseCount = captureUseCount()

			if node.hooks[capturedUseCount] == nil then
				node.hooks[capturedUseCount] = { startingState }
			end

			local state = (node.hooks[capturedUseCount])[1]

			return state, function(newState)
				node.hooks[capturedUseCount][1] = newState
				renderer.diffNode(node, node.element)
			end
		end,
		useEffect = function(effect, dependencies)
			local capturedUseCount = captureUseCount()
			local effectContainer = node.hooks[capturedUseCount]

			if effectContainer == nil then
				local cleanUp = effect()
				node.hooks[capturedUseCount] = { cleanUp = cleanUp, lastCapturedDependencies = dependencies }
				return
			end

			local changed = false
			for index, currentDependency in next, dependencies do
				local lastCapturedDependency = effectContainer.lastCapturedDependencies[index]
				if lastCapturedDependency ~= currentDependency then
					changed = true
					break
				end
			end

			if not changed then
				return
			end
			
			if effectContainer.cleanUp then
				effectContainer.cleanUp()
			end

			effectContainer.cleanUp = effect()
		end

	}
end