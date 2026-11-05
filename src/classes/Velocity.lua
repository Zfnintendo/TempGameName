--[[
Velocity.lua - Zeftarium

Stores velocity in world units per second. Positive Y points upward.
Inherits Vector's coordinate accessors and mathematical methods. Inherited vector-producing operations return Vector instances.
Constructors default omitted coordinates to zero. Set and accelerate require every argument.
Mutators return self for chaining. Validation raises an error without modifying the instance.

[Dependencies]
src.classes.Vector
src.utils.NumberValidation

- [.new] Creates a velocity; omitted coordinates default to zero
- [.newEmpty] Creates a zero velocity

- [:set] Replaces all velocity coordinates
- [:stop] Sets velocity to zero

- [:speed] Returns scalar speed in world units per second
- [:displacement] Returns a new Vector for constant-velocity travel over dt
- [:accelerate] Applies acceleration in world units per second squared over dt

- [:clone] Returns an independent Velocity instance
]]

local Vector = require("src.classes.Vector")
local Validation = require("src.utils.NumberValidation")

local Velocity = {}
Velocity.__index = Velocity

Velocity.__add = Vector.__add
Velocity.__mul = Vector.__mul

local _validateNumber = Validation.validateNumber
local _validateCoordinates = Validation.validateCoordinates

local function _validateTime(dt)
    _validateNumber(dt)
    assert(dt >= 0, "Elapsed time must be non-negative")
end

function Velocity.new(x, y, z)
    if x == nil then x = 0 end
    if y == nil then y = 0 end
    if z == nil then z = 0 end

    _validateCoordinates(x, y, z)

    return setmetatable(Vector.new(x, y, z), Velocity)
end

function Velocity.newEmpty()
    return Velocity.new()
end

function Velocity:set(x, y, z)
    _validateCoordinates(x, y, z)

    self.x = x
    self.y = y
    self.z = z

    return self
end

function Velocity:stop()
    return self:set(0, 0, 0)
end

function Velocity:speed()
    return self:magnitude()
end

function Velocity:displacement(dt)
    _validateTime(dt)

    return Vector.new(
        self.x * dt,
        self.y * dt,
        self.z * dt
    )
end

function Velocity:accelerate(ax, ay, az, dt)
    _validateCoordinates(ax, ay, az)
    _validateTime(dt)

    return self:set(
        self.x + ax * dt,
        self.y + ay * dt,
        self.z + az * dt
    )
end

function Velocity:clone()
    return Velocity.new(self.x, self.y, self.z)
end

setmetatable(Velocity, { __index = Vector })

return Velocity