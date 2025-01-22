require("filesystem")
local fsutils = require("fsutils")
local lfs = love.filesystem
local Termfunc = {}
-- pls organize in lexographic order for better readability
-- terminal commands are here declared functions
-- Syntax: function Termfunc.function(terminal, ...) <function body> end

function Termfunc.cat(terminal, ...) -- reworked -> TODO more permissions have to be added into the handler function
    local args = {...}
    if #args ~= 1 then
        terminal:println("Requires exactly one positional argmuent: <filename>")
        return
    end
    local extracted = fsutils.extractFileContent(args[1])
    terminal:println(extracted)
end

function Termfunc.cd(terminal, ...) -- reworked ->> TODO: Missing permission checks
    local args = {...}
    if #args ~= 1 then
        terminal:println("Requires exactly one positional argmuent.")
        return
    end

    local pathParts = {}
    for part in string.gmatch(args[1], "[^/]+") do
        table.insert(pathParts, part)
    end

    for i, pathPart in ipairs(pathParts) do
        -- print("Iteration: " .. i .. ", with pathPart: " .. pathPart)
        fsutils.handlePathPart(pathPart)
    end
    
end

function Termfunc.clear(terminal) -- reworked (dont need a rework)
    terminal.output = {}
end

function Termfunc.color(terminal, ...) -- reworked (dont need a rework)
    local args = {...}
    if #args ~= 3 then
        terminal:println("Exactly 3 parameters are required.")
        return
    end

    local r, g, b = args[1], args[2], args[3]
    r, g, b = tonumber(r), tonumber(g), tonumber(b)
    print("r: " .. r .. ", g: " .. g .. ", b: " .. b)
    if type(r) ~= 'number' or type(g) ~= 'number' or type(b) ~= 'number' then
        -- terminal:println("r: " .. type(r) .. ", g: " .. type(g) .. ", b: " .. type(b))
        terminal:println("Arguments musst be a valid integer")
    end
    if r < 0 or r > 255 or g < 0 or g > 255 or b < 0 or b > 255 then
        terminal:println("Parameters out of range. All parameters have to be in range [0, 255]")
        return
    end
    termBG = {r / 255, g / 255, b / 255}
end

function Termfunc.cwd(terminal) -- reworked  (dont need a rework)
    terminal:println(termcwd)
end

function Termfunc.echo(terminal, ...)  -- reworked  (dont need a rework)
    local text = table.concat({...}, " ")
    table.insert(terminal.output, text)
end

function Termfunc.exit(terminal)  -- reworked  (dont need a rework)
    currentGamestate = "room"
end

function Termfunc.help(terminal)   -- reworked  (dont need a rework)
    local _commands = {}
    for command in pairs(terminal.commands) do
        table.insert(_commands, command)
    end
    table.sort(_commands)
    for i = 1, #_commands, 3 do
        local coms1 = string.format("%-20s", _commands[i] or "")
        local coms2 = string.format("%-20s", _commands[i+1] or "")
        local coms3 = string.format("%-20s", _commands[i+2] or "")
        -- print(coms1 .. " with length: " .. #coms1)
        -- print(coms2 .. " with length: " .. #coms2)
        -- print(coms3 .. " with length: " .. #coms3)
        
        terminal:println(coms1 .. coms2 .. coms3)
    end
end

function Termfunc.hello(terminal) -- reworked (made it random and funny)
    local greetings = {"Hello", "Hello World!", "Hi", "Hey", "Greetings", "Salutations", "Howdy", "All might to the AI", "We love the AI", "Always remeber: The AI sees everything."}
    local randomGreeting = greetings[math.random(#greetings)]
    terminal:println(randomGreeting)
end

function Termfunc.info(terminal, ...)
    local args = {...}
    if #args ~= 1 then
        terminal:println("Missing positional argument: filename")
        return
    end

    terminal:println(love.filesystem.getWorkingDirectory())
    terminal:println(love.filesystem.getUserDirectory())
    terminal:println(love.filesystem.getInfo(args[1]))

end

function Termfunc.ls(terminal) -- reworked
    local files = lfs.getDirectoryItems(fsutils.toGameRelativePath(termcwd))
    for i, file in ipairs(files) do
        local filename = fsutils.extractFilename(file)
        if filename then terminal:println(filename) end
    end
end

function Termfunc.mkdir(terminal, ...)
    local args = {...}
    if #args ~= 1 then
        terminal:println("Required one positional argument: <directory name>")
        return
    end

    local dir, err = fsutils.navigate(currentPath, Filesystem)
    if not dir then
        terminal:println(err)
        return
    end

    local pathParts = {}
    for part in string.gmatch(args[1], "[^/]+") do
        table.insert(pathParts, part)
    end
    local currentDir = dir

    for _, part in ipairs(pathParts) do
        if currentDir[part] then
            if not isDirectory(currentDir[part]) then
                terminal:println("A file with the name '" .. part .. "' already exists.")
                return
            end
            currentDir = currentDir[part]
        else
            currentDir[part] = {}
            currentDir = currentDir[part]
        end
    end

    terminal:println("Directory created successfully. -> HAHA but you cant see it with ls cause this function is still under dev!")
    
end

function Termfunc.rm(terminal)
    terminal:println("[ERROR] NYI")
end

return Termfunc