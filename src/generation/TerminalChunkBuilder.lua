--[[
TerminalChunkBuilder.lua - Zeftarium
C 2026-11-16
U 2026-11-16

Builds one validated 64-by-64 chunk at a world offset.
Rows run top to bottom; world Y points upward.

0 cells create nothing.
1 cells create solid static physics blocks.
2 cells invoke the factory matching their properties.kind.

Property factories receive: context, x, y, z, properties, tileSize.
Each factory returns one ECS entity ID. Properties are shared configuration and must not be mutated.
Factories must create independent runtime state. Returns wall IDs and plot IDs mapped to entity IDs.
Plot IDs are local to this chunk placement. Building is not transactional. If construction fails, the caller must
discard the partially built scene context and its physics world.

[Dependencies]
src.generation.TerminalChunkValidator
src.utils.NumberValidation
src.classes.Rectangle
src.classes.Color
love2d physics API

- [.build] Builds context, chunk, factory registry, and optional settings
]]

local Validator = require("src.generation.TerminalChunkValidator")
local Validation = require("src.utils.NumberValidation")
local Rectangle = require("src.classes.Rectangle")
local Color = require("src.classes.Color")

local TerminalChunkBuilder = {}

local GRID_SIZE = 64

local function createWall(context, x, y, z, size, color)
    local hitbox = Rectangle.new(x, y, z, size, size)

    local body = love.physics.newBody(context.physicsWorld, x + size / 2, y + size / 2, "static")

    local shape = love.physics.newRectangleShape(size, size)
    local fixture = love.physics.newFixture(body, shape)

    fixture:setFriction(0)
    fixture:setRestitution(0)

    return context.world:create({
        position = hitbox.position,

        collider = {
            hitbox = hitbox,
            solid = true,
        },

        physics = {
            body = body,
            fixture = fixture,
        },

        appearance = {
            visible = true,
            color = color,
            layer = 10,
        },
    })
end

function TerminalChunkBuilder.build(context, chunk, factories, options)
    options = options or {}

    assert(type(factories) == "table", "Expected property factories")

    Validator.validate(chunk, factories)

    for _, properties in pairs(chunk.props) do
        assert(type(factories[properties.kind]) == "function", "expected a factory for kind: " .. properties.kind)
    end

    assert(context.physicsWorld, "Expected a physics world")

    local tileSize = options.tileSize
    if tileSize == nil then tileSize = 32 end

    local offsetX = options.x or 0
    local offsetY = options.y or 0
    local z = options.z or 0

    Validation.validateNumber(tileSize) -- i lowk give up on doing the whole _ naming scheme 
    assert(tileSize > 0, "Tile size must be positive")
    Validation.validateCoordinates(offsetX, offsetY, z)

    local wallColor = options.wallColor or Color.new255(70, 85, 100)

    local result = {
        chunkId = chunk.id,
        x = offsetX,
        y = offsetY,
        width = GRID_SIZE * tileSize,
        height = GRID_SIZE * tileSize,

        walls = {},
        plots = {},
    }

    for row = 1, GRID_SIZE do
        for column = 1, GRID_SIZE do
            local cell = chunk.grid[row][column]
            local kind
            local plotId

            if type(cell) == "table" then
                kind = cell[1]
                plotId = cell[2]
            else
                kind = cell
            end

            local x = offsetX + (column - 1) * tileSize
            local y = offsetY + (GRID_SIZE - row) * tileSize

            if kind == 1 then
                local id = createWall(context, x, y, z, tileSize, wallColor)

                result.walls[#result.walls + 1] = id

            elseif kind == 2 then
                assert(type(plotId) == "string", "Expected plot ID")

                local properties = chunk.props[plotId]
                local factory = factories[properties.kind]

                local id = factory(context, x, y, z, properties, tileSize)

                assert(id ~= nil and context.world:get(id) ~= nil, "Factory must return an existing entity ID: " .. plotId)

                result.plots[plotId] = id
            end
        end
    end

    return result
end

return TerminalChunkBuilder