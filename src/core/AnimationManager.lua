--[[
AnimationManager.lua - Zeftarium

Creates reusable animation clips and independent playback instances.
Supports horizontal sprite strips and ordered sequences of separate images. Strip indices start at 1 and increase from left to right.
Frames use the full image height, without gaps or padding. Each frame stores an image and an optional Quad.
Images and clips may be shared, playback instances must be independent. All frames within a clip use the same duration.
Looping clips repeat. Non looping clips finish after displaying their final frame for its duration.
Images must be loaded before creating clips. Input arrays must be dense sequences without missing entries.
Treat returned clip data as read-only after creation.

[Dependencies]
src.utils.NumberValidation
love2d graphics api

- [.createClip]         Creates a horizontal-strip clip from an image, frame width,
                        ordered frame indices, frame duration, and optional looping flag.
                        Looping defaults to true

- [.createImageClip]    Creates a clip from an ordered array of loaded images,
                        frame duration, and optional looping flag

- [.new]                Creates independent playback from named clips and an initial state

- [.play]               Selects a state and resets playback when the state changes.
                        Pass true for restart to reset the current state.
                        Returns the playback instance. Preserves the paused state.

- [.update]             Advances playback by non-negative elapsed seconds

- [.getFrame]           Returns the current image and optional Quad

- [.pause]              Freezes playback without resetting frame or elapsed time.
                        Returns the playback instance

- [.resume]             Unpauses playback without restarting a finished clip.
                        Returns the playback instance
]]

local Validation = require("src.utils.NumberValidation")

local AnimationManager = {}

local _validateNumber = Validation.validateNumber

local function _validatePositiveInteger(value, name)
    _validateNumber(value)
    assert(value > 0 and value % 1 == 0, name .. " must be a positive integer")
end

local function _validateImage(image)
    assert(type(image) == "userdata" and image:typeOf("Image"), "Expected a love2d Image")
end

local function _validateClipSettings(frameDuration, looping)
    _validateNumber(frameDuration)
    assert(frameDuration > 0, "Frame duration must be positive")
    assert(looping == nil or type(looping) == "boolean", "Looping must be a boolean or nil")
end

local function _validateClip(clip)
    assert(type(clip) == "table", "Expected an animation clip")
    assert(type(clip.frames) == "table" and #clip.frames > 0, "Animation clip must contain frames")
    _validateClipSettings(clip.frameDuration, clip.looping)
end

function AnimationManager.createClip(image, frameWidth, frameIndices, frameDuration, looping)
    _validateImage(image)
    _validatePositiveInteger(frameWidth, "Frame width")
    _validateClipSettings(frameDuration, looping)

    assert(type(frameIndices) == "table" and #frameIndices > 0, "Expected a non-empty array of frame indices")

    local imageWidth, imageHeight = image:getDimensions()

    assert(imageWidth % frameWidth == 0, "Strip width must be divisible by frame width")

    local frameCount = imageWidth / frameWidth
    local frames = {}

    for _, index in ipairs(frameIndices) do
        _validatePositiveInteger(index, "Frame index")
        assert(index <= frameCount, "Frame index exceeds strip size")

        frames[#frames + 1] = {
            image = image,

            quad = love.graphics.newQuad(
                (index - 1) * frameWidth,
                0,
                frameWidth,
                imageHeight,
                imageWidth,
                imageHeight
            ),
        }
    end

    return {
        frames = frames,
        frameDuration = frameDuration,
        looping = looping ~= false,
    }
end

function AnimationManager.createImageClip(images, frameDuration, looping)
    _validateClipSettings(frameDuration, looping)

    assert(type(images) == "table" and #images > 0, "Expected a non-empty array of images")

    local frames = {}

    for _, image in ipairs(images) do
        _validateImage(image)

        frames[#frames + 1] = {
            image = image,
        }
    end

    return {
        frames = frames,
        frameDuration = frameDuration,
        looping = looping ~= false,
    }
end

function AnimationManager.new(clips, initialState)
    assert(type(clips) == "table", "Expected named animation clips")
    assert(type(initialState) == "string", "Expected a state name")

    local clip = clips[initialState]
    assert(clip, "Unknown initial animation: " .. initialState)
    _validateClip(clip)

    return {
        clips = clips,
        state = initialState,
        frame = 1,
        elapsed = 0,
        finished = false,
        paused = false,
    }
end

function AnimationManager.play(animation, state, restart)
    assert(type(state) == "string", "Expected a state name")
    assert(restart == nil or type(restart) == "boolean", "Restart must be a boolean or nil")

    local clip = animation.clips[state]
    assert(clip, "Unknown animation: " .. state)

    if animation.state == state and not restart then return animation end

    _validateClip(clip)

    animation.state = state
    animation.frame = 1
    animation.elapsed = 0
    animation.finished = false

    return animation
end

function AnimationManager.update(animation, dt)
    _validateNumber(dt)
    assert(dt >= 0, "Elapsed time must be non-negative")

    if animation.paused or animation.finished then return end

    local clip = animation.clips[animation.state]
    local elapsed = animation.elapsed + dt

    _validateNumber(elapsed)

    local steps = math.floor(elapsed / clip.frameDuration)

    _validateNumber(steps)

    animation.elapsed = elapsed % clip.frameDuration

    if clip.looping then
        animation.frame =
            (animation.frame - 1 + steps % #clip.frames)
            % #clip.frames + 1

    elseif steps >= #clip.frames - animation.frame + 1 then
        animation.frame = #clip.frames
        animation.elapsed = 0
        animation.finished = true

    else
        animation.frame = animation.frame + steps
    end
end

function AnimationManager.getFrame(animation)
    local clip = animation.clips[animation.state]
    local frame = clip.frames[animation.frame]

    return frame.image, frame.quad
end

function AnimationManager.pause(animation)
    animation.paused = true
    return animation
end

function AnimationManager.resume(animation)
    animation.paused = false
    return animation
end

return AnimationManager