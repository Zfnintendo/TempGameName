--[[
CameraSystem.lua - Zeftarium
C 2026-11-12
U 2026-11-12

Updates a camera to follow an entity in world coordinates. Targets the center of the entity's collider when present.
Otherwise, targets its position. Map bounds begin at world (0, 0).
Camera handles viewport sizing, zoom, and boundary clamping. Does not move entities or apply drawing transformations.

[Dependencies]
World and Camera instances supplied by the caller

- [.update] Follows targetId within mapWidth and mapHeight.
            Returns true when a target is found, otherwise false
]]

local CameraSystem = {}

function CameraSystem.update(world, camera, targetId, mapWidth, mapHeight)
    if targetId == nil then return false end

    local target = world:get(targetId)

    if not target or not target.position then return false end

    local x = target.position.x
    local y = target.position.y

    if target.collider and target.collider.hitbox then
        local hitbox = target.collider.hitbox

        x = x + hitbox.width / 2
        y = y + hitbox.height / 2
    end

    camera:follow(x, y, mapWidth, mapHeight)

    return true
end

return CameraSystem