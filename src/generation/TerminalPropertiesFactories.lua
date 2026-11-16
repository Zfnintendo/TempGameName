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

return TerminalPropertyFactories