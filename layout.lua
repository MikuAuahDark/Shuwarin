-- Layout class
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

--- Layout class.
-- @module Shuwarin.Layout
-- Layout is the thing you need to use for rendering and GUI event handling.
-- Shuwarin doesn't override any LOVE event handlers to keep compatibility
-- with custom [`love.run`](https://love2d.org/wiki/love.run) function, and
-- to allow fast state switching by just discarding the layout object.
-- @usage
-- -- Create new layout with 800x600 size
-- layout = Shuwarin.Layout(800, 600)

local path = string.sub(..., 1, string.len(...) - string.len(".layout"))
local love = require("love")
local class = require(path..".lib.30log")
local layout = class("Shuwarin.Layout")

--- Create new layout.
-- @function Shuwarin.Layout:Layout
-- @tparam number width of the layout.
-- @tparam number height of the layout.
-- @treturn Shuwarin.Layout object.
function layout:init(width, height)
	-- Layout position
	self.x, self.y = 0, 0
	-- Draw position
	self.drawx, self.drawy = 0, 0
	-- List of elements
	self.elements = {}
	-- Touch event state, contains:
	-- - state - Is input available
	-- - touchID - LOVE light userdata touch identifier, or nil for mouse press
	-- - x - X position
	-- - y - Y position
	-- - ix - Initial X position
	-- - iy - Initial Y position
	self.touchState = {false, nil, 0, 0, 0, 0}
	-- Element touch target
	self.touchTarget = nil
	-- Width and height
	self.width = width
	self.height = height
	-- Framebuffer object
	self.fbo = love.graphics.newCanvas(width, height)
	-- Scroll. Horizontal and vertical
	self.scroll = {h = nil, v = nil, x = 0, y = 0}
end

--- Add new element.
-- @function Shuwarin.Layout:addElement
-- @tparam Shuwarin.Element element element to be added.
function layout:addElement(element)
	self.elements[#self.elements + 1] = element
	element.layout = self
end

--- Remove element.
-- @function Shuwarin.Layout:removeElement
-- @tparam Shuwarin.Element element to be removed.
-- @treturn boolean true if element successfully removed, false otherwise.
function layout:removeElement(element)
	for i = 1, #self.elements do
		if self.elements[i] == element then
			table.remove(self.elements, i).layout = nil
			return true
		end
	end

	return false
end

--- Retrieve actual layout display resolution (subtract by scroll object)
-- @function Shuwarin.Layout:getDisplayableDimensions
-- @treturn {number,number} Displayable dimensions.
function layout:getDisplayableDimensions()
	local w, h = self.width, self.height

	if self.scroll.v then
		-- Has vertical scroll. Subtract by width.
		w = w - self.scroll.v.width
	end

	if self.scroll.h then
		-- Has horizontal scroll. Subtract by height
		h = h - self.scroll.h.height
	end

	return w, h
end

--- Update function.
-- @function Shuwarin.Layout:update
-- @tparam number deltaT Time passed since last frame in seconds.
function layout:update(deltaT)
	for i = 1, #self.elements do
		self.elements[i]:_internalUpdate(deltaT)
	end
end

--- Draw function.
-- @function Shuwarin.Layout:draw
function layout:draw()
	-- Setup state stack
	local blm, blma = love.graphics.getBlendMode()
	love.graphics.push("all")
	love.graphics.setCanvas(self.fbo)
	love.graphics.clear(0, 0, 0, 0)
	love.graphics.origin()
	love.graphics.translate(self.drawx, self.drawy)

	-- Iterate elements
	local lastx, lasty = 0, 0
	local drawx, drawy = self:getDisplayableDimensions()
	for i = 1, #self.elements do
		local elem = self.elements[i]
		local lx, ly = elem.x - self.drawx, elem.y - self.drawy

		-- Check if we should really draw this element by checking it's position.
		-- This is probably hits up the CPU but will gives less stress to the GPU
		if lx + elem.width >= 0 and ly + elem.height >= 0 and elem.x < drawx and elem.y < drawy then
			-- Draw element
			lastx, lasty = elem.x - lastx, elem.y - lasty
			love.graphics.translate(lastx, lasty)
			elem:_internalDraw()
		end
	end
	-- Reset to 0,0
	love.graphics.translate(-lastx, -lasty)

	-- If scroll, draw it too
	if self.scroll.v then self.scroll.v:_internalDraw() end
	if self.scroll.h then self.scroll.h:_internalDraw() end

	-- Release stack
	love.graphics.pop()
	-- Draw element
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(self.fbo, self.x, self.y)
	love.graphics.setBlendMode(blm, blma)
end

--- Internal function to translate touch position.
-- @function Shuwarin.Layout:_internalLocalizeTouchPosition
-- @tparam number x Touch X position.
-- @tparam number y Touch Y position.
-- @tparam boolean oor Always return value even if position is out-of-range?
-- @treturn {number,number} Localized touch position, or nil if touch is outside layout.
function layout:_internalLocalizeTouchPosition(x, y, oor)
	-- Relative to current layout first
	local lx, ly = x - self.x, y - self.y
	if (lx >= 0 and ly >= 0 and lx < self.width and ly < self.height) or oor then
		return lx, ly
	else
		-- Position is out of range
		return nil, nil
	end
end

--- Internal function to find suitable element for keypress event handling.
-- @function Shuwarin.Layout:_internalGetElement
function layout:_internalGetElement(checkTextInput)
	-- Iterate backward
	for i = #self.elements, 1, -1 do
		local elem = self.elements[i]

		if elem.event.enabled and elem.event.keyboard.grabInput then
			-- enableText depends on grabInput
			if checkTextInput then
				if elem.event.keyboard.enableText then
					return elem
				end
			else
				return elem
			end
		end
	end

	-- Not found
	return nil
end

--- Internal function to find suitable element by position in layout.
-- @function Shuwarin.Layout:_internalGetElementByPosition
function layout:_internalGetElementByPosition(x, y)
	local lx, ly = x + self.drawx, y + self.drawy
	-- Iterate backward
	for i = #self.elements, 1, -1 do
		local elem = self.elements[i]

		if
			elem.event.enabled and
			lx >= elem.x and ly >= elem.y and
			lx < elem.x + elem.width and ly < elem.y + elem.height
		then
			return elem
		end
	end

	return nil
end

--- Touch pressed event.
-- @function Shuwarin.Layout:touchPressed
-- @param id Touch identifier (or nil for mouse press)
-- @tparam number x X position
-- @tparam number y Y position
-- @treturn boolean true if event is handled, false otherwise.
function layout:touchPressed(id, x, y)
	-- Localize and handle out-of-range touch position
	x, y = self:_internalLocalizeTouchPosition(x, y)
	if not(x and y) then return false end

	local a = self.touchState
	-- Ignore other touchpress
	if a[1] then return false end

	-- Set data
	a[1], a[2], a[3], a[4], a[5], a[6] = true, id, x, y, x, y

	if not(self.scroll.v and self.scroll.h) then
		-- No scroll data. Try to send touch input directly
		if not(self.touchTarget) then
			local elem = self:_internalGetElementByPosition(x, y)
			if elem then
				-- Input in element area. Send it.
				local lx, ly = x + self.drawx, y + self.drawy
				self.touchTarget = elem
				elem.event:touchPressed(lx - elem.x, ly - elem.y, 0, 0)
				return true
			end
		end
	else
		-- Scrollable. Check if we pressed the scroll button instead first.
		-- Remove draw position localize first. Scrollable doesn't affected
		-- by draw position
		-- We don't check for upper limit (lt comparison) because the scroll
		-- element will be placed in the right, hitting the layout width/height.
		if self.scroll.v and x >= self.scroll.v.x and y >= self.scroll.v.y then
			self.touchTarget = self.scroll.v
			self.touchTarget.event:touchPressed(x, y, 0, 0)
		elseif self.scroll.h and x >= self.scroll.h.x and y >= self.scroll.h.y then
			self.touchTarget = self.scroll.h
			self.touchTarget.event:touchPressed(x, y, 0, 0)
		end

		-- It's always handled.
		return true
	end

	-- Not found.
	return false
end

--- Touch moved event.
-- @function Shuwarin.Layout:touchMoved
-- @param id Touch identifier (or nil for mouse press)
-- @tparam number x X position
-- @tparam number y Y position
-- @treturn boolean true if event is handled, false otherwise.
function layout:touchMoved(id, x, y)
	-- Localize touch position
	x, y = self:_internalLocalizeTouchPosition(x, y, true)

	local a = self.touchState
	-- Ignore other
	if a[1] and a[2] == id then
		-- Set data
		a[3], a[4] = x, y

		-- If there's no touch target, check for scrollable delta first
		if not(self.touchTarget) then
			local DISTANCE = 75--px
			-- Vertical scroll distance check
			if self.scroll.v and math.abs(y - a[6]) >= DISTANCE then
				-- Ok. Set target to scrollable
				self.touchTarget = self.scroll.v
				self.touchTarget.event:touchPressed(x, y, x - a[5], y - a[6])
			elseif self.scroll.h and math.abs(x - a[5]) >= DISTANCE then
				-- Set target to scrollable
				self.touchTarget = self.scroll.h
				self.touchTarget.event:touchPressed(x, y, x - a[5], y - a[6])
			end
		end

		-- Check if touch target is set.
		-- We don't wrap it in elseif, because the touch target maybe can be
		-- set based on above code block.
		if self.touchTarget then
			local lx, ly = x - self.touchTarget.x, y - self.touchTarget.y
			local lix, liy = a[5] - self.touchTarget.x, a[6] - self.touchTarget.y
			-- If it's scrollable, it won't be affected by draw position
			if self.touchTarget == self.scroll.v or self.touchTarget == self.scroll.h then
				lx, ly = x, y
				lix, liy = a[5], a[6]
			end

			self.touchTarget.event:touchMoved(lx, ly, lx - lix, ly - liy)
			return true
		end
	end

	-- None
	return false
end

--- Touch released event.
-- @function Shuwarin.Layout:touchReleased
-- @param id Touch identifier (or nil for mouse press).
-- @treturn boolean true if event is handled, false otherwise.
function layout:touchReleased(id)
	local a = self.touchState
	-- Ignore other
	if a[1] and a[2] == id then
		-- If there's touch target already, send release to that element
		if self.touchTarget then
			self.touchTarget.event:touchReleased()
			self.touchTarget = nil
			a[1], a[2], a[3], a[4], a[5], a[6] = false, nil, 0, 0, 0, 0
			return true
		-- But if there isn't, then find element
		else
			local elem = self:_internalGetElementByPosition(a[3], a[4])

			if elem then
				-- Send simultaneous touch pressed and release, in order
				local tx, ty = self.drawx - elem.x, self.drawy - elem.y
				elem:touchPressed(a[3] + tx, a[4] + ty, a[3] + tx - (a[5] + tx), a[4] + ty - (a[6] + ty))
				elem:touchReleased()
				a[1], a[2], a[3], a[4], a[5], a[6] = false, nil, 0, 0, 0, 0
				return true
			end
		end

		a[1], a[2], a[3], a[4], a[5], a[6] = false, nil, 0, 0, 0, 0
	end

	return false
end

--- Key pressed event.
-- @function Shuwarin.Layout:keyPressed
-- @tparam string key Key pressed.
-- @treturn boolean true if event is handled, false otherwise.
function layout:keyPressed(key)
	local elem = self:_internalGetElement()
	if elem then
		elem.event:keyPressed(key)
		return true
	end

	return false
end

--- Key released event.
-- @function Shuwarin.Layout:keyReleased
-- @tparam string key Key released.
-- @treturn boolean true if event is handled, false otherwise.
function layout:keyReleased(key)
	local elem = self:_internalGetElement()
	if elem then
		elem.event:keyReleased(key)
		return true
	end

	return false
end

--- Text input event.
-- @function Shuwarin.Layout:textInput
-- @tparam string char Character inputted.
-- @treturn boolean true if event is handled, false otherwise.
function layout:textInput(char)
	local elem = self:_internalGetElement(true)
	if elem then
		elem.event:textInput(char)
		return true
	end

	return false
end

return layout
