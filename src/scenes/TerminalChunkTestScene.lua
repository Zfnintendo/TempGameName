local TerminalTemplate = require("src.scenes.templates.TerminalTemplate")
local Generator = require("src.generation.TerminalLevelGenerator")
local Factories = require("src.generation.TerminalPropertiesFactories")

local Entry = require("data.terminal.chunks.Entry")
local Flat = require("data.terminal.chunks.EmptySpace")
local Platforms = require("data.terminal.chunks.LowPlatforms")
local SpikesAndSprings = require("data.terminal.chunks.SpikesAndSpringsNewbieOne")

local TerminalChunkTestScene = {}

function TerminalChunkTestScene.new(input, onMenu, options)
    local layout = Generator.generate({
        entry = Entry,

        pool = {
            Flat,
            Platforms,
            SpikesAndSprings,
        },

        chunkCount = 5,

        -- Uncomment to remake a certain a layout
        -- seed = 12345,
    }, 32, Factories)

    local sceneModule = TerminalTemplate.define({
        tileSize = 32,
        chunks = layout.placements,

        player = {
            chunk = 1,
            plot = "playerStart",
        },

        physics = {
            gravityX = 0,
            gravityY = -1400,
        },

        camera = {
            zoom = 2,
        },
    })

    local scene = sceneModule.new(input, onMenu, options)

    scene.generatedLayout = layout

    return scene
end

return TerminalChunkTestScene