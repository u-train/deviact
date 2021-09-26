return {
	mount = function(renderer, node)
		renderer.mountChildren(node, node.parent, node.element.props.children)
	end,
	diff = function(renderer, node, incomingElement)
		renderer.diffChildren(node, node.parent, incomingElement.props.children)
	end,
	unmount = function(renderer, node)
		renderer.unmountChildren(node)
	end
}