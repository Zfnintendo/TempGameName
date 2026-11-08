--[[
Game - Zeftarium

Coordinates game startup and forwards events to active scene

- [:load] creates shared services and opens the menu
- [:update] forwards frame updates
- [:draw] clears the screen and draws the active screen
- [:keyPressed] forwards keyboard presses
- [:resize] forwards window size changes

[Dependencies]
src.core.InputManager
src.core.SceneManager
src.scenes.MenuScene
src.scenes.GameScene
]]

-- Imports
local InputManager = require("src.core.InputManager")
local SceneManager = require("src.core.SceneManager")
local MenuScene = require("src.scenes.MenuScene")
local GameScene = require("src.scenes.GameScene")

local Game = {}

function Game:load()
    self.input = InputManager.new()
    self.scenes = SceneManager.new()

    self:showMenu()
end

function Game:showMenu()
    self.scenes:change(MenuScene.new(function()
        self:startGame()
    end))
end

function Game:startGame()
    self.scenes:change(GameScene.new(self.input, function()
        self:showMenu()
    end))
end

function Game:update(dt)
    self.scenes:dispatch("update", dt)
end

function Game:draw()
    love.graphics.clear(0,0,0)

    self.scenes:dispatch("draw")
end

function Game:keyPressed(key, scancode, isRepeat)
    self.scenes:dispatch("keyPressed", key, scancode, isRepeat)
end

function Game:resize(width, height)
    self.scenes:dispatch("resize", width, height)
end

function Game:quit() end

return Game