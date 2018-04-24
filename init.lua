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
-- Use `Shuwarin.Layout(width, height)` to create new layout. Extend `Shuwarin.Element` to create
-- your own element.
-- @see Shuwarin.Layout
-- @see Shuwarin.Event
-- @usage
-- -- Load Shuwarin. Shuwarin doesn't export itself to global table namespace
-- -- so you need to store the returned value of `require`!
-- local Shuwarin = require("shuwarin")
-- @usage
-- -- Create new layout with 800x600 size
-- layout = Shuwarin.Layout(800, 600)
-- @usage
-- -- Extend element class. The second parameter is the
-- -- class name. It's good to give your class name a meaningful
-- -- name!
-- myelement = Shuwarin.Element:extend("myelement")

local path = ...
local love = require("love")
local Shuwarin = require(path..".main")

assert(love._version >= "11.0", "Shuwarin requires LÖVE 11.0 or later")
assert(love.graphics, "Shuwarin cannot function without love.graphics")

-- Warning about FBO errors
if love._version < "11.1" then
	io.stderr:write("Warning: Shuwarin use Canvas. Please update your LOVE to 11.1\n")
end

Shuwarin.platform = require(path..".platform")

Shuwarin.Layout = require(path..".layout")
Shuwarin.Element = require(path..".element")
Shuwarin.Style = require(path..".style")

return Shuwarin
