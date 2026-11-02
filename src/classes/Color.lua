--[[

Color.lua by Katrina
0.0.0
C 2026-11-02
U 2026-11-02

This class provides a less insufferable, more ameliorable color format to use with the LOVE engine.

[Dependencies]
(none)

[Used By]
(none)


- [.new]    Returns a new Color instance.
  - Values range from 0 to 1.
  - Good for low level code.
  - Defaults to (0, 0, 0, 1) where values are omitted.

- [.new100] Returns a new Color instance.
  - Values range from 0 to 100.
  - Intuitive for some artists.
  - Defaults to (0, 0, 0, 100) where values are omitted.

- [.new255] Returns a new Color instance.
  - Values range from 0 to 255.
  - Intuitive for some other artists.
  - Defaults to (0, 0, 0, 255) where values are omitted.


- [:unpack] Returns a tuple, consisting of the Color instance's red, green, blue, and alpha components in that order.

- [:unpack3] Returns a tuple, consisting of the Color instance's red, green, and blue components in that order.

]]

-- Preamble

local Color = {}
Color.__index = Color


-- Helpers

local function clamp(value, min, max)
    --if max < min then warn(("Clamping %f under %f and over %f is not sensible"):format(value, max, min)) end
    return math.max(min, math.min(value, max))
end


-- Constructors

function Color.new(red, green, blue, alpha)

    red = clamp(red or 0, 0, 1)
    green = clamp(green or 0, 0, 1)
    blue = clamp(blue or 0, 0, 1)
    alpha = clamp(alpha or 0, 0, 1)

    return setmetatable({["red"] = red, ["green"] = green, ["blue"] = blue, ["alpha"] = alpha}, Color)

end

function Color.new100(red, green, blue, alpha)
    return Color.new((red or 0) / 100, (green or 0) / 100, (blue or 0) / 100, (alpha or 100) / 100)
end

function Color.new255(red, green, blue, alpha)
    return Color.new((red or 0) / 255, (green or 0) / 255, (blue or 0) / 255, (alpha or 255) / 255)
end


-- Methods

function Color:unpack()
    return self.red, self.green, self.blue, self.alpha
end

function Color:unpack3()
    return self.red, self.green, self.blue
end


-- Termination

return Color