--[[
Camera.lua - Zeftarium
C 2026-11-12
U 2026-11-12

Provides a camera for a positive-Y-up world. Tracks its center in world coordinates.
Clamps its view to the map, centering maps smaller than the viewport.
Attach applies translation and uniform zoom. Detach restores the previous graphics state.

[Dependencies]
love2d graphics API

- [.new] Creates a camera; zoom defaults to 1

- [:follow] Centers on a target while respecting map boundaries
- [:attach] Applies the camera transformation
- [:detach] Restores the previous graphics state
]]

local Camera = {}
Camera.__index = Camera

local function clampCenter(value, mapSize, viewSize)
    if viewSize >= mapSize then return mapSize / 2 end

    local halfView = viewSize / 2

    return math.max(halfView, math.min(value, mapSize - halfView))
end

function Camera.new(zoom)
    zoom = zoom or 1

    assert(type(zoom) == "number" and zoom > 0 and zoom < math.huge, "Camera zoom must be finite and positive")

    return setmetatable({
        x = 0,
        y = 0,
        zoom = zoom,
    }, Camera)
end

function Camera:follow(x, y, mapWidth, mapHeight)
    local width, height = love.graphics.getDimensions()

    self.x = clampCenter(x, mapWidth, width / self.zoom)
    self.y = clampCenter(y, mapHeight, height / self.zoom)
end

function Camera:attach()
    local width, height = love.graphics.getDimensions()

    love.graphics.push("all")
    love.graphics.translate(width / 2, height / 2)
    love.graphics.scale(self.zoom, self.zoom)
    love.graphics.translate(-self.x, self.y)
end

function Camera:detach()
    love.graphics.pop()
end

return Camera