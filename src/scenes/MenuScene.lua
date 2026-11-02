--[[
MenuScene - Zeftarium

Displays the main menu and handles menu input

- [.new] Creates a new menu scene
- [:draw] Draws the title and instructions
- [:keyPressed] handles menu key presses

[Dependencies]
None
]]

-- Vars
local textColor = {
    red = 243/255,
    green = 232/255,
    blue = 215/255,
    alpha = 1,
}

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

    love.graphics.setColor(textColor.red, textColor.green, textColor.blue, textColor.alpha)

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