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

-- Style shader
style.blurShader = love.graphics.newShader [[
// Modified from https://github.com/Jam3/glsl-fast-gaussian-blur/blob/master/5.glsl
extern number dirx;
extern number diry;

vec4 blur5(Image image, vec2 uv, vec2 resolution, vec2 direction) {
	vec4 color = vec4(0.0);
	vec2 off1 = vec2(1.3333333333333333) * direction;
	color += Texel(image, uv) * 0.29411764705882354;
	color += Texel(image, uv + (off1 / resolution)) * 0.35294117647058826;
	color += Texel(image, uv - (off1 / resolution)) * 0.35294117647058826;
	return color;
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 frag)
{
	vec2 direction = vec2(dirx, diry);
	return blur5(tex, uv, love_ScreenSize.xy, direction) * color;
}
]]

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

	-- Font
	self.font = Shuwarin.platform.getFont()

	-- Background
	self.backgroundColor = {0, 0, 0}
	self.backgroundColorActive = nil

	-- Front color. This is left to element to implement how it works.
	self.color = {1, 1, 1}
	self.colorActive = {1, 1, 1}
	self.textColor = {1, 1, 1}

	-- Shadow
	self.boxShadowEnabled = false
	self.boxShadowRadius = 0
	self.boxShadowOffset = {0, 0}
	self.boxShadowColor = {0, 0, 0, 1}

	-- Text shadow. This is left to element to implement how it works.
	self.textShadowEnabled = false
	self.textShadowRadius = 0
	self.textShadowOffset = {0, 0}
	self.textShadowColor = {0, 0, 0, 1}
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

--- Set box shadow properties.
-- Calling this function without parameters disables box shadow completely.
-- @function Shuwarin.Style:setBoxShadow
-- @tparam number offx Offset X position of shadow.
-- @tparam number offy Offset Y position of shadow.
-- @tparam number blur Blur radius in pixels. Set to 0 to disable blur.
-- @tparam table color Shadow color, with 4 numbers inside (index 1, 2, 3, & 4). Defaults to black if none specified.
function style:setBoxShadow(offx, offy, blur, color)
	-- Disable
	self.boxShadowEnabled = not(offx and offy and blur and color)
	self.boxShadowRadius = (blur or 0)
	self.boxShadowOffset = {offx or 0, offy or 0}
	self.boxShadowColor = color or {0, 0, 0, 1}
	self.modified = true
end

--- Set text shadow properties.
-- Calling this function without parameters disables text shadow completely.
-- @function Shuwarin.Style:setTextShadow
-- @tparam number offx Offset X position of shadow.
-- @tparam number offy Offset Y position of shadow.
-- @tparam number blur Blur radius in pixels. Set to 0 to disable blur.
-- @tparam table color Shadow color, with 4 numbers inside (index 1, 2, 3, & 4). Defaults to black if none specified.
function style:setTextShadow(offx, offy, blur, color)
	-- Disable
	self.textShadowEnabled = not(offx and offy and blur and color)
	self.textShadowRadius = (blur or 0)
	self.textShadowOffset = {offx or 0, offy or 0}
	self.textShadowColor = color or {0, 0, 0, 1}
	self.modified = true
end

--- Internal function to update modified flags.
-- @function Shuwarin.Style:update
function style:update()
	self:updateShadow()
	self.modified = false
end

--- Internal function to add shadow below element
-- @function Shuwarin.Style:updateShadow
function style:updateShadow()
	-- Check if box shadow is enabled
	if self.boxShadowEnabled then
		local ex, ey = self.element:getDimensions()

		-- If there's no FBO created, create one :)
		if not(self.boxShadowFBO) then
			self.boxShadowFBO = love.graphics.newCanvas(ex + 10 * self.boxShadowRadius, ey + 10 * self.boxShadowRadius)
		else
			-- Check the size mismatch!
			local lx, ly = self.boxShadowFBO:getDimensions()
			if lx ~= ex + 10 * self.boxShadowRadius or ly ~= ey + 10 * self.boxShadowRadius then
				self.boxShadowFBO = love.graphics.newCanvas(ex + 10 * self.boxShadowRadius, ey + 10 * self.boxShadowRadius)
				self.modified = true
			end
		end

		-- If the style is modified (like by re-creating new FBO)
		if self.modified then
			-- Then recreate box shadow
			love.graphics.push("all")
			love.graphics.setBlendMode("alpha", "premultiplied")
			love.graphics.setCanvas(self.boxShadowFBO)
			love.graphics.clear(0, 0, 0, 0)
			love.graphics.origin()
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle("fill", self.boxShadowRadius * 5, self.boxShadowRadius * 5, ex, ey)
			if self.boxShadowRadius > 0 then
				-- This is would be bit, uh, FBO switching hell.
				local fbo2 = love.graphics.newCanvas(ex + 10 * self.boxShadowRadius, ey + 10 * self.boxShadowRadius)

				love.graphics.setShader(style.blurShader)
				for i = 1, self.boxShadowRadius do
					local radius = self.boxShadowRadius - i

					-- Horizontal blur
					style.blurShader:send("dirx", radius)
					style.blurShader:send("diry", 0)
					love.graphics.setCanvas(fbo2)
					love.graphics.clear(0, 0, 0, 0)
					love.graphics.draw(self.boxShadowFBO)
					-- Vertical blur
					style.blurShader:send("dirx", 0)
					style.blurShader:send("diry", radius)
					love.graphics.setCanvas(self.boxShadowFBO)
					love.graphics.clear(0, 0, 0, 0)
					love.graphics.draw(fbo2)
				end
				-- Release secondary FBO
				fbo2:release()
			end

			-- Reset state
			love.graphics.pop()
		end
	elseif self.boxShadowFBO then
		-- Delete FBO
		self.boxShadowFBO:release()
		self.boxShadowFBO = nil
	end
end

--- Create new FBO containing text shadow based on style settings.
-- @function Shuwarin.Style:createTextShadowFBO
-- @tparam string text Text to draw.
-- @return Canvas object containing the blurred white text, or nil if text shadow is not enabled.
function style:createTextShadowFBO(text)
	if self.textShadowEnabled then
		-- Calculate needed FBO size
		local w, h = self.font:getWidth(text), self.font:getHeight()
		local fbw, fbh = w + 10 * self.textShadowRadius, h + 10 * self.textShadowRadius
		-- Create new FBO
		local fbo = love.graphics.newCanvas(fbw, fbh)

		-- Start drawing. Push state
		love.graphics.push("all")
		love.graphics.setBlendMode("alpha", "premultiplied")
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(self.font)
		love.graphics.setCanvas(fbo)
		love.graphics.clear(0, 0, 0, 0)
		love.graphics.print(text, 5 * self.textShadowRadius, 5 * self.textShadowRadius)

		-- Blur text if text shadow radius is bigger than 0
		if self.textShadowRadius > 0 then
			-- Create secondary FBO and set blend and shader
			local fbo2 = love.graphics.newCanvas(fbw, fbh)
			love.graphics.setShader(style.blurShader)

			-- FBO switching hell again :P
			for i = 1, self.textShadowRadius do
				local radius = self.textShadowRadius - i

				-- Horizontal blur
				style.blurShader:send("dirx", radius)
				style.blurShader:send("diry", 0)
				love.graphics.setCanvas(fbo2)
				love.graphics.clear(0, 0, 0, 0)
				love.graphics.draw(fbo)
				-- Vertical blur
				style.blurShader:send("dirx", 0)
				style.blurShader:send("diry", radius)
				love.graphics.setCanvas(fbo)
				love.graphics.clear(0, 0, 0, 0)
				love.graphics.draw(fbo2)
			end

			-- Release secondary FBO
			fbo2:release()
		end

		-- Reset state
		love.graphics.pop()
		return fbo
	end

	return nil
end

--- Draw text shadow in specified text coordinate.
-- @function Shuwarin.Style:drawTextShadow
-- @param fbo Previous FBO created with @{Shuwarin.Style:createTextShadowFBO}.
-- @tparam number x Text X position.
-- @tparam number y Text Y position.
function style:drawTextShadow(fbo, x, y)
	if fbo == nil then return end

	x, y = x + self.textShadowRadius*-5 + self.textShadowOffset[1], y + self.textShadowRadius*-5 + self.textShadowOffset[2]
	love.graphics.setColor(self.textShadowColor)
	love.graphics.draw(fbo, x, y)
end

--- Internal function to draw style below element.
-- @function Shuwarin.Style:drawBelow
function style:drawBelow()
	if self.borderColor[4] == 0 then return end
	love.graphics.setColor(self.borderColor)
	love.graphics.rectangle("fill", 0, 0, self.element.width, self.element.height)

	if self.boxShadowFBO then
		-- Calculate draw position
		local x, y = self.boxShadowRadius*-5 + self.boxShadowOffset[1], self.boxShadowRadius*-5 + self.boxShadowOffset[2]
		-- Draw
		love.graphics.setColor(self.boxShadowColor)
		love.graphics.draw(self.boxShadowFBO, x, y)
	end
end

--- Internal function to draw style above element.
-- @function Shuwarin.Style:drawAbove
function style:drawAbove()
	-- Draw border if necessary
	if self.borderWidth > 0 then
		local lz = love.graphics.getLineSize()
		love.graphics.setLineWidth(self.borderWidth)
		love.graphics.setColor(self.borderColor)
		love.graphics.rectangle("line", 0, 0, self.element.width, self.element.height)
		love.graphics.setLineWidth(lz)
	end
end

return style
