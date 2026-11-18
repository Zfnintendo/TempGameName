local OfficeTemplate = require("src.scenes.templates.OfficeTemplate")

return OfficeTemplate.define({
    map = {
        width = 1600,
        height = 1000,

        walls = {
            { x = 0, y = 0, width = 1600, height = 24 },
            { x = 0, y = 976, width = 1600, height = 24 },
            { x = 0, y = 24, width = 24, height = 952 },
            { x = 1576, y = 24, width = 24, height = 952 },
        },

        desks = {
            { x = 300, y = 300, width = 140, height = 70 },
        },
    },

    player = {
        x = 120,
        y = 120,
    },

    camera = {
        zoom = 2,
    },
})