--[[

Color.lua by Katrina
0.0.1
C 2026-11-02
U 2026-11-03

This class provides a less insufferable, more ameliorable color format to use with the LOVE engine.

[Dependencies]
(none)

[Used By]
(none)


[Class]

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

[Instance]

- [.red]   The red channel of the color. Colors range from 0 to 1.
- [.green] The green channel of the color.
- [.blue]  The blue channel of the color.
- [.alpha] The alpha channel of the color.

- [:blend] Returns a Color made by source-over blending to this Color from another Color.

- [:unpack]  Returns a tuple, consisting of the Color instance's red, green, blue, and alpha components in that order.
- [:unpack3] Returns a tuple, consisting of the Color instance's red, green, and blue components in that order.

todo: different blend modes?
]]

-- Preamble

local Color = {}
Color.__index = Color


-- Helpers

local function clamp(value, min, max)
    --if max < min then warn(("Clamping %f under %f and over %f is not sensible"):format(value, max, min)) end
    return math.max(min, math.min(value, max))
end

local function clamp01(value)
    return clamp(value, 0, 1)
end

local function lerp(start, target, coeff)
    return start + (target - start) * coeff
end


-- Constructors

function Color.new(red, green, blue, alpha)

    red   = clamp01(red   or 0)
    green = clamp01(green or 0)
    blue  = clamp01(blue  or 0)
    alpha = clamp01(alpha or 0)

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

function Color:blend(foreground)

    -- Cases where it doesn't matter
    if foreground .alpha == 1 then return foreground end
    if self       .alpha == 0 then return foreground end
    if foreground .alpha == 0 then return self       end

    -- At this point, it would be impossible for the resultant alpha to be 0
    local rs_alpha = self.alpha + foreground.alpha * (1 - self.alpha)

    local bg_red, bg_green, bg_blue = self       :unpack3()
    local fg_red, fg_green, fg_blue = foreground :unpack3()

    -- As a result of that alpha never being 0, the following division is completely fine and safe
    local rs_red, rs_green, rs_blue =
        lerp(bg_red,   fg_red,   rs_alpha) / rs_alpha,
        lerp(bg_green, fg_green, rs_alpha) / rs_alpha,
        lerp(bg_blue,  fg_blue,  rs_alpha) / rs_alpha

    return Color.new(rs_red, rs_green, rs_blue, rs_alpha)

end


-- Termination

return Color