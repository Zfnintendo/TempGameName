--[[
SceneManager - Zeftarium

Owns the active scene and forwards lifecycle and input events to it
Scene callbacks are optional
does not manage run progression, generation or gameplay rules

- [.new] Creates a manager with no active scene
- [:dispatch] calls active scene's named method if exists, passes the scene as self followed by all supplied args, returns the callback result or nil if none
- [:change] immediately transitions to another scene calls exist on old scene then enter params for new scene, 
            callers should return after changing scenes to avoid continuing logic belonging to the previous scene

[Dependenceis]
None
]]


local SceneManager = {}
SceneManager.__index = SceneManager

function SceneManager.new()
    local self = setmetatable({
        current = nil
    }, SceneManager)

    return self
end

function SceneManager:dispatch(event, ...)
    local scene = self.current
    local callback = scene and scene[event]

    if callback then return callback(scene, ...) end

    return nil
end

function SceneManager:change(scene, params)
    assert(type(scene) == "table", "Expected a scene table")

    self:dispatch("exit")
    self.current = scene
    self:dispatch("enter", params)
end

return SceneManager