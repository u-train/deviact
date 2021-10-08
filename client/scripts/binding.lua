---@class binding
local binding = { type = "binding" }
binding.__index = binding

---@param startingValue any
---@return binding
function binding.new(startingValue)
	return setmetatable({
		_value = startingValue, next = nil
	}, binding)
end

---@param value any
function binding:update(value)
	self._value = value

	local node = self.next

	while node do
		node.callback(value)
		node = node.next
	end
end

---@return any value
function binding:value()
	return self._value
end

---@param mapper fun(value:any):any
---@return binding
function binding:map(mapper)
	local newBinder = binding.new()

	self:connect(function(value)
		newBinder:update(mapper(value))
	end)

	return newBinder
end

---@param callback fun(value:any):any
---@return function disconnect
function binding:connect(callback)
	local newNode = { prev = nil, callback = callback, next = nil }

	local tail = self
	while tail.next do
		tail = tail.next
	end

	tail.next = newNode
	newNode.prev = tail

	return function()
		if newNode.prev then
			newNode.prev.next = newNode.next

			if newNode.next then
				newNode.next.prev = newNode.prev
			end
		end
	end
end

return binding
