--[[
Cuboid.lua - Zeftarium

Stores an axis aligned cuboid using a Position and size. Position is the minimum corner along X, Y, and Z. 
Width, height, and depth extend in the positive axis directions. Coordinates must be finite numbers. Dimensions must be finite and non-negative.
All constructor and coordinate arguments are required. Mutators preserve the stored Position object and return self.

Boundary rules:
- contains includes minimum faces and excludes maximum faces
- intersects requires positive overlap on all three axes
- touching faces, edges, or corners do not intersect
- any zero dimension makes the cuboid empty

[Dependencies]
src.classes.Position
src.utils.NumberValidation

- [.new] Creates a cuboid from x, y, z, width, height, depth

- [:setPosition] Changes the minimum corner
- [:setSize] Changes dimensions

- [:translate] Moves by dx, dy, dz

- [:getMaxX] Returns the maximum X coordinate
- [:getMaxY] Returns the maximum Y coordinate
- [:getMaxZ] Returns the maximum Z coordinate
- [:getCenter] Returns center x, y, z
- [:getVolume] Returns volume
- [:getSurfaceArea] Returns surface area

- [:isEmpty] Checks whether the cuboid has no volume
- [:contains] Checks whether a point is inside
- [:intersects] Checks positive-volume overlap with another cuboid

- [:clone] Creates an independent cuboid
- [:unpack] Returns x, y, z, width, height, depth
]]

local Position = require("src.classes.Position")
local Validation = require("src.utils.NumberValidation")

local Cuboid = {}
Cuboid.__index = Cuboid

local _validateSize = Validation.validateSize3
local _validateCoordinates = Validation.validateCoordinates

function Cuboid.new(x, y, z, width, height, depth)
    _validateCoordinates(x, y, z)
    _validateSize(width, height, depth)

    return setmetatable({
        position = Position.new(x, y, z),
        width = width,
        height = height,
        depth = depth,
    }, Cuboid)
end

-- I only remembered i made set methods later on here lol sorry rectangle!
function Cuboid:setPosition(x, y, z)
    _validateCoordinates(x, y, z)

    self.position:setX(x)
    self.position:setY(y)
    self.position:setZ(z)

    return self
end

function Cuboid:setSize(width, height, depth)
    _validateSize(width, height, depth)

    self.width = width
    self.height = height
    self.depth = depth

    return self
end

function Cuboid:translate(dx, dy, dz)
    _validateCoordinates(dx, dy, dz)

    return self:setPosition(
        self.position:getX() + dx,
        self.position:getY() + dy,
        self.position:getZ() + dz
    )
end

function Cuboid:getMaxX()
    return self.position:getX() + self.width
end

function Cuboid:getMaxY()
    return self.position:getY() + self.height
end

function Cuboid:getMaxZ()
    return self.position:getZ() + self.depth
end

function Cuboid:getCenter()
    return self.position:getX() + self.width / 2,
           self.position:getY() + self.height / 2,
           self.position:getZ() + self.depth / 2
end

function Cuboid:getVolume()
    return self.width * self.height * self.depth
end

function Cuboid:getSurfaceArea()
    return 2 * (
        self.width * self.height
        + self.width * self.depth
        + self.height * self.depth
    )
end

function Cuboid:isEmpty()
    return self.width == 0
        or self.height == 0
        or self.depth == 0
end

function Cuboid:contains(x, y, z)
    return x >= self.position:getX() and x < self:getMaxX()
        and y >= self.position:getY() and y < self:getMaxY()
        and z >= self.position:getZ() and z < self:getMaxZ()
end

function Cuboid:intersects(other)
    if self:isEmpty() or other:isEmpty() then return false end

    return self.position:getX() < other:getMaxX()
        and self:getMaxX() > other.position:getX()
        and self.position:getY() < other:getMaxY()
        and self:getMaxY() > other.position:getY()
        and self.position:getZ() < other:getMaxZ()
        and self:getMaxZ() > other.position:getZ()
end

function Cuboid:clone()
    local x, y, z = self.position:unpack3()

    return Cuboid.new(x, y, z, self.width, self.height, self.depth)
end

function Cuboid:unpack()
    local x, y, z = self.position:unpack3()

    return x, y, z, self.width, self.height, self.depth
end

return Cuboid