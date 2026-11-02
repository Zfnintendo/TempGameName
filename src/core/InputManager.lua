--[[
InputManager - Zeftarium

Maps the physical keys to the named game actions
Supports selectable movement layouts and detects the double shift press for ability changes
returns actions for gameplay to handle
Does not execture abilites or change scene

- [.new] creates an input manager with the default movement layout
- [:setMovementScheme] selects a movement layout and raises an error for unknown layout
- [:isDown] returns whether any key bound to the action is currently held so for continuos input
- [:keyPressed] converts a key press into an action or nil if no action applies, ignores repeat events, accounts for double shift\

[Dependencies]
None
]]

-- vars
local DOUBLE_SHIFT_TIME = 0.25

-- class
local InputManager = {}
InputManager.__index = InputManager

-- if you have moe movement schemes pls add here k thx
local movementSchemes = {
    wasd = {
        moveLeft =  "a",
        moveRight = "d",
        moveUp =    "w",
        moveDown =  "s",
    },
    arrows = {
        moveLeft =  "left",
        moveRight = "right",
        moveUp =    "up",
        moveDown =  "down",
    }
}

local sharedBindings = {
    jump =         "space",
    interact =     "e",
    useAbility = { "lshift", "rshift" },
    reset =        "r",
    menu =         "escape",

}

function InputManager.new()
    local self = setmetatable({
        movementScheme = "arrows",
        lastShiftPress = nil,
    }, InputManager)

    return self
end

function InputManager:setMovementScheme(name)
    assert(movementSchemes[name], "Unknown movement layout: " .. tostring(name))
    self.movementScheme = name
end

function InputManager:isDown(action)
    local movementBindings = movementSchemes[self.movementScheme]
    local key = movementBindings[action] or sharedBindings[action]

    assert(key, "Unknown input action: " .. tostring(action))

    if type(key) == "table" then
        for _, boundKey in ipairs(key) do
            if love.keyboard.isDown(boundKey) then
                return true
            end
        end

        return false
    end

    return love.keyboard.isDown(key)
end

function InputManager:keyPressed(key, isRepeat)
    if isRepeat then return nil end

    if key == "lshift" or key =="rshift" then
        local now = love.timer.getTime()

        if self.lastShiftPress and now - self.lastShiftPress <= DOUBLE_SHIFT_TIME then
            self.lastShiftPress = nil
            return "swapAbility"
        end

        self.lastShiftPress = now
        return "useAbility"
    end

    if key == "r" then return "reset" end

    if key == "escape" then return "menu" end

    return nil
end

return InputManager