--[[

MenuScene - Zeftarium, Katrina

Displays the main menu and handles menu input

- [.new] Creates a new menu scene
- [:draw] Draws the title and instructions
- [:keyPressed] handles menu key presses

[Dependencies]
Color class

]]

-- Preamble
local Color = require("src.classes.Color")

-- Vars
local textColor = Color.new255(243, 232, 215)

local MenuScene = {}
MenuScene.__index = MenuScene

function MenuScene.new(onStart)
    local self = setmetatable({
        onStart = onStart,
    }, MenuScene)

    return self
end

function MenuScene:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    love.graphics.setColor(textColor:unpack())

    love.graphics.printf("Game name", 0, height * 0.35, width, "center")
    love.graphics.printf("Escape: quit", 0, height * 0.35 + 60, width, "center")
    love.graphics.printf("Enter: start", 0, height * 0.35 + 35, width, "center")
end

function MenuScene:keyPressed(key, scancode, isRepeat)
    if isRepeat then
        return
    end

    if key == "return" then
        self.onStart()
        return
    end

    if key == "escape" then
        love.event.quit()
    end
end
return MenuScene