--[[
TerminalChunkValidator.lua - Zeftarium
C 2026-11-16
U 2026-11-16

Validates terminal chunk declarations without modifying them.
Requires exactly 8 rows containing exactly 8 cells each.

Allowed cells:
0 or {0}       = empty
1 or {1}       = standard wall block
{2, "plotId"}  = plot linked to props.plotId

Plot IDs may repeat within a chunk. Repeated IDs share configuration but create independent entities.
Every plot requires matching properties. Every properties entry requires at least one matching plot.

[Dependencies]
None

- [.validate] Accepts chunk and supportedKinds.
              Returns true when valid; raises an error otherwise
]]

local TerminalChunkValidator = {}

local GRID_SIZE = 8

local function isNonEmptyString(value)
    return type(value) == "string" and value:find("%S") ~= nil
end

local function fail(location, message)
    error(location .. ": " .. message, 0)
end

local function validateArray(array, expectedSize, location)
    if type(array) ~= "table" then fail(location, "expected an array") end

    for key in pairs(array) do
        if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or key > expectedSize then fail(location, "unexpected array key " .. tostring(key)) end
    end

    for index = 1, expectedSize do
        if rawget(array, index) == nil then fail(location, "missing entry " .. index) end
    end
end

local function readCell(cell, location)
    if type(cell) == "number" then
        if cell == 0 or cell == 1 then return cell, nil end
        fail(location, 'expected 0, 1, or {2, "plotId"}')
    end

    if type(cell) ~= "table" then fail(location, "cell must be a number or table") end

    local kind = rawget(cell, 1)

    if kind == 0 or kind == 1 then
        validateArray(cell, 1, location)
        return kind, nil
    end

    if kind == 2 then
        validateArray(cell, 2, location)

        local plotId = rawget(cell, 2)

        if not isNonEmptyString(plotId) then fail(location, "plot ID must be a non-empty string") end

        return kind, plotId
    end

    fail(location, "unknown cell type " .. tostring(kind))
end

function TerminalChunkValidator.validate(chunk, supportedKinds)
    assert(type(chunk) == "table", "Expected a chunk table")
    assert(type(supportedKinds) == "table", "Expected a supported-kinds lookup table")

    if not isNonEmptyString(chunk.id) then fail("Chunk", "id must be a non-empty string") end

    local location = "Chunk " .. chunk.id

    validateArray(chunk.grid, GRID_SIZE, location .. " grid")

    if type(chunk.props) ~= "table" then fail(location, "props must be a table; use {} when empty") end

    local plots = {}

    for row = 1, GRID_SIZE do
        local rowLocation = location .. " row " .. row

        validateArray(chunk.grid[row], GRID_SIZE, rowLocation)

        for column = 1, GRID_SIZE do
            local cellLocation = rowLocation .. ", column " .. column
            local kind, plotId = readCell(chunk.grid[row][column], cellLocation)

            if kind == 2 then
                assert(type(plotId) == "string", "Expected a plot ID")

                plots[plotId] = true

                if rawget(chunk.props, plotId) == nil then fail(cellLocation, "missing props for plot '" .. plotId .. "'") end
            end
        end
    end

    for plotId, properties in pairs(chunk.props) do
        if not isNonEmptyString(plotId) then fail(location, "props keys must be non-empty strings") end

        if not plots[plotId] then fail(location, "props '" .. plotId .. "' has no matching plot") end

        if type(properties) ~= "table" then fail(location, "props '" .. plotId .. "' must be a table") end

        if not isNonEmptyString(properties.kind) then fail(location, "props '" .. plotId .. "' requires a kind") end

        if not supportedKinds[properties.kind] then fail(location, "unsupported kind '" .. properties.kind .. "' for plot '" .. plotId .. "'") end
    end

    return true
end

return TerminalChunkValidator