--[[
SceneManager.lua - Zeftarium
C 2026-11-??
U 2026-11-11

Owns the active scene and its context. Each transition creates a fresh context containing a World, UIManager, and named entity and UI references.
The context is available as scene.context before enter(params) runs. The previous context remains available to its scene during exit().
Lifecycle callbacks are optional. Transitions are immediate, callers should return after changing scenes.
Do not request transitions from enter or exit callbacks. Scenes explicitly update and draw their systems and UI.
The manager does not automatically save state or dispose external resources. Scenes must release owned resources and subscriptions in exit().

[Dependencies]
src.core.SceneContext

- [.new]            Creates a manager without an active scene

- [:getCurrent]     Returns the active scene, or nil
- [:getContext]     Returns the active context, or nil

- [:change]         Exits the old scene and enters a scene with a fresh context
- [:dispatch]       Calls an optional method on the active scene and returns
                    its result, or nil when the method is absent
]]

local SceneContext = require("src.core.SceneContext")

local SceneManager = {}
SceneManager.__index = SceneManager

function SceneManager.new()
    local self = setmetatable({
        current = nil,
        context = nil,
        transtitioning = false,
    }, SceneManager)

    return self
end

function SceneManager:getCurrent()
    return self.current
end

function SceneManager:getContext()
    return self.context
end

function SceneManager:change(scene, params)
    assert(type(scene) == "table", "Expected a scene table")
    assert(not self.transitioning,"can not change scenes during enter or exit")

    local context = SceneContext.new()

    self.transitioning = true

    local ok, message = pcall(function()
        self:dispatch("exit")

        self.current = scene
        self.context = context
        scene.context = context

        self:dispatch("enter", params)
    end)

    self.transitioning = false

    if not ok then error(message, 0) end
end

function SceneManager:dispatch(event, ...)
    local scene = self.current
    local callback = scene and scene[event]

    if callback == nil then return nil end

    assert(type(callback) == "function", "scene callback must be a function: " .. tostring(event))

    return callback(scene, ...)
end

return SceneManager