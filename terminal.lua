local Terminal = {}
Terminal.__index = Terminal

function Terminal.new()
    return setmetatable({
        input = "", -- Aktueller Eingabetext
        output = {}, -- Liste der Ausgaben
        commands = {}, -- Registrierte Befehle
        maxOutput = 100, -- Maximale Zeilen im Terminal
        cursorBlink = true, -- Blinker für Cursor
        cursorTimer = 0 -- Timer für Cursor-Blinken
    }, Terminal)
end

function Terminal:registerCommand(name, callback)
    self.commands[name] = callback
end

function Terminal:handleInput()
    if #self.input > 0 then
        table.insert(self.output, "> " .. self.input) -- Zeige eingegebenen Text
        local args = {}
        for word in self.input:gmatch("%S+") do
            table.insert(args, word)
        end

        local command = args[1]
        table.remove(args, 1)

        if self.commands[command] then
            if #args > 0 then
                self.commands[command](self, unpack(args))
            else
                self.commands[command](self)
            end
        else
            table.insert(self.output, "Unknown command: " .. command)
        end

        if #self.output > self.maxOutput then
            table.remove(self.output, 1)
        end

        self.input = "" -- Eingabe leeren
    end
end

function Terminal:println(text)
    table.insert(self.output, text)
end

function Terminal:update(dt)
    self.cursorTimer = self.cursorTimer + dt
    if self.cursorTimer >= 0.5 then
        self.cursorBlink = not self.cursorBlink
        self.cursorTimer = 0
    end
end

function Terminal:draw()
    for i, line in ipairs(self.output) do
    -- love.graphics.print( text, x, y)
        love.graphics.print({termFontCol, line}, termSepX, termSepY + (i - 1) * (terminalFontSize + termSepLine))
    end

    local cursor = self.cursorBlink and "|" or ""
    love.graphics.print({termFontCol, "> " .. self.input .. cursor},
                        termSepX,
                        termSepY + #self.output * (terminalFontSize + termSepLine))
end

function Terminal:textinput(t)
    self.input = self.input .. t
end

function Terminal:keypressed(key)
    if key == 'backspace' then
        if love.keyboard.isDown('lctrl') then
            self.input = self.input:gsub("%s*[^%s]+$", "")
        else
            self.input = self.input:sub(1, -2)
        end
    elseif key == 'space' then
        self:textinput(" ")
    elseif key == 'return' then
        self:handleInput()
    else
        if #key == 1 then
            self:textinput(key)
        end
    end
end

return Terminal