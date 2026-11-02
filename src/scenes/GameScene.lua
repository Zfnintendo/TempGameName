--[[
GameScene - Zeftarium

Provides a temporary room for testing platformer movement, just temp testing in general put you temporary testing scenes here if u want

- [.new] creates the room and a temporary character
- [:reset] returns character to starting position
- [:update] applies movement, gravity and floor collision
- [:draw] draws room and character
- [:keyPressed] handles jumping, resettiung and returning to menu

[Dependencies]
InputManager and menu callback supplied by game
]]

-- vars

local MOVE_SPEED = 240
local GRAVITY =    1400
local JUMP_SPEED = 550

local backgroundColor = {
    red = 31/255,
    green = 33/255,
    blue = 43/255,
    alpha = 1,
}

local floorColor = {
    red = 102/255,
    green = 107/255,
    blue = 122/255,
    alpha = 1,
}

local playerColor = {
    red = 242/255,
    green = 217/255,
    blue = 115/255,
    alpha = 1,
}

local textColor = {
    red = 243/255,
    green = 232/255,
    blue = 215/255,
    alpha = 1,
}

-- class
local GameScene = {}
GameScene.__index = GameScene

function GameScene.new(input, onMenu)
    local self = setmetatable({
        input = input,
        onMenu = onMenu,

        player = {
            x = 0, 
            y = 0,
            width = 32,
            height = 48,
            velocityY = 0,
            grounded = false
        },
    }, GameScene)

    self:reset()
    return self
end

function GameScene:reset()
    local player = self.player
    local floorY = love.graphics.getHeight() - 60

    player.x = 60
    player.y = floorY - player.height
    player.velocityY = 0
    player.grounded = true

    self.input.lastShiftPress = nil
end

function GameScene:update(dt)
    local player = self.player
    local direction = 0

    if self.input:isDown("moveLeft") then
        direction = direction - 1
    end

    if self.input:isDown("moveRight") then
        direction = direction + 1
    end

    player.x = player.x + direction * MOVE_SPEED * dt

    local maxX = math.max(0, love.graphics.getWidth() - player.width)
    player.x = math.max(0, math.min(player.x, maxX))

    player.velocityY = player.velocityY + GRAVITY * dt
    player.y = player.y + player.velocityY * dt

    local floorY = love.graphics.getHeight() - 60

    player.grounded = false

    if player.y + player.height >= floorY then
        player.y = floorY - player.height
        player.velocityY = 0
        player.grounded = true
    end
end

function GameScene:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local floorY = height - 60
    local player = self.player

    love.graphics.clear(backgroundColor.red, backgroundColor.green, backgroundColor.blue, backgroundColor.alpha)

    love.graphics.setColor(floorColor.red, floorColor.green, floorColor.blue, floorColor.alpha)
    love.graphics.rectangle("fill", 0, floorY, width, 60)

    love.graphics.setColor(playerColor.red, playerColor.green, playerColor.blue, playerColor.alpha)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

    love.graphics.setColor(textColor.red, textColor.green, textColor.blue, textColor.alpha)
    love.graphics.print("Layout: " .. self.input.movementScheme .. " | Space: jump | R: reset | Escape: menu", 20, 20)
end

function GameScene:keyPressed(key, scancode, isRepeat)
    local action = self.input:keyPressed(key, isRepeat)

    if action == "menu" then
        self.onMenu()
        return
    end

    if action == "reset" then
        self:reset()
        return
    end

    if not isRepeat and key == "space" and self.player.grounded then
        self.player.velocityY = -JUMP_SPEED
        self.player.grounded = false
    end
end

return GameScene