local renderer = require("./renderer.lua")
local createElement = require("./createElement.lua")

local flashComponent = function(props, hooks)
	local text, updateText = hooks.useState("12")

	local colourBinding = hooks.useBinding(props.startingColour)
	local textRef = hooks.useBinding()

	hooks.useEffect(
		function()
			local running = true
			spawn(
				function()
					while running do
						sleep(1)
						colourBinding:update(colour.random())
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
			backgroundColour = colourBinding,
			[".ref"] = textRef,
			["event.mouseLeftDown"] = function()
				updateText(tostring(textRef:value().backgroundColour))
			end,
			children = {
				colorBox = createElement(
					"guiTextBox",
					{
						size = guiCoord(1, 0, 0, 20),
						text = text,
						textAlign = "middle"
					}
				)
			}
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