local binding = { type = "binding" }
binding.__index = binding

function binding.new(startingValue)
	return setmetatable({ _value = startingValue, next = nil }, binding)
end

function binding:update(value)
	self._value = value

	local node = self.next

	while node do
		node.callback(value)
		node = node.next
	end
end

function binding:value()
	return self._value
end

function binding:map(mapper)
	local newBinder = binding.new()

	self:connect(function(value)
		newBinder:update(mapper(value))
	end)

	return newBinder
end

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
