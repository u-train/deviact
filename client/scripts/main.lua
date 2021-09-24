-- --[[
-- 	node = {
-- 		element = element,

-- 		nodeParent = nil,
-- 		hostParent = nil,
-- 		hostName = "",

-- 		mounted = true,
-- 		children = {}

-- 		tevObject = nil,
-- 		bindings = {}
-- 	}
-- ]]

local renderer = require("./renderer.lua")
local createElement = require("./createElement.lua")

local flashComponent = function(props, hooks)
	local currentFlashedColour, updateFlashedColour = hooks.useState(props.startingColour)
	hooks.useEffect(
		function()
			local running = true
			spawn(
				function()
					while running do
						sleep(1)
						updateFlashedColour(colour.random())
					end
				end
			)

			return function()
				running = false
			end
		end,
		{}
	)

	return createElement(
		"guiFrame",
		{
			size = guiCoord(1, 0, 1, 0),
			backgroundColour = currentFlashedColour,
		}
	)
end

renderer.mountElement(
	createElement(
		flashComponent,
		{
			startingColour = colour.random()
		}
	),
	core.interface
)