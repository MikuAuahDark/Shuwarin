-- Simple text input
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

--- Simple text input.
-- @module Shuwarin.Elements.TextInput
-- This is basic text input, which should supports some things which available in
-- full-featured text input. You can position the type position with arrow keys
-- (left or right), home button (set to begin) and end button (set to end).

local path = string.sub(..., 1, string.len(...) - string.len(".elements.textinput"))
local love = require("love")
local element = require(path..".element")
local textInput = element:extend("Shuwarin.Elements.TextInput")

--- Create new text input.
-- The text input height is automatically adjusted based
-- on used font.
-- @tparam number width Text input width.
-- @tparam number maxtext Maximum character which can present in the text input (or nil/0 for no limit)
-- @treturn Shuwarin.Elements.TextInput Text input object.
function textInput:init(width, maxtext)
	-- Initialize element
	element.init(self)
	self.event:setEnable(true)
	self.width = width
	-- Set color
	self.style:setColor({0.5, 0.5, 0.5}, {0.7, 0.7, 0.7})
	-- Set height
	self.height = self.style.font:getHeight() + 7
	-- Set limit
	self.limit = maxtext or 0
	-- Set modified
	self.style.modified = true
	-- Set text
	self.text = {}
	-- Display type position timer
	self.typePositionTimer = 0
	-- Text type cursor position index
	self.typeIndex = 1
	-- Text type cursor position pixel
	self.typePosition = 0
	-- Changed text flag
	self.textChanged = true

	-- Add event handler
	self.event:addHandler("mouseUp", textInput._internalTouchPressed)
	self.event:addHandler("inputChanged", textInput._internalInputChanged)
	self.event:addHandler("keyDown", textInput._internalKeyPressed)
end

--- Internal callback called on touch is pressed.
function textInput:_internalTouchPressed()
	-- Enable keyboard and text input grab, in order.
	self.event:setKeyboardGrab(true)
	self.event:setTextInputGrab(true)
	self.typePositionTimer = 0
end

--- Internal callback called on key press.
function textInput:_internalKeyPressed(key)
	-- If we press left arrow, move it to left
	if key == "left" then self.typeIndex = self.typeIndex -1
	-- If we press right arrow, move it to right
	elseif key == "right" then self.typeIndex = self.typeIndex + 1
	elseif key == "home" then self.typeIndex = 1
	elseif key == "end" then self.typeIndex = #self.text + 1
	-- Otherwise, skip
	else return false end

	-- Clamp
	self.typeIndex = math.min(math.max(self.typeIndex, 1), #self.text + 1)
	-- Recalculate position
	self.typePosition = self.style.font:getWidth(table.concat(self.text, "", 1, self.typeIndex - 1))
	-- Handled.
	return true
end

--- Internal callback called on text input.
function textInput:_internalInputChanged(text)
	-- Check if text is backspace
	if text == "\8" then
		if self.typeIndex > 1 then
			-- Delete character
			table.remove(self.text, self.typeIndex - 1)
			self.typeIndex = self.typeIndex - 1
		else
			-- Skip
			return
		end
	-- Check if text is delete
	elseif text == "\127" then
		if #self.text > self.typeIndex - 1 then
			-- Delete character, but in other ways.
			table.remove(self.text, self.typeIndex)
		else
			-- Skip
			return
		end
	else
		if self.limit == 0 or #self.text < self.limit then
			-- Add to text
			table.insert(self.text, self.typeIndex, text)
			self.typeIndex = self.typeIndex + 1
		else
			-- Skip
			return
		end
	end

	-- Signal modified.
	self.textChanged = true
	self.typePositionTimer = 0
end

--- Update text input.
-- @function Shuwarin.Elements.TextInput:update
-- @tparam deltaT Time passed since last frame, in seconds.
function textInput:update(deltaT)
	self.typePositionTimer = (self.typePositionTimer + deltaT) % 1

	-- Check if previous status is not equal
	if self.textInputActive ~= self.event.keyboard.enableText then
		-- Signal redraw
		self.textChanged = true
		self.textInputActive = self.event.keyboard.enableText
	end

	-- Check if style is modified
	if self.style.modified then
		-- Release FBO
		if self.FBO then self.FBO:release() end
		-- Recalculate height
		self.height = self.style.font:getHeight()
		-- Create new FBO
		self.FBO = love.graphics.newCanvas(self.width, self.height)
		-- Do draw
		self:_internalDrawText()
	elseif self.textChanged then
		-- Do redraw
		self:_internalDrawText()
	end
end

--- Internal function for drawing to FBO.
-- @function Shuwarin.Elements.TextInput:_internalDrawText
function textInput:_internalDrawText()
	-- Get text
	local text = table.concat(self.text)
	-- Start drawing
	love.graphics.push("all")
	love.graphics.setCanvas(self.FBO)
	love.graphics.setFont(self.style.font)
	love.graphics.setColor(self.event.keyboard.enableText and self.style.colorActive or self.style.color)
	love.graphics.rectangle("fill", 0, 0, self.width, self.height)
	love.graphics.setColor(self.style.textColor)
	-- TODO: Text shadow
	love.graphics.print(text)
	love.graphics.pop()

	-- Set type position
	self.typePosition = self.style.font:getWidth(text:sub(1, self.typeIndex - 1))
	-- Set text changed
	self.textChanged = false
end

--- Text input draw.
-- @function Shuwarin.Elements.TextInput:draw
function textInput:draw()
	local a, b = love.graphics.getBlendMode()
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(self.FBO)
	love.graphics.setBlendMode(a, b)

	-- Should we need to draw the type text position too?
	if self.event.keyboard.enableText and self.typePositionTimer <= 0.5 then
		love.graphics.setFont(self.style.font)
		love.graphics.setColor(self.style.textColor)
		love.graphics.print("|", self.typePosition, -1)
	end
end

--- Get text in the text input.
-- @function Shuwarin.Elements.TextInput:getText
-- @treturn string Text
function textInput:getText()
	return table.concat(self.text)
end

return textInput
