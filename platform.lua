-- Platform code (customizable)
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

--- Platform, alterable functions.
-- @module Shuwarin.Platform
-- You can modify all functions in this module if you need more flexibility.

local love = require("love")
local platform = {}

--- Returns the drawable dimensions.
-- This function defaults to `love.graphics.getDimensions`
-- @function Shuwarin.platform.getDimensions
-- @treturn number viewport width.
-- @treturn number viewport height.
platform.getDimensions = love.graphics.getDimensions

--- Returns the current active font.
-- This function defaults to `love.graphics.getFont`
-- @function Shuwarin.platform.getFont
-- @return Font object
platform.getFont = love.graphics.getFont

return platform
