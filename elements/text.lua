-- Simple text display
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

--- Simple text display.
-- @module Shuwarin.Elements.Text
-- This module handles text display. Line break is handled automatically.
-- Please note that to set the text color from style, use @{Shuwarin.Style:setColor}
-- and to set the text shadow, use @{Shuwarin.Style:setBoxShadow} instead of
-- @{Shuwarin.Style:setTextShadow}.

local path = string.sub(..., 1, string.len(...) - string.len(".elements.text"))
local love = require("love")
local element = require(path..".element")
local text = element:extend("Shuwarin.Elements.Text")

--- Create new text display.
-- You can pass simple text, or colored text. If you want colored text, please
-- see [`Text:addf`](https://love2d.org/wiki/Text:addf).
-- @tparam string|table txt Text to show.
-- @tparam boolean newlinetospace Convert new line into space? (only if `txt` is string)
-- @treturn Shuwarin.Elements.Text Text object.
function text:init(txt, newlinetospace)
	-- Initialize element
	element.init(self)
	-- Disable event handling
	self.event:setEnable(false)
	-- Check if text is string and newline to space is true
	if type(txt) == "string" and newlinetospace then
		txt = string.gsub(txt, "[\r\n|\r|\n]", " ")
	end
	-- Set text
	self.txt = txt
	-- Create new text object
	self.textObject = love.graphics.newText(self.style.font)
end

--- Text display update.
-- Unlike other elements, this method can be called by user code if needed.
-- @function Shuwarin.Elements.Text:update
function text:update()
	-- Check if style is modified
	if self.style.modified then
		-- Rebuild text.
		local wraplimit = self.layout:getDisplayableDimensions()
		self.textObject:clear()
		self.textObject:setFont(self.style.font)
		self.textObject:addf(self.txt, wraplimit, "left", 0, 0)
		self.width, self.height = self.textObject:getDimensions()
	end
end

--- Text display draw.
function text:draw()
	-- Calculate color
	local r1, g1, b1, a1 = self.style.color[1], self.style.color[2], self.style.color[3], self.style.color[4] or 1
	local r2, g2 = self.style.textColor[1], self.style.textColor[2]
	local b2, a2 = self.style.textColor[3], self.style.textColor[4] or 1
	love.graphics.setColor(r1 * r2, g1 * g2, b1 * b2, a1 * a2)
	love.graphics.draw(self.textObject)
end

return text
