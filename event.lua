-- Event handling mechanism
-- Part of Shuwarin GUI library
-- Copyright (c) 2039 Dark Energy Processor
--
-- This software is provided 'as-is', without any express or implied
-- warranty. In no event will the authors be held liable for any damages
-- arising from the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:
--
-- 1. The origin of this software must not be misrepresented; you must not
--    claim that you wrote the original software. If you use this software
--    in a product, an acknowledgment in the product documentation would be
--    appreciated but is not required.
-- 2. Altered source versions must be plainly marked as such, and must not be
--    misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source distribution.

--- Event handling mechanism
-- @module Shuwarin.Event
-- Events are needed to handle user input. This can range from touch events to
-- keyboard input (textinput). For touch position, the position is always reported
-- relative to current element.

local path = string.sub(..., 1, string.len(...) - string.len(".event"))
local class = require(path..".lib.30log")
local event = class("Shuwarin.Event")

--- Create new event handler.
-- @function Shuwarin.Event:Event
-- @tparam Shuwarin.Element element Element to attach.
-- @treturn Shuwarin.Event New event handler object.
function event:init(element)
	self.element = element

	-- Status
	self.enabled = false
	-- Event handler
	self.handler = {}

	-- Touch inputs
	-- Each touch index has: state, x, y, dx, dy
	-- dx and dy are distance between initial and current position
	-- Mouse always use index 0 for this purpose
	self.touch = {false, 0, 0, 0, 0}

	-- Keyboard handling
	self.keyboard = {state = {}, grabInput = false, enableText = false, text = {}}
end

--- Add new event handler.
-- Event handler function returns true if the event should not forwarded to next
-- event handler, or false if the event should be forwarded to next event handler.
-- @function Shuwarin.Event:addHandler
-- @tparam string ev Event name to handle.
-- @tparam function func Event handler function callback.
function event:addHandler(ev, func)
	local e = self.handler[ev]
	if not(e) then
		-- No event handler. Register new.
		e = {}
		self.handler[ev] = e
	end

	e[#e + 1] = func
end

--- Remove event handler.
-- @function Shuwarin.Event:removeHandler
-- @tparam string ev Event name to handle.
-- @tparam function func Event handler function callback to remove.
-- @treturn boolean true if success, false otherwise (no event found).
function event:removeHandler(ev, func)
	local e = self.handler[ev]
	-- If e is nil, there should be no event there :P
	if not(e) then return false end

	for i = 1, #e do
		if e[i] == func then
			return not(not(table.remove(e, i)))
		end
	end

	-- Not found
	return false
end

--- Internal function to call specificed event handler.
-- @function Shuwarin.Event:_internalCallHandler
-- @tparam string ev Event name to call all of it's handler.
function event:_internalCallHandler(ev, ...)
	local e = self.handler[ev]
	-- If e is nil, there should be no event there :P
	if not(e) then return end

	-- First added are called first!
	for i = 1, #e do
		local v = e[i](self.element, ...)
		-- If event returns truth value, then done.
		if v then return end
	end
end

--- Touch pressed callback function.
-- @function Shuwarin.Event:touchPressed
-- @tparam number x X position.
-- @tparam number y Y position.
-- @tparam number dx delta-x position from initial click.
-- @tparam number dy delta-y position from initial click.
function event:touchPressed(x, y, dx, dy)
	if not(self.enabled) then return end
	local m = self.touch
	m[1], m[2], m[3], m[4], m[5] = true, x, y, dx, dy
	return self:_internalCallHandler("mouseDown", x, y, dx, dy)
end

--- Touch moved callback function.
-- @function Shuwarin.Event:touchMoved
-- @tparam number x X position.
-- @tparam number y Y position.
-- @tparam number dx delta-x position from initial click.
-- @tparam number dy delta-y position from initial click.
function event:touchMoved(x, y, dx, dy)
	if not(self.enabled) then return end
	local m = self.touch
	if m[1] then
		m[2], m[3], m[4], m[5] = x, y, dx, dy
		self:_internalCallHandler("mouseMoved", x, y, dx, dy)
	end
end

--- Touch released callback function.
-- @function Shuwarin.Event:touchReleased
function event:touchReleased()
	local m = self.touch
	if not(self.enabled) or not(m[1]) then return end
	m[1], m[2], m[3], m[4], m[5] = false, 0, 0, 0, 0
	self:_internalCallHandler("mouseUp", 0, 0, 0, 0)
end

--- Retrieve touch position.
-- @function Shuwarin.Event:getTouchPosition
-- @treturn {number,number} Touch position, or nil if no touches.
function event:getTouchPosition()
	if not(self.enabled) then return end
	if self.touch[1] then
		-- Touch position available
		return self.touch[2], self.touch[3]
	else
		-- None.
		return nil, nil
	end
end

--- Keyboard pressed callback.
-- @function Shuwarin.Event:keyPressed
-- @tparam string key Pressed key.
function event:keyPressed(key)
	if not(self.enabled) then return end
	self.keyboard.state[key] = true
	return self:_internalCallHandler("keyDown", key)
end

--- Keyboard released callback.
-- @function Shuwarin.Event:keyReleased
-- @tparam string key Released key.
function event:keyReleased(key)
	if not(self.enabled) then return end
	self.keyboard.state[key] = nil
	self:_internalCallHandler("keyUp", key)

	-- Erasing?
	if key == "backspace" then
		table.remove(self.keyboard.text)
		self:_internalCallHandler("inputChanged")
	end
end

--- Textinput callback.
-- @function Shuwarin.Event:textInput
-- @tparam string char Character pressed.
function event:textInput(char)
	if not(self.enabled) then return end
	self.keyboard.text[#self.keyboard.text + 1] = char
	return self:_internalCallHandler("inputChanged")
end

--- Set keyboard input grab.
-- @function Shuwarin.Event:setKeyboardGrab
-- @tparam boolean grab Grab status.
function event:setKeyboardGrab(grab)
	if not(self.enabled) then return end
	self.keyboard.grabInput = not(not(grab))

	-- If grab input is disabled, disable textinput grab too
	-- and release all inputs.
	if not(grab) then
		self.keyboard.enableText = false

		-- "pairs" is expensive but unavoidable!
		for k in pairs(self.keyboard.state) do
			self.keyboard.state[k] = nil
			self:_internalCallHandler("keyUp", k)
		end
	end
end

--- Set text input grab.
-- This function does nothing if keyboard input grab is
-- not enabled!
-- @function Shuwarin.Event:setTextInputGrab
-- @tparam boolean grab Grab status.
function event:setTextInputGrab(grab)
	if not(self.enabled) or not(self.keyboard.grabInput) then return end
	self.keyboard.enableText = not(not(grab))
end

--- Set event handling status.
-- This automatically release all keypress and touch if false is specified.
-- This function also disable keyboard input grab.
-- @function Shuwarin.Event:setEnable
-- @tparam boolean enable Enable event handling.
function event:setEnable(enable)
	-- Convert to boolean
	enable = not(not(enable))
	self.enabled = enable

	-- If set to disable, release all key/touch events
	if not(enable) then
		-- Release all keyboardpress. "pairs" is expensive but unavoidable!
		for k in pairs(self.keyboard.state) do
			self.keyboard.state[k] = nil
			self:_internalCallHandler("keyUp", k)
		end
		self.keyboard.grabInput = false
		self.keyboard.enableText = false

		-- Release touch press
		local m = self.touch
		if m[1] then
			m[1], m[2], m[3], m[4], m[5] = false, 0, 0, 0, 0
			self:_internalCallHandler("mouseUp", 0, 0, 0, 0)
		end
	end
end

return event
