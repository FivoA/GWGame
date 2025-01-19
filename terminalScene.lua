local Terminal = require("terminal")

local terminalScene = {}

function terminalScene.load()
    if not terminal then
        terminal = Terminal:new()

        -- Beispielbefehle registrieren
        terminal:registerCommand("hello", function(terminal)
            table.insert(terminal.output, "Hello, World!")
        end)

        terminal:registerCommand("clear", function(terminal)
            terminal.output = {}
        end)

        terminal:registerCommand("echo", function(terminal, ...)
            local text = table.concat({...}, " ")
            table.insert(terminal.output, text)
        end)
        
        terminal:registerCommand("exit", function ()
            currentGamestate = "roomscene"
        end)
    end
end

function terminalScene.draw()
    love.graphics.clear(0.1567, 0.173, 0.204)
    love.graphics.setFont(love.graphics.newFont(20))
    terminal:draw()
end

function terminalScene.update(dt)
    terminal:update(dt)
end

function terminalScene.keypressed(key)
    terminal:keypressed(key)
end



return terminalScene