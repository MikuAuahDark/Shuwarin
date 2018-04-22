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
styled similarly to CSS (border, shadow, padding, margin)

Documentation
-------------

To generate documentation, you need [LDoc](https://github.com/stevedonovan/LDoc) then execute
`ldoc -d doc/. -c ldocConfig.ld` to generate the documentation.
