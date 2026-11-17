--[[
TerminalPropertyFactories.lua - Zeftarium
C 2026-11-16
U 2026-11-16

Maps terminal plot kinds to entity creation functions. Factories receive context, x, y, z, properties, and tileSize.
Each factory returns an existing ECS entity ID. Properties are shared configuration and must not be modified.
Each call creates independent runtime objects.

[Dependencies]
src.entities.PlayerTerminal
love2d physics API

- [.playerSpawn] Creates a terminal player and attaches its physics body
]]

local PlayerTerminal = require("src.entities.PlayerTerminal")
local Rectangle = require("src.classes.Rectangle")
local Color = require("src.classes.Color")
local Validation = require("src.utils.NumberValidation")

local TerminalPropertyFactories = {}

function TerminalPropertyFactories.playerSpawn(context, x, y, z, properties, tileSize)
    local entityId = PlayerTerminal.create(context.world, x, y, z)
    local entity = context.world:get(entityId)
    local hitbox = entity.collider.hitbox

    local body = love.physics.newBody(context.physicsWorld, x + hitbox.width / 2, y + hitbox.height / 2, "dynamic")

    body:setFixedRotation(true)
    body:setBullet(true)

    local shape = love.physics.newRectangleShape(hitbox.width, hitbox.height)

    local fixture = love.physics.newFixture(body, shape, 1)
    fixture:setFriction(0)
    fixture:setRestitution(0)

    entity.physics = {
        body = body,
        fixture = fixture,
    }

    entity.gravity.acceleration = nil

    return entityId
end

function TerminalPropertyFactories.actionObject(context, x, y, z, properties, tileSize)
    local objectType = properties.type

    assert(objectType == "spring" or objectType == "spike", "Unknown action object type")

    if objectType == "spring" then
        Validation.validateNumber(properties.power)
        assert(properties.power > 0, "Spring power must be positive")
    else
        Validation.validateNumber(properties.damage)

        assert(properties.damage > 0 and properties.damage % 1 == 0, "Spike damage must be a positive integer")
    end

    local hitbox = Rectangle.new(x, y, z, tileSize, tileSize)

    return context.world:create({
        position = hitbox.position,

        collider = {
            hitbox = hitbox,
            solid = false,
        },

        appearance = {
            visible = true,
            color = objectType == "spring"
                and Color.new255(80, 220, 140)
                or Color.new255(230, 70, 70),
            layer = 15,
        },

        actionObject = {
            type = objectType,
            power = properties.power,
            damage = properties.damage,
        },
    })
end

return TerminalPropertyFactories