local Validator = require("src.generation.TerminalChunkValidator")
local Factories = require("src.generation.TerminalPropertiesFactories")

local chunks = {
    require("data.terminal.chunks.EmptySpace"),
    require("data.terminal.chunks.LowPlatforms"),
    require("data.terminal.chunks.SpikesAndSpringsNewbieOne"),
    (require("data.terminal.chunks.Entry")),
}

local ids = {}

for _, chunk in ipairs(chunks) do
    Validator.validate(chunk, Factories)

    assert(not ids[chunk.id], "Duplicate chunk ID: " .. chunk.id)
    ids[chunk.id] = true
end

return chunks