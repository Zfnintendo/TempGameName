--[[
SceneContext.lua - Zeftarium
C 2026-11-11
U 2026-11-11

Owns the gameplay world, UI manager, and named references for one scene. Each context receives independent World and UIManager instances.
Named references do not copy object state. Entity references should store IDs; UI references store element objects.
Remove stale references when their associated objects are removed. Does not automatically update, draw, save, or restore scene contents.

[Dependencies]
src.ecs.World
src.ui.UIManager

- [.new] Creates an empty context
]]

local World = require("src.ecs.World")
local UIManager = require("src.ui.UIManager")

local SceneContext = {}
SceneContext.__index = SceneContext

function SceneContext.new()
    local self = setmetatable({
        world = World.new(),
        ui = UIManager.new(),

        entities = {},
        elements = {},
    }, SceneContext)

    return self
end

return SceneContext