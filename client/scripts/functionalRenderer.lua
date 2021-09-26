local newHooks = require "./hooks.lua"

return {
	mount = function(renderer, node)
		local element = node.element.element
		node.hooks = {}

		local hooks = newHooks(renderer, node)
		local result = element(node.element.props, hooks)

		renderer.mountChildren(node, node.parent, { result })
		hooks.runEffects()
	end,
	diff = function(renderer, node, incomingElement)
		local element = incomingElement.element

		local hooks = newHooks(renderer, node)
		local newResult = element(incomingElement.props, hooks)

		renderer.diffChildren(node, node.parent, { newResult })
		hooks.runEffects()
	end,
	unmount = function(renderer, node)
		for _, hook in next, node.hooks do
			if hook.cleanUp then
				hook.cleanUp()
			end
		end

		node.hooks = nil
		renderer.unmountChildren(node)
	end,
}
