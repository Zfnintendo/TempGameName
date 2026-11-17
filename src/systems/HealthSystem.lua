--[[
HealthSystem.lua - Zeftarium
C 2026-11-17
U 2026-11-17

Handles health changes and temporary damage immunity. Health values and damage amounts use whole units.
Damage cannot reduce health below zero. Healing cannot exceed maximum health.
Increasing maximum health optionally grants the added health immediately.

[Dependencies]
src.utils.NumberValidation

- [.update]             Advances invulnerability timers on health components

- [.damage]             Applies damage; returns whether damage was accepted.
                        Optional bypass ignores invulnerability, but not death
- [.heal]               Restores health up to the maximum

- [.increaseMaximum]    Adds maximum health and optionally heals the added amount
]]

local Validation = require("src.utils.NumberValidation")

local HealthSystem = {}

local function validateAmount(amount)
    Validation.validateNumber(amount)

    assert(amount > 0 and amount % 1 == 0, "Health amount must be a positive integer")
end

function HealthSystem.update(world, dt)
    Validation.validateNumber(dt)
    assert(dt >= 0, "Elapsed time must be non-negative")

    for _, entity in world:query("health") do
        local health = entity.health

        health.invulnerabilityRemaining = math.max(0, health.invulnerabilityRemaining - dt)
    end
end

function HealthSystem.damage(health, amount, bypass)
    validateAmount(amount)

    if health.current <= 0 then return false end

    if not bypass and health.invulnerabilityRemaining > 0 then return false end

    health.current = math.max(0, health.current - amount)
    health.invulnerabilityRemaining = health.invulnerabilityDuration

    return true
end

function HealthSystem.heal(health, amount)
    validateAmount(amount)
    health.current = math.min(health.maximum, health.current + amount)
end

function HealthSystem.increaseMaximum(health, amount, healAdded)
    validateAmount(amount)

    health.maximum = health.maximum + amount

    if healAdded then HealthSystem.heal(health, amount) end
end

return HealthSystem