---@module "client.scripts.renderer"
local renderer = require "./renderer.lua"
---@module "client.scripts.createElement"
local createElement = require "./createElement.lua"
---@module "client.scripts.binding"
local binding = require "./binding.lua"

return {
	createElement = createElement,
	binding = binding,
	newBinding = binding.new,
	mount = renderer.mountElement,
	mountNode = renderer.mountNode,
	diff = renderer.diffNode,
	unmount = renderer.unmountNode,
}
