return {
    id = "spikesAndSpringsNewbieOne",

    grid = {
        {1,0,0,0,0,0,0,0},
        {1,0,0,0,1,0,1,1}, 
        {1,{2, "Spring"},{2, "Spike"},0,0,1,{2, "Spike"},1}, 
        {1,1,1,{2, "Spring"},0,0,0,1},
        {1,1,1,1,0,0,{2, "Spring"},1}, 
        {0,0,{2, "Spike"},{2, "Spike"},1,0,1,1}, 
        {0,0,0,0,0,0,0,1},
        {1,1,{2, "Spring"},{2, "Spring"},1,{2, "Spring"},{2, "Spring"},1},
    },

    props = {
        Spring = {
            kind = "actionObject",
            type = "spring",
            power = 850,
        },

        Spike = {
            kind = "actionObject",
            type = "spike",
            damage = 1,
        }
    },
}