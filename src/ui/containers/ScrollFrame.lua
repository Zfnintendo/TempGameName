--[[
ScrollFrame.lua - Zeftarium
C 2026-11-10
U 2026-11-10

Extends Frame with scrolling along one selected axis. Background, border, and optional scrollbar remain fixed.
Child positions use content coordinates. Content size is supplied explicitly. Children are clipped to a rectangular viewport.
Supports translated, unscaled UI containers. Hidden or disabled frames ignore input. Updates follow Container behavior.
Children receive presses in reverse insertion order. Presses outside the viewport are ignored.
The scrollbar overlays content and appears only when scrolling is possible. Left-clicking its track centers the thumb at the pointer.
Thumb dragging and nested wheel routing are not implemented. Setters return self.

[Properties]
Inherits Frame properties.

- orientation     "vertical" or "horizontal"
- scrollOffset    Offset along the selected axis
- contentSize     Content height or width, depending on orientation
- scrollSpeed     Drawing units per wheel unit
- showScrollbar   Whether the scrollbar may be drawn
- scrollbarSize   Scrollbar thickness
- minThumbSize    Minimum scrollbar thumb length
- trackColor      Color instance for the track
- thumbColor      Color instance for the thumb

[Dependencies]
src.ui.containers.Frame
src.classes.Color
src.utils.NumberValidation
love2d graphics API

- [.new]                    Creates a viewport; optional settings are supplied in a table

- [:setContentSize]         Sets non-negative content length along the selected axis
- [:setScrollOffset]        Sets and clamps the scroll offset
- [:setOrientation]         Selects the axis and resets scrolling and content size
- [:setScrollbarVisible]    Enables or disables scrollbar display

- [:draw]                   Draws the frame, clipped content, scrollbar, and border

- [:mousepressed]           Handles scrollbar clicks or forwards content presses;
                            returns true for a handled scrollbar clicks
- [:wheelmoved]             Accepts wheel deltas and parent-relative pointer coordinates;
                            returns true when scrolling changes
]]

local Frame = require("src.ui.containers.Frame")
local Color = require("src.classes.Color")
local Validation = require("src.utils.NumberValidation")

local ScrollFrame = {}
ScrollFrame.__index = ScrollFrame

local function _validateOrientation(value)
    assert(value == "vertical" or value == "horizontal", "Orientation must be vertical or horizontal")
end

local function _viewportSize(self)
    if self.orientation == "vertical" then return self.bounds.height end
    return self.bounds.width
end

local function _maxScroll(self)
    return math.max(0, self.contentSize - _viewportSize(self))
end

local function _scrollbarMetrics(self)
    local length = _viewportSize(self)

    if not self.showScrollbar or length <= 0 or self.bounds.width <= 0 or self.bounds.height <= 0 or _maxScroll(self) <= 0 then return nil end

    local thumbLength = math.min(length,math.max(self.minThumbSize, length * length / self.contentSize))

    local travel = length - thumbLength
    local thumbOffset = self.scrollOffset / _maxScroll(self) * travel

    return length, thumbLength, travel, thumbOffset
end

function ScrollFrame.new(x, y, width, height, options)
    options = options or {}

    local orientation = options.orientation or "vertical"
    _validateOrientation(orientation)

    if options.showScrollbar ~= nil then assert(type(options.showScrollbar) == "boolean", "showScrollbar must be a boolean") end

    local self = Frame.new(x, y, width, height)
    setmetatable(self, ScrollFrame)

    self.orientation = orientation
    self.scrollOffset = 0
    self.contentSize = _viewportSize(self)
    self.scrollSpeed = 40

    self.showScrollbar = options.showScrollbar ~= false
    self.scrollbarSize = 10
    self.minThumbSize = 24

    self.trackColor = Color.new(0.12, 0.12, 0.12, 1)
    self.thumbColor = Color.new(0.55, 0.55, 0.55, 1)

    if options.contentSize ~= nil then self:setContentSize(options.contentSize) end

    return self
end

function ScrollFrame:setContentSize(size)
    Validation.validateNumber(size)
    assert(size >= 0, "Content size must be non-negative")
    self.contentSize = size
    return self:setScrollOffset(self.scrollOffset)
end

function ScrollFrame:setScrollOffset(offset)
    Validation.validateNumber(offset)
    self.scrollOffset = math.max(0, math.min(offset, _maxScroll(self)))
    return self
end

function ScrollFrame:setOrientation(orientation)
    _validateOrientation(orientation)

    if self.orientation ~= orientation then
        self.orientation = orientation
        self.scrollOffset = 0
        self.contentSize = _viewportSize(self)
    end

    return self
end

function ScrollFrame:setScrollbarVisible(visible)
    assert(type(visible) == "boolean", "Expected a boolean")

    self.showScrollbar = visible
    return self
end

function ScrollFrame:draw()
    if not self.visible or self.bounds.width <= 0 or self.bounds.height <= 0 then return end

    self:setScrollOffset(self.scrollOffset)

    local x, y = self.bounds.position:unpack2()
    local width = self.bounds.width
    local height = self.bounds.height

    love.graphics.push("all")
    love.graphics.translate(x, y)

    love.graphics.setColor(self.backgroundColor:unpack())
    love.graphics.rectangle("fill", 0, 0, width, height, self.cornerRadius, self.cornerRadius)

    love.graphics.push("all")

    local screenX, screenY = love.graphics.transformPoint(0, 0)
    love.graphics.intersectScissor(screenX, screenY, width, height)

    love.graphics.push("all")

    if self.orientation == "vertical" then
        love.graphics.translate(0, -self.scrollOffset)
    else
        love.graphics.translate(-self.scrollOffset, 0)
    end

    love.graphics.setColor(1, 1, 1, 1)

    for _, child in ipairs(self.children) do
        child:draw()
    end

    love.graphics.pop()

    local length, thumbLength, _, thumbOffset =
        _scrollbarMetrics(self)

    if length ~= nil and thumbLength ~= nil and thumbOffset ~= nil then
        local thickness = math.min(self.scrollbarSize, self.orientation == "vertical" and width or height)

        love.graphics.setColor(self.trackColor:unpack())

        if self.orientation == "vertical" then
            love.graphics.rectangle("fill", width - thickness, 0, thickness, height)
        else
            love.graphics.rectangle("fill", 0, height - thickness, width, thickness)
        end

        love.graphics.setColor(self.thumbColor:unpack())

        if self.orientation == "vertical" then
            love.graphics.rectangle("fill",width - thickness, thumbOffset,thickness, thumbLength)
        else
            love.graphics.rectangle("fill", thumbOffset, height - thickness, thumbLength, thickness)
        end
    end

    love.graphics.pop()

    if self.borderWidth > 0 then
        love.graphics.setColor(self.borderColor:unpack())
        love.graphics.setLineWidth(self.borderWidth)

        love.graphics.rectangle("line", 0, 0, width, height, self.cornerRadius, self.cornerRadius)
    end

    love.graphics.pop()
end

function ScrollFrame:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end

    if not self:contains(x, y) then
        return false
    end

    self:setScrollOffset(self.scrollOffset)

    local px, py = self.bounds.position:unpack2()
    local localX = x - px
    local localY = y - py

    local length, thumbLength, travel = _scrollbarMetrics(self)

    if length ~= nil and thumbLength ~= nil and travel ~= nil then
        local vertical = self.orientation == "vertical"
        local crossSize = vertical
            and self.bounds.width or self.bounds.height

        local thickness = math.min(self.scrollbarSize, crossSize)
        local crossPointer = vertical and localX or localY
        local onTrack = crossPointer >= crossSize - thickness

        if onTrack then
            if button == 1 then
                local pointer = vertical and localY or localX
                local fraction = 0

                if travel > 0 then
                    fraction = math.max(
                        0,
                        math.min(1, (pointer - thumbLength / 2) / travel)
                    )
                end

                self:setScrollOffset(fraction * _maxScroll(self))
                return true
            end

            return false
        end
    end

    if self.orientation == "vertical" then
        localY = localY + self.scrollOffset
    else
        localX = localX + self.scrollOffset
    end

    for i = #self.children, 1, -1 do
        local child = self.children[i]

        if child.mousepressed then
            child:mousepressed(localX, localY, button)
        end
    end

    return false
end

function ScrollFrame:wheelmoved(dx, dy, pointerX, pointerY)
    if not self.visible or not self.enabled then
        return false
    end

    if not self:contains(pointerX, pointerY) then
        return false
    end

    self:setScrollOffset(self.scrollOffset)

    local delta = dy

    if self.orientation == "horizontal" then
        delta = dx ~= 0 and dx or dy
    end

    local previous = self.scrollOffset

    self:setScrollOffset(self.scrollOffset - delta * self.scrollSpeed)

    return self.scrollOffset ~= previous
end

setmetatable(ScrollFrame, { __index = Frame })

return ScrollFrame