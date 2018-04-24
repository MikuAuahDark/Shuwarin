-- Simple button
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

--- Simple button.
-- @module Shuwarin.Elements.Button
-- This is very simple button implementation. You can use this for reference
-- of creating your own button. This class derived from @{Shuwarin.Element}!

local path = string.sub(..., 1, string.len(...) - string.len(".elements.button"))
local love = require("love")
local element = require(path..".element")
local button = element:extend("Shuwarin.Elements.Button")

--- Create new simple button.
-- @function Shuwarin.Elements.Button:Button
-- @tparam string caption Text to be displayed for the button
-- @tparam number width Button width (or nil for auto)
-- @tparam number height Button height (or nil for auto)
function button:init(caption, width, height)
	-- Caption
	self.caption = caption
	if width and height then
		self.fixedDimensions = {width, height}
	end
	self.padding = 10 -- All directions. Used for non-fixed position
	-- Caption drawing position
	self.cx, self.cy = 0, 0

	-- Initialize parent
	element.init(self)
	-- Enable events
	self.event:setEnable(true)
	-- Set style
	self.style:setColor({0.5, 0.5, 0.5}, {0.7, 0.7, 0.7})
	-- Run update
	self:update()
end

--- Button update (UI recalculation)
-- @function Shuwarin.Elements.Button:update
function button:update()
	--print(self.event, self.event.enable)
	if self.style.modified then
		-- Recalculate
		local txw, txh = self.style.font:getWidth(self.caption), self.style.font:getHeight()
		if self.fixedDimensions then
			-- Fixed dimensions. Recalculate caption draw position.
			self.width, self.height = self.fixedDimensions[1], self.fixedDimensions[2]
			self.cx = (self.width - self.txw) * 0.5
			self.cy = (self.height - self.txh) * 0.5
		else
			-- Auto dimensions. Recalculate width and height.
			self.width = txw + self.padding * 2
			self.height = txh + self.padding * 2
			self.cx, self.cy = self.padding, self.padding
		end

		-- Recreate text FBO
		if self.textShadowFBO then self.textShadowFBO:release() end
		self.textShadowFBO = self.style:createTextShadowFBO(self.caption)
	end
end

--- Button draw
-- @function Shuwarin.Elements.Button:draw
function button:draw()
	local active = self.event:getTouchPosition()

	love.graphics.setColor(active and self.style.colorActive or self.style.color)
	love.graphics.setFont(self.style.font)
	love.graphics.rectangle("fill", 0, 0, self.width, self.height)
	self.style:drawTextShadow(self.textShadowFBO, self.cx, self.cy)
	love.graphics.setColor(self.style.textColor)
	love.graphics.print(self.caption, self.cx, self.cy)
end

return button
