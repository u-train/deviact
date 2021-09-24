local newHooks = require("./hooks.lua")

return {
	mount = function(renderer, node)
		local element = node.element.element
		node.hooks = {}

		local hooks = newHooks(renderer, node)
		local result = element(node.element.props, hooks)

		node.children[1] = renderer.mountElement(result, node.parent, node.key)
	end,
	diff = function(renderer, node, incomingElement)
		local element = incomingElement.element
	
		local hooks = newHooks(renderer, node)
		local newResult = element(incomingElement.props, hooks)

		-- For memorization
		-- if newResult ~= node.children[1].element then
			renderer.diffNode(node.children[1], newResult)
		-- end
	end,
	unmount = function(renderer, node)
		renderer.unmountNode(table.remove(node.children, 1))
	end
}