--[[
OfficeControlSystem.lua - Zeftarium
C 2026-11-12
U 2026-11-12

Converts movement input into velocity for controlled office entities. Does not change position or resolve collisions.
Processes entities containing: playerControlled, officeMovement, and velocity.
Positive Y points upward. Supports eight direction movement.
Opposite direction keys cancel. Diagonal input is normalized to prevent a speed boost when axis speeds match.
Facing prefers the horizontal direction during diagonal movement.
Disabled controls stop velocity while preserving facing. Configured movement velocities are read without being modified.
All enabled matching entities receive the same input.

[Dependencies]
src.classes.Vector
World and InputManager instances supplied by the caller

- [.update] Reads input and sets velocity and facing for office players
]]
local Vector = require("src.classes.Vector")

local OfficeControlSystem = {}

function OfficeControlSystem.update(world, input)
    local horizontal = 0
    local vertical = 0

    if input:isDown("moveLeft") then
        horizontal = horizontal - 1
    end

    if input:isDown("moveRight") then
        horizontal = horizontal + 1
    end

    if input:isDown("moveUp") then
        vertical = vertical + 1
    end

    if input:isDown("moveDown") then
        vertical = vertical - 1
    end

    local direction = Vector.new(horizontal, vertical, 0):normalize()

    for _, components in world:query("playerControlled", "officeMovement", "velocity") do
        local control = components.playerControlled
        local movement = components.officeMovement
        local velocity = components.velocity

        if control.enabled then
            velocity:set(
                direction.x * movement.horizontalSpeed.x,
                direction.y * movement.verticalSpeed.y,
                0
            )

            if direction.x ~= 0 then
                movement.facing = direction.x > 0 and "right" or "left"
            elseif direction.y ~= 0 then
                movement.facing = direction.y > 0 and "up" or "down"
            end
        else
            velocity:stop()
        end
    end
end

return OfficeControlSystem