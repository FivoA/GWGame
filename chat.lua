local dialog = require("dialog")
local chat = {}

local startX = love.graphics.getWidth() / 2

local currentNode = dialog.chad_intro
local selectedOption = dialog.chad_intro.options[1]

function chat.draw()
    if chatFocussed then
        love.graphics.print("im focussed bitch", startX + 10, 50)
    end
end

function chat.keypressed(key)
    if key == "left" and love.keyboard.isDown("lctrl") then
        chatFocussed = false
    end
end

return chat
