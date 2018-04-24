Shuwarin
========

Dreaming LÖVE GUI Library. Retained (stateful; instance) and immediate (rendering) GUI.

History
-------

I can't find any GUI library for LOVE which suits my needs, which are:

* Must able to handle touch events.

* Retained mode (because immediate mode GUI out there won't able to run in phones due to performance issue).

* LOVE 11.0 (I don't have plans to support 0.10.2).

* Not depends on [`love.graphics.getDimensions`](https://love2d.org/wiki/love.graphics.getDimensions) for resolution (Live Simulator: 2 uses virtual constant resolution).

* Runs fast in phones (because Live Simulator: 2; other GUIs eats CPU alot even in desktop).

* No "global" state. Everything must be an instance (because the elements can be unrendered at anytime).

* Not altering any LOVE states and not polluting the Lua global namespace.

Architecture
------------

Unlike other GUI library, in here, everything is instance, including the layout. You add elements
to the layout using existing available pre-written elements, or create your own. All elements can be
styled similarly to CSS (border, shadow, color, ...)

Documentation
-------------

To generate documentation, you need [LDoc](https://github.com/stevedonovan/LDoc) then execute
`ldoc -d docs/. -c ldocConfig.ld .` to generate the documentation.

Example
------

```lua
local love = require("love")
local Shuwarin = require("shuwarin")
local button = require("shuwarin.elements.button")
local text = require("shuwarin.elements.text")
local layout, mybutton, mytext

love.window.setTitle("Shuwarin☆Drea~min")

local placeholderText = [[
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu
fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
culpa qui officia deserunt mollit anim id est laborum.
]]

function love.load()
	-- Create new layout.
	layout = Shuwarin.Layout(800, 600)
	-- Create new text object.
	mytext = text(placeholderText, layout, true)
	-- Set position
	mytext:setPosition(5, 5)
	-- Set text color to black
	mytext.style:setColor({0, 0, 0})
	-- Set shadow and blur
	mytext.style:setBoxShadow(1, 1, 2, {0, 0, 1, 0.8})
	-- Add to layout
	layout:addElement(mytext)
	-- Force update element (recalculate)
	mytext:update()
	-- Create new button with caption "Test Button"
	mybutton = button("Test Button")
	-- Set X position to 25, and Y position to below text element added before + 10px below
	mybutton:setPosition(25, layout:getFreeHeightPosition(select(2, mybutton:getDimensions())) + 10)
	-- Add mouse up event handler (triggered when button is clicked)
	mybutton.event:addHandler("mouseUp", function(self)
		print("Button clicked", self)
	end)
	-- Set box shadow
	mybutton.style:setBoxShadow(4, 4, 4)
	-- Set text (caption) shadow
	mybutton.style:setTextShadow(2, 2, 2)
	-- Add element.
	layout:addElement(mybutton)
end

function love.update(deltaT)
	return layout:update(deltaT)
end

function love.draw()
	love.graphics.clear(1, 1, 1, 1)
	return layout:draw()
end

function love.mousepressed(x, y)
	return layout:touchPressed(nil, x, y)
end

function love.mousemoved(x, y)
	return layout:touchMoved(nil, x, y)
end

function love.mousereleased()
	return layout:touchReleased(nil)
end
```
