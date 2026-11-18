--[[
MenuTemplate.lua - Zeftarium

Creates menu scene modules from a title and button declarations. Uses the UIManager supplied by SceneContext.
Buttons are arranged vertically and centered in the window. The layout updates when the window is resized.
Content is not automatically scaled or scrolled for small windows.
Button actions are resolved from callbacks supplied to new(). Callbacks receive no arguments.
Escape invokes the optional onBack callback. Definitions and shared Color objects should be treated as read-only.
SceneManager must attach a context before calling enter().

[Dependencies]
src.classes.Color
src.ui.elements.Label
src.ui.elements.Button

- [.define]         Returns a menu scene module from a declaration

Generated scene methods:
- [.new]            Receives an optional table of action callbacks

- [:enter]          Builds the title and buttons

- [:update]         Updates UI
- [:draw]           Clears the background and draws UI

- [:keyPressed]     Handles Escape
- [:mousepressed]   Forwards mouse input to UI
- [:wheelmoved]     Forwards wheel input to UI

- [:resize]         Repositions UI
]]

local Color = require("src.classes.Color")
local Label = require("src.ui.elements.Label")
local Button = require("src.ui.elements.Button")

local MenuTemplate = {}

local function layout(scene)
    local windowWidth, windowHeight = love.graphics.getDimensions()

    local width = scene.buttonWidth
    local height = scene.buttonHeight
    local gap = scene.gap

    local buttonCount = #scene.buttons
    local buttonArea = buttonCount * height + math.max(0, buttonCount - 1) * gap

    local totalHeight = 60 + buttonArea
    local x = (windowWidth - width) / 2
    local y = (windowHeight - totalHeight) / 2

    scene.context.elements.title.bounds:setPosition(x, y, 0)

    for index, button in ipairs(scene.buttons) do
        button.bounds:setPosition(x, y + 60 + (index - 1) * (height + gap), 0)
    end
end

function MenuTemplate.define(definition)
    assert(type(definition) == "table", "Expected a menu definition")
    assert(type(definition.title) == "string", "Expected a menu title")
    assert(type(definition.buttons) == "table", "Expected button declarations")

    local Scene = {}
    Scene.__index = Scene

    function Scene.new(actions)
        actions = actions or {}

        assert(type(actions) == "table", "Expected action callbacks")

        return setmetatable({
            actions = actions,
        }, Scene)
    end

    function Scene:enter()
        self.buttonWidth = 280
        self.buttonHeight = 48
        self.gap = 12
        self.buttons = {}

        self.backgroundColor = definition.backgroundColor or Color.new255(25, 28, 35)

        local title = Label.new(0, 0, self.buttonWidth, 40, definition.title):setAlign("center")

        self.context.elements.title = self.context.ui:add(title)

        for index, item in ipairs(definition.buttons) do
            assert(type(item.text) == "string", "Expected button text")
            assert(type(item.action) == "string", "Expected action name")

            local callback = self.actions[item.action]

            assert(type(callback) == "function", "missing menu callback: " .. item.action)

            local button = Button.new(0, 0, self.buttonWidth, self.buttonHeight, item.text, callback)

            self.buttons[index] = self.context.ui:add(button)
        end

        self.context.elements.buttons = self.buttons

        layout(self)
    end

    function Scene:update(dt)
        self.context.ui:update(dt)
    end

    function Scene:draw()
        love.graphics.clear(self.backgroundColor:unpack())

        love.graphics.push("all")
        love.graphics.setColor(1, 1, 1, 1)

        self.context.ui:draw()

        love.graphics.pop()
    end

    function Scene:resize(width, height)
        layout(self)
    end

    function Scene:keyPressed(key, scancode, isRepeat)
        if isRepeat then return end
        if key == "escape" and self.actions.onBack then self.actions.onBack() return end
    end

    function Scene:mousepressed(x, y, button)
        return self.context.ui:mousepressed(x, y, button)
    end

    function Scene:wheelmoved(dx, dy)
        local x, y = love.mouse.getPosition()
        return self.context.ui:wheelmoved(dx, dy, x, y)
    end

    return Scene
end

return MenuTemplate