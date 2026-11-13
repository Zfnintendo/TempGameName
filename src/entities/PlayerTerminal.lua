--[[
PlayerTerminal.lua - Zeftarium

Creates a player for terminal platforming worlds. World coordinates use positive Y upward.
Position is the minimum X/Y corner of the collision rectangle. Z identifies a collision layer.
Position and hitbox share the same Position instance. Systems must update that instance in place.
Creates data only. Input, gravity, movement, collision, and drawing are handled by systems.

[Dependencies]
src.classes.Velocity
src.classes.Rectangle
src.classes.Color
src.utils.NumberValidation
A World instance supplied by the caller

- [.create] Creates a terminal player and returns its entity ID.
            x and y are required; z defaults to zero
]]

local Vector = require("src.classes.Vector")
local Velocity = require("src.classes.Velocity")
local Rectangle = require("src.classes.Rectangle")
local Color = require("src.classes.Color")
local Validation = require("src.utils.NumberValidation")

local PlayerTerminal = {}

local _validateCoordinates = Validation.validateCoordinates

local WIDTH = 24
local HEIGHT = 40

function PlayerTerminal.create(world, x, y, z)
    if z == nil then z = 0 end

    _validateCoordinates(x, y, z)

    local hitbox = Rectangle.new(x, y, z, WIDTH, HEIGHT)

    return world:create({
        position = hitbox.position,
        velocity = Velocity.new(),

        playerControlled = {
            enabled = true,
        },

        platformMovement = {
            horizontalVelocity = Velocity.new(240, 0, 0),
            jumpVelocity = Velocity.new(0, 550, 0),
            facing = "right",
            jumpRequested = false,
        },

        gravity = {
            acceleration = Vector.new(0, -1400, 0),
            terminalVelocity = Velocity.new(0, -700, 0),
        },

        platformBody = {
            grounded = false,
        },

        collider = {
            hitbox = hitbox,
            solid = true,
        },

        appearance = {
            visible = true,
            color = Color.new255(100, 220, 170),
            layer = 20,
        },
    })
end

return PlayerTerminal