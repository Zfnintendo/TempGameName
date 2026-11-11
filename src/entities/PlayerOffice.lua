--[[
PlayerOffice.lua - Zeftarium


Creates an office player for continuous four-direction movement. No gravity or jumping is applied.
Position uses world coordinates with positive Y upward. Position represents the minimum X/Y corner of the collision rectangle.
The position component and hitbox share the same Position instance. Systems must update that Position in place to preserve this relationship.
Configured movement velocities are separate from current velocity. Each player receives independent component instances.

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
    if z == nil then z = 0 end

    _validateCoordinates(x, y, z)

    local hitbox = Rectangle.new(x, y, z, WIDTH, HEIGHT)

    return world:create({
        position = hitbox.position,
        velocity = Velocity.new(),

        playerControlled = {
            enabled = true,
        },

        officeMovement = {
            horizontalSpeed = Velocity.new(160, 0, 0),
            verticalSpeed = Velocity.new(0, 160, 0),
            facing = "down",
        },

        collider = {
            hitbox = hitbox,
            solid = true,
        },

        appearance = {
            visible = true,
        },

        interaction = {
            range = 40,
            requested = false,
        },
    })
end

return PlayerOffice

