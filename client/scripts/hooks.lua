---@module "client.scripts.binding"
local bindings = require "./binding.lua"

return function(renderer, node)
	local hooks = node.hooks
	local useCount = 0
	local effectsQueued = {}

	local captureUseCount = function()
		useCount = useCount + 1
		return useCount
	end

	return {
		useState = function(startingState)
			local capturedUseCount = captureUseCount()

			if hooks[capturedUseCount] == nil then
				hooks[capturedUseCount] = { startingState }
			end

			local state = (hooks[capturedUseCount])[1]

			return state,
				function(newState)
					hooks[capturedUseCount][1] = newState
					renderer.diffNode(node, node.element)
				end
		end,
		useEffect = function(effect, dependencies)
			local capturedUseCount = captureUseCount()
			local effectContainer = hooks[capturedUseCount]

			if effectContainer == nil then
				hooks[capturedUseCount] = {
					effect = effect,
					cleanUp = nil,
					lastCapturedDependencies = dependencies,
				}
				effectsQueued[#effectsQueued + 1] = hooks[capturedUseCount]
				return
			end

			local changed = false
			for index, currentDependency in next, dependencies do
				local lastCapturedDependency =
					effectContainer.lastCapturedDependencies[index]
				if lastCapturedDependency ~= currentDependency then
					changed = true
					break
				end
			end

			if not changed then
				return
			end

			effectsQueued[#effectsQueued + 1] = effectContainer
		end,
		useBinding = function(startingValue)
			local capturedUseCount = captureUseCount()

			if hooks[capturedUseCount] == nil then
				hooks[capturedUseCount] = { bindings.new(startingValue) }
			end

			return hooks[capturedUseCount][1]
		end,
		runEffects = function()
			for _, effectContainer in next, effectsQueued do
				if effectContainer.cleanUp then
					effectContainer.cleanUp()
				end

				effectContainer.cleanUp = effectContainer.effect()
			end
		end,
	}
end
