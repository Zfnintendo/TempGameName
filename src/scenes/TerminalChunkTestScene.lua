local TerminalTemplate =
    require("src.scenes.templates.TerminalTemplate")

local Entry = require("data.terminal.chunks.Entry")

return TerminalTemplate.define({
    tileSize = 32,

    chunks = {
        {
            definition = Entry,
            x = 0,
            y = 0,
        },
    },

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