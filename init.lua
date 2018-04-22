-- Main code.
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

--- Base Shuwarin module.
-- @module Shuwarin

local path = ...
local love = require("love")
local Shuwarin = require(path..".main")

assert(love._version >= "11.0", "Shuwarin requires LÖVE 11.0 or later")
assert(love.graphics, "Shuwarin cannot function without love.graphics")

Shuwarin.platform = require(path..".platform")
Shuwarin.layout = require(path..".layout")
Shuwarin.element = require(path..".element")

--- Create new layout.
-- @function Shuwarin.newLayout
-- @tparam number width of the layout.
-- @tparam number height of the layout.
-- @treturn Shuwarin.Layout object.
function Shuwarin.newLayout(width, height)
	return Shuwarin.layout(width, height)
end

return Shuwarin
