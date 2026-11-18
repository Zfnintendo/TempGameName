--[[
RunState.lua - Zeftarium
C 2026-11-17
U 2026-11-17

Stores progression that survives scene transitions. Create one per new run and pass it to terminal scenes.
Terminal health is shared with the active player's health component. Do not share this health table between simultaneously active players.

[Dependencies]
src.utils.NumberValidation

- [.new] Creates a run with optional initial maximum health
]]

local Validation = require("src.utils.NumberValidation")

local RunState = {}

function RunState.new(maxHealth)
    if maxHealth == nil then maxHealth = 3 end

    Validation.validateNumber(maxHealth)
    assert(maxHealth >= 1 and maxHealth % 1 == 0, "Maximum health must be a positive integer")

    return {
        terminalHealth = {
            current = maxHealth,
            maximum = maxHealth,

            invulnerabilityDuration = 1,
            invulnerabilityRemaining = 0,
        },
    }
end

return RunState