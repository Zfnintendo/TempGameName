--[[
OfficeMapBuilder.lua - Zeftarium
C 2026-11-12
U 2026-11-12

Builds static office entities from a map declaration. Coordinates use positive Y upward.
Rectangles extend from their minimum X/Y corner. Creates a non-solid floor and solid walls and desks.
Each entity's position and hitbox share the same Position instance. Colors are shared by reference and should be treated as read-only.
Call once for an empty scene world. Calling again adds another copy; existing entities are not removed.

[Dependencies]
src.classes.Rectangle
src.classes.Color
src.utils.NumberValidation

- [.build] Creates map entities and returns their IDs,
           grouped as floor, walls, and desks
]]

local Rectangle = require("src.classes.Rectangle")
local Color = require("src.classes.Color")
local Validation = require("src.utils.NumberValidation")

local OfficeMapBuilder = {}

local _validateNumber = Validation.validateNumber
local _validateSize2 = Validation.validateSize2

local function createRectangle(world, definition, color, solid, defaultZ)
    local z = definition.z

    if z == nil then z = defaultZ end

    local hitbox = Rectangle.new(definition.x, definition.y, z, definition.width, definition.height)

    return world:create({
        position = hitbox.position,

        collider = {
            hitbox = hitbox,
            solid = solid,
        },

        appearance = {
            visible = true,
            color = definition.color or color,
        },
    })
end

function OfficeMapBuilder.build(world, map)
    _validateSize2(map.width, map.height)

    assert(map.width > 0 and map.height > 0, "map dimensions must be positive")

    local z = map.z
    if z == nil then z = 0 end

    _validateNumber(z)

    local floorColor = map.floorColor or Color.new255(220, 210, 188)
    local wallColor = map.wallColor or Color.new255(65, 72, 82)
    local deskColor = map.deskColor or Color.new255(130, 91, 62)

    local result = {
        walls = {},
        desks = {},
    }

    result.floor = createRectangle(world, {
        x = 0,
        y = 0,
        width = map.width,
        height = map.height,
    }, floorColor, false, z)

    for _, definition in ipairs(map.walls or {}) do
        result.walls[#result.walls + 1] = createRectangle(
            world, definition, wallColor, true, z
        )
    end

    for _, definition in ipairs(map.desks or {}) do
        result.desks[#result.desks + 1] = createRectangle(
            world, definition, deskColor, true, z
        )
    end

    return result
end

return OfficeMapBuilder