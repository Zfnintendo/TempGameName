--[[
TerminalControlSystem.lua - Zeftarium
C 2026-11-16
U 2026-11-16

Controls physics driven terminal players. Positive Y points upward.
Horizontal input sets body velocity directly. Opposite horizontal keys cancel.
Jump requests are consumed on the next physics step.
Requests made while airborne are discarded.

Disabled controls stop horizontal movement and clear jump requests.
Vertical motion and gravity continue.

[Dependencies]
World and InputManager instances supplied by the caller
love2d physics API

- [.keyPressed] Records Space or named jump actions
- [.update]     Applies horizontal movement and grounded jumping
]]

local TerminalControlSystem = {}

function TerminalControlSystem.keyPressed(world, key, action)
    if action ~= "jump" and key ~= "space" then return end

    for _, entity in world:query("playerControlled", "platformMovement", "platformBody", "physics") do
        if entity.playerControlled.enabled then entity.platformMovement.jumpRequested = true end
    end
end

function TerminalControlSystem.update(world, input, dt)
    local direction = 0

    if input:isDown("moveLeft") then direction = direction - 1 end
    if input:isDown("moveRight") then direction = direction + 1 end

    for _, entity in world:query("playerControlled", "platformMovement", "platformBody", "physics") do
        local movement = entity.platformMovement
        local body = entity.physics.body

        local _, velocityY = body:getLinearVelocity()
        local velocityX = 0

        if entity.playerControlled.enabled then
            velocityX = direction * movement.horizontalVelocity.x

            if direction ~= 0 then movement.facing = direction > 0 and "right" or "left" end

            if movement.jumpRequested and entity.platformBody.grounded then
                velocityY = movement.jumpVelocity.y
                entity.platformBody.grounded = false
            end
        end

        movement.jumpRequested = false

        body:setLinearVelocity(velocityX, velocityY)
    end
end

return TerminalControlSystem