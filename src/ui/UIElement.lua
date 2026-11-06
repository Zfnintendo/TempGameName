--[[
UIElement.lua - Zeftarium

Provides a base UI element with rectangular bounds and state flags. Intended to be extended by elements such as labels and buttons.
Bounds use screen coordinates: positive X points right and positive Y points downward. Rectangle Z is fixed to zero when constructed.
Update and draw are empty methods/hooks for subclasses to override. The UI manager or subclasses must handle visibility, enabled state, and ordering.

[Properties]
- bounds    Rectangle describing the element's position and dimensions
- visible   Whether the element should be shown; defaults to true
- enabled   Whether the element should accept interaction; defaults to true
- zIndex    Intended UI ordering value; defaults to zero.
            Separate from the Rectangle's Z coordinate

[Dependencies]
src.classes.Rectangle

- [.new]        Creates an element from x, y, width, and height.
                Arguments are required; dimensions must be non-negative
                and all arguments must be finite numbers

- [:update]     Empty update hook receiving elapsed seconds as dt
- [:draw]       Empty drawing hook

- [:contains]   Returns whether screen point x, y lies within the bounds.
                Includes left/top edges and excludes right/bottom edges.
                Does not check visible or enabled state
]]

local Rectangle = require("src.classes.Rectangle")

local UIElement = {}
UIElement.__index = UIElement

function UIElement.new(x, y, width, height)
    local self = setmetatable({
        bounds = Rectangle.new(x, y, 0, width, height),
        visible = true,
        enabled = true,
        zIndex = 0,
    }, UIElement)

    return self
end

function UIElement:update(dt)
    -- Override in subclasses
end

function UIElement:draw()
    -- Override in subclasses
end

function UIElement:contains(x, y)
    return self.bounds:contains(x, y, 0)
end

return UIElement