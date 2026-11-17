--[[
TerminalLevelGenerator.lua - Zeftarium
C 2026-11-16
U 2026-11-16

Creates a seeded horizontal sequence of 64 by 64 chunks. The entry is placed first; remaining placements are selected from a pool.
Pool definitions may repeat. Definitions are validated and never modified.
Only the entry may contain playerSpawn properties. Chunks are placed horizontally without floor or doorway restrictions.
Does not validate platforming reachability between or within chunks.
This validates seams, not complete platforming reachability.

[Dependencies]
src.generation.TerminalChunkValidator
src.utils.NumberValidation
lov2d math API

- [.generate] Accepts settings, tileSize, and property factories.
              Returns seed, placements, width, and height
]]

local Validator = require("src.generation.TerminalChunkValidator")
local Validation = require("src.utils.NumberValidation")

local Generator = {}

local SIZE = 8

local function validateChunk(chunk, factories, isEntry)
    Validator.validate(chunk, factories)

    if not isEntry then
        for _, properties in pairs(chunk.props) do
            assert(properties.kind ~= "playerSpawn", "Middle chunks cannot contain player spawns")
        end
    end
end

function Generator.generate(settings, tileSize, factories)
    assert(type(settings) == "table", "Expected generation settings")

    Validation.validateNumber(tileSize)
    assert(tileSize > 0, "Tile size must be positive")

    local count = settings.chunkCount or 5
    Validation.validateNumber(count)

    assert(count >= 2 and count % 1 == 0, "chunkCount must be an integer of at least 2")

    assert(type(settings.pool) == "table" and #settings.pool > 0, "Expected a middle chunk pool")

    validateChunk(settings.entry, factories, true)

    local ids = {
        [settings.entry.id] = true,
    }

    for _, chunk in ipairs(settings.pool) do
        validateChunk(chunk, factories, false)

        assert(not ids[chunk.id], "Duplicate chunk ID: " .. chunk.id)
        ids[chunk.id] = true
    end

    local seed = settings.seed

    if seed == nil then seed = love.math.random(1, 2147483646) end

    Validation.validateNumber(seed)

    assert(seed >= 1 and seed <= 2147483646 and seed % 1 == 0, "Seed must be an integer between 1 and 2147483646")

    local random = love.math.newRandomGenerator(seed)
    local chunkWidth = SIZE * tileSize

    local result = {
        seed = seed,
        placements = {},
        width = count * chunkWidth,
        height = SIZE * tileSize,
    }

    for index = 1, count do
        local chunk = settings.entry

        if index > 1 then chunk = settings.pool[random:random(#settings.pool)] end

        result.placements[index] = {
            definition = chunk,
            x = (index - 1) * chunkWidth,
            y = 0,
        }
    end

    return result
end

return Generator