--[[
TerminalActionSystem.lua - Zeftarium
C 2026-11-17
U 2026-11-17

Processes action-object overlaps against the selected terminal player. Run after physics synchronization.
Springs launch on overlap entry. Spikes apply the strongest overlapping damage when health permits.
Invulnerability prevents repeated damage during its duration.

Returns:
"damaged" = accepted non-fatal damage
"dead"    = accepted fatal damage
nil       = no accepted damage

The scene decides how damage and death affect progression.
Does not teleport players or transition scenes.

[Dependencies]
src.systems.HealthSystem

- [.newState]   Creates independent overlap state
- [.update]     Processes springs and spikes
]]

local HealthSystem = require("src.systems.HealthSystem")

local TerminalActionSystem = {}

function TerminalActionSystem.newState()
    return {
        touching = {},
    }
end

function TerminalActionSystem.update(world, playerId, state)
    local player = world:get(playerId)

    if not player or not player.playerControlled.enabled or player.health.current <= 0 then
        state.touching = {}
        return nil
    end

    local touching = {}
    local launchSpeed = nil
    local damage = 0

    for id, entity in world:query("actionObject", "collider") do
        if player.collider.hitbox:intersects(entity.collider.hitbox) then
            touching[id] = true

            local action = entity.actionObject

            if action.type == "spike" then
                damage = math.max(damage, action.damage)

            elseif action.type == "spring" and not state.touching[id] then
                launchSpeed = math.max(launchSpeed or 0, action.power)
            end
        end
    end

    state.touching = touching

    if damage > 0 and HealthSystem.damage(player.health, damage) then
        if player.health.current <= 0 then return "dead" end
        return "damaged"
    end

    if launchSpeed then
        local body = player.physics.body
        local velocityX, velocityY = body:getLinearVelocity()

        body:setLinearVelocity(velocityX, math.max(velocityY, launchSpeed))

        player.platformBody.grounded = false
    end

    return nil
end

return TerminalActionSystem