local Terminal = require("terminal")
local termfunc = require("termfunc")

local terminalScene = {}

function terminalScene.load()
    if not terminal then
        terminal = Terminal:new()

        -- Beispielbefehle registrieren (hier alphabetisch sortiert für besser Übersicht)
        terminal:registerCommand("cat", termfunc.cat)
        terminal:registerCommand("cd", termfunc.cd)
        terminal:registerCommand("clear", termfunc.clear)
        terminal:registerCommand("color", termfunc.color)
        terminal:registerCommand("echo",  termfunc.echo)
        terminal:registerCommand("exit",  termfunc.exit)
        terminal:registerCommand("hello", termfunc.hello)
        terminal:registerCommand("ls",  termfunc.ls)
        terminal:registerCommand("mkdir",  termfunc.mkdir)
    end
end

function terminalScene.draw()
    love.graphics.clear(termBG)
    love.graphics.setFont(love.graphics.newFont(terminalFontSize))
    terminal:draw()
end

function terminalScene.update(dt)
    terminal:update(dt)
end

function terminalScene.keypressed(key)
    terminal:keypressed(key)
end



return terminalScene