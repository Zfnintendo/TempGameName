--[[
Label.lua - Zeftarium

Extends UIElement to display text using the current love2d font. Coordinates are relative to the parent container.
Text wraps within the bounds' width and starts at the top. Height does not clip text or vertically align it.
Hidden labels skip drawing; enabled state does not affect drawing. Labels do not handle mouse input.
Setters return self for chaining.

[Properties]
Inherits bounds, visible, enabled, and zIndex from UIElement.

- text   Displayed string; defaults to an empty string
- color  Color instance; defaults to opaque white
- align  Horizontal alignment: left, center, or right; defaults to left

[Dependencies]
src.ui.UIElement
src.classes.Color
love2d graphics API

- [.new]            Creates a label from x, y, width, height, and optional text

- [:setText]        Replaces the displayed string
- [:setColor]       Stores a Color instance by reference
- [:setAlign]       Sets horizontal alignment

- [:draw]           Draws visible text and restores the previous graphics state
]]

local UIElement = require("src.ui.UIElement")
local Color = require("src.classes.Color")

local Label = {}
Label.__index = Label

function Label.new(x, y, width, height, text)
    if text == nil then text = "" end

    assert(type(text) == "string", "Label text must be a string")

    local self = UIElement.new(x, y, width, height)
    setmetatable(self, Label)

    self.text = text
    self.color = Color.new(1, 1, 1, 1)
    self.align = "left"

    return self
end

function Label:setText(text)
    assert(type(text) == "string", "Label text must be a string")

    self.text = text
    return self
end

function Label:setColor(color)
    assert(getmetatable(color) == Color, "Label color must be a Color instance")

    self.color = color
    return self
end

function Label:setAlign(align)
    assert(
        align == "left" or align == "center" or align == "right",
        "Label alignment must be left, center, or right"
    )

    self.align = align
    return self
end

function Label:draw()
    if not self.visible
        or self.bounds.width <= 0
        or self.bounds.height <= 0 then
        return
    end

    local x, y = self.bounds.position:unpack2()

    love.graphics.push("all")
    love.graphics.setColor(self.color:unpack())

    love.graphics.printf(
        self.text,
        x, y,
        self.bounds.width,
        self.align
    )

    love.graphics.pop()
end

setmetatable(Label, { __index = UIElement })

return Label