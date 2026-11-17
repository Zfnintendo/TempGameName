--[[
TerminalControlSystem.lua - Zeftarium
C 2026-11-16
U 2026-11-17

Controls physics-driven terminal players using positive-Y-up coordinates.
Processes entities with playerControlled, platformMovement, platformBody, and physics components.
Horizontal input sets body velocity directly. Opposite horizontal keys cancel.
Facing changes when horizontal input is non-zero.
Jump requests are consumed on the next control update. Jumping is allowed while grounded or during the remaining coyote period.
Ground contact refreshes coyote time; jumping consumes it. Requests outside that window are discarded; jump buffering is not implemented.
Disabled controls stop horizontal movement and clear jump requests and coyote time. Vertical velocity is preserved. 
Does not step physics, apply gravity, or update ECS position. The caller must ignore repeated key events before calling keyPressed.
All enabled matching entities receive the same input.

[Dependencies]
World and InputManager instances supplied by the caller
love2d physics API

- [.keyPressed] Records a jump request for enabled entities when
                action is "jump" or key is "space"

- [.update]     Reads horizontal input, advances coyote timers using dt
                in seconds, and applies movement and eligible jumps
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
        local platformBody = entity.platformBody
        local body = entity.physics.body

        local _, velocityY = body:getLinearVelocity()
        local velocityX = 0

        if entity.playerControlled.enabled then
            if platformBody.grounded then 
                movement.coyoteRemaining = movement.coyoteDuration
            else
                movement.coyoteRemaining = math.max(0, movement.coyoteRemaining - dt)
            end

            velocityX = direction * movement.horizontalVelocity.x

            if direction ~= 0 then movement.facing = direction > 0 and "right" or "left" end

            local canJump = platformBody.grounded or movement.coyoteRemaining > 0

            if movement.jumpRequested and canJump then
                velocityY = movement.jumpVelocity.y
                platformBody.grounded = false

                movement.coyoteRemaining = 0
            end
        else
            movement.coyoteRemaining = 0
        end

        movement.jumpRequested = false

        body:setLinearVelocity(velocityX, velocityY)
    end
end

return TerminalControlSystem