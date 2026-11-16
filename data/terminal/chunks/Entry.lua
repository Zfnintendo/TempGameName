local grid = {}

for row = 1, 64 do
    grid[row] = {}

    for column = 1, 64 do
        grid[row][column] = 0
    end
end

for column = 1, 64 do
    grid[64][column] = 1
end

grid[63][4] = {2, "playerStart"}

return {
    id = "entry",

    grid = grid,

    props = {
        playerStart = {
            kind = "playerSpawn",
        },
    },
}