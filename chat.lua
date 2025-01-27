local dialog = require("dialog")
local chat = {}
local history = { { node = "chad_intro", chosen = nil } }

local startX = love.graphics.getWidth() / 2

local selectedOptionIndex = 1

function chat.draw()
    local lines = {}
    for _, entry in ipairs(history) do
        local node = dialog[entry.node]
        table.insert(lines, "Chad: " .. node.text .. "\n")
        if entry.chosen ~= nil then
            table.insert(lines, "citizen#3857: " .. entry.chosen .. "\n")
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
    local currentNode = dialog[history[#history].node]
    local selectedOption = currentNode.options[selectedOptionIndex]
    if key == "left" and love.keyboard.isDown("lctrl") then
        chatFocussed = false
    elseif key == "return" then
        history[#history].chosen = currentNode.options[selectedOptionIndex].text
        table.insert(history, { node = selectedOption.next, chosen = nil })
    elseif key == "down" then
        local optionCount = #currentNode.options
        if selectedOptionIndex < optionCount then
            selectedOptionIndex = selectedOptionIndex + 1
        end
    elseif key == "up" then
        if 1 < selectedOptionIndex then
            selectedOptionIndex = selectedOptionIndex - 1
        end
    end
end

return chat
