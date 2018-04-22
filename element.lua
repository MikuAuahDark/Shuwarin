-- Base element class
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

--- Base element class.
-- @module Shuwarin.Element
-- Element, can be called widgets is the base objects which shows the actual
-- UI in Shuwarin. All elements like button, text input, checkbox, and other
-- are derived from this class. This class can't be constructed directly.

local path = string.sub(..., 1, string.len(...) - string.len(".element"))
local class = require(path..".lib.30log")
local style = require(path..".style")
local event = require(path..".event")
local element = class("Shuwarin.Element")

function element:init()
	-- Prevent user from constructing Shuwarin.Element directly by other means.
	assert(getmetatable(self) ~= element, "attempt to construct 'Shuwarin.Element' (abstract class)")

	-- New event
	self.event = event(self)
	-- Create new style
	self.style = style(self)
	-- Set width and height
	self.width, self.height = self.width or 1, self.height or 1
	-- Set position
	self.x, self.y = self.x or 0, self.y or 0
end

--- Update element state.
-- You should override this function when defining your own drawing function.
-- @function Shuwarin.Element:update
-- @tparam number deltaT Time passed since last frame in seconds.
function element:update(deltaT)
	-- Do nothing
end

--- Internally update element state.
-- This is wrong method that you should override. Override Shuwarin.Element:update instead!
-- @function Shuwarin.Element:_internalUpdate
-- @tparam number deltaT Time passed since last frame in seconds.
function element:_internalUpdate(deltaT)
	self:update(deltaT)
	return self.style:update()
end

--- Draw current element.
-- You should override this function when defining your own drawing function.
-- @function Shuwarin.Element:draw
function element:draw()
	-- Do nothing
end

--- Internally draw current element.
-- You should not override this function as this function ensure style ordering.
-- Only override if you really know what are you doing.
-- @function Shuwarin.Element:_internalDraw
function element:_internalDraw()
	-- Draw style below element
	self.style:drawBelow()
	-- Actual draw function
	self:draw()
	-- Draw style above element
	return self.style:drawAbove()
end

--- Set element position.
-- @tparam number x X position of element relative to current attached layout.
-- @tparam number y Y position of element relative to current attached layout.
function element:setPosition(x, y)
	assert(type(x) == "number", "bad argument #1 to 'setPosition' (number expected)")
	assert(type(y) == "number", "bad argument #2 to 'setPosition' (number expected)")
	self.x, self.y = x, y
end

return element
