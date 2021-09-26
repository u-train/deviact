local renderer = require("./renderer.lua")
local createElement = require("./createElement.lua")
local binding = require("./binding.lua")

local aRef = binding.new()
local bRef = binding.new()


renderer.mountElement(
	createElement(".fragment", {
		children = {
			a = createElement("guiFrame", { [".ref"] = aRef }),
			b = createElement("guiFrame", { [".ref"] = bRef })
		}
	}),
	core.interface
)

print(aRef:value().parent)
print(bRef:value().parent)