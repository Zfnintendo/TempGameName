--[[
World.lua - Zeftarium
C 2026-11-05
U 2026-11-05

Stores entities and their component tables. Entity IDs are unique within a World and are not reused.
Components contain data & systems implement behavior. Each entity's component tables should be independently created.
Do not create or destroy entities while iterating a query. Changes to component values during iteration are allowed.

[Dependencies]
None

- [.new] Creates an empty world

- [:create] Stores components and returns a new entity ID
- [:destroy] Removes an entity; returns whether it existed

- [:get] Returns an entity's components, or nil
- [:query] Returns an iterator over entities containing all named components
]]

local World = {}
World.__index = World

function World.new()
    local self = setmetatable({
        entities = {},
        nextId = 1,
    }, World)

    return self
end

function World:create(components)
    assert(type(components) == "table", "expected component table")

    local id = self.nextId
    self.nextId = id + 1

    self.entities[id] = components

    return id
end

function World:destroy(id)
    local existed = self.entities[id] ~= nil
    self.entities[id] = nil

    return existed
end

function World:get(id)
    return self.entities[id]
end

function World:query(...)
    local required = { ... }
    local currentId = nil

    return function()
        while true do
            local id, components = next(self.entities, currentId)
            currentId = id

            if id == nil then
                return nil
            end

            local matches = true

            for _, name in ipairs(required) do
                if components[name] == nil then
                    matches = false
                    break
                end
            end

            if matches then
                return id, components
            end
        end
    end
end

return World