local NumberValidation = {}

function NumberValidation.validateNumber(value)
    assert(
        type(value) == "number"
            and value == value
            and value > -math.huge
            and value < math.huge,
        "expected a finite number but got: " .. tostring(value)
    )
end

function NumberValidation.validateSize2(width, height)
    NumberValidation.validateNumber(width)
    NumberValidation.validateNumber(height)

    assert(width >= 0 and height >= 0, "Rectangle dimensions have to be non negative")
end

function NumberValidation.validateSize3(width, height, depth)
    NumberValidation.validateNumber(width)
    NumberValidation.validateNumber(height)
    NumberValidation.validateNumber(depth)

    assert(width >= 0 and height >= 0 and depth >= 0, "Cuboid dimensions have to be non negative")
end

function NumberValidation.validateCoordinates(x, y, z)
    NumberValidation.validateNumber(x)
    NumberValidation.validateNumber(y)
    NumberValidation.validateNumber(z)
end

function NumberValidation.validateArguments(x, y, z, width, height)
    NumberValidation.validateCoordinates(x, y, z)
    NumberValidation.validateSize2(width, height)
end

return NumberValidation