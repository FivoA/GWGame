local terminalScene = {}

function terminalScene.draw()
    print("Called draw")
end

function terminalScene.update(dt)
    print("Called update with " .. dt)
end

function terminalScene.mousepressed(x, y, button, istouch)
    print("Called mousepressed with: " .. x " " .. y " " .. button .. " " .. istouch)
end


return terminalScene