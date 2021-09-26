local renderer = require("./renderer.lua")
local createElement = require("./createElement.lua")
local binding = require("./binding.lua")

return {
	createElement = createElement,
	binding = binding,
	newBinding = binding.new,
	mount = renderer.mountElement,
	mountNode = renderer.mountNode,
	diff = renderer.diffNode,
	unmount = renderer.unmountNode
}
