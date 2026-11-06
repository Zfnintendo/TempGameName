--[[
Container.lua - Zeftarium
C 2026-11-06
U 2026-11-06

Extends UIElement to group and forward events to child UI elements. Child positions are relative to the container's origin.
The container's position is relative to its own parent. Children draw in insertion order and receive mouse presses in reverse insertion order.
zIndex is not used for sorting. Visibility controls drawing only. Updates run regardless of the container's visible or enabled state.
Mouse presses are forwarded whenever the container is enabled, including when the container is hidden.
Children handle their own visibility and enabled state. Container bounds do not clip children or restrict mouse forwarding.
The container does not draw a background or arrange child positions.

[Properties]
Inherits bounds, visible, enabled, and zIndex from UIElement.

- children  Ordered array of child element references; initially empty

[Dependencies]
src.ui.UIElement
love2d graphics API

- [.new]            Creates an empty container from x, y, width, and height

- [:addChild]       Appends a child and returns that child.
                    Rejects parenting the container directly to itself.
                    Does not prevent duplicates, shared children, or
                    indirect parenting cycles

- [:removeChild]    Removes the first matching child.
                    Returns true if removed, otherwise false.
                    Does not destroy the child

- [:update]         Forwards dt to children with an update method,
                    in insertion order, regardless of container state

- [:draw]           When visible, translates drawing to the container's origin
                    and calls each child's draw method in insertion order.
                    Restores the previous graphics transformation afterward

- [:mousepressed]   When enabled, accepts x, y relative to the
                    container's parent and converts them to local coordinates.
                    Forwards the press to every child with a mousepressed
                    method, in reverse insertion order.
                    Does not check container visibility or stop propagation
                    when a child handles the press
]]

local UIElement = require("src.ui.UIElement")

local Container = {}
Container.__index = Container

function Container.new(x, y, width, height)
    local self = UIElement.new(x, y, width, height)
    setmetatable(self, Container)

    self.children = {}

    return self
end

function Container:addChild(child)
    assert(child ~= self, "can not parent a container to itself")

    table.insert(self.children, child)
    return child
end

function Container:removeChild(child)
    for i, element in ipairs(self.children) do
        if element == child then
            table.remove(self.children, i)
            return true
        end
    end

    return false
end

function Container:update(dt)
    for _, child in ipairs(self.children) do
        if child.update then
            child:update(dt)
        end
    end
end

function Container:draw()
    if not self.visible then return end

    local x, y = self.bounds.position:unpack2()

    love.graphics.push()
    love.graphics.translate(x, y)

    for _, child in ipairs(self.children) do
        child:draw()
    end

    love.graphics.pop()
end

function Container:mousepressed(x, y, button)
    if not self.enabled then return end

    local px, py = self.bounds.position:unpack2()

    -- this thing converts parent local coordinates to container local coordinates
    local localX = x - px
    local localY = y - py

    -- last child drawn receives input first
    for i = #self.children, 1, -1 do
        local child = self.children[i]

        if child.mousepressed then
            child:mousepressed(localX, localY, button)
        end
    end
end

setmetatable(Container, { __index = UIElement })

return Container