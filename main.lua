-- Setup
local Game = require("src.core.Game")

-- Love2d entry

function love.load()
    Game:load()
end

function love.update(dt)
    Game:update(dt)
end

function love.draw()
    Game:draw()
end

function love.keypressed(key, scancode, isrepeat)
    Game:keyPressed(key, scancode, isrepeat)
end

function love.resize(width, height)
    Game:resize(width, height)
end
