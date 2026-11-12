--[[
RenderSystem.lua - Zeftarium
C 2026-11-12
U 2026-11-12

Draws entities containing position and appearance components. World coordinates use positive Y upward.
Position represents the minimum X/Y corner of the visual. Animated entities use their current animation frame.
Other entities draw their collider rectangle as a placeholder. Optional appearance.width and appearance.height set visual dimensions.
Otherwise, animations use their frame size and rectangles use hitbox size. Appearance color optionally tints the visual; defaults to white.
Drawing does not advance animations or apply a camera. Entities draw in ascending appearance.layer order; layer defaults to zero.
Equal layers draw in ascending entity ID order. Render layers are independent of position Z.

[Dependencies]
src.core.AnimationManager
love2d graphics api

- [.draw] Draws visible entities and restores graphics state
]]

local AnimationManager = require("src.core.AnimationManager")

local RenderSystem = {}

local function setColor(appearance)
    if appearance.color then
        love.graphics.setColor(appearance.color:unpack())
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
end

local function drawAnimation(components)
    local position = components.position
    local appearance = components.appearance

    local image, quad = AnimationManager.getFrame(components.animation)

    local frameWidth, frameHeight

    if quad then
        local _, _, width, height = quad:getViewport()
        frameWidth = width
        frameHeight = height
    else
        frameWidth, frameHeight = image:getDimensions()
    end

    local width = appearance.width or frameWidth
    local height = appearance.height or frameHeight

    local x = position.x
    local y = -position.y - height

    local scaleX = width / frameWidth
    local scaleY = height / frameHeight

    if quad then
        love.graphics.draw(image, quad, x, y, 0, scaleX, scaleY)
    else
        love.graphics.draw(image, x, y, 0, scaleX, scaleY)
    end
end

local function drawPlaceholder(components)
    local hitbox = components.collider.hitbox
    local appearance = components.appearance

    local width = appearance.width or hitbox.width
    local height = appearance.height or hitbox.height

    love.graphics.rectangle("fill", components.position.x, -components.position.y - height, width, height)
end

function RenderSystem.draw(world)
    local drawList = {}

    for id, components in world:query("position", "appearance") do
        if components.appearance.visible and (components.animation or components.collider) then
            drawList[#drawList + 1] = {
                id = id,
                components = components,
            }
        end
    end

    table.sort(drawList, function(a, b)
        local layerA = a.components.appearance.layer or 0
        local layerB = b.components.appearance.layer or 0

        if layerA == layerB then return a.id < b.id end

        return layerA < layerB
    end)

    love.graphics.push("all")

    for _, entry in ipairs(drawList) do
        local components = entry.components

        setColor(components.appearance)

        if components.animation then
            drawAnimation(components)
        else
            drawPlaceholder(components)
        end
    end

    love.graphics.pop()
end

return RenderSystem