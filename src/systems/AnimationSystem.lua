--[[
AnimationSystem.lua - Zeftarium
C 2026-11-12
U 2026-11-12

Advances animation playback for entities with an animation component. Paused or finished animations remain unchanged.
Does not choose animation states or draw entities. Visibility does not affect playback.

[Dependencies]
src.core.AnimationManager
src.utils.NumberValidation
A World instance supplied by the caller

- [.update] Advances all animation components by elapsed seconds
]]

local AnimationManager = require("src.core.AnimationManager")
local Validation = require("src.utils.NumberValidation")

local AnimationSystem = {}

local _validateNumber = Validation.validateNumber

function AnimationSystem.update(world, dt)
    _validateNumber(dt)
    assert(dt >= 0, "elapsed time must be non-negative")

    for _, components in world:query("animation") do
        AnimationManager.update(components.animation, dt)
    end
end

return AnimationSystem