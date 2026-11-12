--[[
Game.lua - Zeftarium
C 2026-11-??
U 2026-11-12

Coordinates application startup and forwards events to the active scene.
Starts directly in TestScene, its menu callback temporarily quits the game.
Scenes own their gameplay systems and UI through their SceneContext.

[Dependencies]
src.core.InputManager
src.core.SceneManager
src.scenes.TestScene

- [:load]           Creates shared services and starts the demo
- [:startGame]      Opens a fresh TestScene
- [:update]         Forwards frame updates
- [:draw]           Clears the screen and draws the active scene
- [:keyPressed]     Forwards keyboard presses
- [:mousepressed]   Forwards mouse presses
- [:wheelmoved]     Forwards mouse wheel input
- [:resize]         orwards window size changes
- [:quit]           Calls the active scene's exit callback during shutdown
]]

local InputManager = require("src.core.InputManager")
local SceneManager = require("src.core.SceneManager")
local TestScene = require("src.scenes.TestScene") -- ignore this for now its incomplete

local Game = {}

function Game:load()
    self.input = InputManager.new()
    self.scenes = SceneManager.new()

    self:startGame()
end

function Game:startGame()
    self.scenes:change(TestScene.new(self.input, function()
        love.event.quit()
    end))
end

function Game:update(dt)
    self.scenes:dispatch("update", dt)
end

function Game:draw()
    love.graphics.clear(0, 0, 0)
    self.scenes:dispatch("draw")
end

function Game:keyPressed(key, scancode, isRepeat)
    self.scenes:dispatch("keyPressed", key, scancode, isRepeat)
end

function Game:mousepressed(x, y, button, istouch, presses)
    self.scenes:dispatch(
        "mousepressed", x, y, button, istouch, presses
    )
end

function Game:wheelmoved(dx, dy)
    self.scenes:dispatch("wheelmoved", dx, dy)
end

function Game:resize(width, height)
    self.scenes:dispatch("resize", width, height)
end

function Game:quit()
    if self.scenes then
        self.scenes:dispatch("exit")
    end
end

return Game