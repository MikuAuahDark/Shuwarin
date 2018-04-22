-- Element styling
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

--- Element styling.
-- @module Shuwarin.Style
-- Style is basically alters how your element look like. You can change it's
-- border, font, colors, ...

local path = string.sub(..., 1, string.len(...) - string.len(".style"))
local love = require("love")
local Shuwarin = require(path..".main")
local class = require(path..".lib.30log")
local style = class("Shuwarin.Style")

--- Create new style.
-- @function Shuwarin.Style:Style
-- @tparam Shuwarin.Element element Element to attach.
-- @treturn Shuwarin.Style Style object.
function style:init(element)
	self.element = element
	-- By default, style is marked as modified
	self.modified = true
	-- Borders
	self.borderWidth = 0
	self.borderColor = {0, 0, 0}
	self.borderColorActive = nil   -- Set to color table if active

	-- Font
	self.font = Shuwarin.platform.getFont()

	-- Background
	self.backgroundColor = {0, 0, 0}
	self.backgroundImage = nil

	-- Front color
	self.color = {1, 1, 1}
	self.colorActive = {1, 1, 1}
end

--- Set the style current font.
-- @function Shuwarin.Style:setFont
-- @param font New LOVE font object.
-- @return Previous set font.
function style:setFont(font)
	local x = self.font
	self.font = font
	self.modified = true
	return x
end

--- Set border properties.
-- Calling this function without any arguments disables border.
-- @function Shuwarin.Style:setBorder
-- @tparam number width Border thickness.
-- @tparam table color Border color.
-- @tparam table hcolor Border hover color.
-- @tparam table acolor Border active color.
function style:setBorder(width, color, hcolor, acolor)
	if not(width) and not(color) and not(hcolor) and not(acolor) then
		self.borderWidth = 0
		self.borderColor = {0, 0, 0, 0}
		self.borderColorHover = nil
		self.borderColorActive = nil
		self.modified = true
	else
		self.borderWidth = assert(type(width) == "number" and width, "bad argument #1 to 'setBorder' (number expected)")
		self.borderColor = assert(type(color) == "table" and color, "bad argument #2 to 'setBorder' (table expected)")
		self.borderColorActive = acolor
		self.modified = true
	end
end

--- Set current style color.
-- @function Shuwarin.Style:setColor
-- @tparam table color Style color.
-- @tparam table hcolor Style hover color.
-- @tparam table acolor Style active color.
function style:setColor(color, acolor)
	self.color = assert(type(color) == "table" and color, "bad argument #1 to 'setColor' (table expected)")
	self.colorActive = acolor
	self.modified = true
end

--- Internal function to update modified flags.
-- @function Shuwarin.Style:update
function style:update()
	self.modified = false
end

--- Internal function to draw style below element.
-- @function Shuwarin.Style:drawBelow
function style:drawBelow()
	if self.borderColor[4] == 0 then return end
	love.graphics.setColor(self.borderColor)
	love.graphics.rectangle("fill", 0, 0, self.element.width, self.element.height)
end

--- Internal function to draw style above element.
-- @function Shuwarin.Style:drawAbove
function style:drawAbove()
end

return style
