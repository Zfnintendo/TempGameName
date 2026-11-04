--[[
Position.lua - Zeftarium
C 2026-11-04
U 2026-11-04

Position class for storing positional data about the map such as tiles or players, is simply a wrapper of a vector class

[Dependencies]
src.classes.Vector

- [.new] creates a new position instance
]]

local Vector = require("src.classes.Vector")

local Position = {}
Position.__index = Position
Position.__add = Vector.__add
Position.__mul = Vector.__mul

function Position.new(x, y, z)
    return setmetatable(Vector.new(x, y, z), Position)
end

setmetatable(Position, { __index = Vector })

return Position