local getDefaultValue = require("./getDefaultValue.lua")
local eventManager = require("./eventManager.lua")

local applyProp = function(node, propName, newPropValue, oldPropValue)
	if propName == "children" or propName == ".ref" then
		return
	end

	if newPropValue == oldPropValue then
		return
	end

	if type(newPropValue) == "table" and newPropValue.type == "binding" then
		if newPropValue ~= oldPropValue then
			if node.bindings[propName] then
				node.bindings[propName]()
				node.bindings = nil
			end

			node.bindings[propName] = newPropValue:connect(
				function(value)
					node.tevObject[propName] = value
				end
			)
		end
		newPropValue = newPropValue:value()
	else
		if  node.bindings[propName] then
			node.bindings[propName]()
			node.bindings = nil
		end
	end

	if propName:match("^%w*$") then
		if newPropValue == nil then
			node.tevObject[propName] = getDefaultValue(node.element, propName)
		else
			node.tevObject[propName] = newPropValue
		end

		return
	end

	if propName:match("event%.") then
		if node.eventManager == nil then
			node.eventManager = eventManager.new(
				node.tevObject
			)
		end

		local eventName = propName:match("%.(%w*)$")
		node.eventManager:setEvent(eventName, newPropValue)
		return
	end
end

return {
	mount = function(renderer, node)
		node.tevObject = core.construct(
			node.element.element,
			{
				parent = node.parent,
				name = tostring(node.key)	
			}
		)

		node.bindings = {}

		for propName, propValue in next, node.element.props do
			applyProp(node, propName, propValue, nil)
		end

		renderer.mountChildren(node, node.tevObject, node.element.props.children)

		if node.element.props[".ref"] then
			node.element.props[".ref"]:update(node.tevObject)
		end


		if node.eventManager then
			node.eventManager:resume()
		end

		return node
	end,

	diff = function(renderer, node, incomingElement)
		if node.eventManager then
			node.eventManager:pause()
		end

		for oldPropName, oldPropValue in next, node.element.props do
			applyProp(node, oldPropName, incomingElement.props[oldPropName], oldPropValue)
		end

		for newPropName, newPropValue in next, incomingElement.props do
			applyProp(node, newPropName, newPropValue, node.element.props[newPropName])
		end

		renderer.diffChildren(node, node.tevObject, incomingElement.props.children)

		node.element = incomingElement

		if node.eventManager then
			node.eventManager:resume()
		end
	end,

	unmount = function(renderer, node)
		if node == nil then
			error("bad argument #2, node expected got nil.", 2)
		end

		if node.mounted == false then
			error("Cannot unmount a unmounted node.", 2)
		end

		for _, cleanUpBinding in next, node.bindings do
			cleanUpBinding()
		end

		node.bindings = nil

		if node.element.props[".ref"] then
			node.element.props[".ref"]:update(nil)
		end
		
		renderer.unmountChildren(node)
		
		node.tevObject:destroy()
		node.tevObject = nil
	end
}