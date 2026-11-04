--[[
Vector.lua - Zeftarium
C 2026-11-04
U 2026-11-04

Vector class for storing vector based data and to be inherited from.
Includes methods that may be used for vectors such as dot products.

[Dependencies]
None

- [.new]        Returns a new vector instance based on the x, y, z arguments given
- [.newEmpty]   Returns an empty vector with all axis being 0

- [.__add]      Adds two vectors together
- [.__mul]      Multiplies a vector by a scalar

- [:getX]       Gets the X axis value
- [:getY]       Gets the Y axis Value
- [:getZ]       Gets the Z axis value

- [:setX]       Sets the X axis value
- [:setY]       Sets the Y axis value
- [:setZ]       Sets the Z axis value

- [:magnitude]  returns the magnitude of the vector

- [:normalize]  returns a new vector based on the normalized vector
- [:dot]        returns the dot product of the two vectors
- [:cross]      returns the cross of 2 vectors, returns a vector
- [:cross2D]    returns the cross of 2 vectors, returns a number
- [:angle]      get the angle of 2 vectors, takes in an optional axis parameter

- [:floor]      floors the current vector
- [:ceil]       ceil the current vector
- [:abs]        abs the current vector

- [:newFloor]   returns a new floored vector
- [:newCeil]    returns a new ceiled vector
- [:newAbs]     returns a new abs'ed vector
]]

local Vector = {}
Vector.__index = Vector

function Vector.new(x, y, z)
    if not z then z = 0 end

    local self = setmetatable({
        x = x,
        y = y,
        z = z,
    }, Vector)

    return self
end

function Vector.newEmpty()
    return Vector.new(0, 0, 0)
end

function Vector.__add(a, b)
    return Vector.new(
        a.x + b.x,
        a.y + b.y,
        a.z + b.z
    )
end

function Vector.__mul(a, b)
    if type(a) == "number" then
        return Vector.new(
            a * b.x,
            a * b.y,
            a * b.z
        )
    elseif type(b) == "number" then
        return Vector.new(
            a.x * b,
            a.y * b,
            a.z * b
        )
    end

    error("Vector multiplication requires a scalar")
end

function Vector:getX()
    return self.x
end

function Vector:setX(x)
    self.x = x
end

function Vector:getY()
    return self.y
end

function Vector:setY(y)
    self.y = y
end

function Vector:getZ()
    return self.z
end

function Vector:setZ(z)
    self.z = z
end

function Vector:magnitude()
    local magnitude = math.sqrt(self.x^2 + self.y^2 + self.z^2)
    return magnitude
end

function Vector:normalize()
    local magnitude = self:magnitude()

    if magnitude == 0 then return Vector.new(0, 0, 0) end

    return Vector.new(
        self.x / magnitude,
        self.y / magnitude,
        self.z / magnitude
    )
end

function Vector:dot(other)
    return self.x * other:getX() + self.y * other:getY() + self.z * other:getZ()
end

function Vector:cross(other)
    return Vector.new(
        self.y * other:getZ() - self.z * other:getY(),
        self.z * other:getX() - self.x * other:getZ(),
        self.x * other:getY() - self.y * other:getX()
    )
end

function Vector:cross2D(other)
    return self.x * other:getY() - self.y * other:getX()
end

function Vector:angle(other, axis)
    local magnitude = self:magnitude() * other:magnitude()

    if magnitude == 0 then return nil end

    local cosine = self:dot(other) / magnitude

    cosine = math.max(-1, math.min(1, cosine))

    local angle = math.acos(cosine)

    if axis then
        local cross = self:cross(other)
        local direction = cross:dot(axis)

        if direction < 0 then
            angle = -angle
        end
    end

    return angle
end

function Vector:floor()
    self.x = math.floor(self.x)
    self.y = math.floor(self.y)
    self.z = math.floor(self.z)
end

function Vector:ceil()
    self.x = math.ceil(self.x)
    self.y = math.ceil(self.y)
    self.z = math.ceil(self.z)
end

function Vector:abs()
    self.x = math.abs(self.x)
    self.y = math.abs(self.y)
    self.z = math.abs(self.z)
end

function Vector:newFloor()
    return Vector.new(
        math.floor(self.x),
        math.floor(self.y),
        math.floor(self.z)
    )
end

function Vector:newCeil()
    return Vector.new(
        math.ceil(self.x),
        math.ceil(self.y),
        math.ceil(self.z)
    )
end

function Vector:newAbs()
    return Vector.new(
        math.abs(self.x),
        math.abs(self.y),
        math.abs(self.z)
    )
end

return Vector