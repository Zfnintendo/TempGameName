--[[
PlayerOffice.lua - Zeftarium

Creates an office player entity with Position and Velocity components.
Office movement has no gravity or jumping. Positive Y points upward in world space.
Each entity receives independent component instances. Collision dimensions extend from the position in positive X and Y.

[Dependencies]
src.classes.Position
src.classes.Velocity
src.classes.Rectangle
src.utils.NumberValidation
*A World instance supplied by the caller*

- [.create] Creates an office player and returns its entity ID, z defaults to zero when omitted
]]

local Position = require("src.classes.Position")
local Velocity = require("src.classes.Velocity")
local Rectangle = require("src.classes.Rectangle")
local Validation = require("src.utils.NumberValidation")

local WIDTH = 24
local HEIGHT = 24

local PlayerOffice = {}

local _validateCoordinates = Validation.validateCoordinates

function PlayerOffice.create(world, x, y, z)
    if z == nil then
        z = 0
    end

    _validateCoordinates(x, y, z)

    local hitbox = Rectangle.new(x, y, z, WIDTH, HEIGHT)

    return world:create({
        position = Position.new(x, y, z),
        velocity = Velocity.new(),

        playerControlled = {},

        officeMovement = {
            horizontalSpeed = Velocity.new(160, 0, 0),
            verticalSpeed = Velocity.new(0, 160, 0),
            facing = "down",
        },

        collider = {
            hitbox = hitbox
        },
    })
end

return PlayerOffice