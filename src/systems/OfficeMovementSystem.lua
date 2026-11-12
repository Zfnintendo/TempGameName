--[[
OfficeMovementSystem.lua - Zeftarium
C 2026-11-12
U 2026-11-12

Moves office entities using velocity and elapsed seconds. Resolves movement against solid rectangles on the same Z layer.
Processes entities containing: officeMovement, position, velocity, and collider.
Position must be the same instance as collider.hitbox.position. Updates Position in place to preserve that relationship.
Movement is divided into small steps and resolved along X, then Y. Blocked axes have their velocity set to zero, allowing wall sliding.
Intended for static obstacles and non-overlapping starting positions. Does not implement moving-body physics or swept collision.
Z is a layer identifier and is not integrated as physical movement.

[Dependencies]
src.utils.NumberValidation
A World instance supplied by the caller

- [.update] Moves office entities and resolves solid collisions
]]

local Validation = require("src.utils.NumberValidation")

local OfficeMovementSystem = {}

local MAX_STEP_DISTANCE = 4
local _validateNumber = Validation.validateNumber

local function moveAxis(world, entityId, components, axis, amount)
    if amount == 0 then return end

    local position = components.position
    local hitbox = components.collider.hitbox

    local start = position[axis]
    local target = start + amount

    if components.collider.solid then
        for otherId, other in world:query("collider") do
            local obstacle = other.collider.hitbox

            if otherId ~= entityId and other.collider.solid and position.z == obstacle.position.z and not obstacle:isEmpty() and not hitbox:isEmpty() then

                local overlapsOtherAxis

                if axis == "x" then 
                    overlapsOtherAxis = position.y < obstacle:getBottom() and position.y + hitbox.height > obstacle.position.y
                else
                    overlapsOtherAxis = position.x < obstacle:getRight() and position.x + hitbox.width > obstacle.position.x
                end

                if overlapsOtherAxis then
                    local size = axis == "x" and hitbox.width or hitbox.height

                    local obstacleMin = obstacle.position[axis]
                    local obstacleMax = axis == "x" and obstacle:getRight() or obstacle:getBottom()

                    if amount > 0 then
                        local edge = obstacleMin - size
                        if start <= edge and target > edge then target = edge end
                    else
                        local edge = obstacleMax
                        if start >= edge and target < edge then target = edge end
                    end
                end
            end
        end
    end

    position[axis] = target

    if target ~= start + amount then components.velocity[axis] = 0 end
end

function OfficeMovementSystem.update(world, dt)
    _validateNumber(dt)
    assert(dt >= 0, "Elapsed time must be non-negative")

    for entityId, components in world:query("officeMovement", "position", "velocity", "collider") do
        assert(rawequal(components.position, components.collider.hitbox.position), "Entity and hitbox must share the same Position instance")

        local velocity = components.velocity

        local distance = math.max(math.abs(velocity.x * dt), math.abs(velocity.y * dt))

        _validateNumber(distance)

        local steps = math.max(1, math.ceil(distance / MAX_STEP_DISTANCE))

        local stepTime = dt / steps

        for _ = 1, steps do
            moveAxis(world, entityId, components, "x", velocity.x * stepTime)
            moveAxis(world, entityId, components, "y", velocity.y * stepTime)
        end
    end
end

return OfficeMovementSystem