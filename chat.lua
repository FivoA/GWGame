local dialog = require("dialog")
local chat = {}
local history = { { node = "chad_intro", chosen = nil } }



local selectedOptionIndex = 1

function chat.draw()
    local startX = love.graphics.getWidth() / 2

    local lines = {}
    for _, entry in ipairs(history) do
        local node = dialog[entry.node]
        table.insert(lines, "Chad: " .. node.text)
        if entry.chosen ~= nil then
            table.insert(lines, "-> citizen#3857: " .. entry.chosen .. "\n")
        else
            if node.options ~= nil then
                for i, option in ipairs(node.options) do
                    local label
                    if i == selectedOptionIndex then
                        label = "[" .. i .. "] "
                    else
                        label = " " .. i .. "  "
                    end
                    table.insert(lines, label .. option.text)
                end
            end
        end
    end

    local totalWrappedLines = {}
    for _, line in ipairs(lines) do
        local _, wrappedLines = terminalFont:getWrap(line, startX - 16);
        for _, wrappedLine in ipairs(wrappedLines) do
            table.insert(totalWrappedLines, wrappedLine)
        end
    end

    local totalString = table.concat(totalWrappedLines, "\n")
    love.graphics.print(totalString, startX + 10, 10)
end

function chat.keypressed(key)
    if key == "left" and love.keyboard.isDown("lctrl") then
        chatFocused = false
    else
        local currentNode = dialog[history[#history].node]
        if currentNode.options == nil then
            return
        end
        local optionCount = #currentNode.options
        if key == "return" then
            local selectedOption = currentNode.options[selectedOptionIndex]
            history[#history].chosen = currentNode.options[selectedOptionIndex].text
            table.insert(history, { node = selectedOption.next, chosen = nil })
            selectedOptionIndex = 1;
        elseif key == "down" then
            if selectedOptionIndex < optionCount then
                selectedOptionIndex = selectedOptionIndex + 1
            end
        elseif key == "up" then
            if 1 < selectedOptionIndex then
                selectedOptionIndex = selectedOptionIndex - 1
            end
        elseif tonumber(key) ~= nil then
            local number = tonumber(key)
            if 1 <= number and number <= optionCount then
                local selectedOption = currentNode.options[number]
                history[#history].chosen = currentNode.options[selectedOptionIndex].text
                table.insert(history, { node = selectedOption.next, chosen = nil })
                selectedOptionIndex = 1;
            end
        end
    end
end

return chat
