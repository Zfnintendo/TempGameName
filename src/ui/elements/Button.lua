--[[
Button.lua - Zeftarium
C 2026-11-06
U 2026-11-06

Extends UIElement with text and an optional click callback. Uses screen coordinates: positive X points right, positive Y downward.
Activation occurs immediately on a left mouse press inside the bounds, rather than on mouse release. Disabled buttons ignore presses.
Mouse events must be forwarded by the caller or UI manager.

[Properties]
Inherits bounds, visible, enabled, and zIndex from UIElement.

- text      Text displayed with a 10-pixel inset from the top-left corner
- onClick   Optional function called without arguments when activated

[Dependencies]
src.ui.UIElement
love2d graphics API

- [.new]            Creates a button from x, y, width, height, text, and onClick.
                    text should be a string; onClick must be a function or nil
                    
- [:draw]           Draws a filled rectangle and text when visible.
                    ses the current graphics color and font.
                    Disabled buttons retain their normal appearance

- [:mousepressed]   Handles a mouse press using screen x, y and button.
                    Activates on button 1 when visible, enabled,
                    and inside the bounds. Returns no value
]]

local UIElement = require("src.ui.UIElement")

local Button = {}
Button.__index = Button

function Button.new(x, y, width, height, text, onClick)
    local self = UIElement.new(x, y, width, height)

    setmetatable(self, Button)

    self.text = text
    self.onClick = onClick

    return self
end

function Button:draw()
    if not self.visible then return end

    local x, y = self.bounds.position:unpack2()
    local width = self.bounds.width
    local height = self.bounds.height

    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.print(self.text, x + 10, y + 10)
end

function Button:mousepressed(x, y, button)
    if not self.enabled then return end

    if button == 1 and self:contains(x, y) then
        if self.onClick then
            self.onClick()
        end
    end
end

setmetatable(Button, { __index = UIElement })

return Button