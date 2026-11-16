local Validator = require("src.generation.TerminalChunkValidator")
local Factories = require("src.generation.TerminalPropertyFactories")

local chunks = {
    (require("data.terminal.chunks.Entry")),
}

local ids = {}

for _, chunk in ipairs(chunks) do
    Validator.validate(chunk, Factories)

    assert(not ids[chunk.id], "Duplicate chunk ID: " .. chunk.id)
    ids[chunk.id] = true
end

return chunks