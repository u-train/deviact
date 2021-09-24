local getDefaultValue = require("./getDefaultValue.lua")
local eventManager = require("./eventManager.lua")

local applyProp = function(node, propName, newPropValue, oldPropValue)
	if propName == "children" then
		return
	end

	if newPropValue == oldPropValue then
		return
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

		for propName, propValue in next, node.element.props do
			applyProp(node, propName, propValue, nil)
		end

		for childKey, childElement in next, node.element.props.children do
			node.children[childKey] = renderer.mountElement(childElement, node.tevObject, childKey)
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

		for newChildKey, newChildElement in next, incomingElement.props.children do
			if node.children[newChildKey] then
				renderer.diffNode(node.children[newChildKey], newChildElement)
			else
				node.children[newChildKey] = renderer.mountElement(newChildElement, node.tevObject, newChildKey)
			end
		end

		for oldChildKey, oldChildNode in next, node.element.props.children do
			if incomingElement.children[oldChildKey] == nil then
				renderer.unmountNode(oldChildNode)
				node.children[oldChildKey] = nil
			end
		end 

		node.element = incomingElement

		if node.eventManager then
			node.eventManager:resume()
		end
	end,

	unmount = function(renderer, node)
		if node == nil then
			error("bad argument #1, node expected got nil.", 2)
		end

		if node.mounted == false then
			error("Cannot unmount a unmounted node.", 2)
		end

		for childKey, childElement in next, node.element.children do
			node.children[childKey] = renderer.unmountNode(childElement, node.tevObject, childKey)
		end

		node.tevObject:destroy()
		node.tevObject = nil
	end
}