local elementRenderers = {
	tevObject = require("./tevObjectRenderer.lua"),
	functional = require("./functionalRenderer.lua")
}

local renderer = {}

local createNode = function(element, parent, key)
	if element == nil then
		error("cannot create a node without an element.")
	end

	return {
		element = element,
		key = key,
		mounted = false,
		
		parent = parent,
		children = {},

		eventManager = nil,
		tevObject = nil,
	}
end

renderer.mountNode = function(node)
	if node == nil then
		error("bad argument #1, node expected got nil.", 2)
	end

	if node.mounted == true then
		error("cannot mount a mounted node", 2)
	end

	if node.parent == nil then
		error("cannot mount a node that does not have a parent.", 2)
	end

	if node.key == nil then
		error("node does not have a key, was this intended?", 2)
	end
	
	local elementType = node.element.type
	;(
		elementRenderers[elementType].mount
	)(renderer, node)

	node.mounted = true
end

renderer.diffNode = function(node, incomingElement)
	if node == nil then
		error("bad argument #1, node expected got nil.", 2)
	end

	if node.mounted == false then
		error("cannot diff a node that isn't mounted")
	end

	if node.element.element ~= incomingElement.element then
		renderer.unmountNode(node)
		node.element = incomingElement
		renderer.mountNode(node)
		return
	end

	local elementType = node.element.type

	;(
		elementRenderers[elementType].diff
	)(renderer, node, incomingElement)
end

renderer.unmountNode = function(node)
	local elementType = node.element.type

	;(
		elementRenderers[elementType].unmount
	)(renderer, node)

	node.mounted = false
end

renderer.mountElement = function(element, parent, key)	
	local node = createNode(element, parent, key or "deviact."..element.type)

	renderer.mountNode(node)

	return node
end

return renderer