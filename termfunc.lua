require("filesystem")
local fsutils = require("fsutils")

local Termfunc = {}
-- pls organize in lexographic order for better readability
-- terminal commands are here declared functions
-- Syntax: function Termfunc.function(terminal, ...) <function body> end

function Termfunc.cat(terminal)
    terminal:println("NYI")
end

function Termfunc.cd(terminal)
    terminal:println("NYI")
end

function Termfunc.clear(terminal)
    terminal.output = {}
end

function Termfunc.color(terminal, ...)
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

function Termfunc.echo(terminal, ...)
    local text = table.concat({...}, " ")
    table.insert(terminal.output, text)
end

-- does not need the terminal since it's not printing anything
function Termfunc.exit()
    currentGamestate = "room"
end

function Termfunc.hello(terminal)
    table.insert(terminal.output, "Hello, World!")
end

function Termfunc.ls(terminal)
    local dir, err = fsutils.navigate(currentPath, Filesystem)
    if not dir then
        terminal:println(err)
        return
    end
    for name, entry in pairs(dir) do
        if isDirectory(entry) then
            terminal:println(name .. "/")
        elseif isFile(entry) then
            terminal:println(name)
        end
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