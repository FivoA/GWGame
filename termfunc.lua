local Termfunc = {}
-- pls organize in lexographic order for better readability
-- terminal commands are here declared functions
-- Syntax: function Termfunc.function(terminal, ...) <function body> end

function Termfunc.clear(terminal)
    terminal.output = {}
end

function Termfunc.color(terminal, ...)
    print(...)
    local args = {...}
    print(args)
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

function Termfunc.exit()
    currentGamestate = "room"
end

function Termfunc.hello(terminal)
    table.insert(terminal.output, "Hello, World!")
end

return Termfunc