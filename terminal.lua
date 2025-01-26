local Terminal = {}
Terminal.__index = Terminal

local fsutils = require("fsutils")

function Terminal.new()
    return setmetatable({
        input = "",         -- Aktueller Eingabetext
        output = {},        -- Liste der Ausgaben
        commands = {},      -- Registrierte Befehle
        maxOutput = 100,    -- Maximale Zeilen im Terminal
        cursorBlink = true, -- Blinker für Cursor
        cursorTimer = 0     -- Timer für Cursor-Blinken
    }, Terminal)
end

function Terminal:registerCommand(name, callback)
    self.commands[name] = callback
end

function Terminal:handleInput()
    if #self.input > 0 then
        table.insert(self.output, connectionState .. "$" .. termcwd .. "> " .. self.input) -- Zeige eingegebenen Text
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
    if text:find("\n") then
        for line in text:gmatch("([^\n]*)\n?") do
            table.insert(self.output, line)
        end
    else
        table.insert(self.output, text)
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
    local screenHeight = love.graphics.getHeight()
    local maxLines = math.floor((screenHeight - termSepY) / (terminalFontSize + termSepLine)) - 1

    for i, line in ipairs(self.output) do
        -- love.graphics.print(text, x, y)
        if i > maxLines then
            table.remove(self.output, 1)
        end
        love.graphics.print({ termFontCol, line }, termSepX, termSepY + (i - 1) * (terminalFontSize + termSepLine))
    end

    local cursor = self.cursorBlink and "|" or ""
    love.graphics.print({ termFontCol, connectionState .. "$" .. termcwd .. "> " .. self.input .. cursor },
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
    elseif key == 'escape' then
        currentGamestate = 'room'
    else
        if #key == 1 then -- TODO: missing key down here for special characters like / or $
            self:textinput(key)
        end
    end
end

return Terminal
