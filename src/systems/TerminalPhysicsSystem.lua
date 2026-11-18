--[[
TerminalPhysicsSystem.lua - Zeftarium
C 2026-11-16
U 2026-11-16

Synchronizes unrotated rectangular physics bodies into ECS components. Body positions represent centers; ECS positions represent minimum corners.
Positive Y points upward. Position and collider.hitbox.position must share the same instance.
Updates Position in place and leaves Z unchanged. Z does not filter physics collisions.
Copies linear velocity when a velocity component exists. Optional gravity.terminalVelocity.y limits downward speed after stepping.
Grounding requires a touching, enabled, non-sensor contact with a sufficiently upward normal toward the entity.
Upward-moving entities are not grounded. Does not step physics or apply additional gravity.

[Dependencies]
love2d physics API
A World instance supplied by the caller

- [.sync] Synchronizes body state and updates grounded status
]]

local TerminalPhysicsSystem = {}

local MIN_GROUND_NORMAL_Y = 0.7

local function isGrounded(body, velocityY)
    if velocityY > 0 then return false end

    for _, contact in ipairs(body:getContacts()) do
        if contact:isTouching() and contact:isEnabled() then
            local fixtureA, fixtureB = contact:getFixtures()

            if not fixtureA:isSensor() and not fixtureB:isSensor() then
                local _, normalY = contact:getNormal()

                if fixtureA:getBody() == body then normalY = -normalY end

                if normalY >= MIN_GROUND_NORMAL_Y then return true end
            end
        end
    end

    return false
end

function TerminalPhysicsSystem.sync(world)
    for _, entity in world:query("physics", "position", "collider") do
        local body = entity.physics.body
        local hitbox = entity.collider.hitbox

        assert(rawequal(entity.position, hitbox.position), "Entity and hitbox must share the same Position instance")

        local x, y = body:getPosition()
        local velocityX, velocityY = body:getLinearVelocity()

        if entity.gravity then
            local minimumY = entity.gravity.terminalVelocity.y

            if velocityY < minimumY then
                velocityY = minimumY
                body:setLinearVelocity(velocityX, velocityY)
            end
        end

        entity.position:setX(x - hitbox.width / 2)
        entity.position:setY(y - hitbox.height / 2)

        if entity.velocity then entity.velocity:set(velocityX, velocityY, 0) end
        if entity.platformBody then entity.platformBody.grounded = isGrounded(body, velocityY) end
    end
end

return TerminalPhysicsSystem