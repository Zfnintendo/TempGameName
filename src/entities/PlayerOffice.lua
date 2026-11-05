--[[
PlayerOffice.lua - Zeftarium

Creates an office player entity with Position and Velocity components.
Office movement has no gravity or jumping. Positive Y points upward in world space.
Each entity receives independent component instances. Collision dimensions extend from the position in positive X and Y.

[Dependencies]
src.classes.Position
src.classes.Velocity
src.utils.NumberValidation
*A World instance supplied by the caller*

- [.create] Creates an office player and returns its entity IDs, z defaults to zero when omitted
]]

local Position = require("src.classes.Position")
local Velocity = require("src.classes.Velocity")
local Validation = require("src.utils.NumberValidation")

local PlayerOffice = {}

local _validateCoordinates = Validation.validateCoordinates

function PlayerOffice.create(world, x, y, z)
    if z == nil then
        z = 0
    end

    _validateCoordinates(x, y, z)

    return world:create({
        position = Position.new(x, y, z),
        velocity = Velocity.new(),

        playerControlled = {},

        officeMovement = {
            speed = 160,
            facing = "down",
        },

        collider = {
            width = 24,
            height = 24,
        },
    })
end

return PlayerOffice