# Code Documentation Referal/Style sheet
##### cc: @MaquaYT @mintpopser @lacelit684

Please refer to this documentation when commenting and creating any APIs or scripts when contributing to the codebase pls thx.

<br>
<br>

## Guidelines/Outlines

When documenting the code you made, for any APIs or scripts please have a multiline comment describing what the file does, what its objective is and any 
methods or function it may have defined with what it does and optionally the arguments and what it returns with

<br>
<br>

You can also comment the lines that are complex or you think may need some guidance for others reading it. and comment above functions/methods when defining them optionally

<br>
<br>

An example of how you could document your code would be like the following code snippet:

```lua
--[[
Code made by x and/or y

This script does this and that and takes this and that as the arguments and does this specifically, does not do that, can interact with what, offers this etc

- [:method] this method does something
- [.function] this function does something

[Dependencies]
None/"src.category.script"
]]
-- imports
local importedThing = require("src.category.script")

-- vars
local helloWorld = "Hello World!"

-- class
SomeClass = {}
SomeClass.__index = SomeClass

-- constructor
function SomeClass.new()
    return setmetatable({}, SomeClass)
end 

return SomeClass
```

