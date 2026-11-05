--[[
Rectangle.lua - Zeftarium
C 2026-11-04
U 2026-11-05

Stores an axis aligned rectangle using its top-left position and size. Coordinates must be finite numbers, dimensions must also be non negative.
Methods expect Rectangle instances containing a Position, width, and height. Z represents a discrete layer so contains and intersects require matching Z.
All coordinate arguments, including z and dz, are required. Set, setPosition, setSize, and translate modify self and return it.
Set, setPosition, and translate replace the stored Position object. intersection returns an independent rectangle or nil. 
Union and clone return independent rectangles. Direct field changes must preserve the same validation rules.

Boundary rules:
- contains includes the left/top edges and excludes the right/bottom edges
- intersects requires positive overlap; touching edges do not intersect
- rectangles with zero width or height are empty

[Dependencies]
src.classes.Position

- [.new]                    Creates a rectangle

- [:set]                    Replaces position and dimensions
- [:setPosition]            Changes position
- [:setSize]                Changes dimensions

- [:translate]              Moves by an offset

- [:getRight]               Returns the right edge
- [:getBottom]              Returns the bottom edge
- [:getCenter]              Returns center x and y
- [:getArea]                Returns area
- [:getVertices]            Returns four new Positions in a new array: top-left, top-right, bottom-right, bottom-left

- [:isEmpty]                Checks whether the rectangle has no area

- [:contains]               Checks whether a point is inside
- [:containsRectangle]      Checks full containment on the same Z layer; shared boundaries and zero-size rectangles are allowed
- [:intersects]             Checks positive-area overlap with another rectangle
- [:intersection]           Returns a new overlap rectangle, or nil when no positive area intersection exists on the same Z layer
- [:overlapArea]            Returns the intersection area, or 0 when there is none
- [:union]                  Returns a new smallest enclosing rectangle, raises an error when Z layers differ

- [:equals]                 Compares position and dimensions using exact numeric equality
- [.__eq]                   Enables == comparisons between Rectangle instances using equals

- [:clone]                  Creates an independent Rectangle instance
- [:unpack]                 Returns x, y, z, width, and height
]]

local Position = require("src.classes.Position")
local Validation = require("src.utils.NumberValidation")

local Rectangle = {}
Rectangle.__index = Rectangle

local _validateArguments = Validation.validateArguments
local _validateSize = Validation.validateSize2
local _validateCoordinates = Validation.validateCoordinates

function Rectangle.new(x, y, z, width, height)
    _validateArguments(x, y, z, width, height)

    local self = setmetatable({
        position = Position.new(x, y, z),
        width = width,
        height = height,
    }, Rectangle)

    return self
end

function Rectangle:set(x, y, z, width, height)
    _validateArguments(x, y, z, width, height)

    self.position = Position.new(x, y, z)
    self.width = width
    self.height = height

    return self
end

function Rectangle:setPosition(x, y, z)
    _validateCoordinates(x, y, z)

    self.position = Position.new(x, y, z)

    return self
end

function Rectangle:setSize(width, height)
    _validateSize(width, height)

    self.width = width
    self.height = height

    return self
end

function Rectangle:translate(dx, dy, dz)
    _validateCoordinates(dx, dy, dz)

    return self:setPosition(self.position:getX() + dx, self.position:getY() + dy, self.position:getZ() + dz)
end

function Rectangle:getRight()
    return self.position:getX() + self.width
end

function Rectangle:getBottom()
    return self.position:getY() + self.height
end

function Rectangle:getCenter()
    return self.position:getX() + self.width / 2,
           self.position:getY() + self.height / 2
end

function Rectangle:getArea()
    return self.width * self.height
end

function Rectangle:getVertices()
    local x, y, z = self.position:unpack3()

    return {
        Position.new(x, y, z),
        Position.new(x + self.width, y, z),
        Position.new(x + self.width, y + self.height, z),
        Position.new(x, y + self.height, z)
    }
end

function Rectangle:isEmpty()
    return self.width == 0 or self.height == 0
end

function Rectangle:contains(x, y, z)
    return x >= self.position:getX() and x < self:getRight() and y >= self.position:getY() and y < self:getBottom() and z == self.position:getZ()
end

function Rectangle:containsRectangle(other)
    if self.position:getZ() ~= other.position:getZ() then return false end

    return other.position:getX() >= self.position:getX()
       and other.position:getY() >= self.position:getY()
       and other:getRight() <= self:getRight()
       and other:getBottom() <= self:getBottom()
end

function Rectangle:intersects(other)
    if self.position:getZ() ~= other.position:getZ() then return false end
    if self:isEmpty() or other:isEmpty() then return false end

    return self.position:getX() < other:getRight()
        and self:getRight() > other.position:getX()
        and self.position:getY() < other:getBottom()
        and self:getBottom() > other.position:getY()
end

function Rectangle:intersection(other)
    if not self:intersects(other) then return nil end

    local x = math.max(self.position:getX(), other.position:getX())
    local y = math.max(self.position:getY(), other.position:getY())

    local right = math.min(self:getRight(), other:getRight())
    local bottom = math.min(self:getBottom(), other:getBottom())

    return Rectangle.new(x, y, self.position:getZ(), right - x, bottom - y)
end

function Rectangle:overlapArea(other)
    local overlap = self:intersection(other)

    if not overlap then return 0 end

    return overlap:getArea()
end

function Rectangle:union(other)
    assert(
        self.position:getZ() == other.position:getZ(),
        "Cannot union rectangles on different Z layers"
    )

    local x = math.min(self.position:getX(), other.position:getX())
    local y = math.min(self.position:getY(), other.position:getY())

    local right = math.max(self:getRight(), other:getRight())
    local bottom = math.max(self:getBottom(), other:getBottom())

    return Rectangle.new(x, y, self.position:getZ(), right - x, bottom - y)
end

function Rectangle:equals(other)
    return self.position:getX() == other.position:getX()
       and self.position:getY() == other.position:getY()
       and self.position:getZ() == other.position:getZ()
       and self.width == other.width
       and self.height == other.height
end

Rectangle.__eq = Rectangle.equals

function Rectangle:clone()
    local x, y, z = self.position:unpack3()

    return Rectangle.new(x, y, z, self.width, self.height)
end

function Rectangle:unpack()
    local x, y, z = self.position:unpack3()

    return x, y, z, self.width, self.height
end

return Rectangle




