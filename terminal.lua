local Terminal = {}
Terminal.__index = Terminal

local fsutils = require("fsutils")

function Terminal.new()
    return setmetatable({
        input = "",         -- Aktueller Eingabetext
        output = {},        -- Liste der Ausgaben
        commands = {},      -- Registrierte Befehle
        history = {},       -- History mit pfeiltasten
        historyindex = 1,   -- histroy index für history mit pfeiltasten
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
        if #self.history == 0 then
            table.insert(self.history, self.historyindex, self.input)
            self.historyindex = #self.history + 1
            -- print("// added " .. self.input .. " to history")
        elseif #self.history >= 1 and not string.match(self.input, "^%s*" .. self.history[#self.history] .. "%s*$") then
            table.insert(self.history, self.historyindex, self.input)
            self.historyindex = #self.history + 1
            -- print("// added " .. self.input .. " to history")
        end
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
    local maxWidth = love.graphics.getWidth() -- padding ig
    -- local maxWidth = 100 -- padding ig
    if chatEnabled then maxWidth = maxWidth / 2 end
    local font = love.graphics.getFont()

    local lineHeight = font:getHeight()
    local maxLines = screenHeight / lineHeight - 1

    local totalWrappedLines = {}
    for _, line in ipairs(self.output) do
        local _, wrappedLines = font:getWrap(line, maxWidth)
        for _, wrappedLine in ipairs(wrappedLines) do
            table.insert(totalWrappedLines, wrappedLine)
        end
    end

    local cursor = self.cursorBlink and "|" or ""
    local prompt = connectionState .. "$" .. termcwd .. "> " .. self.input .. cursor

    table.insert(totalWrappedLines, prompt)

    -- handle vertical overflow
    local overflow = #totalWrappedLines - maxLines
    if overflow > 0 then
        for i = 1, overflow do
            table.remove(totalWrappedLines, i)
        end
    end

    local totalString = table.concat(totalWrappedLines, "\n")
    love.graphics.print(totalString, 10, 10)
end

function Terminal:textinput(t)
    self.input = self.input .. t
end

function Terminal:keypressed(key)
    if chatEnabled and key == "right" and love.keyboard.isDown("lctrl") then
        chatFocused = true
    elseif key == 'up' and #self.history > 0 then
        -- print("// " .. key .. " - " .. #self.history .. " - " .. self.historyindex)
        if self.historyindex == #self.history + 1 then
            self.historyindex = self.historyindex - 1
            self.input = self.history[self.historyindex]
        elseif self.historyindex <= #self.history and self.historyindex > 1 then
            self.historyindex = self.historyindex - 1
            self.input = self.history[self.historyindex]
        elseif self.historyindex <= 1 then
            self.input = self.history[1]
            self.historyindex = 1
        end
    elseif key == 'down' and #self.history > 0 then
        -- print("// " .. key .. " - " .. #self.history .. " - " .. self.historyindex)
        if self.historyindex == #self.history + 1 then
            -- do nothing
        elseif self.historyindex == #self.history then
            self.historyindex = self.historyindex + 1
            self.input = ""
        elseif self.historyindex <= 1 then
            -- print(table.concat(self.history, '\t'))
            self.historyindex = 2
            self.input = self.history[self.historyindex]
        elseif self.historyindex < #self.history then
            self.historyindex = self.historyindex + 1
            self.input = self.history[self.historyindex]
        end
        self.historyindex = self.historyindex
    elseif key == 'backspace' then
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
        if #key == 1 then -- TODO: missing key down here for special characters like / or $
            self:textinput(key)
        end
    end
end

return Terminal
