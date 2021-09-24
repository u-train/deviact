local eventManager = {}
eventManager.__index = eventManager

function eventManager.new(tevObject)
	return setmetatable(
		{
			_tevObject = tevObject,
			_status = "paused", -- paused, running, resuming
			_eventList = {},
			_queuedEvents = {}
		},
		eventManager
	)
end

function eventManager:setEvent(eventName, callback)
	if callback == nil then
		self:clearEvent(eventName)
	else
		local eventNode = self._eventList[eventName]

		if eventNode then
			eventNode.callback = callback
		else
			self:newEvent(eventName, callback)
		end
	end
end

function eventManager:newEvent(eventName, callback)
	self._eventList[eventName] = {
		callback = callback,
		id = self._tevObject:on(eventName, function(...)
			if self._status == "running" then
				callback(self._tevObject, ...)
			else
				self._queuedEvents[#self._queuedEvents + 1] = {
					event = eventName,
					args = {
						n = select("#", ...),
						...
					} 
				}
			end
		end)
	}
end

function eventManager:clearEvent(eventName)
	local eventNode = self._eventList[eventName]
	if eventNode then
		core.disconnect(eventNode.id)
		self._eventList[eventName] = nil
	end
end

function eventManager:pause()
	self._status = "paused"
end

function eventManager:resume()
	if self._status ~= "paused" then return end
	if self._status == "running" then return end
	self._status = "resuming"

	local i = 1
	local queuedEvent = self._queuedEvents[i]
	while queuedEvent do
		local eventNode = self._eventList[queuedEvent.event]

		if eventNode then
			eventNode.callback(self._tevObject, unpack(queuedEvent.args))
		end

		self._queuedEvents[i] = nil
		i = i + 1
		queuedEvent = self._queuedEvents[i]
	end

	self._status = "running"
end

function eventManager:isRunning()
	return self._status == "running"
end

return eventManager