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
            self.commands[command](self, table.unpack(args))
        else
            table.insert(self.output, "Unknown command: " .. command)
        end

        if #self.output > self.maxOutput then
            table.remove(self.output, 1)
        end

        self.input = "" -- Eingabe leeren
    end
end

function Terminal:update(dt)
    self.cursorTimer = self.cursorTimer + dt
    if self.cursorTimer >= 0.5 then
        self.cursorBlink = not self.cursorBlink
        self.cursorTimer = 0
    end
end

function Terminal:draw()
    local startY = 10
    local startX = 20
    for i, line in ipairs(self.output) do
    -- love.graphics.print( text,  x,        y, r, sx, sy, ox, oy, kx, ky )
        love.graphics.print(line, 10, startY + (i - 1) * 15)
    end

    local cursor = self.cursorBlink and "|" or ""
    love.graphics.print("> " .. self.input .. cursor, 10, startY + #self.output * 15)
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