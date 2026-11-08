--[[
Frame.lua - Zeftarium

Extends Container with a background, optional border, and rounded corners.
Children use coordinates relative to the frame's origin. Children are drawn after the background and border, in insertion order.
Children are not clipped to the frame. Hidden frames skip drawing. Drawing preserves and restores the caller's graphics state.
The graphics color is reset to white before drawing children. All setters return self for chaining.

[Properties]
Inherits bounds, visible, enabled, zIndex, and children from Container.

- backgroundColor  Color instance; defaults to RGBA (0.2, 0.2, 0.2, 1)
- borderColor      Color instance; defaults to RGBA (0.4, 0.4, 0.4, 1)
- borderWidth      Finite non-negative thickness; defaults to 1. Zero disables border drawing
- cornerRadius     Finite non-negative corner radius; defaults to 0

[Dependencies]
src.ui.containers.Container
src.classes.Color
love2d graphics API

- [.new]                Creates a frame from x, y, width, and height

- [:draw]               Draws the visible frame and its children,
                        restoring the previous graphics state afterward

- [:setBackgroundColor] Stores the supplied Color instance by reference
- [:setBorderColor]     Stores the supplied Color instance by reference
- [:setBorderWidth]     Sets a finite non-negative border thickness
- [:setCornerRadius]    Sets a finite non-negative corner radius
]]

local Container = require("src.ui.containers.Container")
local Color = require("src.classes.Color")

local Frame = {}
Frame.__index = Frame

function Frame.new(x, y, width, height)
    local self = Container.new(x, y, width, height)
    setmetatable(self, Frame)

    self.backgroundColor = Color.new(0.2, 0.2, 0.2, 1)
    self.borderColor = Color.new(0.4, 0.4, 0.4, 1)

    self.borderWidth = 1
    self.cornerRadius = 0

    return self
end

function Frame:setBackgroundColor(color)
    assert(getmetatable(color) == Color, "Background color must be a Color instance")

    self.backgroundColor = color
    return self
end

function Frame:setBorderColor(color)
    assert(getmetatable(color) == Color, "Border color must be a Color instance")

    self.borderColor = color
    return self
end

function Frame:setBorderWidth(width)
    assert(
        type(width) == "number"
        and width >= 0
        and width < math.huge,
        "border width must be a finite non negative number"
    )

    self.borderWidth = width
    return self
end

function Frame:setCornerRadius(radius)
    assert(
        type(radius) == "number"
        and radius >= 0
        and radius < math.huge,
        "Corner radius must be a finite non negative number"
    )

    self.cornerRadius = radius
    return self
end

function Frame:draw()
    if not self.visible then return end

    local x, y = self.bounds.position:unpack2()
    local width = self.bounds.width
    local height = self.bounds.height

    love.graphics.push("all")
    love.graphics.translate(x, y)

    love.graphics.setColor(self.backgroundColor:unpack())

    love.graphics.rectangle("fill", 0, 0, width, height, self.cornerRadius, self.cornerRadius)

    if self.borderWidth > 0 then
        love.graphics.setColor(self.borderColor:unpack())
        love.graphics.setLineWidth(self.borderWidth)

        love.graphics.rectangle("line", 0, 0, width, height, self.cornerRadius, self.cornerRadius)
    end

    love.graphics.setColor(1, 1, 1, 1)

    for _, child in ipairs(self.children) do
        child:draw()
    end

    love.graphics.pop()
end

setmetatable(Frame, { __index = Container })

return Frame