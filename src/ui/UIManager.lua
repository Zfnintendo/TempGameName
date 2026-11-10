--[[
UIManager.lua - Zeftarium
C 2026-11-11
U 2026-11-11

UIManager manages the UI elements belonging to a scene. Create one with UIManager.new(), then use add(element) to register root elements such asframes or standalone buttons. 
Children only need to be added to their parent container. remove(element) unregisters a root, and clear() removes all roots.

[Dependencies]
None

- [.new] Creates an empty manager

- [:add]            Appends a root element and returns it
- [:remove]         Removes the first matching root; returns whether it existed
- [:clear]          Removes all roots without destroying their objects

- [:update]         Updates roots that implement update
- [:draw]           Draws visible roots

- [:mousepressed]   Dispatches a press; returns whether it was handled
- [:wheelmoved]     Dispatches wheel input and screen pointer coordinates;
                    returns whether it was handled
]]

local UIManager = {}
UIManager.__index = UIManager

function UIManager.new()
    return setmetatable({
        roots = {},
    }, UIManager)
end

function UIManager:add(element)
    assert(type(element) == "table", "Expected a UI element")

    table.insert(self.roots, element)
    return element
end

function UIManager:remove(element)
    for index, root in ipairs(self.roots) do
        if root == element then
            table.remove(self.roots, index)
            return true
        end
    end

    return false
end

function UIManager:clear()
    self.roots = {}
end

function UIManager:update(dt)
    for _, root in ipairs(self.roots) do
        if root.update then
            root:update(dt)
        end
    end
end

function UIManager:draw()
    for _, root in ipairs(self.roots) do
        if root.visible and root.draw then
            root:draw()
        end
    end
end

function UIManager:mousepressed(x, y, button)
    for index = #self.roots, 1, -1 do
        local root = self.roots[index]

        if root.visible and root.enabled and root.mousepressed then
            if root:mousepressed(x, y, button) then
                return true
            end
        end
    end

    return false
end

function UIManager:wheelmoved(dx, dy, pointerX, pointerY)
    for index = #self.roots, 1, -1 do
        local root = self.roots[index]

        if root.visible and root.enabled and root.wheelmoved then
            if root:wheelmoved(dx, dy, pointerX, pointerY) then
                return true
            end
        end
    end

    return false
end

return UIManager