local Terminal = require("terminal")
local termfunc = require("termfunc")
local chat = require("chat")

local terminalScene = {}

function terminalScene.load()
    if not terminal then
        terminal = Terminal:new()

        -- Beispielbefehle registrieren (hier alphabetisch sortiert für besser Übersicht)
        terminal:registerCommand("cat", termfunc.cat)
        terminal:registerCommand("cd", termfunc.cd)
        terminal:registerCommand("clear", termfunc.clear)
        terminal:registerCommand("color", termfunc.color)
        terminal:registerCommand("connect", termfunc.connect)
        terminal:registerCommand("cwd", termfunc.cwd)
        terminal:registerCommand("echo", termfunc.echo)
        terminal:registerCommand("exit", termfunc.exit)
        terminal:registerCommand("hack", termfunc.hack)
        terminal:registerCommand("help", termfunc.help)
        terminal:registerCommand("hello", termfunc.hello)
        terminal:registerCommand("ls", termfunc.ls)
        terminal:registerCommand("scan", termfunc.scan)
        terminal:registerCommand("talk", termfunc.talk)
    end
end

function terminalScene.draw()
    love.graphics.clear(termBG)
    love.graphics.setFont(love.graphics.newFont(terminalFontSize))
    love.graphics.setColor(termFontCol)
    terminal:draw()

    if chatEnabled then
        local lineX = love.graphics.getWidth() / 2
        love.graphics.line(lineX, 0, lineX, love.graphics.getHeight())
        chat.draw()
    end
end

function terminalScene.update(dt)
    if chatEnabled and chatFocussed then
    else
        terminal:update(dt)
    end
end

function terminalScene.keypressed(key)
    if key == "escape" then
        currentScene = "room"
    elseif chatEnabled and chatFocussed then
        chat.keypressed(key)
    else
        terminal:keypressed(key)
    end
end

return terminalScene
