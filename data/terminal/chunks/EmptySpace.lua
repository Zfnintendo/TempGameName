local grid = {}

for row = 1, 64 do
    grid[row] = {}

    for column = 1, 64 do
        grid[row][column] = 0
    end
end

return {
    id = "entry",

    grid = grid,

    props = {
        
    },
}